# Syntax_FInstancedStruct — `FInstancedStruct` 类型擦除 USTRUCT 容器

> **所属前缀**: Syntax_（智能指针与引用包装族 / 类型擦除分支）
> **关注层面**: AS 端语法机制、`?&in` / `?&out` 通配桥、`UScriptStruct*` + 字节数组的擦除模型与 StructUtils 模块依赖（不写"怎么用"——那是 `Guide_*` 的活；不写 USTRUCT 反射对象生成本身——那是 `Type_StructGeneration.md`）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp`（全文 ~173 行，唯一注册入口）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Helpers.h` `:105-128`（`FAngelscriptInstancedStructHelpers` / `FScriptStructType` 静态助手）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptAnyStructParameter.h`（`FAngelscriptAnyStructParameter` USTRUCT，公开 API 边界）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDelegateWithPayload.h`（`FAngelscriptDelegateWithPayload::Payload` 复用 FInstancedStruct）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp`（payload 路径 + boxed primitive 兼容）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASStruct.h` `:56-60`（`FScriptStructWildcard` 引用占位 USTRUCT）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` `:6165-6182`（`GetUnrealStructFromAngelscriptTypeId` AS TypeId → `UStruct*`）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` `:33-45`（`PublicDependencyModuleNames` 含 `StructUtils`）
> · `Plugins/Angelscript/Angelscript.uplugin` `:35-48`（`Plugins` 块启用 `StructUtils`）
> · `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptInstancedStructBindingsTests.cpp`（CQTest 行为契约：Default / Reset）
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h` `:710-775`（`InspectInstancedStructByPath` / `GetInstancedStructByPath` 反射路径访问）
> · `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp` `:1370-1521`（已知 AS USTRUCT × FInstancedStruct 边界问题）
> **关联文档**:
> `Documents/Knowledges/ZH/Syntax_TSubclassOf.md` —— 兄弟 wrapper（类型擦除 vs 类型标签）
> · `Documents/Knowledges/ZH/Syntax_TOptional.md` —— 单 T 模板包装的对照样本
> · `Documents/Knowledges/ZH/Syntax_TWeakObjectPtr.md` —— 同族弱引用包装
> · `Documents/Knowledges/ZH/Type_StructGeneration.md` —— USTRUCT 生成路径与 `FASStructOps`
> · `Documents/Knowledges/ZH/Type_BindSystem.md` —— `FAngelscriptType` 多态分派与 TypeId / UScriptStruct 关联
> · `Documents/Knowledges/ZH/Type_Core.md` §四 —— `asITypeInfo::SetUserData(UScriptStruct*)` 的关联机制
> **外部参考**（可选）:
> [UE5 `FInstancedStruct` 头文件](https://github.com/EpicGames/UnrealEngine/blob/release/Engine/Source/Runtime/CoreUObject/Public/StructUtils/InstancedStruct.h)
> · [UE StructUtils 插件文档](https://docs.unrealengine.com/5.7/en-US/struct-utils-in-unreal-engine/)

---

## 概览

`FInstancedStruct` 是 UE 的"**类型擦除 USTRUCT 容器**"——单实例可在运行时携带任意 `UScriptStruct*` + 一段堆分配的 `uint8*` 字节数组，让一个 `UPROPERTY` 字段或函数参数能存放"派生于某个基础结构体的任意子类型"。这是 UE 5.0 引入的 `StructUtils` 插件提供的运行时设施，UE 5.5 起被并入 `CoreUObject` 但仍由独立模块装载。

在当前 AS 插件中，`FInstancedStruct` 被注册为**普通 USTRUCT 值类型**（不是模板）——它的构造/拷贝/析构由 UE 自身的 `TStructOpsTypeTraits<FInstancedStruct>` 提供（自带 `WithSerializer` / `WithIdentical` / `WithExportTextItem` / `WithImportTextItem` / `WithAddStructReferencedObjects` / `WithNetSerializer`）。AS 插件**只**额外暴露 11 个方法/重载——所有"读写需要类型信息"的入口（`InitializeAs` / `Get` / `GetMutable` / `Make`）都靠 AS 的**通配参数语法 `?&in` / `?&out`** 透传一个匿名 struct，配合 `FAngelscriptEngine::GetUnrealStructFromAngelscriptTypeId(TypeId)` 反查得到 `UScriptStruct*`，再调 `FInstancedStruct::InitializeAs(ScriptStruct, Memory)` 拼回去。

```text
        AS 脚本侧                              C++ 实现侧
        ====================                  ============================
   FInstancedStruct S;                       默认构造 → ScriptStruct=null,
                                              StructMemory=null, IsValid=false
   S.InitializeAs(MyStruct);                 wildcard ?&in → TypeId 查 UScriptStruct
                                              → InitializeAs(SS, &MyStruct)
   FInstancedStruct S = FInstancedStruct::Make(MyStruct);
                                             静态 Make wildcard ?&in 同上
   if (S.IsValid()) ...                      ScriptStruct != null && Memory != null
   if (S.Contains(FMyStruct::StaticStruct()))…  ScriptStruct == StructType
   FMyStruct M = S.Get(FMyStruct);           const FScriptStructWildcard& 返回
                                              + exact-result `.DeterminesOutputType(0)`
                                              → 编译期 narrow 为 const FMyStruct&
   FMyStruct& M = S.GetMutable(FMyStruct);   同上但 mutable
   S.Get(MyStruct);                          wildcard ?&out → TypeId 校验
                                              + CopyScriptStruct 拷出（已弃用）
   S.Reset();                                FInstancedStruct::Reset() 释放堆 + 置 null
   S.GetScriptStruct()                       直接透传
```

### 在族谱中的位置

```text
          ┌──────────────────────────────────────────────────────┐
          │  类型擦除 / 反射包装家族                                │
          ├──────────────────────────────────────────────────────┤
          │  FInstancedStruct      "类型擦除 USTRUCT 容器" ← 本文 │
          │  TSubclassOf<T>        "保证子类的 UClass*"           │
          │  TOptional<T>          "可选值"                       │
          │  TWeakObjectPtr<T>     "弱引用 UObject"               │
          ├──────────────────────────────────────────────────────┤
          │   关键差异:                                            │
          │  ┌──────────────┬──────────────┬──────────────────┐  │
          │  │  FInstanced  │  TSubclassOf │  TWeakObjectPtr  │  │
          │  ├──────────────┼──────────────┼──────────────────┤  │
          │  │ 持 UScriptS- │ 持 UClass*   │ 持 FWeakObject   │  │
          │  │ truct + 数据 │              │ Ptr (无数据)     │  │
          │  │ "类 + 实例"  │ "类型标签"   │ "对象引用"       │  │
          │  │ 堆分配字节   │ 单指针       │ Index+Serial     │  │
          │  │ 普通 USTRUCT │ 模板值类型   │ 模板值类型       │  │
          │  │ 反射: F-    │ 反射: FClass-│ 反射: FWeakObj-  │  │
          │  │ StructProp- │ Property +   │ ectProperty +    │  │
          │  │ erty (Struct │ MetaClass    │ PropertyClass    │  │
          │  │ =FInstanced- │              │                  │  │
          │  │ Struct)      │              │                  │  │
          │  └──────────────┴──────────────┴──────────────────┘  │
          └──────────────────────────────────────────────────────┘
```

后续按以下顺序展开：① 数据布局与设计动机；② StructUtils 模块依赖与启用链路；③ Bind_FInstancedStruct 注册全景（11 个入口）；④ Wildcard `?&in` / `?&out` × TypeId 反查 `UScriptStruct*`；⑤ `FScriptStructWildcard` 与 exact-result `.DeterminesOutputType(0)`；⑥ `FAngelscriptAnyStructParameter` —— 脚本端 any-struct 参数；⑦ `FAngelscriptDelegateWithPayload` —— FInstancedStruct 作 payload 复用；⑧ UPROPERTY 与编辑器集成；⑨ 序列化与 cooked build；⑩ 与 `TSubclassOf` 的对照；⑪ 限制与避坑（含 AS USTRUCT × FInstancedStruct 已知 bug）。

---

## 一、数据布局与设计动机

### 1.1 物理布局：`UScriptStruct* + uint8*`

UE 的 `FInstancedStruct` 在 5.7 中位于 `CoreUObject/Public/StructUtils/InstancedStruct.h`：

```cpp
// ============================================================================
// 文件: Engine/Source/Runtime/CoreUObject/Public/StructUtils/InstancedStruct.h
// 性质: UE 标准库（节选示意，非本仓库代码）
// ============================================================================
USTRUCT(BlueprintType, meta = (DisableSplitPin,
        HasNativeMake = "/Script/Engine.BlueprintInstancedStructLibrary.MakeInstancedStruct"))
struct [[nodiscard]] FInstancedStruct
{
    GENERATED_BODY()
public:
    // ... 一系列构造 / Initialize / Get / GetMutable / Reset / Identical / NetSerialize ...
protected:
    TObjectPtr<const UScriptStruct> ScriptStruct = nullptr;   // ★ "类型标签"
    uint8*                          StructMemory = nullptr;   // ★ 堆分配字节数组
};
```

也就是说每个 `FInstancedStruct` 物理上**两个指针 + 一段堆字节**：

- `ScriptStruct` 决定"我现在装的是什么 struct"——可以在运行时在不同 `UScriptStruct*` 之间切换。
- `StructMemory` 是 `Malloc(StructureSize, MinAlignment)` 出来的字节数组，承载实际值。
- `Reset()` 调 `ScriptStruct->DestroyStruct(StructMemory)` + `Free(StructMemory)`，再把两个字段置 null。

这与裸 `USTRUCT` 字段的根本差异：**裸 USTRUCT 字段在编译期固定类型**（`FVector` 字段就只能装 `FVector`），而 `FInstancedStruct` 字段在运行期任意切换类型。这给 UE 数据驱动配置（编辑器中"动态结构选择器"）提供了底层支撑。

### 1.2 与裸 USTRUCT 字段的差异

```text
裸 USTRUCT 字段:                      FInstancedStruct 字段:
  - 类型固定（FStructProperty.Struct  - 类型可变（编辑器/脚本运行时切换）
    在编译期决定）                      - 编辑器面板出"结构选择下拉框"
  - 内联存储（sizeof = 实际 struct）   - 间接存储（sizeof = 16-24 字节, 即两指针）
  - 默认值序列化为 ScriptText         - 序列化先写 ScriptStruct path 再写值
  - 不能放在 TArray 中"每个元素不同型" - TArray<FInstancedStruct> 每元素可异型
  - C++ 端：MyStruct Field;           - C++ 端：FInstancedStruct Field;
                                       Field.InitializeAs<MyStruct>(...);
```

### 1.3 设计动机

`FInstancedStruct` 的存在解决三类问题：

1. **数据驱动配置**：游戏 GAS Effect、AI Behavior、Mass ECS Fragment、Quest 步骤等场景下，配表者需要在编辑器里为同一个槽位选择不同 struct 类型。`UPROPERTY(meta=(BaseStruct="..."))` + `FInstancedStruct` 让这成为单字段配置。
2. **委托 Payload**：`FAngelscriptDelegateWithPayload::Payload`（见 §七）就是用 FInstancedStruct 装"任意 payload struct"——绑定时记录 ScriptStruct，触发时 ProcessEvent 用同一段 Memory。
3. **跨脚本/蓝图传递**：当蓝图节点输出"动态结构"，C++ 接收侧要么知道精确类型用裸 struct，要么用 `FInstancedStruct` 接收任意类型。AS 插件用法主要是后者。

`TInstancedStruct<BaseStructT>` 是同头文件中的"类型受限版本"——把 `FInstancedStruct` 包成 C++ 模板让编译期检查 `IsChildOf(BaseStructT)`，但**反射层把 `TInstancedStruct<X>` 视为 `FInstancedStruct`**（见头文件第 496-497 行注释）。当前 AS 插件**未**为 `TInstancedStruct<>` 暴露脚本端模板 wrapper，脚本作者只能用裸 `FInstancedStruct`。

---

## 二、StructUtils 模块依赖与启用链路

### 2.1 Build.cs 公开依赖

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
// 角色: PublicDependencyModuleNames 节选
// ============================================================================
PublicDependencyModuleNames.AddRange(new string[]
{
    "ApplicationCore", "Core", "CoreUObject", "Engine",
    "EngineSettings", "DeveloperSettings",
    "Json", "JsonUtilities",
    "GameplayTags",
    "StructUtils",                    // ★ FInstancedStruct 所在模块
});
```

`StructUtils` 在 UE 5.0–5.4 是独立 plugin（路径 `Engine/Plugins/Runtime/StructUtils`）；UE 5.5+ 头文件被搬到 `CoreUObject/Public/StructUtils/InstancedStruct.h`，但模块名仍叫 `StructUtils` 以保持 link 兼容性。`AngelscriptRuntime.Build.cs` 把它放在 `PublicDependencyModuleNames`——任何依赖 `AngelscriptRuntime` 的下游模块都自动获得 `StructUtils` 的 include path 与 link 库。

### 2.2 .uplugin 启用项

```json
// ============================================================================
// 文件: Plugins/Angelscript/Angelscript.uplugin
// 角色: Plugins 启用块
// ============================================================================
"Plugins": [
    { "Name": "StructUtils",          "Enabled": true },
    { "Name": "PropertyBindingUtils", "Enabled": true },
    { "Name": "EnhancedInput",        "Enabled": true }
]
```

启用 `StructUtils` 让 UE 在加载阶段把这个 plugin 拉起，确保 `FInstancedStruct::StaticStruct()` 能被反射查到。`Plan_StructUtilsMigration.md` 已经把"是否继续把 StructUtils 留在 public 边界"列为 OpenSpec 待决策项——本文档以**当前公开依赖**为基线写。

### 2.3 头文件传播链

```text
Bind_FInstancedStruct.cpp
    │  #include "StructUtils/InstancedStruct.h"      ← 直接引
    ▼
Bind_Helpers.h
    │  #include "StructUtils/InstancedStruct.h"      ← 公共 helper 头
    ▼
AngelscriptAnyStructParameter.h                       ← AS USTRUCT，含 FInstancedStruct 字段
AngelscriptDelegateWithPayload.h                      ← AS USTRUCT，含 FInstancedStruct 字段
    │
    ▼
任何 #include "AngelscriptDelegateWithPayload.h"
    或 "AngelscriptAnyStructParameter.h" 的下游模块
    都隐式获得 StructUtils 头依赖
```

这条链路是 `Plan_StructUtilsMigration.md` 中描述的"public header 漏出 StructUtils 类型"的核心证据——任何想把 StructUtils 变成 private dependency 的尝试都必须先从 §2.3 的两个 USTRUCT 头文件里把 `FInstancedStruct` 字段藏起来。

---

## 三、Bind_FInstancedStruct 注册全景

### 3.1 唯一注册入口

`Bind_FInstancedStruct.cpp` 是 `FInstancedStruct` 在 AS 端的**唯一手工绑定入口**——`FInstancedStruct::StaticStruct()` 自身的注册（让 AS 知道有一个 USTRUCT 叫 `FInstancedStruct`、它的 size / alignment / construct / destruct）走的是引擎绑定数据库通用 USTRUCT 反射注册路径（见 `Type_StructGeneration.md`）；本文件只补充**带行为的方法**。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 函数: BindFInstancedStructFunctions（显式目标 callback）
// ============================================================================
namespace
{
    void BindFInstancedStructFunctions(FAngelscriptBinds& Binds)
    {
        auto FAngelscriptAnyStructParameter_ =
            Binds.ExistingClassForTarget("FAngelscriptAnyStructParameter");
        FAngelscriptAnyStructParameter_
            .ImplicitConstructor(
                "void f(const ?&in Struct)",
                FUNC(FAngelscriptFInstancedStructBinds::ImplicitConstructAnyStruct))
            .NoDiscard();
        FAngelscriptAnyStructParameter_
            .ImplicitConstructor(
                "void f(const FInstancedStruct& Struct)",
                FUNC(FAngelscriptFInstancedStructBinds::ImplicitConstructAnyStructFromInstancedStruct))
            .NoDiscard();

        auto FInstancedStruct_ = Binds.ExistingClassForTarget("FInstancedStruct");
        // ... 11 个方法 + 1 个 namespaced 全局函数 Make ...
    }
}

AS_FORCE_LINK const FAngelscriptBind Bind_FInstancedStruct(
    TEXT("FInstancedStruct.Functions"),
    EAngelscriptBindPhase::ManualBindings,
    &BindFInstancedStructFunctions);
```

注意几个**形态特征**：

- **`EAngelscriptBindPhase::ManualBindings`**：在 `TypeDeclarations` / `TypeInfrastructure` 建好 USTRUCT 类型和关联数据后补充方法——`FInstancedStruct` 自己的 USTRUCT 注册必须先发生，本文件才能拿到已注册的类型。
- **callback 参数 `FAngelscriptBinds& Binds`**：所有注册都沿 callback 收到的显式目标执行；不能再通过 ambient current engine 选择写入对象。
- **`ExistingClassForTarget(...)`**：在 `Binds` 的目标 engine 上复用已有 type，不重复注册。这是绑定后置补丁的标准模式。
- **`ImplicitConstructor`**：让"任何 USTRUCT 实例可以隐式构造成 `FAngelscriptAnyStructParameter`"——这是 §六的脚本端 any-struct 参数的关键。
- **exact-result `.NoDiscard()`**：trait 直接链到刚返回的 `FAngelscriptBoundFunction`，编译器会对“构造完丢弃”报警告；它不再依赖全局“上一条绑定”槽位。

### 3.2 11 个方法 + 全局 Make 一览

| AS 签名 | C++ 实现 | 含 wildcard? |
|---------|---------|--------------|
| `bool opEquals(const FInstancedStruct& Other) const` | `FInstancedStruct::operator==` | 否 |
| `void InitializeAs(const ?&in Struct)` | `FAngelscriptInstancedStructHelpers::InitializeAs_Struct` | `?&in` |
| `void InitializeAs(const UScriptStruct StructType)` | `InitializeAs_Default` (inline) | 否 |
| `const FScriptStructWildcard& Get(const UScriptStruct StructType) const no_discard` | `GetMemory` | 类 wildcard 返回 |
| `FScriptStructWildcard& GetMutable(const UScriptStruct StructType) no_discard` | `GetMemory` | 类 wildcard 返回 |
| `void Get(?&out Struct) const`（已弃用） | inline lambda | `?&out` |
| `void Reset()` | `FInstancedStruct::Reset` | 否 |
| `bool Contains(const UScriptStruct StructType) const` | `Contains` (inline) | 否 |
| `bool IsValid() const` | `FInstancedStruct::IsValid` | 否 |
| `UScriptStruct GetScriptStruct() const` | `FInstancedStruct::GetScriptStruct` | 否 |
| `FInstancedStruct Make(const ?&in Struct)`（namespaced） | `FAngelscriptInstancedStructHelpers::Make` | `?&in` |
| `FAngelscriptAnyStructParameter::ctor(const ?&in)` | `ImplicitConstructAnyStruct` | `?&in` |
| `FAngelscriptAnyStructParameter::ctor(const FInstancedStruct&)` | `ImplicitConstructAnyStructFromInstancedStruct` | 否 |

**关键观察**：含 wildcard 的入口（`?&in` 或 `?&out` 或 `FScriptStructWildcard&`）正是"需要在运行时根据脚本传入的 struct 类型决定行为"的入口——它们都通过 §四的 TypeId 桥拿到 `UScriptStruct*`。

### 3.3 注册顺序与依赖

```text
TypeDeclarations    声明 USTRUCT FInstancedStruct 对应的 AS value type
    │                + FAngelscriptAnyStructParameter / FAngelscriptDelegateWithPayload
    │                + FScriptStructWildcard
    ▼
TypeInfrastructure  关联 UScriptStruct*、type adapter 与 TypeId 反查所需数据
    ▼
ManualBindings      Bind_FInstancedStruct 补充 11 个方法
    │                Bind_AngelscriptDelegateWithPayload 补充 4 个方法
    │
    ▼
模块启动            asITypeInfo::SetUserData(UScriptStruct*) 已建好
                     GetUnrealStructFromAngelscriptTypeId(TypeId) 可用
                     脚本可调 InitializeAs(MyStruct) 等
```

为什么 InitializeAs 必须在 `ManualBindings` 阶段：它依赖 §四的 TypeId → UScriptStruct 反查。`TypeDeclarations` 与 `TypeInfrastructure` 需要先注册 USTRUCT，并把 `UScriptStruct*` 写到对应 `asITypeInfo::userData`，TypeId 反查才能拿到非 null 结果。

---

## 四、Wildcard `?&in` / `?&out` 与 TypeId 反查

### 4.1 `?&in` —— 脚本端"任意类型 const 引用入参"

AS 的 `?` 类型是引擎级的"通配类型"——函数声明 `void Foo(const ?&in X)` 表示参数 X 的实际类型由调用点决定，调用时引擎把（`void* DataPtr`, `int TypeId`）作为两个真实参数注入到 C++ 函数：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 函数: FAngelscriptInstancedStructHelpers::InitializeAs_Struct
// ============================================================================
void FAngelscriptInstancedStructHelpers::InitializeAs_Struct(
    FInstancedStruct* Self, void* Data, const int TypeId)
{
    const UStruct* StructDef =
        FAngelscriptEngine::Get().GetUnrealStructFromAngelscriptTypeId(TypeId);
    if (StructDef == nullptr)
    {
        FAngelscriptEngine::Throw("Not a valid USTRUCT");      // ★ AS 端非 USTRUCT
        return;
    }

    const UScriptStruct* ScriptStructDef = Cast<UScriptStruct>(StructDef);
    if (ScriptStructDef == nullptr)
    {
        FAngelscriptEngine::Throw("Not a valid UScriptStruct"); // ★ 是 UClass / UDelegate 等非 ScriptStruct
        return;
    }

    Self->InitializeAs(ScriptStructDef, (uint8*)Data);          // ★ 转交 UE 端
}
```

调用 `FInstancedStruct::InitializeAs(ScriptStruct, Memory)` 会：

1. 比对当前 ScriptStruct 与传入的是否相同 → 相同则就地 `~T()` + placement new；
2. 不同则 `Reset()` 释放原内容 → `Malloc(Size, Alignment)` → `SetStructData(Struct, Memory)` → 用 `Struct->CopyScriptStruct(Memory, Data)` 拷贝（`InitializeAs` 接受 `const uint8*` 时走拷贝构造路径）。

### 4.2 `?&out` —— "拷出到任意类型变量"

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 角色: 把具名 CopyTo callable 与文档、弃用 trait 绑定到同一个 exact result
// ============================================================================
FInstancedStruct_
    .Method(
        "void Get(?&out Struct) const",
        &FAngelscriptFInstancedStructBinds::CopyTo)
    .Documentation(TEXT("Returns a copy of the struct. This getter assumes that all data is valid."))
    .Deprecated("Use Get() or GetMutable() that returns a reference instead of copying");
```

注意末尾链在 exact result 上的 `.Deprecated(...)`——这版"拷出 API"已被弃用，新代码应改用 `Get(StructType) -> const FScriptStructWildcard&`（§五）：原来的 `?&out` 路径每次调用都做 `CopyScriptStruct` 深拷贝，对大 struct 浪费严重；新路径直接返回内部内存的引用，零拷贝。

### 4.3 `GetUnrealStructFromAngelscriptTypeId` 桥

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::GetUnrealStructFromAngelscriptTypeId
// ============================================================================
UStruct* FAngelscriptEngine::GetUnrealStructFromAngelscriptTypeId(int TypeId)
{
    auto* TypeInfo = (asCTypeInfo*)Engine->GetTypeInfoById(TypeId);
    if (TypeInfo == nullptr)              return nullptr;
    if (TypeInfo->GetSubTypeCount() != 0) return nullptr;        // ★ 拒绝模板类型
    void* UserData = (void*)TypeInfo->plainUserData;
    if (UserData == FAngelscriptType::TAG_UserData_Delegate)             return nullptr;
    if (UserData == FAngelscriptType::TAG_UserData_Multicast_Delegate)   return nullptr;
    if (UserData != nullptr && Cast<UDelegateFunction>((UObject*)UserData) != nullptr)
                                          return nullptr;
    if ((TypeInfo->flags & asOBJ_ENUM) != 0) return nullptr;     // ★ 拒绝 enum
    return (UStruct*)UserData;            // ★ 命中：USTRUCT 或 UClass
}
```

工作机制：

- **`Engine->GetTypeInfoById(TypeId)`**：AS TypeId 是引擎内单调递增 ID，反查得到 `asITypeInfo*`。
- **`asITypeInfo::userData`**：在 `Type_BindSystem.md` 中讲过，每个 AS 注册的对象类型可以挂一个 `void*` 用户数据；插件把对应的 `UScriptStruct*`（USTRUCT）或 `UClass*`（UCLASS）写在这里。
- **过滤模板/enum/委托**：`TArray<X>` 等模板类型有 SubType；`enum class` 在 AS 中是 enum 类型；委托被打上特殊 TAG。

调用方再用 `Cast<UScriptStruct>` 把 `UStruct*` 收窄为 `UScriptStruct*`——这一层 Cast 把 UCLASS 排除（UCLASS 也是 UStruct 派生）。最终结果就是脚本侧 `FInstancedStruct.InitializeAs(MyStruct)` 中 `MyStruct` 一定是个真正的 USTRUCT。

### 4.4 调用链路总览

```text
AS:    FInstancedStruct S;
       S.InitializeAs(MyStructLiteral);     ← MyStructLiteral 是 FStructFoo 类型
       │
       │  AS 编译器:
       │    1. 看到 InitializeAs("void f(const ?&in)") 重载
       │    2. 把 MyStructLiteral 取地址 + TypeId 包成两实参
       │
       ▼
C++:   InitializeAs_Struct(Self, &MyStructLiteral, TypeId(FStructFoo))
       │
       │  GetUnrealStructFromAngelscriptTypeId(TypeId):
       │    asITypeInfo[TypeId].userData → UScriptStruct*(FStructFoo)
       │
       ▼
       Self->InitializeAs(FStructFoo::StaticStruct(),
                          (const uint8*)&MyStructLiteral)
       │
       ▼
UE:    FMemory::Malloc(StructureSize, MinAlignment)
       FStructFoo::StaticStruct()->CopyScriptStruct(StructMemory, &MyStructLiteral)
       Self->ScriptStruct  = FStructFoo::StaticStruct()
       Self->StructMemory  = NewMemory
```

---

## 五、`FScriptStructWildcard` 引用返回 + 输出类型决定

### 5.1 `FScriptStructWildcard` 的角色

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/ASStruct.h
// 角色: 占位 USTRUCT，无任何字段
// ============================================================================
USTRUCT(BlueprintType)
struct FScriptStructWildcard
{
    GENERATED_BODY()
};
```

这是一个**没有字段的占位 USTRUCT**——它在 AS 端被注册，但脚本作者从不直接构造它，它只出现在两类签名中：

- 返回值类型：`const FScriptStructWildcard& Get(const UScriptStruct StructType) const`
- 返回值类型：`FScriptStructWildcard& GetMutable(const UScriptStruct StructType)`

它的"通配"性质通过下一节 exact-result `.DeterminesOutputType(0)` 触发——AS 编译器在编译期把返回类型 narrow 成第 0 号实参所代表的具体 USTRUCT。

### 5.2 `GetMemory` 的实现

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 函数: FAngelscriptInstancedStructHelpers::GetMemory
// ============================================================================
static FScriptStructWildcard InstancedStructEmptyWildcard;     // ★ 静态空对象兜底
FScriptStructWildcard& FAngelscriptInstancedStructHelpers::GetMemory(
    FInstancedStruct* Self, const UScriptStruct* StructType)
{
    if (!Self->IsValid())
    {
        FAngelscriptEngine::Throw("Source is empty or not valid. "
            "Check `IsValid()` before trying to `Get()` the underlying struct.");
        return InstancedStructEmptyWildcard;             // ★ 抛异常但仍返回引用
    }
    if (StructType != Self->GetScriptStruct())
    {
        const FString Debug = FString::Printf(
            TEXT("Mismatching types. FInstancedStruct contains a %s but tried to Get a %s."),
            *Self->GetScriptStruct()->GetStructCPPName(),
            *StructType->GetStructCPPName());
        FAngelscriptEngine::Throw(TCHAR_TO_ANSI(*Debug));
        return InstancedStructEmptyWildcard;
    }
    return *(FScriptStructWildcard*)Self->GetMemory();    // ★ reinterpret 内部内存
}
```

四点细节：

- **校验时 `==` 不是 `IsChildOf`**：`Get(FParentStruct)` 在装的是 `FChildStruct` 时**会**抛异常——AS 端 InstancedStruct 不允许"父类型读子类型"，必须精确匹配。这与 UE C++ 端 `FInstancedStruct::Get<T>()` 的 `IsChildOf` 校验**不一致**——是 AS 实现的简化决定。
- **静态 `InstancedStructEmptyWildcard`**：抛异常路径不能 abort，必须返回有效引用；用一个全局空 wildcard 占位。脚本侧若不响应异常继续访问，会读到这个空对象的"全 0 字段"——再访问字段会触发后续异常或读到默认值。
- **reinterpret 内部内存**：`Self->GetMemory()` 返回 `const uint8*`，强转成 `FScriptStructWildcard*`。后续靠 §5.3 的 narrow 让脚本编译器用正确字段偏移访问。
- **`no_discard`**：让"调完不用返回值"产生编译警告，提醒脚本作者别把宝贵的"零拷贝引用"丢弃。

### 5.3 exact-result `.DeterminesOutputType(0)` —— 编译期类型 narrow

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 角色: 注册 Get / GetMutable 时 narrow 返回类型
// ============================================================================
FInstancedStruct_
    .Method(
        "const FScriptStructWildcard& Get(const UScriptStruct StructType) const no_discard",
        FUNC(FAngelscriptFInstancedStructBinds::GetMemory))
    .Documentation(TEXT("Returns struct data of a particular type. Throws on a type mismatch."))
    .DeterminesOutputType(0);   // ★

FInstancedStruct_
    .Method(
        "FScriptStructWildcard& GetMutable(const UScriptStruct StructType) no_discard",
        FUNC(FAngelscriptFInstancedStructBinds::GetMemory))
    .Documentation(TEXT("Returns mutable struct data of a particular type. Throws on a type mismatch."))
    .DeterminesOutputType(0);   // ★
```

`.DeterminesOutputType(0)` 告诉 AS 编译器：返回类型由第 0 号实参（`StructType`）决定。它直接修改 `Method(...)` 返回的准确 `FAngelscriptBoundFunction`，即使多个 engine 或多条注册交错也不会写到错误函数。在脚本里写：

```angelscript
FInstancedStruct S;
S.InitializeAs(FStructFoo());
const FStructFoo& Foo = S.Get(FStructFoo);     // ← 编译器把返回类型 narrow 成 FStructFoo&
Foo.SomeField;                                   // 直接按 FStructFoo 字段偏移访问
```

`FStructFoo` 在脚本端实际上是被解释为 `TSubclassOf<UObject>` 风格的 `__StaticType_FStructFoo` 全局值——`StaticClass()` / `StaticStruct()` 被解析回到 `UScriptStruct*` 引用（`Type_StructGeneration.md` 详述这一路径）。

实现机制是 `asCScriptFunction::determinesOutputTypeArgumentIndex` 字段：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: FAngelscriptBoundFunction::DeterminesOutputType
// ============================================================================
FAngelscriptBoundFunction& FAngelscriptBoundFunction::DeterminesOutputType(
    const int32 ArgumentIndex)
{
    if (asCScriptFunction* Function = static_cast<asCScriptFunction*>(GetFunction()))
    {
        Function->determinesOutputTypeArgumentIndex = static_cast<int8>(ArgumentIndex);
    }
    return *this;
}
```

AS 编译器在解析方法调用时检查这个字段：若非 -1，则用第 N 号实参解析出的具体类型（这里是 `UScriptStruct*` 指向的实际 USTRUCT）替换返回值的"通配类型"。这套机制不止为 `FInstancedStruct` 服务——`Bind_UObject.cpp` 中的 `NewObject` / `Bind_AActor.cpp` 中的 `SpawnActor` 也用它把 "UObject" 收窄成 "T"。

---

## 六、`FAngelscriptAnyStructParameter` —— 脚本端 any-struct 参数

### 6.1 USTRUCT 定义

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptAnyStructParameter.h
// 性质: 公开 USTRUCT，承载任意 struct 作 UFUNCTION 参数
// ============================================================================
USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptAnyStructParameter
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Struct Data")
    FInstancedStruct InstancedStruct;
};
```

它就是 `FInstancedStruct` 的薄包装——多了一个 USTRUCT 标识让 AS 反射桥能识别它，多了一个 `BlueprintType` 让蓝图也能用。它存在的理由：直接让一个 UFUNCTION 参数声明为 `FInstancedStruct` 时，蓝图侧表现差强人意（pin 不展开为 struct picker）；包成 `FAngelscriptAnyStructParameter` 后蓝图节点可以正确展示。

### 6.2 隐式构造的两条路径

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 角色: FAngelscriptAnyStructParameter 的两个 ImplicitConstructor
// ============================================================================
FAngelscriptAnyStructParameter_
    .ImplicitConstructor(
        "void f(const ?&in Struct)",
        FUNC(FAngelscriptFInstancedStructBinds::ImplicitConstructAnyStruct))
    .NoDiscard();

FAngelscriptAnyStructParameter_
    .ImplicitConstructor(
        "void f(const FInstancedStruct& Struct)",
        FUNC(FAngelscriptFInstancedStructBinds::ImplicitConstructAnyStructFromInstancedStruct))
    .NoDiscard();
```

让脚本作者既能从**任意 USTRUCT** 隐式构造（`?&in` wildcard），也能从已有 `FInstancedStruct` 隐式构造。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
// 函数: FAngelscriptInstancedStructHelpers::ImplicitConstructAnyStruct
// ============================================================================
void FAngelscriptInstancedStructHelpers::ImplicitConstructAnyStruct(
    FAngelscriptAnyStructParameter* Self, void* Data, const int TypeId)
{
    new (Self) FAngelscriptAnyStructParameter();           // ★ placement new 先建空对象

    const UStruct* StructDef =
        FAngelscriptEngine::Get().GetUnrealStructFromAngelscriptTypeId(TypeId);
    // ... 双层 Cast 校验 ...
    Self->InstancedStruct.InitializeAs(ScriptStructDef, (uint8*)Data);  // ★ 转交内部
}
```

### 6.3 在 UFUNCTION 参数中的样态

```angelscript
// ============================================================================
// 文件: 任意 .as
// 角色: 脚本端 any-struct 参数 UFUNCTION
// ============================================================================
UCLASS()
class AMyActor : AActor
{
    UFUNCTION()
    void DispatchPayload(FAngelscriptAnyStructParameter Payload)
    {
        if (Payload.InstancedStruct.IsValid())
        {
            UScriptStruct ScriptStruct = Payload.InstancedStruct.GetScriptStruct();
            Print(f"Got struct: {ScriptStruct.GetName()}");
        }
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        FStructFoo Foo;
        Foo.SomeField = 42;

        DispatchPayload(Foo);                         // ★ 隐式构造路径
        DispatchPayload(FInstancedStruct::Make(Foo)); // ★ 显式 FInstancedStruct
    }
}
```

第一个 `DispatchPayload(Foo)` 调用会触发 `?&in` ImplicitConstructor：AS 编译器把 `Foo` 包成 `(void* &Foo, TypeId(FStructFoo))`，调用 `ImplicitConstructAnyStruct(NewPayload, &Foo, TypeId)` 在调用栈上构造 `FAngelscriptAnyStructParameter`，再以引用传给 `DispatchPayload`。

---

## 七、`FAngelscriptDelegateWithPayload` —— FInstancedStruct 作 payload 复用

### 7.1 USTRUCT 定义

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptDelegateWithPayload.h
// 性质: 公开 USTRUCT，单参数 delegate 自带 payload 字段
// ============================================================================
USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptDelegateWithPayload
{
    GENERATED_BODY()

    UPROPERTY(BlueprintReadWrite, Category = "Delegate")
    FInstancedStruct Payload;                    // ★ 任意 payload struct

    UPROPERTY(BlueprintReadWrite, Category = "Delegate")
    TWeakObjectPtr<UObject> Object;

    UPROPERTY(BlueprintReadWrite, Category = "Delegate")
    FName FunctionName;

    bool IsBound() const;
    void ExecuteIfBound() const;
    void BindUFunction(UObject* Object, FName FunctionName);
    void BindUFunctionWithPayload(UObject* Object, FName FunctionName,
                                  void* PayloadPtr, int PayloadScriptTypeId);
    void Reset();
    static UScriptStruct* GetBoxedPrimitiveStructFromTypeId(int TypeId);
};
```

这是一个"一参数 dynamic delegate"——绑定的目标 UFUNCTION 接受一个参数，参数实际值由 `Payload` 这个 `FInstancedStruct` 携带。

### 7.2 BindWithPayload —— 三层兼容性校验

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp
// 函数: FAngelscriptDelegateWithPayload::BindUFunctionWithPayload（节选）
// ============================================================================
UScriptStruct* StructType = Cast<UScriptStruct>(
    FAngelscriptEngine::Get().GetUnrealStructFromAngelscriptTypeId(PayloadScriptTypeId));
if (StructType == nullptr)
{
    StructType = FAngelscriptDelegateWithPayload::GetBoxedPrimitiveStructFromTypeId(
        PayloadScriptTypeId);                                    // ★ 基本类型 boxed
}
if (StructType == nullptr) { Throw("Invalid payload type"); return; }

// ... 校验 InObject / FindFunction(FunctionName) / NumParms == 1 ...

bool bSignatureMismatch = false;
FStructProperty* StructProp = CastField<FStructProperty>(Function->PropertyLink);
if (StructProp == nullptr && Function->PropertyLink == nullptr)
{
    bSignatureMismatch = true;
}
else if (StructProp == nullptr)
{
    switch (PayloadScriptTypeId & asTYPEID_MASK_SEQNBR)         // ★ 基本类型逐项校验
    {
    case asTYPEID_BOOL:    bSignatureMismatch = !Function->PropertyLink->IsA<FBoolProperty>();   break;
    case asTYPEID_UINT8:   bSignatureMismatch = !Function->PropertyLink->IsA<FByteProperty>();   break;
    case asTYPEID_INT32:   bSignatureMismatch = !Function->PropertyLink->IsA<FIntProperty>();    break;
    case asTYPEID_FLOAT32: bSignatureMismatch = !Function->PropertyLink->IsA<FFloatProperty>();  break;
    // ... 其它基本类型 ...
    }
}
else if (StructProp->Struct != StructType) { bSignatureMismatch = true; }

if (Function->NumParms != 1 || bSignatureMismatch || ...) { Throw("..."); return; }

Payload.InitializeAs(StructType, (const uint8*)PayloadPtr);     // ★ 落库
Object       = InObject;
FunctionName = InFunctionName;
```

`GetBoxedPrimitiveStructFromTypeId` 把 `int / float / bool` 等基本类型映射到对应的 `FAngelscriptBoxedInt32 / FAngelscriptBoxedFloat / FAngelscriptBoxedByte` USTRUCT——这是为了让"一参数 delegate" 也能绑到接受基本类型参数的 UFUNCTION：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptDelegateWithPayload.h
// 性质: 6 个 boxed primitive USTRUCT
// ============================================================================
USTRUCT(BlueprintType, Meta = (NoAutoAngelscriptBind))
struct FAngelscriptBoxedByte    { GENERATED_BODY() UPROPERTY() uint8 Value = 0; };
USTRUCT(BlueprintType, Meta = (NoAutoAngelscriptBind))
struct FAngelscriptBoxedShort   { GENERATED_BODY() UPROPERTY() uint16 Value = 0; };
USTRUCT(BlueprintType, Meta = (NoAutoAngelscriptBind))
struct FAngelscriptBoxedInt32   { GENERATED_BODY() UPROPERTY() uint32 Value = 0; };
// ... Int64 / Float / Double ...
```

`NoAutoAngelscriptBind` 元数据让自动绑定跳过这些 USTRUCT——它们是纯 C++ 内部使用的"装箱容器"，脚本作者不直接看到。

### 7.3 ExecuteIfBound —— ProcessEvent 复用 Memory

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp
// 函数: FAngelscriptDelegateWithPayload::ExecuteIfBound
// ============================================================================
void FAngelscriptDelegateWithPayload::ExecuteIfBound() const
{
    if (!Object.IsValid() || FunctionName.IsNone()) return;
    UFunction* Function = Object->FindFunction(FunctionName);
    if (Function == nullptr) return;

    Object->ProcessEvent(Function,
        Payload.IsValid() ? (void*)Payload.GetMemory() : nullptr);   // ★ 直接使用内部 Memory
}
```

**关键**：调 `ProcessEvent(Function, Parms)` 时，`Parms` 应当是按 UFunction 参数布局排列的 struct——`Payload.GetMemory()` 拿到的是裸字节，正好被解释为"目标函数的 NumParms == 1 时的单参数布局"。这要求 §7.2 的校验严格——StructType 与函数 PropertyLink 必须精确匹配，否则 ProcessEvent 会读越界。

---

## 八、UPROPERTY 与编辑器集成

### 8.1 反射桥：`FStructProperty(Struct=FInstancedStruct)`

`FInstancedStruct` 在 UE 反射中**没有自定义 FProperty 子类**——它是普通 USTRUCT，由通用 `FStructProperty` 承载，`FStructProperty::Struct` 指向 `FInstancedStruct::StaticStruct()`。这与 `TSubclassOf` 的 `FClassProperty + CPF_UObjectWrapper` 不同。

```cpp
// ============================================================================
// 文件: AngelscriptTest/Shared/AngelscriptReflectiveAccess.h
// 函数: InspectInstancedStructByPath（节选）
// ============================================================================
const FStructProperty* StructProp = CastField<const FStructProperty>(Leaf.GetProperty());
// ... 校验 StructProp 非 null ...

if (!Test.TestTrue(
        *FString::Printf(TEXT("Property '%.*s' should be backed by FInstancedStruct"),
            Path.Len(), Path.GetData()),
        StructProp->Struct == FInstancedStruct::StaticStruct()))    // ★ 反射判定
{
    return false;
}

const FInstancedStruct* Instanced =
    static_cast<const FInstancedStruct*>(Leaf.GetPropertyAddress());
return Fn(Instanced->GetScriptStruct(), Instanced->GetMemory());
```

判定逻辑：先看是不是 `FStructProperty`，再看 `Struct` 字段等于 `FInstancedStruct::StaticStruct()`——双层确认才能确定这是个 `FInstancedStruct` UPROPERTY。

### 8.2 在脚本中的声明

```angelscript
// ============================================================================
// 文件: 任意 .as
// 角色: UPROPERTY FInstancedStruct 字段
// ============================================================================
UCLASS()
class AMyConfigActor : AActor
{
    UPROPERTY(EditAnywhere, Category = "Config")
    FInstancedStruct Effect;             // 编辑器面板出 ScriptStruct picker + 嵌入字段编辑

    UPROPERTY(EditAnywhere, Category = "Config", meta = (BaseStruct = "/Script/MyModule.FStructFooBase"))
    FInstancedStruct ConstrainedEffect;  // ScriptStruct picker 限定为 FStructFooBase 派生
}
```

第二种声明利用 `meta = (BaseStruct = "...")`——`StructUtils` 插件提供的编辑器 widget 会读这个 metadata 限定下拉框选项。

### 8.3 编辑器 widget

`StructUtils` 插件在 `StructUtilsEditor` 模块（独立 plugin）中提供 `SInstancedStructDetails`——当编辑器看到 `FStructProperty` + `FInstancedStruct::StaticStruct()` 时自动 dispatch 到这个 widget：

```text
编辑器面板:
  Effect:                   [▼ FGameplayEffect_Damage    ]    ← ScriptStruct 选择器
    Damage:                 25.0
    DamageType:             Physical
  ConstrainedEffect:        [▼ FStructFooBase 派生项... ]    ← BaseStruct 限制
    ...
```

选择不同 ScriptStruct 时编辑器会触发 `FInstancedStruct::Reset()` + `InitializeAs(NewStruct)`，并在 PropertyEditor 中重新展开新 struct 的字段。

### 8.4 反射读取 helper（测试侧）

```cpp
// ============================================================================
// 文件: AngelscriptTest/Shared/AngelscriptReflectiveAccess.h
// 函数: GetInstancedStructByPath（模板）
// ============================================================================
template <typename StructType>
bool GetInstancedStructByPath(FAutomationTestBase& Test, UObject* Object,
                              FStringView Path, StructType& OutValue)
{
    return InspectInstancedStructByPath(
        Test, Object, Path,
        [&](const UScriptStruct* RuntimeStruct, const void* Memory) -> bool
        {
            const UScriptStruct* Expected = TBaseStructure<StructType>::Get();
            if (!Test.TestTrue(..., RuntimeStruct->IsChildOf(Expected))) return false;
            // ★ 这里用 IsChildOf, 与 GetMemory 的 == 校验不一致
            OutValue = *static_cast<const StructType*>(Memory);
            return true;
        });
}
```

注意这里的校验是 `IsChildOf`——测试侧 helper 允许"父类型读子类型"，而 §五的 `GetMemory` 用 `==` 精确匹配。这种不一致是**已知设计偏差**：`GetMemory` 走脚本快路径，固定 ScriptStruct 等价是为了让脚本作者自己处理多态；测试侧 helper 走反射慢路径，可以放宽。

---

## 九、序列化、网络化与 cooked build

### 9.1 标准序列化路径（`Serialize`）

`FInstancedStruct` 在 `TStructOpsTypeTraits` 里声明了 `WithSerializer = true`：

```cpp
bool FInstancedStruct::Serialize(FArchive& Ar, UStruct* DefaultsStruct, const void* Defaults)
{
    if (Ar.IsLoading())
    {
        FString StructPath;
        Ar << StructPath;                         // ★ 类型路径名
        if (StructPath.IsEmpty())
        {
            Reset();
            return true;
        }
        UScriptStruct* SS = LoadObject<UScriptStruct>(nullptr, *StructPath);
        InitializeAs(SS);                         // ★ 默认初始化
        SS->SerializeBin(Ar, GetMutableMemory()); // ★ 二进制序列化字段
    }
    else
    {
        FString StructPath = ScriptStruct ? ScriptStruct->GetPathName() : FString();
        Ar << StructPath;
        if (ScriptStruct) ScriptStruct->SerializeBin(Ar, StructMemory);
    }
    return true;
}
```

序列化时**先写类型路径，再写值**——加载时根据路径动态 `LoadObject` 出 UScriptStruct，再按其布局反序列化字节。

**Cooked build 影响**：

- 类型路径必须在 cooked package 中能 resolve——若 `FStructFoo` 是脚本类，cook 时必须把对应 `UASStruct`（脚本生成的 USTRUCT）打包；
- 升级版本中删了某 USTRUCT，旧存档读到这条记录会 `LoadObject` 失败 → `InitializeAs(nullptr)` → 字段为空。

### 9.2 网络化（`NetSerialize`）

```cpp
bool FInstancedStruct::NetSerialize(FArchive& Ar, UPackageMap* Map, bool& bOutSuccess)
{
    if (NetSerializeScriptStructDelegate.IsBound())
        return NetSerializeScriptStructDelegate.Execute(*this, Ar, Map);
    // ... 默认实现：写 ScriptStruct path + Map->SerializeObject + 字段二进制 ...
}
```

委托 `NetSerializeScriptStructDelegate` 让上层（如 GAS / Mass）可以注入定制网络协议（区分 reliable / unreliable）。AS 插件不主动注入这个委托。

### 9.3 文本导入导出（`ExportTextItem` / `ImportTextItem`）

支持`.ini` / `.uasset` 文本表示——这条路径让蓝图编辑器面板的"Copy / Paste struct"功能在 `FInstancedStruct` 上工作。

### 9.4 GC（`AddStructReferencedObjects`）

```cpp
void FInstancedStruct::AddStructReferencedObjects(FReferenceCollector& Collector)
{
    if (ScriptStruct && StructMemory)
    {
        // 让 GC 遍历内部 struct 引用的所有 UObject
        Collector.AddReferencedObjects(ScriptStruct, StructMemory);
    }
}
```

这一段非常关键——它让 `FInstancedStruct` 内部承载的 struct 中的 `UObject*` / `UClass*` / `TObjectPtr<X>` 等 GC 强引用都能被 GC 遍历到，避免承载的对象被误回收。

---

## 十、与 `TSubclassOf` / `TWeakObjectPtr` 的对照

| 维度 | `FInstancedStruct` | `TSubclassOf<T>` | `TWeakObjectPtr<T>` |
|------|-------------------|------------------|---------------------|
| 物理布局 | `UScriptStruct* + uint8*` (16-24B) | `UClass*` (8B) | `int32 ObjectIndex + int32 Serial` (8B) |
| 携带数据 | ✓ struct 实例 | ✗ 仅类型标签 | ✗ 仅对象引用 |
| 持有 GC | ✓ 内部对象引用 | ✓ UClass 弱引用（实际常驻） | ✗ 弱引用 |
| 校验时机 | 运行时 `==` ScriptStruct | 运行时 `IsChildOf(T)` | 运行时 `IsValid` 防 GC |
| AS 注册 | 普通 USTRUCT + 后置 11 方法 | 模板值类型 + 两阶段 | 模板值类型 + 两阶段 |
| FProperty 子类 | `FStructProperty` (Struct=FInstancedStruct) | `FClassProperty` (+CPF_UObjectWrapper, MetaClass) | `FWeakObjectProperty` |
| 模板特化 | ✗ 单一 wildcard 路径 | ✓ 每个 T 独立类型 | ✓ 每个 T 独立类型 |
| 序列化策略 | path + binary | UClass path | ObjectIndex+Serial |
| 编辑器 widget | StructPicker + 嵌入字段 | ClassPicker (MetaClass 过滤) | ObjectPicker |
| 用例 | 数据驱动配置, payload | 类型槽位 (SpawnActor) | 对象弱引用 (Cache, Avoid Retain) |
| AS 端访问开销 | TypeId → UScriptStruct → Memory cast | 单指针读取 | Index 解引用 |

**核心区分**：`TSubclassOf<T>` 是"类型槽位"（只装类不装数据）；`FInstancedStruct` 是"类型 + 数据"复合（既装类型也装实例）；`TWeakObjectPtr<T>` 是"对象引用"（既不装类型也不装数据，只装一个安全引用）。

---

## 十一、限制与避坑

### 11.1 已知 bug：AS 声明的 USTRUCT 装入 FInstancedStruct 在 BeginPlay 崩溃

```cpp
// ============================================================================
// 文件: AngelscriptTest/Template/Template_ReflectionAccess.cpp
// 节选自代码注释 (line ~1413-1421)
// ============================================================================
// NOTE on FInstancedStruct:
//   Wrapping an AS-declared USTRUCT into FInstancedStruct triggers a crash
//   inside FASStructOps::Construct during BeginPlay (the AS struct's
//   FASStructOps is not live at the point UScriptStruct::InitializeStruct
//   walks into it). Wrapping a raw C++ USTRUCT like FVector throws
//   "Not a valid USTRUCT" because AS registers math types without a
//   UScriptStruct peer for the AS TypeId <-> UScriptStruct lookup.
//   We therefore omit FInstancedStruct from this test matrix - leave it to a
//   targeted test that exercises AS FInstancedStruct through AS-only helpers.
```

这是当前 fork 的**两个边界缺陷**：

1. **AS USTRUCT × FInstancedStruct**：脚本端定义 `USTRUCT()` 装入 `FInstancedStruct` 后，BeginPlay 阶段调用 `FInstancedStruct::InitializeAs` 会路由到 `FASStructOps::Construct`——但脚本类的 `FASStructOps` 注册时机晚于 BeginPlay 启动，导致取空指针 + 崩溃。
2. **AS 端数学 struct（FVector / FRotator / ...）× FInstancedStruct**：这些类型 AS 端注册时**没有**关联到 `UScriptStruct*`（AS 在 ThirdParty 初始化里把它们当作纯 AS 值类型），`GetUnrealStructFromAngelscriptTypeId` 返回 nullptr → "Not a valid USTRUCT"。

**当前可用的安全用法**：

- C++ 端定义的 USTRUCT（`FStructFoo` 在 `.h` 中 `GENERATED_BODY()` + UHT 处理）→ 装入 `FInstancedStruct` ✓
- 脚本端只调 `IsValid` / `Reset` / `GetScriptStruct`（不实际写入）→ ✓
- 脚本端用 `FInstancedStruct::Make(SomeCppStruct)` → ✓

**目前不可用的**：

- AS 端 `USTRUCT()` 类型作 payload；
- 数学类型 `FVector` 等装入 FInstancedStruct（应改装入 boxed primitive struct 或自定义 USTRUCT）。

### 11.2 类型错配：`==` 而非 `IsChildOf`

```angelscript
FInstancedStruct S;
S.InitializeAs(FStructDerived());

const FStructBase& Base = S.Get(FStructBase);    // ✗ 抛 "Mismatching types"
                                                  //   FInstancedStruct contains a FStructDerived
                                                  //   but tried to Get a FStructBase
```

AS 端 `Get(StructType)` 的 ScriptStruct 比较是精确 `==`，**不**走 `IsChildOf`。要按基类访问派生 struct 时只能用 `Contains` 验证后用 `GetScriptStruct->IsChildOf` 自行判断，再 reinterpret cast——但这种手工跨层的写法在 AS 端罕见且危险。

### 11.3 未 Init 直接 Get

```angelscript
FInstancedStruct S;                              // ScriptStruct == null, IsValid == false
const FStructFoo& Foo = S.Get(FStructFoo);       // ✗ 抛 "Source is empty or not valid"
                                                  //   返回静态空 wildcard
Foo.SomeField;                                    // 读到默认 0 / 空字符串等
```

正确流程：先 `IsValid()` / `Contains(StructType)` 校验，再 `Get`。

### 11.4 已弃用的 `Get(?&out)`

```angelscript
FStructFoo Out;
S.Get(Out);                                      // ⚠ 编译期 deprecation 警告
                                                  //   "Use Get() or GetMutable() that returns a reference instead of copying"
```

这条 API 留作历史兼容，但每次都做 `CopyScriptStruct` 深拷贝。新代码用 `const FStructFoo& F = S.Get(FStructFoo);` 零拷贝。

### 11.5 ProcessEvent 与 Payload Memory 布局对齐

`FAngelscriptDelegateWithPayload::ExecuteIfBound` 用 `Payload.GetMemory()` 直接喂给 ProcessEvent——这要求 BindWithPayload 时校验过的 StructType 与目标 UFunction 的 PropertyLink **精确匹配**。任何 AS 端绕过 `BindUFunctionWithPayload` 直接给 `Payload` 赋值的写法都可能让 ProcessEvent 读越界。脚本作者应当只通过暴露的 `BindWithPayload` 入口操作。

### 11.6 `?&in` wildcard 不支持模板类型

```angelscript
TArray<int> A;
FInstancedStruct S;
S.InitializeAs(A);            // ✗ GetUnrealStructFromAngelscriptTypeId 拒绝 SubTypeCount != 0
                              //   抛 "Not a valid USTRUCT"
```

`GetUnrealStructFromAngelscriptTypeId` 第一道关卡 `if (TypeInfo->GetSubTypeCount() != 0) return nullptr;` 拒绝所有 AS 模板类型——`TArray<X>` / `TMap<K,V>` / `TSubclassOf<T>` 等都不能直接装进 `FInstancedStruct`（要装也得包成 USTRUCT 字段再装）。

### 11.7 调试器显示

`FInstancedStruct` 在 DAP 调试器中显示为：

```text
S:                              ▼ FInstancedStruct = { ScriptStruct=FStructFoo }
  ScriptStruct:                   FStructFoo (UScriptStruct)
  ► Memory:                       (展开看实际字段)
  IsValid:                        true
```

由于 `FInstancedStruct` 走通用 USTRUCT 反射展开，调试器靠 `FInstancedStruct::FindInnerPropertyInstance` 找到内部字段——这套机制让 DAP 能把 Memory 解释为对应 ScriptStruct 的字段。

---

## 附录 A：API 速查

### 脚本端方法

| AS 签名 | 语义 | 错误模式 |
|---------|------|---------|
| `FInstancedStruct()` | 默认构造空（不抛） | — |
| `FInstancedStruct(const FInstancedStruct&)` | 深拷贝（C++ 默认拷贝构造） | — |
| `bool opEquals(const FInstancedStruct&) const` | 类型同 + 内容深比较 | — |
| `void InitializeAs(const ?&in Struct)` | 通配 USTRUCT 落入 | 非 USTRUCT 抛 "Not a valid USTRUCT" |
| `void InitializeAs(const UScriptStruct StructType)` | 默认构造该类型 struct | StructType 为 null 时崩溃 |
| `const FScriptStructWildcard& Get(const UScriptStruct) const no_discard` | 零拷贝引用读 | `==` 不匹配抛 "Mismatching types" |
| `FScriptStructWildcard& GetMutable(const UScriptStruct) no_discard` | 零拷贝引用写 | 同上 |
| `void Get(?&out Struct) const`（已弃用） | 深拷贝读 | 同上 |
| `void Reset()` | 释放 + 置 null | — |
| `bool Contains(const UScriptStruct) const` | `IsValid && ScriptStruct == StructType` | — |
| `bool IsValid() const` | `Memory != null && ScriptStruct != null` | — |
| `UScriptStruct GetScriptStruct() const` | 取 `ScriptStruct` | 未 Init 时返回 null |
| `FInstancedStruct::Make(const ?&in)` | 一步构造 | 非 USTRUCT 抛 |

### 反射桥（FStructProperty）

| 字段 | 取值 |
|------|------|
| `FProperty 类` | `FStructProperty` |
| `FStructProperty::Struct` | `FInstancedStruct::StaticStruct()` |
| `PropertyFlags` | 普通 USTRUCT 字段位（无 CPF_UObjectWrapper） |

### 关键内部函数

| 函数 | 文件 | 角色 |
|------|------|------|
| `GetUnrealStructFromAngelscriptTypeId` | `Core/AngelscriptEngine.cpp` | TypeId → `UStruct*`，过滤模板/enum/委托 |
| `FAngelscriptInstancedStructHelpers::InitializeAs_Struct` | `Bind_FInstancedStruct.cpp` | wildcard 入参实现 |
| `FAngelscriptInstancedStructHelpers::GetMemory` | `Bind_FInstancedStruct.cpp` | wildcard 引用返回 |
| `FAngelscriptInstancedStructHelpers::Make` | `Bind_FInstancedStruct.cpp` | 静态构造 |
| `FAngelscriptInstancedStructHelpers::ImplicitConstructAnyStruct` | `Bind_FInstancedStruct.cpp` | AnyStructParameter 隐式构造 |

### 复用 FInstancedStruct 的公开类型

| USTRUCT | 字段 | 用途 |
|---------|------|------|
| `FAngelscriptAnyStructParameter` | `InstancedStruct` | UFUNCTION 任意 struct 参数 |
| `FAngelscriptDelegateWithPayload` | `Payload` | 单参数 dynamic delegate payload |

---

## 附录 B：避坑清单

1. **类型校验是 `==`**：`Get(BaseStruct)` 在 InstancedStruct 装的是派生类时**会**抛异常，不走 `IsChildOf`。需要多态访问时先 `Contains` 加自定义 reinterpret。
2. **AS USTRUCT 不可装 FInstancedStruct**：脚本端定义的 `USTRUCT()` 装入后 BeginPlay 调用会因 `FASStructOps` 未就绪而崩溃。使用前确认 USTRUCT 是 C++ 端定义的。
3. **AS 数学类型不可装**：`FVector` / `FRotator` 等 AS 端**没有** UScriptStruct 关联，会抛 "Not a valid USTRUCT"。
4. **未 Init 直接 Get 不会崩**：会抛异常 + 返回静态空 wildcard。脚本作者要么响应异常，要么先 `IsValid`。
5. **`Get(?&out)` 已弃用**：编译期 deprecation 警告——新代码用零拷贝引用形 `Get(StructType)` / `GetMutable(StructType)`。
6. **模板类型无法直接装入**：`TArray<X>` / `TMap<K,V>` 等需要先包成 USTRUCT 字段再装。
7. **`InitializeAs(UScriptStruct)` 零参数版本不查 null**：传 null 直接 crash。需要在脚本侧自己 `if (StructType.IsValid())`。
8. **delegate payload 必须经 BindWithPayload 入口**：直接给 `FAngelscriptDelegateWithPayload::Payload` 赋值会绕过签名校验，触发 ProcessEvent 越界。
9. **StructUtils 是公开依赖**：任何依赖 `AngelscriptRuntime` 的下游模块都隐式依赖 `StructUtils`——`Plan_StructUtilsMigration.md` 计划在未来降级为 private，但当前为 public。
10. **序列化先写类型路径**：cook 时必须保证所有用过的 ScriptStruct 都会被打包；删除 ScriptStruct 后旧存档会读到 null InstancedStruct。
11. **GC 已正确处理**：`AddStructReferencedObjects` 让内部 struct 中的 `UObject*` 引用可达——可放心存放含 `UObject` 字段的 struct。
12. **FAngelscriptAnyStructParameter 是参数包装而非通用容器**：它存在的目的是 UFUNCTION 参数蓝图友好；普通 AS 字段直接用 `FInstancedStruct` 即可。
13. **boxed primitive 有专属 USTRUCT**：`FAngelscriptBoxedInt32` 等 6 个内部包装类型；这些是 `BindWithPayload` 处理基本类型 payload 时透明使用的，脚本作者无须关心。

---

## 小结

- `FInstancedStruct` = "**类型擦除 USTRUCT 容器**" —— 物理上 `UScriptStruct* + uint8*`，逻辑上"任意 USTRUCT 实例"。它由 UE `StructUtils` 模块/插件提供（5.0–5.4 plugin / 5.5+ CoreUObject 头文件 + StructUtils 模块），AS 插件通过 `Build.cs::PublicDependencyModuleNames` + `.uplugin::Plugins` 双重启用。
- AS 实现采用**普通 USTRUCT + 后置方法补充**模式：`Bind_FInstancedStruct.cpp` 的 `ManualBindings` callback 接收显式 `FAngelscriptBinds& Binds`，注册 11 个方法 + 1 个 namespaced `Make`；所有"读写需类型信息"的入口靠 AS 通配参数 `?&in` / `?&out` 透传 `(void*, TypeId)`，配合 `GetUnrealStructFromAngelscriptTypeId(TypeId)` 反查 `UScriptStruct*`。
- `FScriptStructWildcard` + exact-result `.DeterminesOutputType(0)` 让 `Get(StructType)` / `GetMutable(StructType)` 在编译期把"占位空 USTRUCT 引用"narrow 成具体 struct 类型——零拷贝读写的关键机制。
- `FAngelscriptAnyStructParameter`（UFUNCTION 任意 struct 入参 + ImplicitConstructor `?&in` 双路径）与 `FAngelscriptDelegateWithPayload`（payload 字段 + ProcessEvent 直喂内部 Memory + boxed primitive 兼容）是 FInstancedStruct 在公开 API 中的两个主要复用点。
- 反射桥是普通 `FStructProperty(Struct=FInstancedStruct::StaticStruct())`——不像 `TSubclassOf` 有 `CPF_UObjectWrapper` 标志，`FInstancedStruct` 的"类型擦除"性质完全发生在数据布局而非 FProperty 元数据层；编辑器 `StructUtilsEditor` 模块的 `SInstancedStructDetails` widget 负责"动态结构选择 + 嵌入字段"的面板表现。
- 当前 fork 存在两条已知边界：① AS 脚本端 USTRUCT 装入 FInstancedStruct 会因 `FASStructOps` 未就绪在 BeginPlay 崩溃；② AS 端数学类型（FVector 等）不能装入（无 UScriptStruct 关联）。两者都在 `Template_ReflectionAccess.cpp` 注释中显式记录。
- 与 `TSubclassOf<T>` 的对照核心：`TSubclassOf` 是"只装类不装数据"的类型槽位；`FInstancedStruct` 是"类型 + 数据"复合容器——前者校验子类（`IsChildOf`），后者校验同类（`==`），用于场景互斥不可替代。

---

## 修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-05-24 | 首版：基于 `Bind_FInstancedStruct.cpp`（173 行，11 方法 + Make）+ `Bind_Helpers.h`（`FAngelscriptInstancedStructHelpers` / `FScriptStructType`）+ `AngelscriptAnyStructParameter.h`（公开 USTRUCT 包装）+ `AngelscriptDelegateWithPayload.h/.cpp`（payload 复用 + boxed primitive 兼容）+ `ASStruct.h::FScriptStructWildcard`（占位空 USTRUCT）+ `AngelscriptEngine.cpp::GetUnrealStructFromAngelscriptTypeId`（TypeId → `UStruct*` 反查 + 模板/enum/委托过滤）+ `AngelscriptRuntime.Build.cs::PublicDependencyModuleNames` 含 StructUtils + `Angelscript.uplugin::Plugins` 启用 StructUtils + UE5.7 `FInstancedStruct` 头文件 + `AngelscriptInstancedStructBindingsTests.cpp` (Default / Reset 行为契约) + `AngelscriptReflectiveAccess.h` 反射 path 访问 helper + `Template_ReflectionAccess.cpp` 已知 AS USTRUCT × FInstancedStruct 边界 + `Plan_StructUtilsMigration.md` 迁移计划背景。覆盖：① 数据布局（UScriptStruct* + uint8*）与设计动机（数据驱动配置 / payload / 跨脚本传递）；② StructUtils 模块依赖与启用链路（Build.cs + .uplugin 双重启用 + 头文件传播链）；③ 11 方法注册全景（EOrder::Late / ExistingClass / wildcard 与非 wildcard 入口分类）；④ Wildcard `?&in` / `?&out` × TypeId 反查的完整调用链；⑤ `FScriptStructWildcard` + `SetPreviousBindArgumentDeterminesOutputType(0)` 编译期类型 narrow（asCScriptFunction::determinesOutputTypeArgumentIndex 单字段标记）；⑥ `FAngelscriptAnyStructParameter` 隐式构造双路径（`?&in` + `const FInstancedStruct&`）+ UFUNCTION 参数样态；⑦ `FAngelscriptDelegateWithPayload` payload 复用 + 三层签名校验（StructType / FStructProperty / boxed primitive 6 个内部 USTRUCT）+ ExecuteIfBound 的 ProcessEvent 直喂 Memory 路径；⑧ UPROPERTY 反射桥（普通 FStructProperty + 编辑器 SInstancedStructDetails widget + meta=BaseStruct 限制）；⑨ 序列化（path + binary）/ 网络化（NetSerializeScriptStructDelegate）/ 文本导入导出 / GC（AddStructReferencedObjects 遍历内部对象）四种 trait；⑩ 与 `TSubclassOf` / `TWeakObjectPtr` 的 11 维度对照（"类型 + 数据"复合 vs "类型槽位" vs "对象引用"）；⑪ 7 项限制与避坑（含 AS USTRUCT × FInstancedStruct 已知 BeginPlay 崩溃 + 数学类型不可装 + `==` 而非 `IsChildOf` + 已弃用 `?&out` + 模板类型不可装 + null UScriptStruct 不防御 + payload 必经 BindWithPayload 入口）。 |
