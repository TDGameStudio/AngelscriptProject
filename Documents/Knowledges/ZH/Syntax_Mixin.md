# Syntax_Mixin — `mixin` 关键字与 `ScriptMixin` 元数据实现原理

> **所属前缀**: Syntax_
> **关注层面**: 语法机制与实现原理（非用户使用指南）
> **关键源码**: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp` · `as_builder.cpp` · `Binds/Helper_FunctionSignature.h` · `Binds/Bind_BlueprintType.cpp` · `Binds/Bind_FunctionLibraryMixins.cpp` · `FunctionLibraries/*Mixin*.h`
> **关联文档**: `Documents/Guides/ASSDK_Fork_Differences.md` §5（与 vanilla AngelScript 的差异）· `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` §7.11（`ArgumentDefaults` 联动裁剪）· `Documents/Plans/Plan_HazelightScriptFeatureParity.md` §FunctionLibrary 实现面（运行时 / Editor 库与 Mixin 划分）

---

## 概览：两条彼此独立的 Mixin 路径

`mixin` 在当前插件里是一个高度重载的概念，背后是**两条互不依赖的实现路径**——只是英文名字相同，初学者最容易把它们混为一谈：

```text
"mixin" 概念的两种含义

[Path 1] AS 语言层的 mixin 关键字
    形如:    mixin void DoSomething(AActor Self, FVector Location) { ... }
    实现:    AS Parser ParseMixin -> ttMixin token + ParseFunction
             -> as_builder 把声明登记到模块全局函数表
             -> 调用点 Self.DoSomething(Loc) 由 AS 编译器在前端展开
    范围:    .as 脚本内部声明，作用域随模块导入

[Path 2] C++ 反射层的 ScriptMixin 元数据
    形如:    UCLASS(meta = (ScriptMixin = "AActor"))
             class UAngelscriptActorLibrary : public UObject { ... };
    实现:    UFunction meta -> Helper_FunctionSignature.h 第 0 参数剥离
             -> ClassName 改写为目标类型 -> 在类绑定期注册为成员方法
    范围:    C++ BlueprintFunctionLibrary 风格的扩展，全局对所有脚本可见
```

两条路径**不共享任何数据结构**，只是关键字字面量重合。本文按这两条路径分别展开，最后汇总四种实际触发方式、测试覆盖布局以及当前仓库的现状反思。

---

## 一、路径①：AS 语言层的 `mixin` 关键字

### 1.1 词法与解析：fork 砍掉了 `mixin class`

vanilla AngelScript 2.38 同时支持 `mixin class` 与 `mixin function` 两种形态。当前 fork 与 Hazelight 同步**主动砍掉了 `mixin class`**——理由是它与 UE `UClass` 单根继承模型冲突，与 fork "AS 类必须能映射到 UClass" 的核心契约不兼容。

`as_parser.cpp:3671-3686` 直接把 `MIXIN` 的 BNF 限定到函数声明：

```cpp
// BNF:1: MIXIN         ::= 'mixin' FUNCTION
asCScriptNode *asCParser::ParseMixin()
{
    auto* tokenNode = ParseToken(ttMixin);
    if (tokenNode == nullptr)
        return nullptr;

    // A mixin token must be followed by a function declaration
    auto* funcNode = ParseFunction();
    if (funcNode == nullptr)
        return tokenNode;

    tokenNode->next = funcNode->firstChild;
    funcNode->firstChild = tokenNode;
    return funcNode;
}
```

而在脚本顶层 dispatcher（`as_parser.cpp:2453-2458`）里，`ttMixin` token 被严格映射到 `ParseMixin()`，不会绕进 `ParseClass()`：

```cpp
else if( t1.type == ttMixin )
    node->AddChildLast(ParseMixin());
```

也就是说，写 `mixin class Foo {}` 不会在解析期被偷偷吞掉，而是**会一路报错到 `TXT_MIXIN_*` 文本族**——`as_texts.h:171-175` 仍然保留这些错误字符串，是为了让 `as_builder.cpp` 的 mixin class 残余路径在被误激活时给出可读提示，而不是回滚到 vanilla 行为。

`Inheritance.Mixin` 这条**负向断言**测试就是钉死这条边界（详见 §五）。

### 1.2 语义：第一个参数即"调用者本身"

`mixin` 函数在前端展开时由 AS 编译器把"`Self.Method(args...)`"重写成"`Method(Self, args...)`"。语义上：

- **声明端**：第一个参数（无论值/引用/句柄）就是调用方对象，必须显式写出来。
- **调用端**：必须以"成员方法"语法调用；不能直接以全局函数语法调用。
- **可见性**：`mixin` 函数是模块全局函数，被 import 后即可在该模块的任意位置作为目标类型的方法调用。

仓库里官方示例（`Script/Examples/Core/Example_MixinMethods.as`）就是最小 cookbook：

```angelscript
mixin void ExampleMixinActorMethod(AActor Self, FVector Location)
{
    Print("Mixin invoked on: " + Self.GetClass().GetName());
}

void Example_MixinMethod()
{
    AActor ActorReference;
    ActorReference.ExampleMixinActorMethod(FVector(0.0, 0.0, 100.0));
}
```

### 1.3 与 vanilla AS 行为差异

| 维度 | vanilla AS 2.38 | 当前 fork（与 Hazelight 一致） |
|---|---|---|
| `mixin function` | 支持 | 支持 |
| `mixin class` | 支持 | **不支持**，编译失败 |
| 关键字 | `mixin` | `mixin` |
| 调用语法 | 仅成员方法 | 仅成员方法 |
| 第 0 参数语义 | 调用者 | 调用者 |

完整差异记录见 `Documents/Guides/ASSDK_Fork_Differences.md` §5。

---

## 二、路径②：C++ 反射层的 `ScriptMixin` 元数据

### 2.1 元数据 key 注册

`Helper_FunctionSignature.h:23-32` 在静态 FName 区集中声明了 mixin 相关的所有 meta key：

```cpp
static const FName NAME_Signature_ScriptMixin("ScriptMixin");
// ...
static const FName NAME_Signature_ScriptMethod("ScriptMethod");
```

- `ScriptMixin`：UCLASS 级 meta，值是空格分隔的目标类型名（见 §三.3.1）。
- `ScriptMethod`：UE 5.7+ 增量，挂在单个 UFUNCTION 上，由当前 fork 自行实现"从第 0 参数推断目标类型"逻辑。

### 2.2 核心逻辑：`Helper_FunctionSignature.h::InitFromFunction` 的第 0 参数剥离

整个 ScriptMixin 注入的核心**只有一段**——`Helper_FunctionSignature.h:329-404`，发生在 `FAngelscriptFunctionSignature::InitFromFunction()` 中处理静态 UFUNCTION 的分支：

```cpp
// Figure out the namespace for static functions
bool bForceConst = false;
bStaticInUnreal = Function->HasAnyFunctionFlags(FUNC_Static);
if (bStaticInUnreal)
{
    FString Namespace = GetScriptNamespaceForClass(InType, Function);
    bGlobalScope = HasFuncMeta(NAME_Signature_ScriptGlobalScope);

    // If our class is marked as a 'script mixin', and our argument matches, bind it as a member
    bool bFoundMixin = false;
    const FString& MixinClasses = GetClassMetaRef(NAME_Signature_ScriptMixin);

    // UE 5.7+: function-level ScriptMethod metadata is no longer propagated to class-level
    // ScriptMixin by UHT. When the class has no ScriptMixin but the function itself carries
    // ScriptMethod, treat the first parameter's type as the mixin target.
    bool bFunctionLevelScriptMethod = false;
    if (MixinClasses.Len() == 0 && HasFuncMeta(NAME_Signature_ScriptMethod))
    {
        bFunctionLevelScriptMethod = true;
    }

    if ((MixinClasses.Len() != 0 || bFunctionLevelScriptMethod) && ArgumentTypes.Num() > 0
        && (ArgumentTypes[0].IsObjectPointer()
            || ArgumentTypes[0].Type->IsUnresolvedObjectPointer()
            || ArgumentTypes[0].bIsReference))
    {
        TArray<FString> MixinList;
        MixinClasses.ParseIntoArray(MixinList, TEXT(" "));

        // UE 5.7+: when function-level ScriptMethod is set but no class-level
        // ScriptMixin exists, use the first parameter's type as the mixin target.
        if (bFunctionLevelScriptMethod && MixinList.Num() == 0)
        {
            FString FirstParamType = ArgumentTypes[0].Type->GetAngelscriptTypeName(ArgumentTypes[0]);
            MixinList.Add(FirstParamType);
        }

        FString FirstParamType = ArgumentTypes[0].Type->GetAngelscriptTypeName(ArgumentTypes[0]);
        // ... 处理 unresolved object pointer 的特殊路径 ...
        for (const FString& Mixin : MixinList)
        {
            if (FirstParamType == Mixin || UnresolvedObjectMixinType == Mixin)
            {
                if (ArgumentTypes[0].bIsConst)
                    bForceConst = true;

                ArgumentTypes.RemoveAt(0);
                ArgumentNames.RemoveAt(0);
                ArgumentDefaults.RemoveAt(0);
                ClassName = Mixin;

                bStaticInScript = false;
                bFoundMixin = true;

                if (WorldContextArgument >= 0)
                    WorldContextArgument -= 1;
                if (DeterminesOutputTypeArgument >= 0)
                    DeterminesOutputTypeArgument -= 1;
                break;
            }
        }
    }

    if (!bFoundMixin)
    {
        ClassName = Namespace;
        bStaticInScript = true;
    }
}
```

要点：

1. **触发前置条件**：UFUNCTION 必须 `FUNC_Static`、第 0 参数必须是对象指针/未解析对象指针/引用、且类有 `ScriptMixin` meta 或函数有 `ScriptMethod` meta（UE 5.7+ 新增分支）。
2. **三组并行数组同步裁剪**：`ArgumentTypes` / `ArgumentNames` / `ArgumentDefaults` 三者必须同步 `RemoveAt(0)`，否则下游读出的参数索引会错位。这一约束的完整推导见 `Syntax_DefaultStatement.md` §7.11。
3. **索引型字段补偿**：`WorldContextArgument` 和 `DeterminesOutputTypeArgument` 是按索引指向参数的字段，剥离 1 个参数后必须 `-= 1`，否则 WorldContext 推断与输出类型推断会指错位置。
4. **`const` 传播**：第 0 参数若是 `const T&`，整个方法被强制声明为 `const` 成员，与"`this` 是 const"语义一致。
5. **`MixinClasses` 的多目标**：UCLASS meta 上空格分隔多个目标类型时（如 `RuntimeFloatCurveMixinLibrary` 的 `"FRuntimeFloatCurve UCurveFloat"`），同一组函数会被尝试在每个目标上注册一次，第一个匹配 `FirstParamType` 的目标胜出。
6. **回退路径**：`bFoundMixin = false` 时退回 `bStaticInScript = true` 的命名空间静态函数——也就是说，`UCLASS` 上挂了 `ScriptMixin` 但函数签名第 0 参数对不上，那条函数会**默默退化为静态函数**，不会报错。这是排查"为什么我的 mixin 没生效"时最容易踩的坑。

### 2.3 类生成期：把签名注册成成员方法

裁剪好的 `FAngelscriptFunctionSignature.ClassName` 后续被 `Bind_BlueprintType.cpp:1318-1322` 的 `BindFunctionWithAdditionalName()` 消费：

```cpp
else if (Function->HasAnyFunctionFlags(FUNC_BlueprintCallable | FUNC_BlueprintPure))
    BindBlueprintCallable(InType, Function, DBMethod, *TargetName);
else if (Function->HasMetaData(NAME_ScriptCallable))
    BindBlueprintCallable(InType, Function, DBMethod, *TargetName);
```

`InType` 就是 `ClassName` 解析出的目标 `FAngelscriptType`，这一步把"原本属于 BlueprintFunctionLibrary 的 static UFUNCTION"挂载成"目标类型的成员方法"。

注意 `else if (HasMetaData(NAME_ScriptCallable))` 这条分支——它是 Hazelight 风格的"脚本可见但蓝图不可见"通路：函数即使没有 `BlueprintCallable` 也能通过 `ScriptCallable` meta 进入脚本反射。当前 fork 的 `FunctionLibraries/` 大量保留了 Hazelight 上游对照位置但**整体改写成了 `BlueprintCallable`**（详见 §六），所以这条 `ScriptCallable` 分支在 runtime 上**实际命中很少**，主要在 native 层（`UObjectInWorld.h` / `UObjectTickable.h`）和 editor 层（`AssetToolsStatics.h` / `EditorStatics.h`）使用。

### 2.4 `Bind_FunctionLibraryMixins.cpp` 阶段：补漏与冲突回避

`ScriptMixin` meta 路径在 `EOrder::Late+100` 自动注册（`Bind_BlueprintType.cpp` 内部的 `Bind_Defaults`）。但有些方法签名（含 `out` 引用、特殊 wrapper、需要直接 lambda 的形式）不适合走纯反射路径，由 `Bind_FunctionLibraryMixins.cpp`（`EOrder::Late+110`）补充——这是 mixin 的第三种触发路径，在 §三.3.3 单独展开。

---

## 三、Mixin 的四种触发方式

把上面两条机制路径再细分一下，开发者实际能用到的 mixin 触发方式一共有四种：

### 3.1 方式 1：脚本侧 `mixin function`（路径①）

写法、范围、限制见 §一。最小例子见 `Script/Examples/Core/Example_MixinMethods.as`。

### 3.2 方式 2：`UCLASS(meta=(ScriptMixin="..."))` 类级 meta（路径②主形态）

写法：在 `BlueprintFunctionLibrary` 风格的 UObject 子类上挂 meta，整个 library 内**所有静态 UFUNCTION**自动按 §二.2.2 的规则尝试 mixin 注入。

```cpp
// AngelscriptFrameTimeMixinLibrary.h:7-18
UCLASS(meta = (ScriptMixin = "FQualifiedFrameTime"))
class ANGELSCRIPTRUNTIME_API UAngelscriptFrameTimeMixinLibrary : public UObject
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category = "FrameTime")
    static double AsSeconds(const FQualifiedFrameTime& Target)
    {
        return Target.AsSeconds();
    }
};
```

支持空格分隔多目标类型：

```cpp
// RuntimeFloatCurveMixinLibrary.h:16-17
UCLASS(meta = (ScriptMixin = "FRuntimeFloatCurve UCurveFloat"))
class ANGELSCRIPTRUNTIME_API URuntimeFloatCurveMixinLibrary : public UObject
```

当前仓库**实际启用**这条 meta 的 library（截至 `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/`）：

| 文件 | 目标类型 |
|---|---|
| `AngelscriptFrameTimeMixinLibrary.h` | `FQualifiedFrameTime` |
| `GameplayTagQueryMixinLibrary.h` | `FGameplayTagQuery` |
| `RuntimeFloatCurveMixinLibrary.h` | `FRuntimeFloatCurve` + `UCurveFloat` |
| `RuntimeCurveLinearColorMixinLibrary.h` | `FRuntimeCurveLinearColor` |
| `WidgetBlueprintStatics.h`（`UAngelscriptWidgetMixinLibrary`） | `UWidget` |
| `AngelscriptLevelStreamingLibrary.h` | `ULevelStreaming` |
| `AngelscriptActorLibrary.h` | `AActor` |
| `AngelscriptComponentLibrary.h` | `USceneComponent` |

### 3.3 方式 3：UE 5.7+ 函数级 `meta=(ScriptMethod)`（路径②增量）

UE 5.7 升级后 UHT 不再把函数级 `ScriptMethod` 元数据传播到类级 `ScriptMixin`，当前 fork 在 `Helper_FunctionSignature.h:341-348` 增加了显式回退：函数自身有 `ScriptMethod` meta 且第 0 参数能解析时，把第 0 参数类型当作 mixin 目标。

由 `Angelscript.TestModule.Engine.BindConfig.FunctionLevelScriptMethodUsesFirstParameterAsMixin` 守住（详见 §五）。

### 3.4 方式 4：`Bind_*.cpp` 手动 `Method(...)` 注册（路径②补漏）

适用于含 `out` 引用、需要 lambda wrapper、或有冲突需要幂等检查的场景。`Bind_FunctionLibraryMixins.cpp:47-75` 是典型样板：

```cpp
auto RuntimeFloatCurve_ = FAngelscriptBinds::ExistingClass("FRuntimeFloatCurve");
asITypeInfo* RuntimeFloatCurveType = RuntimeFloatCurve_.GetTypeInfo();
if (!RuntimeFloatCurve_.HasMethod(TEXT("AddDefaultKey")))
{
    RuntimeFloatCurve_.Method(
        "void AddDefaultKey(float32 InTime, float32 InValue)",
        [](FRuntimeFloatCurve* Target, float InTime, float InValue)
        {
            URuntimeFloatCurveMixinLibrary::AddDefaultKey(*Target, InTime, InValue);
        });
}
// ...
RuntimeFloatCurve_.Method(
    "void GetTimeRange(float32&out MinTime, float32&out MaxTime) const",
    [](const FRuntimeFloatCurve* Target, float& MinTime, float& MaxTime)
    {
        URuntimeFloatCurveMixinLibrary::GetTimeRange(*Target, MinTime, MaxTime);
    });
```

要点：

- `ExistingClass(name).Method(decl, lambda)` 直接挂成员方法。
- `HasMethod(...)` / `GetMethodByDecl(...)` 在前面做幂等检查——因为 `ScriptMixin` meta 路径已经在 `EOrder::Late+100` 注册过基础函数，本文件运行在 `EOrder::Late+110` 是补漏，必须避开重复注册（`asALREADY_REGISTERED -13` 错误）。
- 也可以同时用 `FAngelscriptBinds::FNamespace` + `BindGlobalFunction(...)` 让脚本既能 `Curve.GetTimeRange(...)` 又能 `URuntimeFloatCurveMixinLibrary::GetTimeRange(Curve, ...)` 双向调用。

---

## 四、Mixin 与 `ArgumentDefaults` 的协同

第 0 参数被裁剪时，三组并行数组（`ArgumentTypes`、`ArgumentNames`、`ArgumentDefaults`）必须同步裁剪，否则下游 default 值展开会错位。

完整推导（含副作用：原 C++ 静态函数第 0 参数若设了 `CPP_Default_*` meta，默认值会随 `RemoveAt(0)` 一起丢失，但因为第 0 参数已是 mixin 目标对象，必须由调用方提供，丢失默认值无影响）见 `Syntax_DefaultStatement.md` §7.11。

---

## 五、测试覆盖布局

按"测的是哪一层"分组，当前仓库的 mixin 自动化测试一共有以下几条专测，加上一批 `*MixinLibrary` 的运行时行为测试。

### 5.1 路径①：`mixin function` 语法边界

| Automation | 文件 | 验证内容 |
|---|---|---|
| `Angelscript.TestModule.ScriptExamples.MixinMethods` | `Examples/AngelscriptScriptExampleMixinMethodsTest.cpp` | `Example_MixinMethods.as` 完整编译通过 |
| `Angelscript.TestModule.AngelScriptSDK.ASSDK.OOP.MixinNamespace` | `AngelScriptSDK/AngelscriptASSDKOOPTests.cpp` | ASSDK 风格 native 直测：`mixin void AddToCounter(Counter& Self, int Delta)` 编译 + 运行结果断言 |
| `Angelscript.TestModule.Angelscript.Inheritance.Mixin` | `Angelscript/AngelscriptInheritanceTests.cpp` | **负向**断言 `mixin class SharedValueMixin {}` 编译失败，守住 fork 不接受 `mixin class` 这条边界 |

### 5.2 路径②：`ScriptMixin` 元数据注入

| Automation | 文件 | 验证内容 |
|---|---|---|
| `Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures` | `Core/AngelscriptFunctionLibrarySignatureTests.cpp` | 用 FrameTime / Widget / GameplayTagQuery 三个生产 mixin 库做样本，逐项断言 `bStaticInScript == false`、参数类型剥离正确、`ArgumentNames[0]` 是被裁剪后的真实参数名 |
| `Angelscript.TestModule.Engine.BindConfig.FunctionLevelScriptMethodUsesFirstParameterAsMixin` | `Core/AngelscriptBindConfigTests.cpp` | UE 5.7+ 函数级 `ScriptMethod` 自动推断 mixin 目标 |

### 5.3 GAS 端到端 mixin 测试

`Angelscript.TestModule.Engine.GAS.AttributeChangedDataMixin.AccessorsExposeWrappedCallbackDataAndNullPaths`（`Core/AngelscriptGASAttributeChangedDataMixinTests.cpp`）覆盖 `FAngelscriptAttributeChangedData` mixin accessor 的 control（`GEModData == nullptr`）+ callback（实际触发 GameplayEffect）双路径，是当前 mixin 测试里最深的一条。

### 5.4 各 `*MixinLibrary` 的运行时行为

| `*MixinLibrary` | 对应 Automation |
|---|---|
| `AngelscriptFrameTimeMixinLibrary` | `Angelscript.TestModule.FunctionLibraries.FrameTimeAsSeconds` |
| `RuntimeFloatCurveMixinLibrary` | `FunctionLibraries.RuntimeFloatCurveInstanceSurface` + `Parity.RuntimeCurveLinearColorCompile` |
| `RuntimeCurveLinearColorMixinLibrary` | `FunctionLibraries.RuntimeCurveLinearColorAddDefaultKey` |
| `UAssetManagerMixinLibrary` | `FunctionLibraries.AssetManagerNullAndInvalidCallbackGuards` |
| `GameplayTagMixinLibrary` | `FunctionLibraries.GameplayTagHierarchySemantics` 等 |
| `GameplayTagContainerMixinLibrary` | `FunctionLibraries.GameplayTagContainerHierarchyAndFilters` + `GameplayTagContainerRemoveTagMiss` |
| `UAngelscriptWidgetMixinLibrary`（`WidgetBlueprintStatics.h`） | `FunctionLibraries.WidgetRenderTransformNullGuard` + `Parity.UserWidgetPaintCompile` |
| `InputComponentScriptMixinLibrary` | **当前没有以 "InputComponent" 为名的运行时专测**，是显式可见的覆盖空缺 |

---

## 六、当前项目 Mixin 现状反思

### 6.1 名实相符的 mixin 库（少数）

`FunctionLibraries/` 下**真正启用 `UCLASS(meta=(ScriptMixin=...))`** 的库只有 §三.3.2 列出的 8 个。它们走完整 ScriptMixin 路径，被 §五.5.2 的 `ProductionScriptMixinSignatures` 测试守住。

### 6.2 名字承诺没有兑现的 mixin 库（多数）

仓库里另一批文件名带 `Mixin` 但 `UCLASS(meta = (ScriptMixin = "..."))` 实际**被整行注释**、退化成 `UCLASS(Meta = ())` 的库，包括：

- `UAssetManagerMixinLibrary.h`（注释 `ScriptMixin = "UAssetManager"`）
- `GameplayTagMixinLibrary.h`（注释 `ScriptMixin = "FGameplayTag"`）
- `GameplayTagContainerMixinLibrary.h`（注释 `ScriptMixin = "FGameplayTagContainer"`）
- `InputComponentScriptMixinLibrary.h` 三个子类（注释 `UInputComponent` / `APlayerController` / `UPlayerInput`）
- `AngelscriptMathLibrary.h` 内 `UAngelscriptFVectorMixinLibrary` 等 8 个数学子类
- `Core/GAS/AngelscriptAbilitySystemComponent.h` 内的 `UAngelscriptAttributeChangedDataMixinLibrary`
- `AngelscriptHitResultLibrary.h`、`AngelscriptWorldLibrary.h` 等

这些库的"Mixin"行为**实际靠 `BlueprintCallable` 反射回退**（`BlueprintCallableReflectiveFallback`）实现：因为这些函数恰好是 `static + 第一个参数是目标类型`，反射回退路径会把它们识别为成员方法。**功能上等价于走 `ScriptMixin` 注入，但语义代价**是它们全部以 BlueprintCallable 节点形式出现在蓝图编辑器面板里，与 Hazelight 风格的"脚本独占可见"不一致。

### 6.3 `//UFUNCTION(ScriptCallable)` 死注释

同源问题：Hazelight 上游的 `UFUNCTION(ScriptCallable)` 标记被整行注释、改写成 `UFUNCTION(BlueprintCallable)`。截至目前，`FunctionLibraries/` 下保留的此类死注释合计 **270+ 行**，单 `AngelscriptMathLibrary.h` 一个文件就占 **97 行**。

`ScriptCallable` meta key 在绑定层是**真实存在且仍然被识别**的（`Bind_BlueprintEvent.cpp:551`、`Bind_BlueprintType.cpp:46/1321`），所以这些死注释不是无意义的草稿，而是**Hazelight 上游对照位置 + 一条隐含 TODO**：未来若想恢复"脚本可见、蓝图不可见"的语义，照注释打开即可。

### 6.4 后果

1. 名字叫 `*MixinLibrary` 但其实没挂 `ScriptMixin` meta，新人会以为它们都走 mixin 注入路径；
2. `*MixinLibrary` 函数全部以 BlueprintCallable 出现在蓝图节点面板，蓝图体验被污染；
3. 270+ 行死注释提高了文件阅读成本——每个函数需要读两遍 UFUNCTION 才能确定哪行生效。

### 6.5 已落地的语法噪音清理（2026-04-28，工作树待提交）

截至 2026-04-28 工作树状态（**未提交**），15 个 `FunctionLibraries/*.h` 已把 §6.4 第 3 项的可视噪音清掉（净减 187 行，详细文件清单见 `Plan_FunctionLibrariesCleanup.md` 的"已完成基线变更详单"章节）：

- 删除全部 `//UFUNCTION(ScriptCallable, ...)` 死注释（净减 270+ 行）；
- 修复 `Meta = ()` 空占位、`Meta = (BlueprintCallable)` 嵌套笔误；
- 保留 17 处 `//UCLASS(Meta = (ScriptMixin = "..."))` 类级锚点 + 7 个文件加文件头一段统一的 parity note；
- 行为零变化：`ProductionScriptMixinSignatures` 1/1、`FunctionLibraries.*` 23/23 PASS。

但本次清理**只解决了 §6.4 的第 3 项**（噪音），**没有解决第 1、2 项**（名实分离 + BP 污染），也没有恢复死注释里携带的功能性 meta（`ScriptTrivial / NotAngelscriptProperty / ScriptName 重载`）—— 这些 meta 在 fork 改造时早已从 active 行丢失。此外，`AngelscriptActorLibrary.h` 的 27 个裸 `UFUNCTION()` 函数因不进入 `Bind_BlueprintType.cpp:1428-1437` 任一绑定分支，整文件高度疑似 dead code。

### 6.6 ScriptMixin 关闭文件并非统一走同一条路径

后续若要重启被关闭的 `//UCLASS(Meta = (ScriptMixin = "..."))`，必须先**审计每个文件的实际 AS 注入路径**——8 个文件至少存在三类不同状态：

- **类 1：已被 `Bind_*.cpp` 手工 lambda 接管**（fork 历史形态，2026-04-28 P4.4 已迁移完毕、当前实例数为 0）。历史典型例子是 `AngelscriptWorldLibrary.h` × `Bind_UWorld.cpp:79-82`：fork 早期用 `UWorld_.Method("TArray<ULevelStreaming> GetStreamingLevels() const", [...] { return UAngelscriptWorldLibrary::GetStreamingLevels(World); })` 显式注册成员方法、关闭 ScriptMixin meta，目的是强制 AS 端签名为 `TArray<ULevelStreaming>` 而非反射推导的 `TArray<ULevelStreaming@>`。**P4.4 实测结论**：删除手工 lambda + 重启 ScriptMixin 后 AS 调用 `World.GetStreamingLevels().Num()` / `[i] != Expected` 等用法零回归（2 个 WorldStreaming 测试 PASS），手工 lambda 是**冗余的历史包袱**——fork 已处理 `TObjectPtr` 路由，UObject 容器在 AS 中按引用语义传递，`@` 与无 `@` 形式在调用语义上等价。fork 现状：World 已切回 Hazelight 上游形态（`UCLASS(Meta = (ScriptMixin = "UWorld"))` + 无 `Bind_UWorld.cpp` 接管）。未来若有新文件被引入手工 lambda 模式，应重做"是否真有签名差异需求"的评估。
- **类 2：走 `BlueprintCallableReflectiveFallback` 反射兜底**。函数没有 native function pointer entry，由 `Bind_BlueprintCallable.cpp:74-91` 的 `BindBlueprintCallableReflectiveFallback` 接住。这类文件重启 ScriptMixin 后注入路径会切换，需要逐函数对比签名是否兼容。
- **类 3：仅静态命名空间形式可见**。函数没被任何路径绑定为成员方法，AS 脚本里只能写 `Lib::Func(target, ...)`。这类文件重启 ScriptMixin 是**净增益**（对齐 Hazelight，提供成员调用形式）。

判断启发式：grep `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下哪些 `Bind_*.cpp` `#include` 了对应 `FunctionLibraries/*.h`，命中即类 1 嫌疑大。完整审计矩阵由 `Plan_FunctionLibrariesCleanup.md` Phase 4 的 P4.1 任务承接。

后续推进由独立计划 `Documents/Plans/Plan_FunctionLibrariesCleanup.md` 承接：盘点 meta 损失矩阵、决策 ActorLibrary 处置（删除 / 反射接入 / 手工迁移）、批量恢复 active 行功能 meta、按文件分类评估 ScriptMixin 重启可行性（类 3 优先、类 2 谨慎、类 1 单独决策）。本文不在此展开行动建议，仅作客观现状记录。

---

## 七、与参考实现的差异

| 维度 | vanilla AS 2.38 | Hazelight | 当前 fork |
|---|---|---|---|
| `mixin function` 语法 | 支持 | 支持 | 支持 |
| `mixin class` 语法 | 支持 | **不支持** | **不支持**（与 Hazelight 一致） |
| `UCLASS(meta=(ScriptMixin="..."))` | 不适用 | 支持 | 支持，逻辑与 Hazelight 一致 |
| 函数级 `meta=(ScriptMethod)` 自动推断 | 不适用 | 不支持 | **支持**（UE 5.7 适配增量，fork 独有） |
| `ScriptCallable` meta 通路 | 不适用 | 主路径，整套 helper 走 ScriptCallable | 通路保留，但 `FunctionLibraries/` 主体改写为 `BlueprintCallable`（见 §六.6.3） |
| GAS / EnhancedInput mixin helper 数量 | 不适用 | 17 + 4 + 2（厚） | 8 个 `*MixinLibrary` + 反射回退兜底（薄） |

机制层面与 Hazelight 完全对齐，**没有功能减损**；API 表面（mixin helper 数量）相对偏薄，已被 `Plan_StatusPriorityRoadmap.md` P2.3 收口。

详细差异分析见 `Documents/Plans/Plan_StatusPriorityRoadmap.md:88` 与 `Documents/Plans/Plan_HazelightScriptFeatureParity.md:284-330`。

---

## 八、关键源码索引

| 路径 | 行号 | 内容 |
|---|---|---|
| `ThirdParty/angelscript/source/as_parser.cpp` | `2453-2454` | 顶层 dispatcher：`ttMixin` → `ParseMixin()` |
| `ThirdParty/angelscript/source/as_parser.cpp` | `3671-3686` | `ParseMixin()` BNF 实现，限定为 `mixin FUNCTION` |
| `ThirdParty/angelscript/source/as_texts.h` | `171-189` | `TXT_MIXIN_*` 错误文本族（mixin class 残余路径用） |
| `ThirdParty/angelscript/source/as_builder.cpp` | `2000-2050`、`2848-2879` | `RegisterMixinClass` / `AddInterfaceFromMixinToClass`（vanilla 路径，fork 不进入） |
| `Binds/Helper_FunctionSignature.h` | `23` | `NAME_Signature_ScriptMixin` 注册 |
| `Binds/Helper_FunctionSignature.h` | `32` | `NAME_Signature_ScriptMethod`（UE 5.7 增量） |
| `Binds/Helper_FunctionSignature.h` | `329-404` | 第 0 参数剥离 + `ClassName` 改写核心逻辑 |
| `Binds/Bind_BlueprintType.cpp` | `46`、`1321` | `NAME_ScriptCallable` 通路 |
| `Binds/Bind_BlueprintType.cpp` | `1325-...` | `Bind_Defaults` `EOrder::Late+100` 自动 mixin 注册 |
| `Binds/Bind_FunctionLibraryMixins.cpp` | `9-117` | `EOrder::Late+110` 手动 `Method()` 补漏样板 |
| `FunctionLibraries/AngelscriptFrameTimeMixinLibrary.h` | 全文 | 单目标 `ScriptMixin` 最简模板 |
| `FunctionLibraries/RuntimeFloatCurveMixinLibrary.h` | `16-17` | 多目标 `ScriptMixin = "FRuntimeFloatCurve UCurveFloat"` |
| `FunctionLibraries/GameplayTagQueryMixinLibrary.h` | `13-38` | 启用状态的多函数 mixin 模板 |
| `Script/Examples/Core/Example_MixinMethods.as` | 全文 | 路径① `mixin function` 最小用户级例子 |

---

## 九、延伸阅读

- `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` §7.11 — `ArgumentDefaults` 与 mixin 的联动裁剪推导
- `Documents/Guides/ASSDK_Fork_Differences.md` §5 — 与 vanilla AS 2.38 的差异记录
- `Documents/Guides/AngelscriptForkStrategy.md` — fork 演进策略，解释为何砍掉 `mixin class`
- `Documents/Plans/Plan_HazelightScriptFeatureParity.md` §FunctionLibrary 测试覆盖 — mixin 测试矩阵
- `Documents/Plans/Plan_StatusPriorityRoadmap.md` P2.3 — Mixin helper surface 收口规划
- `Documents/Knowledges/ZH/Index.md` Syntax_ 与 Guide_ 章节 — 知识文档命名空间总览（`Guide_ScriptMixin.md` 用户使用指南为待补占位）
