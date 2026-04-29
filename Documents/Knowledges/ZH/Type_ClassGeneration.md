# Type_ClassGeneration — 脚本类生成机制

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: 架构与实现原理（非用户使用指南）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h` (245 行)
> · `ClassGenerator/AngelscriptClassGenerator.cpp` (~5932 行，核心实现)
> · `ClassGenerator/ASClass.h` (555 行，`UASClass` / `UASFunction` 及 17+ 子类)
> · `ClassGenerator/ASClass.cpp` (~97 KB，运行时构造器 + 组件创建)
> · `ClassGenerator/ASStruct.h` / `ASStruct.cpp` (`UASStruct` 脚本结构体)
> · `ClassGenerator/AngelscriptAdditionalCompileChecks.h` (扩展检查接口)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览
> · `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — `FProperty` 创建链路（`AddClassProperties` 共用）
> · `Documents/Knowledges/ZH/Syntax_DefaultComponent.md` — DefaultComponent / Attach 组件声明（`FinalizeActorClass` 消费）
> · `Documents/Knowledges/ZH/RT_HotReload.md` — 热重载链路（Soft/Full Reload 策略的调用者）

---

## 概览

ClassGenerator 子系统是当前 Angelscript 插件的**核心运行时类型桥接层**——它把 AS 编译器产出的脚本类型（类、结构体、枚举、委托）转换为**完整的 UE 反射对象**（`UASClass` / `UASStruct` / `UEnum` / `UDelegateFunction`），使其对蓝图、编辑器、序列化、GC、网络复制**完全透明**。

```text
============================================================================
  类生成全景：从 .as 源码到活的 UClass
============================================================================

[Phase 1: 编译]
  .as 源码 -> 预处理器 -> AS 编译器 -> 字节码模块 (asIScriptModule)
      |
      | 编译结束后, 预处理器/ClassGenerator 合作构造 FAngelscriptModuleDesc
      | 其中包含: TArray<FAngelscriptClassDesc> Classes
      |           TArray<FAngelscriptEnumDesc> Enums
      |           TArray<FAngelscriptDelegateDesc> Delegates
      v

[Phase 2: AddModule]
  FAngelscriptClassGenerator::AddModule(ModuleDesc)
      -> FModuleData { NewModule, OldModule, ModuleIndex }
      -> 建立 ModuleIndexByName / ModuleIndexByNewScriptModule 查找表
      |
      v

[Phase 3: Setup]  (分析 + 确定重载级别)
  FAngelscriptClassGenerator::Setup()  -> 返回 EReloadRequirement
      |
      ├─ SetupModule()            为每个模块创建 FClassData/FEnumData/FDelegateData
      │    └─ 匹配新旧类/委托, 注册 DataRefByName/DataRefByNewScriptType
      ├─ Analyze(Module)          分析每个模块
      │    ├─ Analyze(Module, DelegateData)   委托冲突检测
      │    ├─ Analyze(Module, ClassData)      类: 属性/函数遍历 + 比较新旧版本
      │    ├─ InitEnums() + AnalyzeEnums()    枚举
      │    └─ 检测被移除的类 -> FullReloadRequired
      └─ PropagateReloadRequirements()   沿依赖链传播重载需求
           -> 确定最终 SoftReload / FullReloadSuggested / FullReloadRequired / Error
      |
      v

[Phase 4: PerformReload]  (执行重载, 10 步流程)
  PerformFullReload() 或 PerformSoftReload()  -> 都调 PerformReload(bFullReload)
      |
      ├─ Step 1: 创建/链接类/结构体/委托
      │    CreateFullReloadClass / CreateFullReloadStruct / CreateFullReloadDelegate
      │    LinkSoftReloadClasses
      ├─ Step 2: 重载枚举
      ├─ Step 3: 重载结构体 (先于类)
      │    DoFullReloadStruct -> AddClassProperties -> CreateProperty 递归
      ├─ Step 4: 重载委托
      ├─ Step 5: 准备软重载 (PrepareSoftReload)
      ├─ Step 6: 重载类 (非结构体)
      │    DoFullReloadClass -> 设 ClassFlags/SuperStruct/PropertyLink
      │                      -> AddClassProperties -> FProperty 创建
      │                      -> 创建 UASFunction (17+ 子类按签名特化)
      │                      -> DetectAngelscriptReferences (GC Schema)
      │                      -> 迁移已有对象实例
      ├─ Step 7: 执行软重载 (DoSoftReload)
      ├─ Step 8: 最终化所有类 — FinalizeClass
      │    ├─ SetUpRuntimeReplicationData (网络复制)
      │    ├─ 解析 ComposeOntoClass
      │    ├─ 添加 ImplementedInterfaces
      │    ├─ FinalizeActorClass -> 设 StaticActorConstructor + DefaultComponents
      │    ├─ FinalizeComponentClass -> 设 StaticComponentConstructor
      │    └─ FinalizeObjectClass -> 设 StaticObjectConstructor
      ├─ Step 9: 初始化默认对象 (CallPostInitFunctions + InitDefaultObjects)
      └─ Step 10: 广播重载委托
           OnClassReload / OnStructReload / OnDelegateReload / OnPostReload / OnFullReload
      |
      v

[Phase 5: 运行时实例化]  (SpawnActor / NewObject)
  UE 调用 UASClass::ClassConstructor -> 分派到:
    StaticActorConstructor    (Actor 类)
    StaticComponentConstructor (组件类)
    StaticObjectConstructor    (普通 UObject)
      -> ApplyOverrideComponents (仅 Actor)
      -> CodeSuperClass->ClassConstructor() (调 C++ 父类)
      -> new asCScriptObject(ScriptType) (构造脚本对象内存)
      -> CreateDefaultComponents (仅 Actor, 递归从父到子)
      -> ExecuteConstructFunction (调 AS 构造函数)
```

---

## 一、核心类型层次

### 1.1 文件清单

| 文件 | 大小 | 用途 |
|------|------|------|
| `AngelscriptClassGenerator.h` | 9.5 KB | 定义 `FAngelscriptClassGenerator` 结构体 + 8 个重载委托 |
| `AngelscriptClassGenerator.cpp` | 203 KB | 类生成器全部实现（~5932 行） |
| `ASClass.h` | 16 KB | 定义 `UASClass`、`UASFunction` 及 17+ 特化子类 |
| `ASClass.cpp` | 97 KB | `UASClass` 运行时构造器 + `CreateDefaultComponents` |
| `ASStruct.h` / `.cpp` | 1 KB / 7 KB | `UASStruct`：脚本结构体，支持热重载版本链 + 自定义 `CppStructOps` |
| `AngelscriptAdditionalCompileChecks.h` | 480 B | 可继承的编译附加检查接口 |

### 1.2 `UASClass`（继承自 `UClass`）

`UASClass` 是所有 Angelscript 脚本类在 UE 类型系统中的代表。关键字段：

```cpp
UCLASS()
class ANGELSCRIPTRUNTIME_API UASClass : public UClass
{
    UClass* CodeSuperClass;                  // C++ 侧的父类（不含 AS 继承层）
    UASClass* NewerVersion;                  // 热重载版本链
    bool bHasASClassParent;                  // 父类是否也是 AS 类
    bool bCanEverTick, bStartWithTickEnabled; // Tick 设置
    int32 ContainerSize, ScriptPropertyOffset;
    asIScriptFunction* ConstructFunction;    // 脚本构造函数指针
    asIScriptFunction* DefaultsFunction;     // 脚本默认值函数指针
    UClass* ComposeOntoClass;                // Composable 类支持
    void* ScriptTypePtr;                     // asCObjectType 指针
    TArray<FDefaultComponent> DefaultComponents;    // 默认组件列表
    TArray<FOverrideComponent> OverrideComponents;  // 覆盖组件列表

    // 三种静态构造器 — 根据类类型分派
    static void StaticActorConstructor(const FObjectInitializer&);
    static void StaticComponentConstructor(const FObjectInitializer&);
    static void StaticObjectConstructor(const FObjectInitializer&);
};
```

关键洞察：

- **`CodeSuperClass` vs `GetSuperClass()`**: `GetSuperClass()` 返回完整继承链（含 AS 父类）；`CodeSuperClass` 跳过所有 AS 中间层，直接指向最近的 C++ 原生类——用于在构造器中调 `CodeSuperClass->ClassConstructor(Initializer)` 避免递归。
- **`NewerVersion` 链**: 热重载时旧 `UASClass` 不立即销毁，而是挂到新版本的 `NewerVersion` 链上，让仍引用旧类的 CDO/实例能通过 `GetMostUpToDateClass()` 找到最新版本。
- **`FDefaultComponent`**: 存储 `DefaultComponent` 标记的属性元数据（`ComponentClass` / `ComponentName` / `VariableOffset` / `bIsRoot` / `Attach` / `AttachSocket`），在 `StaticActorConstructor` 阶段消费。

### 1.3 `UASFunction`（继承自 `UFunction`）与 17+ 特化子类

`UASFunction` 是脚本函数在 UE 函数系统中的代表。核心：

```cpp
UCLASS()
class ANGELSCRIPTRUNTIME_API UASFunction : public UFunction
{
    asIScriptFunction* ScriptFunction;       // AS 字节码函数
    int32 GeneratedSourceLineNumber;
    UFunction* ValidateFunction;             // RPC _Validate 函数
    TArray<FArgument> Arguments;             // 参数描述列表
    FArgument ReturnArgument;                // 返回值描述
    asJITFunction JitFunction;               // JIT 入口（可选）

    static UASFunction* AllocateFunctionFor(UClass*, FName, TSharedPtr<FAngelscriptFunctionDesc>);
};
```

**17+ 特化子类的设计动机**: 每个特化针对不同的参数/返回签名优化 `RuntimeCallFunction` 的虚分派：

| 特化 | 优化场景 |
|------|---------|
| `UASFunction_NoParams` | 无参函数，跳过参数压栈 |
| `UASFunction_DWordArg` | 单 int32 参数，直接寄存器传递 |
| `UASFunction_FloatArg` | 单 float 参数 |
| `UASFunction_ReferenceArg` | 单引用参数 |
| `UASFunction_ObjectReturn` | 返回 UObject*，专用对象指针处理 |
| `UASFunction_*_JIT` | 以上各版本的 JIT 优化变体 |
| `UASFunction_NotThreadSafe` | 需线程安全检查的版本 |

`AllocateFunctionFor` 根据 `FAngelscriptFunctionDesc` 的参数类型和数量**自动选择最优特化子类**。

### 1.4 `UASStruct`（继承自 `UScriptStruct`）

```cpp
UCLASS()
class ANGELSCRIPTRUNTIME_API UASStruct : public UScriptStruct
{
    UASStruct* NewerVersion;                 // 热重载版本链
    asITypeInfo* ScriptType;
    FGuid Guid;                              // 序列化标识
    bool bIsScriptStruct;

    void PrepareCppStructOps() override;     // 自定义 CppStructOps
    ICppStructOps* CreateCppStructOps();
};
```

结构体与类的区别：

| 维度 | `UASClass` | `UASStruct` |
|------|-----------|-------------|
| 继承自 | `UClass` | `UScriptStruct` |
| 可实例化为 | `UObject` 派生实例 | 纯值类型（栈/嵌入字段） |
| 构造器 | `StaticActor/Component/ObjectConstructor` | `ICppStructOps` |
| GC | 通过 `UObject` 引用追踪 | 通过 `EmitReferenceInfo` Schema |
| 序列化 | `FGuid` 用于稳定标识 | 同 |

---

## 二、`FAngelscriptClassGenerator` —— 核心结构体

### 2.1 公有 API

```cpp
struct FAngelscriptClassGenerator
{
    enum EReloadRequirement { SoftReload, FullReloadSuggested, FullReloadRequired, Error };

    // --- 公有入口 ---
    void AddModule(TSharedRef<FAngelscriptModuleDesc> Module);  // Phase 2
    EReloadRequirement Setup();                                  // Phase 3
    void PerformFullReload();                                    // Phase 4 (Full)
    void PerformSoftReload();                                    // Phase 4 (Soft)

    bool WantsFullReload(TSharedRef<FAngelscriptModuleDesc>);
    bool NeedsFullReload(TSharedRef<FAngelscriptModuleDesc>);

    // --- 8 个重载委托 ---
    static FOnAngelscriptClassReload OnClassReload;
    static FOnAngelscriptEnumCreated OnEnumCreated;
    static FOnAngelscriptEnumChanged OnEnumChanged;
    static FOnAngelscriptStructReload OnStructReload;
    static FOnAngelscriptDelegateReload OnDelegateReload;
    static FOnAngelscriptPostReload OnPostReload;
    static FOnAngelscriptFullReload OnFullReload;
    static FOnAngelscriptLiteralAssetReload OnLiteralAssetReload;
};
```

### 2.2 内部数据结构

```text
FAngelscriptClassGenerator
├── TArray<FModuleData> Modules
│   ├── TArray<FClassData> Classes        // 继承 FReloadPropagation
│   │   ├── NewClass / OldClass           // 新旧 FAngelscriptClassDesc
│   │   ├── ReplacedClass (UASClass*)     // 被替换的旧 UASClass
│   │   └── ReloadReq (EReloadRequirement)
│   ├── TArray<FEnumData> Enums
│   ├── TArray<FDelegateData> Delegates   // 继承 FReloadPropagation
│   └── TArray<RemovedClasses>
├── TMap<FString, FDataRef> DataRefByName
├── TMap<asITypeInfo*, FDataRef> DataRefByNewScriptType
└── TMap<asITypeInfo*, asITypeInfo*> UpdatedScriptTypeMap  // 新旧脚本类型映射
```

### 2.3 `FReloadPropagation` —— 依赖传播骨架

```cpp
struct FReloadPropagation
{
    bool bStartedPropagating = false;
    bool bFinishedPropagating = false;
    bool bHasOutstandingDependencies = false;
    EReloadRequirement ReloadReq = SoftReload;
    TArray<FReloadPropagation*> PendingDependees;     // 等待本节点传播完才能确定级别的下游
};
```

类与委托都继承此骨架。依赖传播规则：

```text
如果 ClassA 的属性类型是 ClassB:
  ClassB 的 ReloadReq 确定后 -> 传播到 ClassA
  ClassB 需要 FullReload -> ClassA 至少也需要 FullReloadSuggested

传播入口: AddReloadDependency(Source, Type)
  -> 递归处理 SubTypes (如 TArray<ClassB> 的元素类型)
  -> 如果 Type 对应的 FClassData 还没 propagate 完, 加到 PendingDependees
  -> 等完成后 ResolvePendingReloadDependees 批量通知
```

---

## 三、Phase 3: `Setup()` —— 分析与重载级别确定

**源码所在**: `AngelscriptClassGenerator.cpp:1993-2029`。

```cpp
EReloadRequirement FAngelscriptClassGenerator::Setup()
{
    // Step 1: 为每个模块创建内部数据结构
    for (auto& ModuleData : Modules)
        SetupModule(ModuleData);

    // Step 2: 分析所有模块
    for (auto& ModuleData : Modules)
        Analyze(ModuleData);

    // Step 3: 依赖传播
    for (auto& ModuleData : Modules)
    {
        for (auto& ClassData : ModuleData.Classes)
            PropagateReloadRequirements(ModuleData, ClassData);
        for (auto& DelegateData : ModuleData.Delegates)
            PropagateReloadRequirements(ModuleData, DelegateData);
    }

    // Step 4: 取所有模块中最高级别的 ReloadReq
    EReloadRequirement ReloadReq = SoftReload;
    for (auto& ModuleData : Modules)
        if (ModuleData.ReloadReq > ReloadReq)
            ReloadReq = ModuleData.ReloadReq;
    return ReloadReq;
}
```

### 3.1 `Analyze(Module, ClassData)` 的关键逻辑

```text
Analyze(ModuleData, ClassData):
  [1] 如果上一个模块有 swap-in 错误 -> 强制 FullReloadRequired
  [2] 解析脚本类型 (ScriptType), 建立新旧类型映射
  [3] 递归确保父类已分析 (EnsureClassAnalyzed)
  [4] 遍历所有属性:
      - 跳过继承的属性 (IsPropertyInherited)
      - 通过 FAngelscriptTypeUsage::FromProperty 构造类型描述
  [5] 检查是否可替换已有 UClass (FindObject<UObject>)
  [6] 比较新旧版本确定重载级别:
      - 属性增删/类型变更 -> FullReloadRequired
      - 仅函数体变更 -> SoftReload
  [7] AddReloadDependency 建立类型依赖图
```

### 3.2 四级重载需求

| 级别 | 含义 | 触发条件 |
|------|------|---------|
| `SoftReload` | 仅替换字节码指针 | 只有函数体变更，属性/签名/继承链不变 |
| `FullReloadSuggested` | 建议 Full，但不是必须 | 依赖的类发生了 Full，但本类无直接变更 |
| `FullReloadRequired` | 必须 Full | 属性增删/类型变更/继承链变更/类被移除 |
| `Error` | 编译错误，不执行重载 | 命名冲突/类型无法解析 |

---

## 四、Phase 4: `PerformReload` —— 10 步执行流程

**源码所在**: `AngelscriptClassGenerator.cpp:2246-2425`。

### 4.1 严格顺序

```text
PerformReload(bFullReload):
  Step 1: 创建/链接        → CreateFullReload{Class,Struct,Delegate} / LinkSoftReloadClasses
  Step 2: 重载枚举          → DoFullReload(Module, EnumData)
  Step 3: 重载结构体        → DoFullReload(Module, ClassData) [bIsStruct]
  Step 4: 重载委托          → DoFullReload(Module, DelegateData)
  Step 5: 准备软重载        → PrepareSoftReload
  Step 6: 重载类            → DoFullReload(Module, ClassData) [!bIsStruct]
  Step 7: 执行软重载        → DoSoftReload
  Step 8: 最终化所有类      → FinalizeClass
  Step 9: 初始化默认对象    → CallPostInitFunctions + InitDefaultObjects
  Step 10: 广播重载委托     → OnClassReload / OnPostReload / OnFullReload
```

顺序约束的根本原因：**类依赖结构体，结构体依赖枚举**——先低后高保证所有依赖在被消费前已就绪。

### 4.2 `DoFullReloadClass` —— 类重载核心

```text
DoFullReloadClass(ModuleData, ClassData):
  [1] 解析父类: 递归 EnsureReloaded(ParentASClass)
  [2] 收集已有实例 GetObjectsOfClass
  [3] 设置 ClassFlags:
      - CLASS_CompiledFromBlueprint
      - CLASS_Config (如有 ConfigName)
      - CLASS_DefaultConfig (如有 DefaultConfig meta)
  [4] 设置 SuperStruct + PropertyLink
  [5] AddClassProperties() -> 遍历 AS 类型属性, 创建 FProperty
  [6] 创建 UASFunction:
      - 遍历 ClassDesc->Functions
      - AllocateFunctionFor 选择特化子类
      - FinalizeArguments 设置参数布局
  [7] DetectAngelscriptReferences() -> GC Schema 生成
  [8] 迁移已有对象实例到新类
```

### 4.3 `FinalizeClass` —— 类最终化

```text
FinalizeClass(ModuleData, ClassData):
  [1] SetUpRuntimeReplicationData (网络复制)
  [2] 解析 ComposeOntoClass
  [3] 添加 ImplementedInterfaces (递归解析接口类)
  [4] 根据类类型分派:
      ├─ Actor 类  → FinalizeActorClass
      │   ├─ 设 ClassConstructor = StaticActorConstructor
      │   ├─ 遍历 Properties 找 DefaultComponent meta
      │   │   -> 构造 FDefaultComponent { ComponentClass, Name, Offset, bIsRoot, Attach, AttachSocket }
      │   └─ 遍历 Properties 找 OverrideComponent meta
      │       -> 构造 FOverrideComponent
      ├─ Component 类 → FinalizeComponentClass
      │   └─ 设 ClassConstructor = StaticComponentConstructor
      └─ Object 类 → FinalizeObjectClass
          └─ 设 ClassConstructor = StaticObjectConstructor
  [5] VerifyClass: 校验抽象组件/具体 Actor 的一致性
```

---

## 五、运行时实例化：三种构造器

### 5.1 `StaticActorConstructor`（Actor 类，最复杂）

**源码所在**: `ASClass.cpp:1362-1412`。

```text
StaticActorConstructor(Initializer):
  [1] 取 UASClass* 和 asCObjectType*
  [2] ApplyOverrideComponents(Initializer, Actor, Class)
  [3] CodeSuperClass->ClassConstructor(Initializer)        ← 调 C++ 父类构造
  [4] 设置 Tick: bCanEverTick / bStartWithTickEnabled
  [5] new(Object) asCScriptObject(ScriptType)              ← placement-new AS 对象
  [6] CreateDefaultComponents(Initializer, Actor, Class)   ← 递归创建组件
  [7] ExecuteConstructFunction(Object, Class)              ← 调 AS 构造函数
```

### 5.2 `CreateDefaultComponents` —— 递归组件创建

**源码所在**: `ASClass.cpp:1212-1310`。

```cpp
static FORCEINLINE_DEBUGGABLE void CreateDefaultComponents(
    const FObjectInitializer& Initializer, AActor* Actor, UASClass* ScriptClass)
{
    // 父类先创建 (递归)
    if (UASClass* ParentClass = Cast<UASClass>(ScriptClass->GetSuperClass()))
        CreateDefaultComponents(Initializer, Actor, ParentClass);

    // 遍历本层的 DefaultComponents
    for (auto& DefaultComponent : ScriptClass->DefaultComponents)
    {
        UActorComponent* Component;
        UClass* ComponentClass = DefaultComponent.ComponentClass;

        if (WITH_EDITOR && DefaultComponent.bEditorOnly)
            Component = Initializer.CreateEditorOnlyDefaultSubobject(Actor, DefaultComponent.ComponentName, ComponentClass, false);
        else
            Component = Initializer.CreateDefaultSubobject(Actor, DefaultComponent.ComponentName, ComponentClass, ComponentClass, true, false);

        // 把新组件写入脚本对象的属性槽
        UActorComponent** VariablePtr = (UActorComponent**)((SIZE_T)Actor + DefaultComponent.VariableOffset);
        *VariablePtr = Component;

        // SceneComponent 处理 Attach / RootComponent
        if (auto* SceneComponent = Cast<USceneComponent>(Component))
        {
            if (DefaultComponent.bIsRoot)
                Actor->SetRootComponent(SceneComponent);
            else if (DefaultComponent.Attach != NAME_None)
                // 延迟附着 (等目标组件也创建完)
                DelayedComponentAttach.Add({SceneComponent, ...});
        }
    }
    // 执行延迟附着
    for (auto& [Comp, TargetIdx] : DelayedComponentAttach)
        Comp->SetupAttachment(FindAttachTarget(...), DefaultComponent.AttachSocket);
}
```

关键设计：

- **递归从父到子**：C++ `AActor` → AS 父类 → AS 子类，每层只创建**自己新增**的组件。
- **延迟附着**：同层内的组件可能有依赖（`Attach=MeshComp`），先全部创建，再批量 `SetupAttachment`。

### 5.3 `StaticObjectConstructor`（最简单）

```cpp
void UASClass::StaticObjectConstructor(const FObjectInitializer& Initializer)
{
    UObject* Object = Initializer.GetObj();
    UASClass* Class = GetFirstASClass(Object);
    asCObjectType* ScriptType = (asCObjectType*)Class->ScriptTypePtr;

    Class->CodeSuperClass->ClassConstructor(Initializer);   // C++ 父类构造

    if (!bIsScriptAllocation && ScriptType != nullptr)
        new(Object) asCScriptObject(ScriptType);            // 脚本对象内存

    if (!bIsScriptAllocation)
        ExecuteConstructFunction(Object, Class);            // AS 构造函数
}
```

无组件创建、无 Tick 设置、无 Override 处理——纯粹的"C++ 父类 + AS 对象 + AS 构造函数"三段式。

---

## 六、`AddClassProperties` —— 属性桥接

**源码所在**: `AngelscriptClassGenerator.cpp:2850+`。

此函数遍历 `asCObjectType` 的所有属性，跳过继承属性，为每个非继承属性创建对应的 `FProperty`（调用 `FAngelscriptTypeUsage::CreateProperty`）。产出的 `FProperty` 链表挂到 `UASClass::PropertyLink` 上，使 UE 反射系统可以遍历/序列化/编辑。

与 `Syntax_UPROPERTY.md` 中描述的 `FAngelscriptPropertyDesc → FProperty` 链路对接：

```text
预处理器:  UPROPERTY(EditAnywhere) int Health;
              -> FAngelscriptPropertyDesc { bEditAnywhere=true, ... }

ClassGenerator:
  AddClassProperties(ClassDesc):
    for each PropDesc:
      FAngelscriptTypeUsage type = FAngelscriptTypeUsage::FromProperty(ScriptType, i);
      FProperty* Prop = type.CreateProperty(Params);  // ← 同 Syntax_UPROPERTY §3
      // 设置 CPF_* flags 根据 PropDesc 的 bool 字段
```

---

## 七、Soft Reload vs Full Reload

| 维度 | Soft Reload | Full Reload |
|------|------------|-------------|
| **触发条件** | 仅函数体变更 | 属性/签名/继承链/类增删 |
| **UASClass** | 不替换，复用旧对象 | 新建 `UASClass`，旧对象挂到 `NewerVersion` 链 |
| **字节码** | 只替换 `asIScriptFunction*` 指针 | 全部重建 |
| **实例迁移** | 不需要 | `GetObjectsOfClass` 收集 + 逐个迁移 |
| **CDO 重建** | 不需要 | 重建 CDO + `InitDefaultObjects` |
| **性能** | 几乎瞬间（< 1ms 级） | 可能数百毫秒（取决于实例数） |
| **蓝图影响** | 无 | 可能需要重编译引用的蓝图 |

Soft Reload 的核心操作（`SoftReloadFunction`）：

```text
SoftReloadFunction(UFunction* Function):
  -> 更新 ScriptFunction 指针
  -> 更新 JitFunction 指针 (如果 JIT 启用)
  -> 不触碰属性/ClassFlags/继承链
```

---

## 八、设计哲学

### 8.1 为什么继承 `UClass` 而不是用 `UBlueprintGeneratedClass`？

```text
+ 更轻量:
  - UBlueprintGeneratedClass 携带大量 BP 编辑器基础设施 (BlueprintGraph, UbergraphPages...)
  - UASClass 只需要运行时+热重载, 不需要那些编辑器状态

+ 更可控:
  - 自定义 ClassConstructor 分派 (Actor/Component/Object 三路)
  - 自定义 GetContainerSize / GetMostUpToDateClass
  - 不受 BP 编译管线约束

- 代价:
  - 与 BP 系统不完全兼容 (某些 BP-only 的编辑器功能需要特殊处理)
  - 需要自己处理 DefaultObject 重建
```

### 8.2 为什么 `UASFunction` 有 17+ 特化子类？

每个虚分派都有虚函数调用开销。脚本函数被 UE 通过 `UFunction::Invoke` 调用时，参数需要从 `FFrame` 栈上取出并转为 AS 可用形式。按签名特化：

```text
+ 无参函数: 跳过参数压栈循环, 直接 Context->Execute()
+ 单 DWord 参数: 直接 SetArgDWord, 避免类型判断
+ JIT 变体: 跳过字节码解释, 直接调原生函数指针
  -> 每种特化节省 3-10 条分支指令, 累积到每秒数千次调用时有显著差异
```

### 8.3 为什么结构体先于类重载？

```text
类属性可以是结构体类型:
  UPROPERTY() FMyStruct Data;

如果 FMyStruct 还没重载, CreateProperty 会拿到旧的 UASStruct
-> 属性 size/alignment 对不上 -> 内存布局错误

所以: 枚举 -> 结构体 -> 委托 -> 类, 严格拓扑序
```

### 8.4 为什么 `CreateDefaultComponents` 是递归的？

```text
class AParent : AActor
{
    UPROPERTY(DefaultComponent) USceneComponent Root;
}

class AChild : AParent
{
    UPROPERTY(DefaultComponent, Attach=Root) UStaticMeshComponent Mesh;
}
```

如果不递归、只处理本层，`AChild` 创建 `Mesh` 时 `Root` 还不存在——`SetupAttachment` 会失败。从父到子递归保证**每层的附着目标在下层创建时已就绪**。

---

## 九、关键结论速查

| 主题 | 结论 |
|------|------|
| **核心职责** | 把 AS 编译产出的脚本类型转换为 `UASClass`/`UASStruct`/`UEnum`/`UDelegateFunction`，完全融入 UE 反射系统 |
| **主入口** | `AddModule` → `Setup`（分析+确定级别）→ `PerformFullReload`/`PerformSoftReload` |
| **10 步重载流程** | 创建/链接 → 枚举 → 结构体 → 委托 → 准备软重载 → 类 → 软重载 → Finalize → 初始化 CDO → 广播 |
| **Soft vs Full** | Soft 仅替换字节码指针（< 1ms）；Full 重建 UASClass + 迁移实例（可达数百 ms） |
| **重载级别确定** | `FReloadPropagation` 依赖传播：属性类型变更 → 沿依赖链向上传播 `FullReloadRequired` |
| **三种构造器** | `StaticActorConstructor`（含组件创建+Tick+Override）/ `StaticComponentConstructor` / `StaticObjectConstructor` |
| **递归组件创建** | `CreateDefaultComponents` 从父到子递归，先创建再延迟附着 |
| **17+ UASFunction 特化** | 按参数/返回签名 + JIT 维度组合特化，减少虚分派开销 |
| **属性桥接** | `AddClassProperties` 调 `FAngelscriptTypeUsage::CreateProperty`，与 `Syntax_UPROPERTY` §3 共用链路 |
| **GC Schema** | `DetectAngelscriptReferences` 为没有 UPROPERTY 宏的私有属性补 GC Schema |
| **版本链** | `UASClass::NewerVersion` / `UASStruct::NewerVersion` 维护热重载版本链 |
| **8 个广播委托** | `OnClassReload` / `OnStructReload` / `OnDelegateReload` / `OnEnumCreated` / `OnEnumChanged` / `OnPostReload` / `OnFullReload` / `OnLiteralAssetReload` |

---

## 十、关联文档

- 架构层：
  - `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览与模块职责
  - `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — Runtime 总控与生命周期（`InitializeAngelscript` 调用 ClassGenerator 入口）
- 类型系统：
  - `Documents/Knowledges/ZH/Type_StructGeneration.md` — 脚本结构体生成（`DoFullReloadStruct` 子流程，待写）
  - `Documents/Knowledges/ZH/Type_BindSystem.md` — `FAngelscriptType` / `FAngelscriptTypeUsage` 类型系统
  - `Documents/Knowledges/ZH/Type_Core.md` — 类型系统核心
- 语法机制：
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — `FProperty` 创建链路，被 `AddClassProperties` 消费
  - `Documents/Knowledges/ZH/Syntax_DefaultComponent.md` — `DefaultComponent` / `Attach` / `RootComponent` 组件声明语法
  - `Documents/Knowledges/ZH/Syntax_DelegateEvent.md` — 委托/事件类型生成
- 运行时：
  - `Documents/Knowledges/ZH/RT_HotReload.md` — 热重载与文件变更链路（Soft/Full 策略的调用方）
  - `Documents/Knowledges/ZH/RT_StaticJIT.md` — `UASFunction::JitFunction` 绑定
  - `Documents/Knowledges/ZH/RT_StateDump.md` — State Dump 中类生成状态的导出
- 核心源码：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h` — 类生成器头文件
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` — 主实现（5932 行）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h` / `.cpp` — `UASClass` + `UASFunction` + 构造器
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASStruct.h` / `.cpp` — `UASStruct`
- 测试覆盖：
  - `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` — 28 个类生成测试文件

---

## 十一、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-29 | 首版：基于 `AngelscriptClassGenerator.h`(245 行) / `AngelscriptClassGenerator.cpp`(5932 行) / `ASClass.h`(555 行) / `ASClass.cpp`(~97 KB) / `ASStruct.h`(61 行) / `ASStruct.cpp` / `AngelscriptAdditionalCompileChecks.h`(9 行) 完整产出。覆盖：① 全景管线（编译 → AddModule → Setup → PerformReload → 运行时实例化）五阶段概览；② 核心类型层次：`UASClass`（关键字段 CodeSuperClass / NewerVersion / DefaultComponents / 三种静态构造器）+ `UASFunction`（17+ 特化子类设计动机）+ `UASStruct`（CppStructOps / 热重载 Guid）；③ `FAngelscriptClassGenerator` 公有 API + 内部数据结构 `FModuleData`/`FClassData`/`FEnumData`/`FDelegateData` + `FReloadPropagation` 依赖传播骨架；④ Phase 3 `Setup()` 四步分析流程 + `Analyze(Module, ClassData)` 关键逻辑 + 四级重载需求矩阵；⑤ Phase 4 `PerformReload` 10 步严格执行顺序 + `DoFullReloadClass` 核心步骤 + `FinalizeClass` Actor/Component/Object 三路分派；⑥ 运行时三种构造器：`StaticActorConstructor`（含 `CreateDefaultComponents` 递归从父到子 + 延迟附着）/ `StaticComponentConstructor` / `StaticObjectConstructor`；⑦ `AddClassProperties` 与 `Syntax_UPROPERTY` 的共用链路；⑧ Soft vs Full Reload 对比矩阵；⑨ 4 个设计哲学（继承 UClass vs UBlueprintGeneratedClass / 17+ UASFunction 特化 / 结构体先于类重载 / 递归组件创建）。 |
