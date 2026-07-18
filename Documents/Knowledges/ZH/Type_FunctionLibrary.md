# Type_FunctionLibrary — FunctionLibrary 暴露面

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: 站在"插件如何把游离函数 / 反射 BlueprintFunctionLibrary 风格的 helper 暴露成 AS 端可调用符号"的视角看 `FunctionLibraries/` 这 21 份 helper header——它们与 `Binds/Bind_*.cpp` 形成怎样的"类型绑定 / 功能扩展"互补、`UCLASS(meta=(ScriptMixin=...))` 那一行 meta 是怎么在 `EOrder::Late+100` 被改写成 AS 成员方法的、5 份名字以 `Bind_*ScriptMixins` / `Bind_FunctionLibraryMixins` 开头的"补漏"绑定文件具体补什么、以及 `AngelscriptMathLibrary.h` 里那 8 个被注释掉的 `//UCLASS(Meta=(ScriptMixin=...))` 命名空间退化态又是什么。本文不重复"`mixin` 关键字与 `ScriptMixin` 元数据的两条路径"（那是 `Syntax_Mixin.md` 的用户视角），不重复"`FBind` 注册框架与 `EOrder` 排序"（那是 `Type_BindSystem.md` 的职责），不重复"反射 fallback 调用约定"（那是 `Type_FunctionCaller.md`）；本文聚焦的是把上述三件事**在 `FunctionLibraries/` 文件夹里粘起来的工程约定**——21 份 header 是怎么分类、怎么命名、怎么与 5 份 `Bind_*.cpp` 配合、怎么在测试模块下被验证的。
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/`（20 个 .h + 1 个 .cpp，共 21 份文件）
> · `FunctionLibraries/AngelscriptMathLibrary.h` (~1100+ 行，10 个 sub-class，最大单文件)
> · `FunctionLibraries/AngelscriptActorLibrary.h` / `AngelscriptComponentLibrary.h`（成员方法 mixin 主体）
> · `FunctionLibraries/RuntimeFloatCurveMixinLibrary.h`（多目标 mixin 模板）
> · `FunctionLibraries/AngelscriptScriptLibrary.cpp`（21 份中唯一一份带 .cpp 的库）
> · `Binds/Bind_FunctionLibraryMixins.cpp` (~131 行，`EOrder::Late+110` 补漏样板)
> · `Binds/Bind_InputComponentScriptMixins.cpp` / `Bind_AssetManagerScriptMixins.cpp`（UHT 重载消歧 helper）
> · `Binds/Bind_BlueprintType.cpp::Bind_Defaults` (~1146 行起，`EOrder::Late+100` 自动注入主入口)
> · `Binds/Helper_FunctionSignature.h:280-345`（第 0 参数剥离 + `ClassName` 改写核心逻辑）
> · `AngelscriptTest/Bindings/Angelscript*FunctionLibraryTests.cpp`（17 份运行时行为测试）
> **关联文档**:
> `Documents/Knowledges/ZH/Type_BindSystem.md` — `FBind` / `EOrder` 注册框架（本文复用其 `Late+100` 阶段）
> · `Documents/Knowledges/ZH/Type_FunctionCaller.md` — 反射 fallback 与 generic trampoline 调用约定
> · `Documents/Knowledges/ZH/Type_BaseClass.md` — UClass 反射类型Runtime-linked（mixin 注入挂载在其结果之上）
> · `Documents/Knowledges/ZH/Syntax_Mixin.md` — `mixin` 关键字 / `ScriptMixin` meta 的脚本作者视角与四种触发方式
> · `Documents/Knowledges/ZH/AS_TypeRegistration.md` — `RegisterObjectMethod` / `RegisterGlobalFunction` 内核细节
> · `Documents/Knowledges/ZH/Type_Core.md` — `FAngelscriptType` 数据库（mixin ClassName 改写最终查的就是它）

---

## 概览

本文聚焦一个核心问题：**`FunctionLibraries/` 这 21 份 helper header 在 AS 引擎眼里是怎样的存在？它们既不是 `Bind_FVector.cpp` 那样的"类型绑定"（`RegisterObjectType` + 一堆 `Method`），也不是用户可见的 .as 脚本，而是一组"长得像 BlueprintFunctionLibrary 的 UCLASS"——这个 UCLASS 自身在 AS 端**根本没有对象实例**，它的存在只为承载若干 `static UFUNCTION`，让 `Bind_Defaults`（`EOrder::Late+100`）扫到时按 `ScriptMixin` meta 把这些 static UFUNCTION 改写成"目标类型的成员方法"或"目标命名空间下的 free function"。这套约定与 `Bind_*.cpp` 的"类型绑定"形成清晰互补：`Bind_*.cpp` 负责"把一个 C++ 类型搬到 AS 端"，`FunctionLibraries/` 负责"在已搬过来的类型上挂功能扩展"。**

```text
================================================================================
 FunctionLibrary 暴露面：UCLASS-meta 承载层 vs Bind_*.cpp 类型绑定层
================================================================================

[A 层：类型绑定]    Binds/Bind_FVector.cpp / Bind_AActor.cpp / Bind_UWorld.cpp ...
                    ┌───────────────────────────┐
                    │ static FBind Bind_FVector(│
                    │   EOrder::Early, []{      │
                    │     ValueClass<FVector>(  │   ← RegisterObjectType
                    │       "FVector").Method(  │
                    │       ...)                │
                    │ });                       │
                    └───────────────────────────┘
                                ▼
                    AS 引擎里出现 FVector / AActor / UWorld 类型骨架

[B 层：功能扩展]    FunctionLibraries/AngelscriptComponentLibrary.h ...
                    ┌───────────────────────────────────────┐
                    │ UCLASS(meta=(ScriptMixin="USceneComp"))│
                    │ class UAngelscriptComponentLibrary    │
                    │   : public UObject {                  │
                    │   UFUNCTION(BlueprintCallable)        │
                    │   static FVector GetRelativeLocation( │
                    │     const USceneComponent* Comp);     │
                    │   ...                                  │
                    │ };                                     │
                    └────────────────────┬───────────────────┘
                                         │
                                         │ Bind_Defaults @ EOrder::Late+100
                                         ▼ Helper_FunctionSignature.h:280-345
                    ┌───────────────────────────────────────┐
                    │ 第 0 参数剥离: ArgumentTypes.RemoveAt(0)│
                    │ ClassName 改写: ClassName = "USceneComp"│
                    │ bStaticInScript = false               │
                    └────────────────────┬───────────────────┘
                                         ▼
                    AS 引擎里 USceneComponent 多出 GetRelativeLocation 成员

[C 层：补漏]        Binds/Bind_FunctionLibraryMixins.cpp (Late+110)
                    Binds/Bind_InputComponentScriptMixins.cpp (Late+49)
                    Binds/Bind_AssetManagerScriptMixins.cpp (Late+49)
                    ┌───────────────────────────────────────┐
                    │ RegisterFunctionBinding(...)  ← UHT 重载消歧  │
                    │ ExistingClass(name).Method(decl, λ)   │
                    │   if (!HasMethod("...")) { ... }      │   ← 幂等检查
                    │ FNamespace ns; BindGlobalFunction(...)│
                    └───────────────────────────────────────┘

[D 层：测试]        AngelscriptTest/Bindings/Angelscript*FunctionLibraryTests.cpp
                    AngelscriptTest/Core/AngelscriptFunctionLibrarySignatureTests.cpp
                    17 份 *FunctionLibraryTests.cpp + 2 份签名测试
```

后续章节按"21 份文件清单 → 注册管道 → 补漏文件 → 四种暴露形态 → 命名约定 → 与 Bind 的边界 → 与 Syntax_Mixin 的边界 → 重载与冲突 → 测试覆盖"的顺序展开。

---

## 一、21 份文件清单与功能分类

### 1.1 文件总数核对

`Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/` 当前共 **21 份文件**，结构是 **20 份 .h** + **1 份 .cpp**（仅 `AngelscriptScriptLibrary` 因要触达 AS 内核 `asCModule::InitializingGlobalProperty` 而拆分了 `.cpp`，其余 19 份头文件全部 inline 实现）。`AGENTS.md` 提到的"21 mixin helper 库"指代的是这个数字——但严格说**只有 12 份 header 实际启用了 `UCLASS(meta=(ScriptMixin=...))`**，其余 9 份是名字带 Library 但走另外路径（命名空间静态、UCLASS-meta 注释关闭、纯 delegate 声明壳）。

### 1.2 按 UCLASS-meta 状态四象限分类

| 状态 | 数量 | 文件 | 说明 |
|---|---|---|---|
| **真 ScriptMixin（启用）** | 12 | `AngelscriptActorLibrary` / `AngelscriptComponentLibrary` / `AngelscriptFrameTimeMixinLibrary` / `AngelscriptHitResultLibrary` / `AngelscriptLevelStreamingLibrary` / `AngelscriptWorldLibrary` / `GameplayTagMixinLibrary` / `GameplayTagContainerMixinLibrary` / `GameplayTagQueryMixinLibrary` / `RuntimeCurveLinearColorMixinLibrary` / `RuntimeFloatCurveMixinLibrary` / `UAssetManagerMixinLibrary` / `WidgetBlueprintStatics`（`UAngelscriptWidgetMixinLibrary` 子类）/ `InputComponentScriptMixinLibrary`（3 个子类） | 走 §二 自动注入路径，AS 端为 `Target.Method(...)` 形式 |
| **命名空间静态（meta 注释关闭）** | 1 | `AngelscriptMathLibrary.h`（`UAngelscriptFVectorMixinLibrary` 等 8 个数学子库） | 8 处 `//UCLASS(Meta=(ScriptMixin=...))` 仍是注释，仅以 `<Lib>::<Func>(target, ...)` 命名空间静态形式可见，详见 `Syntax_Mixin.md` §6.6 类 3 namespace-regression 子类 |
| **纯命名空间** | 4 | `AngelscriptMathLibrary` 主体 / `AngelscriptScriptLibrary` / `GameplayLibrary` / `SubsystemLibrary` / `WidgetBlueprintStatics`（`UWidgetBlueprintStatics` 主类） | 仅 `Meta=(ScriptName="...")`，所有静态 UFUNCTION 进入"命名空间下的 free function"通路 |
| **纯壳承载 delegate** | 2 | `SoftReferenceStatics.h` / `WorldCollisionStatics.h` | UCLASS body 为空，仅用 `DECLARE_DYNAMIC_DELEGATE_*Param` 暴露脚本可消费的动态委托类型，被对应的 `Bind_TSoftObjectPtr.cpp` / `Bind_WorldCollision.cpp` `#include` 拖入链接段 |

`AngelscriptMathLibrary.h` 同时跨"纯命名空间"（`UAngelscriptMathLibrary` 主类）+ "命名空间静态"（8 个数学子库）+ "未来候选 ScriptMixin"（注释保留），是最复杂的一份。

### 1.3 按功能领域分类

按"目标对象的领域"再切一刀：

```text
┌─────────────────┬──────────────────────────────────────────────────────────────┐
│ 领域            │ 文件                                                          │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Actor / Scene   │ AngelscriptActorLibrary, AngelscriptComponentLibrary,        │
│                 │ AngelscriptLevelStreamingLibrary, AngelscriptWorldLibrary    │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Math            │ AngelscriptMathLibrary（10 个 sub-class）                     │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Engine 数据     │ AngelscriptHitResultLibrary, AngelscriptFrameTimeMixinLibrary │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Curve           │ RuntimeFloatCurveMixinLibrary,                               │
│                 │ RuntimeCurveLinearColorMixinLibrary                          │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ GameplayTag     │ GameplayTagMixinLibrary, GameplayTagContainerMixinLibrary,   │
│                 │ GameplayTagQueryMixinLibrary                                 │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Input           │ InputComponentScriptMixinLibrary（3 个子类）                  │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Asset           │ UAssetManagerMixinLibrary, SoftReferenceStatics              │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Subsystem/Widget│ SubsystemLibrary, WidgetBlueprintStatics                     │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Gameplay save   │ GameplayLibrary（AsyncSaveGameToSlot/AsyncLoadGameFromSlot） │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ Collision       │ WorldCollisionStatics（仅承载 FScriptTraceDelegate 等）       │
├─────────────────┼──────────────────────────────────────────────────────────────┤
│ AS 自省         │ AngelscriptScriptLibrary（GetNameOfGlobalVariableBeing...）  │
└─────────────────┴──────────────────────────────────────────────────────────────┘
```

11 个领域 × 21 份文件——分布密度反映出**这层"功能扩展"主要补的是 Actor/Component/Math/GameplayTag/Curve 几条 fork 长期重点投资的链路**，与 `Bind_*.cpp` 主体覆盖的"基础类型搬运"形成职责互补。

---

## 二、注册管道：从 UCLASS-meta 到 AS 成员方法

### 2.1 一行 meta 的全部含义

最简单的样本是 `AngelscriptFrameTimeMixinLibrary.h`——10 行的 helper 库就能讲清整个注册链路：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/FunctionLibraries/AngelscriptFrameTimeMixinLibrary.h
// 性质: 单目标 ScriptMixin 最简模板
// ============================================================================
UCLASS(meta = (ScriptMixin = "FQualifiedFrameTime"))
class ANGELSCRIPTRUNTIME_API UAngelscriptFrameTimeMixinLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable, Category = "FrameTime")
    static double AsSeconds(const FQualifiedFrameTime& Target)
    {
        return Target.AsSeconds();   // ★ 第 0 参数即 mixin 目标
    }
};
```

`UCLASS(meta=(ScriptMixin="FQualifiedFrameTime"))` 这一行做的事是给 UClass 的 `MetaData` 表挂一条 key-value：`"ScriptMixin" => "FQualifiedFrameTime"`。`Helper_FunctionSignature.h:280-345` 后续读这条 meta 决定如何改写函数签名。

### 2.2 `Helper_FunctionSignature.h::InitFromFunction` 的第 0 参数剥离

整个改写在 `Helper_FunctionSignature.h:280-345` 的一段静态分支里完成：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Helper_FunctionSignature.h
// 函数: FAngelscriptFunctionSignature::InitFromFunction（静态分支）
// 节选自: 行 280-345，处理 FUNC_Static UFUNCTION 的 mixin 注入
// ============================================================================
bool bForceConst = false;
bStaticInUnreal = Function->HasAnyFunctionFlags(FUNC_Static);
if (bStaticInUnreal)
{
    FString Namespace = GetScriptNamespaceForClass(InType);
    bGlobalScope = HasFuncMeta(NAME_Signature_ScriptGlobalScope);

    bool bFoundMixin = false;
    const FString& MixinClasses = GetClassMetaRef(NAME_Signature_ScriptMixin);

    bool bFunctionLevelScriptMethod = false;          // UE 5.7+ 增量
    if (MixinClasses.Len() == 0 && HasFuncMeta(NAME_Signature_ScriptMethod))
        bFunctionLevelScriptMethod = true;

    if ((MixinClasses.Len() != 0 || bFunctionLevelScriptMethod) && ArgumentTypes.Num() > 0
        && (ArgumentTypes[0].IsObjectPointer()
            || ArgumentTypes[0].Type->IsUnresolvedObjectPointer()
            || ArgumentTypes[0].bIsReference))
    {
        TArray<FString> MixinList;
        MixinClasses.ParseIntoArray(MixinList, TEXT(" "));
        // ...
        FString FirstParamType = ArgumentTypes[0].Type->GetAngelscriptTypeName(ArgumentTypes[0]);
        for (const FString& Mixin : MixinList)
        {
            if (FirstParamType == Mixin || UnresolvedObjectMixinType == Mixin)
            {
                if (ArgumentTypes[0].bIsConst) bForceConst = true;

                ArgumentTypes.RemoveAt(0);            // ★ 三组并行数组同步裁剪
                ArgumentNames.RemoveAt(0);
                ArgumentDefaults.RemoveAt(0);
                ClassName = Mixin;                    // ★ 改写宿主类名
                bStaticInScript = false;              // ★ 不再是命名空间静态
                bFoundMixin = true;
                break;
            }
        }
    }
    // ...
}
```

读懂这段需要抓住三处副作用：

- **三组并行数组同步裁剪**：`ArgumentTypes` / `ArgumentNames` / `ArgumentDefaults` 三者必须一起 `RemoveAt(0)`。索引型字段（`WorldContextArgument` / `DeterminesOutputTypeArgument`）也要 `-= 1`。完整推导见 `Syntax_DefaultStatement.md` §7.11。
- **`ClassName` 改写**：原本指向 `UAngelscriptFrameTimeMixinLibrary` 的 namespace 字符串被替换为 `"FQualifiedFrameTime"`，下游 `BindFunctionWithAdditionalName()` 据此把函数挂到目标类型而不是 helper 自身。
- **`const` 传播**：第 0 参数若是 `const T&`，整个函数被强制声明为 `const` 成员方法，与"this 是 const"语义一致。

### 2.3 `Bind_Defaults` 在 `EOrder::Late+100` 的扫描时机

注入并不是在 helper 库的静态初始化器里完成的——21 份 header 里没有任何 `static FBind`。改写发生在 `Bind_BlueprintType.cpp:1146` 的 `Bind_Defaults` 阶段：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
// 函数: Bind_Defaults（EOrder::Late+100 自动扫描入口）
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_Defaults(
    (int32)FAngelscriptBinds::EOrder::Late + 100, []
{
    FAngelscriptScopeTimer Timer(TEXT("blueprinttype bindings"));
    auto* ScriptEngine = FAngelscriptEngine::Get().Engine;

    // ... Phase 1: 收集 ClassesToBind（含所有 UCLASS）
    for (UClass* Class : TObjectRange<UClass>())
        FClassVisiter::Visit(ScriptEngine, Class, ClassesToBind, VisitedClasses);

    // ... Phase 1.5: GameThread 预热 NameArray
    // ... Phase 2A (Prepare): 并行枚举每个 UClass 的 UFunction，构造
    //                         FAngelscriptFunctionSignature——第 0 参数剥离在这里发生
    // ... Phase 2B (Commit): GameThread 写入 AS Engine（asIScriptEngine 写不可重入）
});
```

`Bind_Defaults` 的 `Late+100` 在所有手写 `Bind_*.cpp`（`Early` ~ `Normal` ~ `Late`）跑完后才执行，这一时序保证：到这里时 `FQualifiedFrameTime` / `USceneComponent` / `AActor` 等目标类型已经被 `Bind_FQualifiedFrameTime.cpp` / `Bind_USceneComponent.cpp` / `Bind_AActor.cpp` 注册到 AS 引擎，`ExistingClass(name).Method(...)` 才能找到宿主。

完整 `EOrder` 时序见 `Type_BindSystem.md` §三。

### 2.4 写入 AS 引擎的最终调用

裁剪后的 `FAngelscriptFunctionSignature` 由 `Bind_BlueprintType.cpp:1318-1322` 的 `BindFunctionWithAdditionalName()` 消费，最终 `RegisterObjectMethod(asITypeInfo*, decl, ...)` 把它注册到目标类型上：

```cpp
// 节选自 Bind_BlueprintType.cpp:1318-1322（伪码近似）
if (Function->HasAnyFunctionFlags(FUNC_BlueprintCallable | FUNC_BlueprintPure))
    BindBlueprintCallable(InType, Function, DBMethod, *TargetName);
else if (Function->HasMetaData(NAME_ScriptCallable))
    BindBlueprintCallable(InType, Function, DBMethod, *TargetName);
```

注意 `else if (HasMetaData(NAME_ScriptCallable))` 是 Hazelight 风格的"脚本可见但蓝图不可见"通路——当前 fork 的 `FunctionLibraries/` 主体改写为 `BlueprintCallable`，所以这条 `ScriptCallable` 分支在生产路径上基本不命中（背景见 `Syntax_Mixin.md` §6.3）。

---

## 三、补漏管道：5 份 `Bind_*.cpp` 各做什么

`FunctionLibraries/` 的 21 份 header 不是孤立的——`Binds/` 下有 5 份 `Bind_*.cpp` 显式 `#include` `FunctionLibraries/*.h`，承担三类不同的"补漏"职责。Grep 结果：

```text
Binds/Bind_FunctionLibraryMixins.cpp        ← Late+110  手写 Method/lambda 补漏
Binds/Bind_InputComponentScriptMixins.cpp   ← Late+49   RegisterFunctionBinding 重载消歧
Binds/Bind_AssetManagerScriptMixins.cpp     ← Late+49   RegisterFunctionBinding 重载消歧
Binds/Bind_TSoftObjectPtr.cpp               ← 链接段拖入 SoftReferenceStatics 的 delegate
Binds/Bind_WorldCollision.cpp               ← 链接段拖入 WorldCollisionStatics 的 delegate
```

三类职责各自的代码形态截然不同。

### 3.1 类 1：`Bind_FunctionLibraryMixins.cpp`（`Late+110` 手写补漏）

`Bind_Defaults` 在 `Late+100` 已经把基础 mixin 注册完毕，但**含 `out` 引用、需要 lambda wrapper、需要回避 `asALREADY_REGISTERED` 的签名**走不了纯反射路径，由 `Bind_FunctionLibraryMixins.cpp`（`Late+110`）补：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FunctionLibraryMixins.cpp
// 函数: Bind_FunctionLibraryMixins（EOrder::Late+110）
// 性质: 自动注入路径覆盖不全的边角签名补漏
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FunctionLibraryMixins(
    (int32)FAngelscriptBinds::EOrder::Late + 110, []
{
    // ── 子段 1：UHT 重载消歧 helper（FAngelscriptBinds::RegisterFunctionBinding）
    FAngelscriptBinds::RegisterFunctionBinding(
        URuntimeFloatCurveMixinLibrary::StaticClass(), "GetTimeRange",
        { ERASE_FUNCTION_PTR(URuntimeFloatCurveMixinLibrary::GetTimeRange,
            (const FRuntimeFloatCurve&, float&, float&), ERASE_ARGUMENT_PACK(void)) });

    // ── 子段 2：HasMethod / GetMethodByDecl 幂等检查 + ExistingClass.Method(λ)
    auto SceneComponent_ = FAngelscriptBinds::ExistingClass("USceneComponent");
    asITypeInfo* SceneComponentType = SceneComponent_.GetTypeInfo();
    if (SceneComponentType == nullptr
        || SceneComponentType->GetMethodByDecl(
            "void SetRelativeRotation(FRotator NewRotation)") == nullptr)
    {
        SceneComponent_.Method(
            "void SetRelativeRotation(FRotator NewRotation)",
            [](USceneComponent* Component, const FRotator& NewRotation)
            { UAngelscriptComponentLibrary::SetRelativeRotation(Component, NewRotation); });
    }

    // ── 子段 3：含 out 引用的签名（Bind_Defaults 的反射路径走不了）
    auto RuntimeFloatCurve_ = FAngelscriptBinds::ExistingClass("FRuntimeFloatCurve");
    if (!RuntimeFloatCurve_.HasMethod(TEXT("AddDefaultKey")))
    {
        RuntimeFloatCurve_.Method(
            "void AddDefaultKey(float32 InTime, float32 InValue)",
            [](FRuntimeFloatCurve* Target, float InTime, float InValue)
            { URuntimeFloatCurveMixinLibrary::AddDefaultKey(*Target, InTime, InValue); });
    }
    // ...

    // ── 子段 4：双向暴露——BindGlobalFunction 让脚本既能用成员方法形式
    //          也能用 namespace 静态形式调同一个 helper
    FAngelscriptBinds::FNamespace RuntimeFloatCurveHelperNs(
        "URuntimeFloatCurveMixinLibrary");
    FAngelscriptBinds::BindGlobalFunction(
        "void GetTimeRange(const FRuntimeFloatCurve& Target, "
        "float32&out MinTime, float32&out MaxTime)",
        [](const FRuntimeFloatCurve& Target, float& MinTime, float& MaxTime)
        { URuntimeFloatCurveMixinLibrary::GetTimeRange(Target, MinTime, MaxTime); });
});
```

四段读完就能掌握"补漏"的全部姿势：

1. `RegisterFunctionBinding`——给 UHT 函数表写一条精确指针，避免反射回退；
2. `HasMethod` / `GetMethodByDecl` 幂等检查 + `ExistingClass(name).Method(decl, λ)` 手挂；
3. 含 `out` 引用、Wrapper、跨类型转换的 lambda 形态；
4. `FNamespace + BindGlobalFunction` 让同一 helper 同时在成员方法 + 命名空间静态两个形态可见。

### 3.2 类 1.5：`Bind_*ScriptMixins.cpp`（`Late+49` 重载消歧）

`Bind_InputComponentScriptMixins.cpp` 与 `Bind_AssetManagerScriptMixins.cpp` 共用同一形态——**只用 `RegisterFunctionBinding` 给 UHT 函数表写指针，不注册 AS 方法**：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins.cpp
// 性质: UHT 重载消歧（与 ScriptMixin 自动注入路径正交、可共存）
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_InputComponentScriptMixins(
    (int32)FAngelscriptBinds::EOrder::Late + 49, []
{
    // UHT marks these wrappers overloaded-unresolved, so register the exact
    // signatures before the generated function table falls back to reflective
    // dispatch.
    FAngelscriptBinds::RegisterFunctionBinding(
        UPlayerInputScriptMixinLibrary::StaticClass(), "AddActionMapping",
        { ERASE_FUNCTION_PTR(UPlayerInputScriptMixinLibrary::AddActionMapping,
            (UPlayerInput*, const FInputActionKeyMapping&), ERASE_ARGUMENT_PACK(void)) });
    // 同形态 ×3...
});
```

注释自陈这条路径在做什么——让 UHT 生成的 `AS_FunctionBinding_*.cpp` 拿到精确函数指针，避免落到"反射 fallback"的慢路径。它**不**注册 AS 成员方法，所以与 `Late+100` 的 mixin 自动注入并存不会冲突。`EOrder::Late+49` 比 `Late+100` 早，时序上保证 `Bind_Defaults` 扫到这些 UFUNCTION 时函数指针表已就绪。

`Syntax_Mixin.md` §6.6 把这种文件归为"类 1.5"。

### 3.3 类 2：链接段拖入（`Bind_TSoftObjectPtr.cpp` / `Bind_WorldCollision.cpp`）

`SoftReferenceStatics.h` 与 `WorldCollisionStatics.h` 的 UCLASS body 全空——它们存在的唯一作用是承载 `DECLARE_DYNAMIC_DELEGATE_*Param`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/FunctionLibraries/SoftReferenceStatics.h
// 性质: 纯壳，仅承载脚本可消费的 dynamic delegate 类型
// ============================================================================
DECLARE_DYNAMIC_DELEGATE_OneParam(FOnSoftObjectLoaded, UObject*, LoadedObject);
DECLARE_DYNAMIC_DELEGATE_OneParam(FOnSoftClassLoaded, UClass*, LoadedClass);

UCLASS()
class USoftReferenceStatics : public UObject
{
    GENERATED_BODY()
};
```

被 `Bind_TSoftObjectPtr.cpp` 在第 7 行 `#include` 拖入，目的是让 UHT 看到这两个 `FOnSoftObjectLoaded` / `FOnSoftClassLoaded` 委托类型并生成函数表项，再由 `Bind_TSoftObjectPtr.cpp` 用作软指针异步加载回调签名的一部分。

`WorldCollisionStatics.h` 同形态——`FScriptTraceDelegate` / `FScriptOverlapDelegate` 被 `Bind_WorldCollision.cpp` 用于 `AsyncLineTrace` / `AsyncOverlap` 的脚本签名。

这两份 header 的功能完全是"反射类型容器"，不走 mixin 路径，**也不该被归类为"mixin helper 库"——是 `AGENTS.md` 21 个文件总数下的边缘成员**。

---

## 四、四种暴露形态对照

把 §二、§三的内容压缩成一张表，21 份 header 实际暴露给 AS 端的形态可分四种：

| 形态 | AS 调用语法 | 触发路径 | 代表文件 |
|---|---|---|---|
| 成员方法（mixin 注入） | `Target.Method(args)` | `UCLASS(meta=(ScriptMixin="T"))` + `Bind_Defaults` 自动 | `AngelscriptComponentLibrary` / `AngelscriptHitResultLibrary` / `GameplayTagMixinLibrary` 等 12 份 |
| 命名空间静态 | `Lib::Func(target, args)` | `UCLASS(Meta=(ScriptName="..."))` + `bStaticInScript=true` | `UAngelscriptMathLibrary` / `UAngelscriptScriptLibrary` / `UAngelscriptFVectorMixinLibrary`（注释关闭态） |
| 全局 free function | `Func(args)` | `FNamespace + BindGlobalFunction` 手挂 | `Bind_FunctionLibraryMixins.cpp` 子段 4 |
| Delegate 类型 / 反射壳 | `FOnSoftObjectLoaded MyDg;` | `DECLARE_DYNAMIC_DELEGATE_*` 由 UHT 拾起 | `SoftReferenceStatics` / `WorldCollisionStatics` |

同一份 helper 经常**同时**走前两种或前三种形态——`URuntimeFloatCurveMixinLibrary::GetTimeRange` 既在 `FRuntimeFloatCurve` 上挂成员方法，又在 `URuntimeFloatCurveMixinLibrary` 命名空间下挂全局函数（见 §3.1 子段 4）。这种"双向暴露"是 `Bind_FunctionLibraryMixins.cpp` 唯一显式做的事——不要试图在自动注入路径里实现它。

---

## 五、命名约定

### 5.1 文件命名

`FunctionLibraries/` 下 20 份 header 的命名遵循三组规则：

```text
1) Angelscript<Subject>Library.h            ← Hazelight 上游对照位置
   AngelscriptActorLibrary.h
   AngelscriptComponentLibrary.h
   AngelscriptHitResultLibrary.h
   AngelscriptLevelStreamingLibrary.h
   AngelscriptMathLibrary.h
   AngelscriptScriptLibrary.h
   AngelscriptWorldLibrary.h
   AngelscriptFrameTimeMixinLibrary.h        ← 主体 + Mixin suffix

2) <Subject>MixinLibrary.h                   ← 显式标注走 mixin 路径
   GameplayTagMixinLibrary.h
   GameplayTagContainerMixinLibrary.h
   GameplayTagQueryMixinLibrary.h
   InputComponentScriptMixinLibrary.h
   RuntimeCurveLinearColorMixinLibrary.h
   RuntimeFloatCurveMixinLibrary.h
   UAssetManagerMixinLibrary.h

3) <Subject>Statics.h                         ← 纯命名空间 / 反射壳
   GameplayLibrary.h        (UGameplayLibrary)
   SubsystemLibrary.h       (USubsystemLibrary)
   SoftReferenceStatics.h
   WidgetBlueprintStatics.h
   WorldCollisionStatics.h
```

命名规则**没有强约束**——`Angelscript*Library.h` 与 `*MixinLibrary.h` 都可能挂 `ScriptMixin` meta；`*Statics.h` 既可能是真静态库（`SubsystemLibrary` 走命名空间形式），也可能是纯壳（`SoftReferenceStatics`）。文件名只是**意图提示**，真实路径必须看 `UCLASS` meta + `UFUNCTION` flag 组合。

### 5.2 内部 namespace 习惯

- helper 类名以 `U` 前缀（强制要求，UHT 约束）。
- helper 类名后缀使用 `Library` / `MixinLibrary` / `Statics`，与文件名保持一致。
- 多目标 mixin 在同一 header 拆 sub-class（典型样本：`InputComponentScriptMixinLibrary.h` 含 3 个子 UCLASS：`UInputComponentScriptMixinLibrary` / `UPlayerControllerInputScriptMixinLibrary` / `UPlayerInputScriptMixinLibrary`，目标分别是 `UInputComponent` / `APlayerController` / `UPlayerInput`），而**不**在同一 UCLASS meta 上空格分隔多目标——除非函数签名第 0 参数语义在多个目标间确实可互换（如 `RuntimeFloatCurveMixinLibrary` 的 `"FRuntimeFloatCurve UCurveFloat"` 双目标）。
- 函数命名按 UE 风格 PascalCase；Hazelight 上游用 `ScriptName` meta 重命名时，fork 仍保留 `ScriptName=...` 形式（见 `AngelscriptComponentLibrary.h:44` 的 `SetRelativeRotation` / `SetRelativeRotationQuat` 重载策略）。

### 5.3 编译器约束

- 21 份 helper 全部 `public : UObject`（UHT 强制 UCLASS 要继承自 UObject 链路）。
- `GENERATED_BODY()` 必须在 `public:` 前面。
- inline 实现是默认形态，仅 `AngelscriptScriptLibrary` 因要触达 AS 内核 (`asCModule::InitializingGlobalProperty`) 才拆出 `.cpp`。
- 19 份 inline header 的代价是 **每个 .cpp `#include` 它都会拉一遍整套 helper 进编译单元**——对编译时间的影响目前尚未优化（潜在的"是否拆 .cpp"重构空间）。

---

## 六、与 `Bind_*.cpp` 系统的边界

**FunctionLibrary 不是 Bind 系统的子集**，它们是两套互补的 API 表面。一图概括：

```text
                          ┌─────────────────────────────────────┐
                          │  Bind_*.cpp（121 份手写）            │
                          │  ─────────────────                   │
                          │  • RegisterObjectType (FVector)      │
                          │  • RegisterEnum / RegisterValueClass │
                          │  • Constructor / Destructor / Op     │
                          │  • Method (核心运算/属性 Getter/Setter)│
                          │  • RegisterGlobalFunction (free)     │
                          │  → 把"C++ 类型骨架"搬到 AS           │
                          └────────────┬────────────────────────┘
                                       │ AS 引擎已有 FVector / AActor / ...
                                       ▼
                          ┌─────────────────────────────────────┐
                          │  FunctionLibraries/（21 份 helper）  │
                          │  ─────────────────                   │
                          │  • UCLASS(meta=(ScriptMixin="T"))    │
                          │  • static UFUNCTION(BlueprintCallable)│
                          │  → 在已有类型上"挂功能扩展"          │
                          └─────────────────────────────────────┘
```

边界判定法：

- 如果你想**搬一个新 C++ 类型到 AS**（含构造/析构/运算符/字段）→ 写 `Bind_<Type>.cpp`，不要塞 `FunctionLibraries/`。
- 如果你想**给已绑过来的类型加一组功能函数**（且函数刚好能做 `BlueprintFunctionLibrary` 风格的 `static T Func(const Target&, ...)`）→ 写 `FunctionLibraries/<Subject>MixinLibrary.h`。
- 如果功能函数**含 `out` 引用、特殊 wrapper、需要 lambda、需要重载消歧**→ helper header 写函数主体，再在 `Bind_FunctionLibraryMixins.cpp` 或专属 `Bind_<Subject>ScriptMixins.cpp` 里手动 `Method(decl, λ)` 注册。
- 如果只是想**让 UHT 看到一组 dynamic delegate 类型**→ 写 `<Subject>Statics.h`（空 UCLASS body + `DECLARE_DYNAMIC_DELEGATE_*`），由对应的 `Bind_*.cpp` `#include` 拖入。

---

## 七、与 Syntax_Mixin 的边界

`Syntax_Mixin.md` 与本文都讲"mixin"，但视角不同：

| 维度 | `Syntax_Mixin.md` | `Type_FunctionLibrary.md`（本文） |
|---|---|---|
| 视角 | 脚本作者：怎么写 `mixin function` / 怎么用 `UCLASS(meta=...)` | 插件实现：21 份 header 的工程组织 |
| 关注点 | 两条 mixin 路径（语言级 mixin 关键字 + 反射 ScriptMixin meta）的语义、四种触发方式、ASSDK 与 fork 的差异 | 21 份文件的功能分类、5 份 `Bind_*.cpp` 的补漏分工、命名约定、单元测试位置 |
| 代码引用 | `as_parser.cpp::ParseMixin` / `Helper_FunctionSignature.h` | `FunctionLibraries/*.h` / `Bind_FunctionLibraryMixins.cpp` |
| 何时读 | 读懂"为什么我的 `mixin void Foo(...)` 没生效" / "ScriptMixin 注入失败的诊断" | 读懂"我要给 USceneComponent 加一个 GetXxx 函数应该写在哪个文件、走哪条路径" |

两文不冲突——`Syntax_Mixin.md` §6.6 的"四类启用状态"分类（类 1 / 类 1.5 / 类 2 / 类 3）就是本文 §三、§四的语言学描述；本文则是从"插件维护者怎么动文件夹"视角的工程描述。

---

## 八、命名冲突、重载与幂等

### 8.1 `asALREADY_REGISTERED -13` 是最常见的 mixin 冲突信号

`Bind_Defaults` 在 `Late+100` 自动扫一遍所有 `UCLASS(meta=(ScriptMixin=...))` 然后挂上去；`Bind_FunctionLibraryMixins` 在 `Late+110` 紧接着补漏。**两步若注册同一签名，AngelScript 内核返回 `asALREADY_REGISTERED (-13)`，asIScriptEngine 会进入"半坏"状态，后续测试（典型：MultiEngine / DependencyInjection 的 clone-rebind 路径）都跑不下去**。

幂等检查的两种姿势：

```cpp
// 姿势 1：HasMethod（按方法名匹配，宽松）
if (!RuntimeFloatCurve_.HasMethod(TEXT("AddDefaultKey")))
    RuntimeFloatCurve_.Method("void AddDefaultKey(float32 InTime, float32 InValue)", ...);

// 姿势 2：GetMethodByDecl（按完整声明匹配，严格）
if (SceneComponentType == nullptr
    || SceneComponentType->GetMethodByDecl("void SetRelativeRotation(FRotator NewRotation)") == nullptr)
    SceneComponent_.Method("void SetRelativeRotation(FRotator NewRotation)", ...);
```

何时用哪种？`Bind_FunctionLibraryMixins.cpp` 的注释自陈：

```text
// UCurveFloat: guard with HasMethod (name-based) instead of GetMethodByDecl.
// Bind_Defaults (EOrder::Late+100) auto-registers these via ScriptMixin on
// URuntimeFloatCurveMixinLibrary. The auto-generated declaration string may
// differ from the hand-written one, causing GetMethodByDecl to miss the
// existing method and trigger asALREADY_REGISTERED (-13).
```

**经验法则**：自动注入路径生成的 declaration 字符串（如 `"void AddAutoCurveKey(float, float)"`）可能与手写的（`"FCurveKeyHandle AddAutoCurveKey(float32 InTime, float32 InValue)"`）不一致——`GetMethodByDecl` 会假阴性。重载多的类型（`UCurveFloat`）改用 `HasMethod` 名称匹配；签名稳定且无重载的（`USceneComponent::SetRelativeRotation` 单次）用 `GetMethodByDecl` 精确匹配。

### 8.2 多 helper 库暴露同名 helper 时的解析规则

`AngelscriptMathLibrary.h` 里 8 个数学子库（`UAngelscriptFVectorMixinLibrary` / `UAngelscriptFRotatorLibrary` / ...）各自有 `Size2D` / `GetForwardVector` 等同名函数。能并存的原因是它们的**命名空间不同**：

```cpp
UCLASS(Meta = (ScriptName = "FRotator"))      // ← namespace = "FRotator"
class UAngelscriptFRotatorLibrary : public UObject { ... };

UCLASS(Meta = (ScriptName = "FQuat"))         // ← namespace = "FQuat"
class UAngelscriptFQuatStaticLibrary : public UObject { ... };
```

AS 端通过 `FRotator::GetForwardVector(rot)` / `FQuat::GetDelta(a, b)` 命名空间前缀消歧。

如果**真有两个库挂同一目标 mixin** 且签名相同（罕见），后注册的会触发 `asALREADY_REGISTERED`——必须由 `Bind_FunctionLibraryMixins` 加幂等检查或拆签名。

### 8.3 `ScriptName` 重载映射

`AngelscriptComponentLibrary.h` 用 `Meta=(ScriptName="SetRelativeRotation")` 把多个 C++ 名互不相同的重载（`SetRelativeRotation` / `SetRelativeRotationQuat`）映射到 AS 端同一个 `SetRelativeRotation`：

```cpp
UFUNCTION(BlueprintCallable)
static void SetRelativeRotation(USceneComponent* C, const FRotator& NewRotation) { ... }

UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation", NotAngelscriptProperty))
static void SetRelativeRotationQuat(USceneComponent* C, const FQuat& NewRotation) { ... }
```

下游 `Helper_FunctionSignature.h::ApplyScriptName(...)` 把 declaration 改写后再走 `RegisterObjectMethod`，AS 端最终看到 `void SetRelativeRotation(FRotator)` + `void SetRelativeRotation(FQuat)` 两个重载共用一个名字。`NotAngelscriptProperty` 防止被识别为属性 setter。

### 8.4 namespace-regression 风险

`AngelscriptMathLibrary.h` 的 8 处 `//UCLASS(Meta=(ScriptMixin=...))` 注释关闭——这是 fork 历史包袱。详细成因见 `Syntax_Mixin.md` §6.6 类 3 namespace-regression：fork 测试代码 `AngelscriptMathFunctionLibraryTests.cpp:412-424` / `AngelscriptMathOrientationFunctionLibraryTests.cpp:164-181` 大量使用 `<Lib>::<Func>(target, ...)` 静态形式（如 `AngelscriptFVectorMixin::Size2D(vec, normal)` / `FRotator::GetForwardVector(rot)`），启用 ScriptMixin 后类级注入路径会**剥除第一参数并改写成成员方法形式**，原 namespace 静态形式编译失败。

留作 `Plan_MathScriptMixinReenablement.md` 专项推进——**新增 helper 时不要照抄数学库的注释关闭模式**，应该直接走 §二的成员方法路径。

---

## 九、单元测试覆盖

### 9.1 `AngelscriptTest/Bindings/Angelscript*FunctionLibraryTests.cpp`（17 份）

每个生产 helper 库对应一份测试：

| 文件 | 覆盖目标 | Automation 前缀 |
|---|---|---|
| `AngelscriptFrameTimeFunctionLibraryTests.cpp` | `UAngelscriptFrameTimeMixinLibrary::AsSeconds` | `Angelscript.TestModule.FunctionLibraries.FrameTime.*` |
| `AngelscriptHitResultFunctionLibraryTests.cpp` | `UAngelscriptHitResultLibrary` | `FunctionLibraries.HitResult.*` |
| `AngelscriptCurveFunctionLibraryTests.cpp` | `URuntimeFloatCurveMixinLibrary` / `URuntimeCurveLinearColorMixinLibrary` | `FunctionLibraries.RuntimeFloatCurveInstance*` / `Parity.RuntimeCurveLinearColor*` |
| `AngelscriptGameplayTagContainerFunctionLibraryTests.cpp` | `UGameplayTagContainerMixinLibrary` + `UGameplayTagMixinLibrary` | `FunctionLibraries.GameplayTagContainer*` |
| `AngelscriptAssetManagerFunctionLibraryTests.cpp` | `UAssetManagerMixinLibrary` | `FunctionLibraries.AssetManager*` |
| `AngelscriptWidgetFunctionLibraryTests.cpp` | `UWidgetBlueprintStatics` + `UAngelscriptWidgetMixinLibrary` | `FunctionLibraries.Widget*` / `Parity.UserWidgetPaintCompile` |
| `AngelscriptSoftReferenceFunctionLibraryTests.cpp` | `SoftReferenceStatics` 的 `FOnSoftObjectLoaded` 等 delegate | `FunctionLibraries.SoftReference*` |
| `AngelscriptScriptFunctionLibraryTests.cpp` | `UAngelscriptScriptLibrary::GetNameOfGlobalVariableBeingInitialized` | `FunctionLibraries.Script.*` |
| `AngelscriptWorldFunctionLibraryTests.cpp` | `UAngelscriptWorldLibrary::GetStreamingLevels` | `FunctionLibraries.World*` |
| `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp` / `*ComponentTests.cpp` | `WorldCollisionStatics` 委托 + `Bind_WorldCollision.cpp` 的 trace API | `FunctionLibraries.WorldCollision*` |
| `AngelscriptMathFunctionLibraryTests.cpp` / `AngelscriptMathOrientationFunctionLibraryTests.cpp` | `UAngelscriptMathLibrary` + 8 个数学子库 | `FunctionLibraries.Math*` |
| `AngelscriptGameplayFunctionLibraryTests.cpp` | `UGameplayLibrary::AsyncSaveGameToSlot` | `FunctionLibraries.Gameplay*` |

`InputComponentScriptMixinLibrary` 当前**没有**专属 `*FunctionLibraryTests.cpp`——`Syntax_Mixin.md` §5.4 把这条记为已知覆盖空缺，间接由 `Bind_InputComponentScriptMixins` UHT 重载消歧自检 + 上层 EnhancedInput 集成测试覆盖。

### 9.2 `AngelscriptTest/Core/AngelscriptFunctionLibrarySignatureTests.cpp`（签名级别测试）

不是测 helper 行为，而是测 **`Helper_FunctionSignature.h` 的第 0 参数剥离 + `bStaticInScript` 翻转 + `ClassName` 改写**这三件事是否在生产 mixin 库上正确发生：

```text
Automation: Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures
样本:       FrameTime / Widget / GameplayTagQuery
断言:       bStaticInScript == false
            ArgumentTypes 长度等于 C++ 参数数 - 1
            ArgumentNames[0] 是裁剪后的"真实"参数名
```

加上 `Angelscript.TestModule.Engine.BindConfig.FunctionLevelScriptMethodUsesFirstParameterAsMixin`——UE 5.7+ 新增分支的回归保险。这两条测试是 `FunctionLibraries/` 增删 helper 时**必须看着不掉绿**的两根钢梁。

### 9.3 `AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`（绑定配置）

覆盖 `SubsystemLibrary` 的命名空间静态形式（`UEngineSubsystem* GetEngineSubsystem(...)` 等 Subsystem 访问器）的元数据语义——`WorldContextObject` 隐藏参数索引、`DeterminesOutputType` 返回类型推断、`ScriptNoDiscard` 等。是 `SubsystemLibrary.h` 改动时的回归保险。

---

## 附录 A：21 库速查表

| # | 文件 | 主类 / 子类数 | 暴露形态 | 目标类型 / namespace | 关键 helper |
|---|---|---|---|---|---|
| 1 | `AngelscriptActorLibrary.h` | 1 | mixin | `AActor` | `SetActorRotationQuat` / `SetActorRelativeRotationQuat` / `GetAttachedActors` |
| 2 | `AngelscriptComponentLibrary.h` | 1 | mixin | `USceneComponent` | `GetRelativeLocation` / `SetRelative*` / `AttachToComponent` |
| 3 | `AngelscriptFrameTimeMixinLibrary.h` | 1 | mixin | `FQualifiedFrameTime` | `AsSeconds` |
| 4 | `AngelscriptHitResultLibrary.h` | 1 | mixin | `FHitResult` | `GetActor` / `GetComponent` / `Reset` / `SetbBlockingHit` |
| 5 | `AngelscriptLevelStreamingLibrary.h` | 1 | mixin（仅 WITH_EDITOR） | `ULevelStreaming` | `GetShouldBeVisibleInEditor` |
| 6 | `AngelscriptMathLibrary.h` | 10（1 主 + 8 子库 + 3 静态） | namespace + 8 个 namespace-regression | `Math` / `FRotator` / `FQuat` / `FTransform` / `FVector` / `FVector3f` / `FRotator3f` / `FQuat4f` / `FTransform3f` | `LerpShortestPath` / `Wrap` / `Modf` / `Size2D` |
| 7 | `AngelscriptScriptLibrary.h` (+ .cpp) | 1 | namespace | `Script` | `GetNameOfGlobalVariableBeingInitialized` |
| 8 | `AngelscriptWorldLibrary.h` | 1 | mixin | `UWorld` | `GetStreamingLevels` |
| 9 | `GameplayLibrary.h` | 1 | namespace | `UGameplayLibrary`（隐式） | `AsyncSaveGameToSlot` / `AsyncLoadGameFromSlot` |
| 10 | `GameplayTagContainerMixinLibrary.h` | 1 | mixin | `FGameplayTagContainer` | `AppendTags` / `HasTag` / `Filter` / `MatchesQuery` |
| 11 | `GameplayTagMixinLibrary.h` | 1 | mixin | `FGameplayTag` | `MatchesTag` / `RequestDirectParent` |
| 12 | `GameplayTagQueryMixinLibrary.h` | 1 | mixin | `FGameplayTagQuery` | `Matches` / `IsEmpty` / `GetDescription` |
| 13 | `InputComponentScriptMixinLibrary.h` | 3 | mixin × 3 | `UInputComponent` / `APlayerController` / `UPlayerInput` | `BindAction` / `PushInputComponent` / `AddActionMapping` |
| 14 | `RuntimeCurveLinearColorMixinLibrary.h` | 1 | mixin | `FRuntimeCurveLinearColor` | `AddDefaultKey` |
| 15 | `RuntimeFloatCurveMixinLibrary.h` | 1 | mixin（双目标） | `FRuntimeFloatCurve` + `UCurveFloat` | `GetFloatValue` / `GetTimeRange` / `AddCurveKey* ×8` |
| 16 | `SoftReferenceStatics.h` | 1（空壳） | 反射壳 | — | `FOnSoftObjectLoaded` / `FOnSoftClassLoaded` 委托 |
| 17 | `SubsystemLibrary.h` | 1 | namespace | `USubsystemLibrary`（隐式） | `GetEngineSubsystem` / `GetWorldSubsystem` / `GetGameInstanceSubsystem` |
| 18 | `UAssetManagerMixinLibrary.h` | 1 | mixin | `UAssetManager` | `GetPrimaryAsset*` / `CallOrRegister_OnCompletedInitialScan` |
| 19 | `WidgetBlueprintStatics.h` | 2 | namespace + mixin | `UWidgetBlueprintStatics`（隐式）+ `UWidget` | `CreateWidget` / `GetRenderTransform` |
| 20 | `WorldCollisionStatics.h` | 1（空壳） | 反射壳 | — | `FScriptTraceDelegate` / `FScriptOverlapDelegate` 委托 |

合计 21 份文件（20 .h + 1 .cpp），其中 12 份启用真 mixin meta（含 `WidgetBlueprintStatics` 的 `UAngelscriptWidgetMixinLibrary` 子类、`InputComponentScriptMixinLibrary` 的 3 个子类）；4 份纯命名空间；2 份反射壳；3 份混合（`AngelscriptMathLibrary` / `WidgetBlueprintStatics` / `InputComponentScriptMixinLibrary`）。

---

## 附录 B：调试 / 避坑清单

1. **`asALREADY_REGISTERED -13`**：自动注入路径 + `Bind_FunctionLibraryMixins` 重复注册同签名。修法：`HasMethod` / `GetMethodByDecl` 幂等守护，重载多的用前者，签名稳的用后者。
2. **mixin 没生效（函数被默默退化为命名空间静态）**：`UCLASS(meta=(ScriptMixin="X"))` 写了，但 `static UFUNCTION` 第 0 参数类型对不上 `X`。`Helper_FunctionSignature.h:340` 的 `bFoundMixin = false` 分支吞掉这个错——不报错、退到 `bStaticInScript = true`。诊断：跑 `Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures` 加你的库做样本。
3. **多目标 mixin 顺序敏感**：`UCLASS(meta=(ScriptMixin="A B"))` 第一个匹配第 0 参数类型的目标胜出。如果两个目标都可隐式转换，结果不确定。修法：拆 sub-class（如 `InputComponentScriptMixinLibrary` 的 3 类）。
4. **`Late+100` 时序依赖**：自动注入路径假定目标类型已在 `Bind_<TargetType>.cpp` 中按 `EOrder::Early ~ Late` 注册完成。如果新增的 mixin 目标不在这条线（如某个 `Bind_*.cpp` 写成了 `EOrder::Late+200`），自动注入会找不到 `ExistingClass`。修法：检查目标的 `Bind_*.cpp` `EOrder` 不应晚于 `Late+99`。
5. **`out` 引用 / wrapper / 跨类型转换**：自动注入路径走不了，必须走 `Bind_FunctionLibraryMixins.cpp` 手工 lambda。形态参考 §3.1 子段 3。
6. **UHT 反射函数表 fallback 慢**：UHT 标记某些重载为 unresolved → 反射 dispatch。形态参考 §3.2 类 1.5——给一份 `Bind_<Subject>ScriptMixins.cpp` 用 `RegisterFunctionBinding + ERASE_FUNCTION_PTR` 写精确指针。
7. **`GetMethodByDecl` 假阴性**：自动注入生成的 declaration 与手写不一致。改用 `HasMethod`（按方法名匹配）。
8. **`ScriptCallable` vs `BlueprintCallable`**：fork 主体改写为 `BlueprintCallable`，导致 `*MixinLibrary` 函数全部出现在蓝图节点面板，污染蓝图体验（`Syntax_Mixin.md` §6.4）。重启 `ScriptCallable` 死注释需要改 `Helper_FunctionSignature.h` 的 meta 分发逻辑——目前不在主线。
9. **`AngelscriptMathLibrary.h` 8 处 namespace-regression 注释**：不要照抄。新增数学 helper 直接走 `*MixinLibrary` 文件 + 启用 ScriptMixin meta，不要重蹈数学库的命名空间退化。
10. **测试基线**：改 `FunctionLibraries/` 任何文件，至少跑 `Angelscript.TestModule.Engine.BindConfig.*` + `Angelscript.TestModule.FunctionLibraries.*` 两组——前者守住签名级别行为，后者守住运行时调用结果。

---

## 小结

- `FunctionLibraries/` 21 份 header 是 `Bind_*.cpp` 的功能扩展层：Bind 搬"类型骨架"，FunctionLibrary 在已搬来的类型上"挂功能函数"。两者职责互不重叠，由 `EOrder::Late+100` 的 `Bind_Defaults` 把后者按 `ScriptMixin` meta 自动改写成前者已注册类型的成员方法。
- 21 份文件按 UCLASS-meta 状态四象限分为：12 份启用真 mixin / 1 份命名空间静态退化 / 4 份纯命名空间 / 2 份纯反射壳 / 2 份混合形态。`AGENTS.md` 说的"21 mixin helper 库"这个数字在文件级精确，但语义上**只有 12 份是真 mixin**。
- 自动注入路径覆盖不了的边角签名（`out` 引用 / lambda wrapper / UHT 重载消歧）由 5 份 `Bind_*.cpp` 补漏：`Bind_FunctionLibraryMixins.cpp` 在 `Late+110` 手挂 `Method(decl, λ)`，`Bind_InputComponentScriptMixins.cpp` / `Bind_AssetManagerScriptMixins.cpp` 在 `Late+49` 用 `RegisterFunctionBinding` 写精确函数指针，`Bind_TSoftObjectPtr.cpp` / `Bind_WorldCollision.cpp` 通过 `#include` 拖入空壳 helper 让 UHT 拾起 dynamic delegate。
- 命名约定有三组（`Angelscript*Library.h` / `*MixinLibrary.h` / `*Statics.h`），但这只是**意图提示**，真实暴露形态必须看 `UCLASS` meta + `UFUNCTION` flag 组合——`*Statics.h` 既可能是真静态库也可能是反射壳；`*MixinLibrary.h` 也可能 meta 注释关闭走命名空间退化。
- 单元测试两层：`AngelscriptTest/Bindings/Angelscript*FunctionLibraryTests.cpp` 17 份覆盖运行时行为；`AngelscriptTest/Core/AngelscriptFunctionLibrarySignatureTests.cpp` 一份守住第 0 参数剥离 + `bStaticInScript` 翻转的签名级别正确性。改 `FunctionLibraries/` 必须看 `Engine.BindConfig.ProductionScriptMixinSignatures` 不掉绿。
