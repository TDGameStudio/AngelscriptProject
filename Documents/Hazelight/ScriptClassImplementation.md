# 脚本 UClass 实现机制分析

> **分析日期**：2026-04-03
> **分析范围**：AngelPortV2 `UASClass` 机制 vs Hazelight UEAS2 引擎级 `UClass` 扩展
> **关联文档**：`UEAS2-UHT-Modifications-Analysis.md`、`ScriptStructImplementation.md`

---

## 目录

1. [问题域](#1-问题域)
2. [我们的实现方案：UASClass 子类化](#2-我们的实现方案uasclass-子类化)
   - 2.1 [核心类型：UASClass](#21-核心类型uasclass)
   - 2.2 [类的运行时创建](#22-类的运行时创建)
   - 2.3 [对象构造流程](#23-对象构造流程)
   - 2.4 [函数注册：UASFunction 体系](#24-函数注册uasfunction-体系)
   - 2.5 [GC 引用追踪](#25-gc-引用追踪)
   - 2.6 [网络复制](#26-网络复制)
   - 2.7 [热重载](#27-热重载)
3. [Hazelight 的实现方案：引擎内嵌](#3-hazelight-的实现方案引擎内嵌)
   - 3.1 [UClass 直接扩展字段](#31-uclass-直接扩展字段)
   - 3.2 [UFunction 虚方法注入](#32-ufunction-虚方法注入)
   - 3.3 [ScriptCore.cpp 执行路径分流](#33-scriptcorecpp-执行路径分流)
   - 3.4 [对象初始化与 CDO](#34-对象初始化与-cdo)
4. [对比分析](#4-对比分析)
   - 4.1 [架构差异总览](#41-架构差异总览)
   - 4.2 [各维度对比](#42-各维度对比)
5. [性能分析](#5-性能分析)
   - 5.1 [脚本函数被 C++/Blueprint 调用](#51-脚本函数被-cblueprint-调用)
   - 5.2 [对象构造](#52-对象构造)
   - 5.3 [GC 引用追踪](#53-gc-引用追踪)
   - 5.4 [热重载](#54-热重载)
   - 5.5 [性能差异汇总](#55-性能差异汇总)
6. [结论](#6-结论)

---

## 1. 问题域

在 Unreal Engine 中支持脚本定义的 UClass 需要解决以下核心问题：

| 问题 | 说明 |
|------|------|
| **类的运行时创建** | 从脚本声明生成一个合法的 `UClass`，能被 UE 反射系统识别 |
| **对象构造** | `NewObject<>()` 创建脚本类实例时，正确执行 C++ 父类构造 + 脚本构造 |
| **函数注册** | 脚本定义的方法表现为 `UFunction`，可被蓝图/C++ 调用 |
| **属性注册** | 脚本定义的属性表现为 `FProperty`，参与序列化、编辑器、GC |
| **GC 引用追踪** | 脚本持有的 UObject 引用必须被 GC 系统发现，否则会被提前回收 |
| **网络复制** | 脚本属性支持 `Replicated` 标记和 `GetLifetimeReplicatedProps` |
| **热重载** | 修改脚本后，运行中的实例平滑迁移到新类 |
| **CDO（Class Default Object）** | 脚本类需要正确的 CDO，承载默认值 |

UE 原生的蓝图（`UBlueprintGeneratedClass`）通过继承 `UClass` 来解决这些问题。Angelscript 作为第三方脚本系统，也需要一套完整的 UClass 集成方案。

---

## 2. 我们的实现方案：UASClass 子类化

### 2.1 核心类型：UASClass

我们的方案是 **继承 `UClass` 创建 `UASClass` 子类**，在其中存储脚本相关的所有状态：

```cpp
UCLASS()
class UASClass : public UClass
{
    GENERATED_BODY()
public:
    UClass* CodeSuperClass = nullptr;        // C++ 父类（跳过脚本继承链的最近原生父类）
    UASClass* NewerVersion = nullptr;        // 热重载：指向替换后的新版本类
    bool bHasASClassParent = false;          // 是否有 AS 脚本父类
    bool bCanEverTick = true;                // Tick 控制
    bool bStartWithTickEnabled = true;
    int32 ContainerSize = 0;                 // AS 脚本对象大小
    int32 ScriptPropertyOffset = 0;          // 脚本属性在 UObject 内存中的起始偏移
    asIScriptFunction* ConstructFunction;    // AS 构造函数
    asIScriptFunction* DefaultsFunction;     // AS default 语句函数
    UClass* ComposeOntoClass = nullptr;      // Mixin 目标
    void* ScriptTypePtr = nullptr;           // asITypeInfo* 指向 AS 类型信息
    bool bIsScriptClass = false;             // 脚本类标记

    UE::GC::FSchemaOwner ReferenceSchema;    // 自定义 GC 引用 schema

    TArray<FDefaultComponent> DefaultComponents;    // 默认组件声明
    TArray<FOverrideComponent> OverrideComponents;  // 覆盖组件声明

    // 静态构造器（按对象类型分派）
    static void StaticActorConstructor(const FObjectInitializer& Initializer);
    static void StaticComponentConstructor(const FObjectInitializer& Initializer);
    static void StaticObjectConstructor(const FObjectInitializer& Initializer);

    // 运行时虚方法
    virtual UClass* GetMostUpToDateClass();
    virtual void RuntimeDestroyObject(UObject* Object);
    virtual bool IsFunctionImplementedInScript(FName InFunctionName) const;
    virtual void GetLifetimeScriptReplicationList(TArray<FLifetimeProperty>& OutLifetimeProps) const;
    virtual int32 GetContainerSize() const { return ContainerSize; }
};
```

**设计要点**：
- `CodeSuperClass` 记录最近的 C++ 原生父类，构造时链式调用 `CodeSuperClass->ClassConstructor`
- `ScriptTypePtr` 是 AngelScript 类型系统与 UE 反射系统之间的桥梁
- `ReferenceSchema` 持有自定义的 GC 遍历 schema，追踪脚本属性中的 UObject 引用
- 不同对象类型（Actor/Component/Object）使用不同的静态构造器，处理各自的特殊逻辑

### 2.2 类的运行时创建

类创建发生在 `FAngelscriptClassGenerator::CreateFullReloadClass` 和 `DoFullReloadClass` 中：

```
脚本编译完成
    ↓
CreateFullReloadClass()
    ↓ NewObject<UASClass>(Package, UASClass::StaticClass(), ClassName)
创建 UASClass 实例
    ↓
DoFullReloadClass() / FinalizeClass()
    ↓
设置 ClassFlags = CLASS_CompiledFromBlueprint
设置 bIsScriptClass = true
设置 SuperStruct (支持 AS→AS 继承链)
    ↓
AddClassProperties() → 为每个脚本属性创建 FProperty
AddClassFunctions() → 为每个脚本方法创建 UASFunction
    ↓
StaticLink() + AssembleReferenceTokenStream()
    ↓
设置 ClassConstructor 指针（根据父类类型选择）
    ↓
GetDefaultObject(true) → 创建 CDO
```

关键步骤：

1. **类对象分配**：使用 `NewObject<UASClass>` 在 Angelscript 包内创建，设置 `RF_Public | RF_Standalone | RF_MarkAsRootSet`
2. **ClassFlags 设置**：使用 `CLASS_CompiledFromBlueprint`，让 UE 将脚本类视为"蓝图编译类"
3. **继承链构建**：支持 AS→AS→C++ 多级继承，通过 `SetSuperStruct` 连接
4. **构造器选择**：根据最终父类类型（Actor / Component / Object），分派到对应的静态构造器

### 2.3 对象构造流程

以 Actor 为例，`StaticActorConstructor` 的执行流程：

```
NewObject<AMyScriptActor>() 触发
    ↓
UASClass::StaticActorConstructor(Initializer)
    ↓
1. ApplyOverrideComponents()     — 处理组件覆盖声明
2. CodeSuperClass->ClassConstructor(Initializer)  — 调用 C++ 父类构造
3. PrimaryActorTick 设置（bCanEverTick / bStartWithTickEnabled）
4. new(Object) asCScriptObject(ScriptType)  — 在 UObject 内存上构造 AS 脚本对象
5. CreateDefaultComponents()     — 创建声明的默认组件
6. ExecuteConstructFunction()    — 执行 AS 构造函数
7. ExecuteDefaultsFunctions()    — 执行 AS default 语句（按继承链从基到派生）
```

**关键机制**：
- **双层构造**：先执行 C++ 父类构造（通过 `CodeSuperClass->ClassConstructor`），再执行脚本构造
- **Placement new**：`new(Object) asCScriptObject(ScriptType)` 在已分配的 UObject 内存上就地构造 AS 脚本对象，脚本属性存储在 `ScriptPropertyOffset` 之后的内存区域
- **default 链**：`ExecuteDefaultsFunctions` 按继承链从最基类到最派生类依次调用，确保父类默认值先于子类设置
- **脚本分配检测**：通过 `bIsScriptAllocation` 判断是否由 AS 侧发起（如 `Cast<>` 或 `NewObject` from script），避免重复构造

### 2.4 函数注册：UASFunction 体系

脚本方法通过 `UASFunction` 子类注册为 UE 反射系统中的 `UFunction`：

```cpp
UCLASS()
class UASFunction : public UFunction
{
    asIScriptFunction* ScriptFunction;     // 对应的 AS 脚本函数
    UFunction* ValidateFunction;            // RPC 验证函数缓存
    TArray<FArgument> Arguments;            // 参数描述（含类型和 VM 行为）
    FArgument ReturnArgument;               // 返回值描述
    asJITFunction JitFunction;              // JIT 函数指针（如有）

    virtual void RuntimeCallFunction(UObject*, FFrame&, RESULT_DECL);
    virtual void RuntimeCallEvent(UObject*, void* Parms);
    virtual UFunction* GetRuntimeValidateFunction();
};
```

**特化子类体系**（按参数/返回值模式优化）：

| 子类 | 优化场景 |
|------|---------|
| `UASFunction_NoParams` | 无参无返回值 |
| `UASFunction_DWordArg` | 单个 4 字节参数 |
| `UASFunction_QWordArg` | 单个 8 字节参数 |
| `UASFunction_FloatArg` | 单个 float 参数 |
| `UASFunction_DoubleArg` | 单个 double 参数 |
| `UASFunction_ByteArg` | 单个 byte 参数 |
| `UASFunction_ReferenceArg` | 单个引用参数 |
| `UASFunction_ObjectReturn` | 返回对象指针 |
| `UASFunction_DWordReturn` / `FloatReturn` / `DoubleReturn` / `ByteReturn` | 各类型返回值 |
| `UASFunction_JIT` | 通用 JIT 路径 |
| 各类型 `_JIT` 变体 | 上述各类型的 JIT 优化版本 |

**调用路径**：

```
C++ / Blueprint 调用脚本函数
    ↓
UFunction 标记 FUNC_Native，NativeFunc = UASFunctionNativeThunk
    ↓
UASFunctionNativeThunk(Object, Stack, RESULT_PARAM)
    ↓
Cast<UASFunction>(Stack.Node) → Function
    ↓
Function->RuntimeCallFunction(Object, Stack, RESULT_PARAM)
    ↓（虚分派到具体子类）
AngelscriptCallFromBPVM<ThreadSafe, NonVirtual>(...)
    ↓
[有 JIT] → 直接调用 JIT 函数，参数通过 VMArgs 数组传递
[无 JIT] → 准备 AS 上下文，Prepare/SetArg/Execute
```

**关键设计**：
- 所有 `UASFunction` 都标记为 `FUNC_Native` 并设置 `NativeFunc = &UASFunctionNativeThunk`
- 通过 `FUNC_Native` 标志，UE 的 `ProcessEvent` 走原生函数快速路径，跳过蓝图字节码解释器
- `UASFunctionNativeThunk` 是一个轻量的跳板（cast + 虚调用），开销极小
- JIT 路径直接构建 `asDWORD* VMArgs` 数组并调用 JIT 函数，避免 AS 上下文创建

### 2.5 GC 引用追踪

脚本类的 GC 引用追踪通过 `DetectAngelscriptReferences` 实现：

```
FAngelscriptClassGenerator::DetectAngelscriptReferences(ClassDesc)
    ↓
遍历 AS 脚本类型的所有属性（ScriptType->GetPropertyCount()）
    ↓
对于非原始类型、非继承属性：
    检查是否已注册为 FProperty（bHasUnrealProperty）
    ↓
如果是未注册为 FProperty 的脚本属性且持有 UObject 引用：
    Type.EmitReferenceInfo() → 向 GC Schema 添加引用信息
    ↓
Schema.Build(GetARO(Class)) → 构建 GC 引用 schema
Class->ReferenceSchema.Set(View)  → 设置到 UASClass 上
```

**两层追踪**：
1. **FProperty 层**：已注册为 FProperty 的脚本属性，通过 UE 原生的 `AssembleReferenceTokenStream` 自动追踪
2. **ReferenceSchema 层**：纯脚本属性（未暴露为 FProperty 但持有 UObject 引用）通过 `ReferenceSchema` 追踪

### 2.6 网络复制

脚本属性的网络复制通过 `GetLifetimeScriptReplicationList` 实现：

```cpp
void UASClass::GetLifetimeScriptReplicationList(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    for (TFieldIterator<FProperty> It(this, EFieldIteratorFlags::ExcludeSuper); It; ++It)
    {
        FProperty* Prop = *It;
        if (Prop && Prop->GetPropertyFlags() & CPF_Net)
            OutLifetimeProps.AddUnique(FLifetimeProperty(Prop->RepIndex, Prop->GetBlueprintReplicationCondition()));
    }
    // 递归处理父 AS 类
    UASClass* SuperScriptClass = Cast<UASClass>(GetSuperStruct());
    if (SuperScriptClass)
        SuperScriptClass->GetLifetimeScriptReplicationList(OutLifetimeProps);
}
```

脚本属性在声明时标记 `Replicated` 后，会设置 `CPF_Net` flag 和 `RepIndex`，与蓝图属性的复制机制一致。

### 2.7 热重载

热重载是 UASClass 体系中最复杂的部分：

```
脚本修改 → 重新编译
    ↓
CreateFullReloadClass() → 创建新 UASClass（替换旧的同名类）
    ↓
旧类重命名为 ClassName_REPLACED_N，设置 CLASS_NewerVersionExists
旧类.NewerVersion = 新类
    ↓
DoFullReloadClass() → 填充新类的属性、函数、元数据
    ↓
属性迁移：
    遍历旧实例的脚本属性
    匹配名称和类型相同的属性
    执行属性值复制
    ↓
CDO 重建 + 实例重建
    ↓
GarbageCollection → 回收旧类和旧实例
```

**GetMostUpToDateClass()** 用于在热重载链中追踪到最新版本：

```cpp
UClass* UASClass::GetMostUpToDateClass()
{
    if (NewerVersion == nullptr)
        return this;
    UASClass* NewerClass = NewerVersion;
    while (NewerClass->NewerVersion != nullptr)
        NewerClass = NewerClass->NewerVersion;
    return NewerClass;
}
```

---

## 3. Hazelight 的实现方案：引擎内嵌

### 3.1 UClass 直接扩展字段

Hazelight 直接在引擎的 `UClass`（`Class.h`）中添加字段：

```cpp
// AS FIX(LV): Runtime generated classes (angelscript)
TMap<FName, ASAutoCaller::FReflectedFunctionPointers> ASReflectedFunctionPointers;
void* ScriptTypePtr = nullptr;
bool bIsScriptClass = false;
const TMap<FName, TObjectPtr<UFunction>>& GetFunctionMap() { return FuncMap; }
// END AS FIX
```

| 字段 | 作用 |
|------|------|
| `ASReflectedFunctionPointers` | 每个原生函数的类型擦除方法指针，用于脚本→C++ 直接调用 |
| `ScriptTypePtr` | 指向 AS 类型信息 |
| `bIsScriptClass` | 标记是否为脚本生成的类 |
| `GetFunctionMap()` | 暴露私有 `FuncMap` 给外部访问 |

**关键区别**：这些字段存在于**所有** `UClass` 实例上，包括与 Angelscript 无关的原生类。

### 3.2 UFunction 虚方法注入

Hazelight 在引擎的 `UFunction` 基类（`Class.h`）中添加虚方法：

```cpp
// AS FIX (LV): Allow calling runtime generated functions directly through UFunction
virtual void RuntimeCallFunction(UObject* Object, FFrame& Stack, RESULT_DECL) { ensureAlways(false); }
virtual void RuntimeCallEvent(UObject* Object, void* Parms) { ensureAlways(false); }
virtual UFunction* GetRuntimeValidateFunction() { ensureAlways(false); return nullptr; }
// END AS FIX
```

这让 Angelscript 的 UFunction 子类可以覆盖这些方法，但代价是所有 `UFunction` 的 vtable 都增大了。

### 3.3 ScriptCore.cpp 执行路径分流

Hazelight 添加了 `FUNC_RuntimeGenerated`（0x10）到 `EFunctionFlags`，并在 `ScriptCore.cpp` 中修改了 6 处执行路径：

```cpp
// 原始：if (Function->FunctionFlags & FUNC_Native)
// HAZE FIX：
if (Function->FunctionFlags & (FUNC_Native | FUNC_RuntimeGenerated))
    ↓
if (Function->FunctionFlags & FUNC_Native)
    Function->Invoke(this, Stack, RESULT_PARAM);     // 原生路径
else // FUNC_RuntimeGenerated
    Function->RuntimeCallFunction(this, Stack, RESULT_PARAM);  // 脚本路径
```

以及 RPC 路径的完整脚本处理（~70 行）。

### 3.4 对象初始化与 CDO

Hazelight 修改了 `UObjectGlobals.cpp` 中的 4 处对象初始化逻辑：

| 修改 | 内容 |
|------|------|
| `bNeedInitialize` | 脚本类跳过 UE 默认属性初始化 |
| `bIsScriptCDO` | 脚本类 CDO 使用 PostConstructLink |
| `bSkipInitCustom` | 脚本类实例从 CDO 复制时不重复初始化 |
| `bIsNativeClass` | 脚本子对象被视为原生以避免重建 |

以及 `Class.cpp` 中 CDO 的属性初始化跳过。

---

## 4. 对比分析

### 4.1 架构差异总览

| 维度 | 我们的方案（UASClass） | Hazelight（引擎内嵌） |
|------|----------------------|---------------------|
| **实现方式** | UClass 子类化 + 插件内闭合 | 修改引擎 UClass/UFunction/ScriptCore |
| **引擎侵入性** | **零** — 不修改任何引擎代码 | **重度** — 修改 22 个 C++ 文件 + 11 个 C# 文件 |
| **ABI 兼容性** | 完全兼容 vanilla UE5 | 破坏 ABI，所有 .gen.cpp 必须重新生成 |
| **升级成本** | UE 大版本升级无影响 | 每次 UE 升级需要重新合并引擎修改 |
| **数据存储** | 脚本数据在 UASClass 子类字段中 | 脚本数据直接在 UClass 基类字段中 |
| **函数调用入口** | FUNC_Native + NativeFunc thunk | FUNC_RuntimeGenerated + ScriptCore 分流 |
| **对象初始化** | ClassConstructor 函数指针替换 | 修改 UObjectGlobals.cpp 初始化流程 |
| **可移植性** | 可发布为独立插件 | 必须随引擎分发 |

### 4.2 各维度对比

#### 4.2.1 类的运行时创建

| | 我们 | Hazelight |
|---|------|-----------|
| **类对象** | `NewObject<UASClass>` | 同样是 UClass 子类的 NewObject |
| **ClassFlags** | `CLASS_CompiledFromBlueprint` | 同 |
| **脚本标记** | `UASClass::bIsScriptClass = true` | `UClass::bIsScriptClass = true` |
| **类型信息** | `UASClass::ScriptTypePtr` | `UClass::ScriptTypePtr` |
| **区别** | 脚本数据在子类中 | 脚本数据在基类中，所有 UClass 都有 |

两者在类创建流程上几乎相同，差异在于数据存放位置。

#### 4.2.2 函数调用路径

| | 我们 | Hazelight |
|---|------|-----------|
| **UFunction 标志** | `FUNC_Native` | `FUNC_RuntimeGenerated` (0x10) |
| **入口** | `NativeFunc = UASFunctionNativeThunk` | ScriptCore.cpp `RuntimeCallFunction` 分支 |
| **调用链** | ProcessEvent → Invoke → UASFunctionNativeThunk → Cast → RuntimeCallFunction | ProcessEvent → `FUNC_RuntimeGenerated` 分支 → RuntimeCallFunction |
| **Cast 开销** | 有 `Cast<UASFunction>` | 无（直接在 UFunction 上调用虚方法） |

**我们的路径详解**：

```
ProcessEvent(Function, Parms)
    ↓ Function 标记为 FUNC_Native
CallFunction(Stack, RESULT_PARAM, Function)
    ↓ FUNC_Native 快速路径（跳过字节码解释器）
Function->Invoke(Object, Stack, RESULT_PARAM)
    ↓ 间接调用 NativeFunc 函数指针
UASFunctionNativeThunk(Object, Stack, RESULT_PARAM)
    ↓ Cast<UASFunction>(Stack.Node) → 虚调用
UASFunction::RuntimeCallFunction(Object, Stack, RESULT_PARAM)
    ↓ 特化子类的优化实现
AngelscriptCallFromBPVM → AS VM / JIT
```

**Hazelight 的路径详解**：

```
ProcessEvent(Function, Parms)
    ↓ Function 标记为 FUNC_RuntimeGenerated
CallFunction(Stack, RESULT_PARAM, Function)
    ↓ (FUNC_Native | FUNC_RuntimeGenerated) 快速路径
    ↓ 不是 FUNC_Native → RuntimeCallFunction 分支
Function->RuntimeCallFunction(Object, Stack, RESULT_PARAM)
    ↓ UFunction 虚方法调用
AS UFunction 子类的实现
    ↓
AS VM / JIT
```

#### 4.2.3 对象构造

| | 我们 | Hazelight |
|---|------|-----------|
| **构造入口** | `ClassConstructor` 函数指针替换 | 同 |
| **C++ 父类构造** | `CodeSuperClass->ClassConstructor(Initializer)` | 类似 |
| **脚本对象构造** | `new(Object) asCScriptObject(ScriptType)` | 类似 |
| **CDO 初始化** | 通过 ClassConstructor 正常流程 | 引擎侧修改跳过属性初始化 |
| **对象初始化跳过** | 不需要（ClassConstructor 覆盖处理一切） | 修改 UObjectGlobals.cpp 的 4 处初始化逻辑 |

我们使用 `ClassConstructor` 函数指针替换这一 UE 公开 API，完全避免了 Hazelight 需要修改 `UObjectGlobals.cpp` 的问题。

#### 4.2.4 GC 引用追踪

| | 我们 | Hazelight |
|---|------|-----------|
| **FProperty 追踪** | `AssembleReferenceTokenStream` | 同 |
| **脚本属性追踪** | `ReferenceSchema` + `DetectAngelscriptReferences` | 引擎侧 `GarbageCollectionSchema.cpp` 修改 |
| **自定义引用** | `UE::GC::FSchemaOwner ReferenceSchema` | 直接修改 GC schema 构建流程 |

两者最终效果相同，但我们完全在插件内完成，不需要修改引擎的 GC 代码。

---

## 5. 性能分析

### 5.1 脚本函数被 C++/Blueprint 调用

这是最关键的性能路径。对比两种方案：

**我们的方案**：
```
ProcessEvent → CallFunction (FUNC_Native 快速路径)
    → Invoke → NativeFunc 函数指针间接调用
    → UASFunctionNativeThunk
    → Cast<UASFunction>  ← 额外开销 1: RTTI cast
    → 虚调用 RuntimeCallFunction  ← 实际上这里虚分派到特化子类
    → AS VM / JIT
```

**Hazelight 的方案**：
```
ProcessEvent → CallFunction (FUNC_Native|FUNC_RuntimeGenerated 快速路径)
    → 条件判断 FUNC_Native vs RuntimeGenerated  ← 额外开销 1: 分支
    → UFunction::RuntimeCallFunction 虚调用
    → AS VM / JIT
```

**差异分析**：

| 开销项 | 我们 | Hazelight | 差异 |
|--------|------|-----------|------|
| ProcessEvent 前置处理 | 相同 | 相同 | — |
| 快速路径判断 | `FUNC_Native` 一次检查 | `FUNC_Native \| FUNC_RuntimeGenerated` 一次检查 + 二次区分 | 我们略快 |
| 进入 RuntimeCallFunction | 函数指针间接调用 + Cast + 虚调用 | 虚调用 | 我们多一次 Cast |
| Cast 成本 | `Cast<UASFunction>` ≈ 1 次虚表指针比较 | — | ~2-3ns |
| 虚分派 | 特化子类（UASFunction_NoParams 等） | 通用虚方法 | 我们通过特化减少函数体内分支 |
| 实际脚本执行 | 相同（同一个 AS VM / JIT） | 相同 | — |

**结论**：我们多了一次 `Cast<UASFunction>` 和一次 `NativeFunc` 间接调用，合计 ~3-5ns。但我们通过 **17 个特化 UASFunction 子类** 减少了 `RuntimeCallFunction` 函数体内的参数分支判断，实际可能持平甚至更优。

### 5.2 对象构造

| 开销项 | 我们 | Hazelight |
|--------|------|-----------|
| C++ 构造调用 | `CodeSuperClass->ClassConstructor(Initializer)` | 类似 |
| CDO 初始化跳过 | 通过 ClassConstructor 函数指针覆盖自然处理 | 引擎侧 `bIsScriptClass` 检查跳过 |
| 性能差异 | — | — |

**结论**：对象构造性能相同。两者都是先调用 C++ 父类构造，再执行脚本构造。

### 5.3 GC 引用追踪

| 开销项 | 我们 | Hazelight |
|--------|------|-----------|
| FProperty 追踪 | UE 原生 token stream | 相同 |
| 脚本属性追踪 | ReferenceSchema 查找 | 引擎 GC schema 直接包含 |
| 差异 | 通过 Schema 间接一层 | 在 UClass 上直接访问 |

**结论**：GC 追踪性能几乎无差异。`ReferenceSchema` 在类创建时一次性构建，运行时访问路径与 Hazelight 相同。

### 5.4 热重载

两者的热重载机制几乎相同：旧类→新类替换、实例属性迁移、CDO 重建。性能无显著差异。

### 5.5 性能差异汇总

| 场景 | 差异 | 影响 |
|------|------|------|
| **脚本函数被调用** | 多 1 次 Cast + 1 次间接调用 (~3-5ns) | **可忽略**，被 17 种特化子类的分支优化抵消 |
| **对象构造** | 无差异 | **无损失** |
| **GC 追踪** | 无差异 | **无损失** |
| **热重载** | 无差异 | **无损失** |
| **内存** | UASClass 比 UClass 略大（额外字段仅在脚本类上） | **更优**（Hazelight 所有 UClass 都增大） |
| **RPC 调用** | 我们仍创建 FFrame 栈 | Hazelight 跳过 FFrame 创建 | **纳秒级**差异 |

---

## 6. 结论

### 架构优势

我们的 `UASClass` 子类化方案是一个 **优雅且实用** 的设计：

1. **零引擎修改**：完全在插件内闭合，不修改 UClass、UFunction、ScriptCore 或 UObjectGlobals 的任何一行代码
2. **利用 UE 公开 API**：
   - `UClass` 子类化是 UE 明确支持的模式（`UBlueprintGeneratedClass` 就是这么做的）
   - `ClassConstructor` 函数指针替换是 UE 公开的构造控制机制
   - `FUNC_Native` + `SetNativeFunc` 是 UE 支持的原生函数注册方式
   - `AssembleReferenceTokenStream` + `ReferenceSchema` 是 UE 提供的 GC 集成接口
3. **更优的内存效率**：脚本相关数据只存在于 `UASClass` 实例上，不污染普通 UClass
4. **更好的可维护性**：UE 引擎升级时不需要合并任何修改

### 性能结论

**与 Hazelight 的引擎级方案相比，几乎无性能损失**：

- 函数调用路径多一次 Cast（~3-5ns），但通过 UASFunction 特化子类抵消
- 对象构造、GC 追踪、热重载完全等价
- 唯一可测量的差异在 RPC 路径上（纳秒级 FFrame 创建），对实际游戏无影响

### 后续专项计划

`UASClass` 子类化方案下，`Cast<UASClass>(Class)`、父类链上的 AS-backed 查询、以及 `ScriptTypePtr` live 检查不能混用。后续语义梳理与加速研究由 `Documents/Plans/Plan_ASClassLookupSemanticsAndAcceleration.md` 承接，重点评估 helper 命名、父链查询缓存、UObject annotation / side table，以及 reload/discard 场景下的缓存失效策略。

### 与 UBlueprintGeneratedClass 的对比

我们的方案与 UE 原生的 `UBlueprintGeneratedClass` 模式高度一致：

| 特性 | UBlueprintGeneratedClass | UASClass |
|------|-------------------------|----------|
| 继承 UClass | ✓ | ✓ |
| CLASS_CompiledFromBlueprint | ✓ | ✓ |
| ClassConstructor 替换 | ✓ | ✓ |
| 自定义 UFunction 子类 | UBlueprintGeneratedBPFunction (虚拟机执行) | UASFunction (17 种特化) |
| 属性注册为 FProperty | ✓ | ✓ |
| GC 引用追踪 | ReferenceTokenStream | ReferenceTokenStream + ReferenceSchema |
| 热重载 | 蓝图重编译 | 脚本重编译 |

这说明我们的方案不是 workaround，而是**与 UE 原生蓝图相同的设计模式**。Hazelight 选择修改引擎是因为他们有引擎分支的维护能力；作为独立插件，UASClass 子类化是最正确的架构选择。
