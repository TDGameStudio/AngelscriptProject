# Guide_ScriptMixin — ScriptMixin 非侵入式方法注入

> **所属前缀**: Guide_（实践指南族）
> **适用读者**: 想给 UE 内置类型（`FVector` / `AActor` / `USceneComponent` / `FHitResult` / `FGameplayTag` …）在 `.as` 端加一两个 helper 方法、又不想 fork 引擎的 C++ 工程师 / 脚本作者。
> **前置知识**:
> 看完 `Documents/Knowledges/ZH/Guide_QuickStart.md` 至少前 6 个案例（知道 `.as` 类怎么写、UFUNCTION 怎么标）。
> · 知道 `BlueprintCallable static` helper 函数的写法（你已经写过类似 `UMyHelpers::DoSomething(Target, Arg)` 的工具函数）。
> **关联 Knowledges**:
> `Documents/Knowledges/ZH/Guide_QuickStart.md` —— 脚本作者的入门骨架（mixin 在案例 0 之外）
> · `Documents/Knowledges/ZH/Guide_ClassBinding.md` —— C++ 类型暴露给 AS 的三层路径，§六 引出 mixin
> · `Documents/Knowledges/ZH/Guide_SyntaxFeatures.md` —— AS 与 C++ 心智差异速览
> · `Documents/Knowledges/ZH/Syntax_Mixin.md` —— 维护者视角：`mixin` 关键字与 `ScriptMixin` 元数据的两条实现路径
> · `Documents/Knowledges/ZH/Type_FunctionLibrary.md` —— 维护者视角：21 份 helper header 的工程组织
> · `Script/Examples/Core/Example_MixinMethods.as` —— 路径① `mixin` 关键字最小可运行例子

---

## 概览

本文聚焦一个核心问题：**我手里有一个 UE 内置类型——`FVector` / `AActor` / `USceneComponent` / `FHitResult` / `FGameplayTag` ——它的源码不在我的项目里、我也不想 fork 引擎，但我想在 `.as` 里写出 `Comp.GetRelativeLocation()` 这种"看起来像成员方法"的调用，怎么办？**

答案是 **ScriptMixin**——一种非侵入式的方法注入机制。你写一份 C++ 静态 helper 函数，挂一行 meta，AS 端就能像调用成员方法一样调用它，目标类型本身**一行没改**。

```text
                ScriptMixin 调用分派全景

   .as 调用现场
   ┌───────────────────────────────────────────────────┐
   │ USceneComponent Comp = ...;                       │
   │ FVector Loc = Comp.GetRelativeLocation();   ← 看起来像成员
   │ Comp.SetRelativeLocation(FVector(0, 0, 100));     │
   └─────────────────────────┬─────────────────────────┘
                             │
            AS 编译器在前端把这个调用展开为:
                             │
                             ▼
   ┌───────────────────────────────────────────────────┐
   │ FVector Loc = UAngelscriptComponentLibrary::      │
   │     GetRelativeLocation(Comp);     ← 实际是 free  │
   └───────────────────────────────────────────────────┘
                             │
                             │ Comp 自动作为第 0 参数传入
                             ▼
   ┌───────────────────────────────────────────────────┐
   │ C++ 端:                                           │
   │   UCLASS(meta=(ScriptMixin="USceneComponent"))    │
   │   class UAngelscriptComponentLibrary : UObject {  │
   │     UFUNCTION(BlueprintCallable)                  │
   │     static FVector GetRelativeLocation(           │
   │         const USceneComponent* Comp);  ← 第 0 参就是 self
   │   };                                              │
   └───────────────────────────────────────────────────┘
```

**两个关键事实**：

1. AS 端写的 `Comp.GetRelativeLocation()` **看起来像成员调用**，但 dispatch 的实际是 free function——目标类型本身完全没动。
2. C++ 端写的 `static UFUNCTION` 第 0 参数就是"调用者"——插件在绑定阶段自动把它**剥离**，让脚本侧看到的签名只剩剩余参数。

后续章节按 **何时该写 mixin / 三种命名形态 / 写一个最小 mixin / 第一参数语义 / 调用语法 / 决策对比 / 限制 / 现有 mixin 库速查 / 调试诊断** 的顺序展开。如果你只读一节，建议从 §一（决策树）开始。

> 本文是**用户使用指南**。两条 mixin 实现路径（AS 语言层 `mixin` 关键字 + C++ 反射层 `ScriptMixin` 元数据）的内核源码、UHT 行为、`Late+100` 时序、`asALREADY_REGISTERED` 故障模式等深度内容请阅读 `Syntax_Mixin.md` 与 `Type_FunctionLibrary.md`，本文不重复。

---

## 一、何时该写 mixin（决策树）

### 1.1 三个问题就能定路径

```text
我想给一个类型（UE 内置 / 别人写的 / 我自己的）加 helper 方法
                        │
        ┌───────────────┴──────────────┐
        ▼                               ▼
 Q1：这个类型是我自己             否：我能改它的源码吗?
 写的、源码也在我项目里？               │
        │                          ┌───┴───┐
       是                          否        是
        ▼                          ▼         ▼
 直接给类加成员方法           ★ ScriptMixin ★      ★ ScriptMixin 也可（推荐）★
 + UFUNCTION，无需 mixin       本文主角             因为它把 helper 收纳到
                                                   单独 library 文件里，业务代码
                                                   不被 helper 污染
        │
       继续 Q2: 我要加的 helper 是不是
       "工具性的"（与类型核心职责弱耦合）？
        │
   ┌────┴────┐
  是          否
   ▼          ▼
 ★ScriptMixin★  类成员方法
 推荐         （和类一起演进）
```

### 1.2 mixin vs 三种竞争方案的速览

| 方案 | 写在哪 | AS 端调用形式 | 优点 | 缺点 |
|------|--------|--------------|------|------|
| **ScriptMixin**（本文） | `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/<X>Library.h` | `Target.Method(args)`，看起来像成员 | 不动目标类型源码；脚本侧调用语法自然 | helper 函数会以 `BlueprintCallable` 形式出现在蓝图节点面板（轻度污染） |
| **类继承**（自定义 subclass） | 你自己的 .h / .cpp | `MyDerived.Method()` | 完全可控；可访问 protected 成员 | 必须显式继承——基类的所有现成实例都用不了你的方法 |
| **`BlueprintCallable static` helper** | `UBlueprintFunctionLibrary` 子类 | `MyHelpers::Func(target, args)` | 实现最简单，0 学习成本 | 调用语法不像成员；命名空间污染；与 mixin 在性能/可见性上等价但语法别扭 |
| **AS `mixin function`** | `.as` 脚本内 | `Target.Method(args)`，看起来像成员 | 完全脚本侧，无需 C++；热重载即时生效 | 仅对 import 该模块的脚本可见；不能用 const-ref 重载等 C++ 特性 |

**经验法则**：

- **要给 UE 内置类型加方法** → ScriptMixin
- **要给 USTRUCT 加方法**（USTRUCT 的 `UFUNCTION` UHT 不会自动搬到脚本侧） → ScriptMixin
- **要给自己的脚本类加 helper** → 直接成员方法 / 或 AS `mixin function`
- **helper 与类型核心强耦合** → 类成员方法
- **只要在 `.as` 里 quick-and-dirty 加一个本地辅助** → AS `mixin function`（见 §九）

### 1.3 ScriptMixin 与"普通 BlueprintCallable static"的关系

很多人写过这种代码：

```cpp
UCLASS()
class UMyHelpers : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static FVector GetSafeLocation(const USceneComponent* Comp) { ... }
};
```

AS 端只能这样调：

```angelscript
FVector Loc = UMyHelpers::GetSafeLocation(Comp);   // ← 命名空间静态形式
```

**改造成 mixin 只需加一行 meta**：

```cpp
UCLASS(meta = (ScriptMixin = "USceneComponent"))   // ★ 只加这一行
class UMyHelpers : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static FVector GetSafeLocation(const USceneComponent* Comp) { ... }
};
```

AS 端立即多了一种调法：

```angelscript
FVector Loc = Comp.GetSafeLocation();   // ★ 像成员方法
// 同时 UMyHelpers::GetSafeLocation(Comp) 还能用——双向暴露
```

**即** ScriptMixin = "普通 BlueprintCallable static" + "脚本侧的成员方法语法糖"。底层调用机制完全相同；mixin 只是让调用语法更自然。

---

## 二、命名形态：三种实际可见的样子

仓库里所有 mixin 库都集中放在 `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/`，目前有 21 份 header（`Type_FunctionLibrary.md` 有完整清单），按文件名分三种习惯：

```text
1) <Subject>MixinLibrary.h            ← 显式标注是 mixin 库
   GameplayTagMixinLibrary.h          → ScriptMixin = "FGameplayTag"
   GameplayTagContainerMixinLibrary.h → ScriptMixin = "FGameplayTagContainer"
   RuntimeFloatCurveMixinLibrary.h    → ScriptMixin = "FRuntimeFloatCurve UCurveFloat"
   AngelscriptFrameTimeMixinLibrary.h → ScriptMixin = "FQualifiedFrameTime"
   InputComponentScriptMixinLibrary.h → 三个子类，分别 mixin 到
                                         UInputComponent / APlayerController / UPlayerInput
   UAssetManagerMixinLibrary.h        → ScriptMixin = "UAssetManager"

2) Angelscript<Subject>Library.h      ← 历史命名，沿用 Hazelight 上游
   AngelscriptActorLibrary.h          → ScriptMixin = "AActor"
   AngelscriptComponentLibrary.h      → ScriptMixin = "USceneComponent"
   AngelscriptHitResultLibrary.h      → ScriptMixin = "FHitResult"
   AngelscriptWorldLibrary.h          → ScriptMixin = "UWorld"
   AngelscriptLevelStreamingLibrary.h → ScriptMixin = "ULevelStreaming"

3) <Subject>Statics.h                 ← 纯命名空间静态库（不是 mixin）
   SubsystemLibrary.h
   GameplayLibrary.h
   AngelscriptScriptLibrary.h         （Script::GetNameOfGlobalVariableBeingInitialized）
```

**重要**：**文件名只是命名习惯**——是不是 mixin 看的不是文件名，而是 `UCLASS` 上有没有 `meta=(ScriptMixin="...")`。`AngelscriptComponentLibrary.h` 没带 `Mixin` 字样，但它就是一个 `USceneComponent` 的 mixin 库；反之 `AngelscriptScriptLibrary.h` 带 `Library` 字样，但它是命名空间静态。

实际暴露形态以源码 `UCLASS` meta 为准。

---

## 三、写一个最小 mixin（C++ 侧 + .as 侧）

### 3.1 最小骨架：单目标 mixin

最简单的样本——`AngelscriptFrameTimeMixinLibrary.h` 一个类、一个函数、共 19 行：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptFrameTimeMixinLibrary.h
// 性质: 单目标 ScriptMixin 最简模板
// ============================================================================
#pragma once

#include "CoreMinimal.h"
#include "Misc/QualifiedFrameTime.h"
#include "AngelscriptFrameTimeMixinLibrary.generated.h"

UCLASS(meta = (ScriptMixin = "FQualifiedFrameTime"))   // ★ 关键 meta 行
class ANGELSCRIPTRUNTIME_API UAngelscriptFrameTimeMixinLibrary : public UObject
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category = "FrameTime")
    static double AsSeconds(const FQualifiedFrameTime& Target)   // ★ 第 0 参数 = self
    {
        return Target.AsSeconds();
    }
};
```

`.as` 端立即可用：

```angelscript
// ============================================================================
// 文件: Script/MyGame/FrameTimeDemo.as
// ============================================================================
void Demo(FQualifiedFrameTime Frame)
{
    double Seconds = Frame.AsSeconds();   // ★ 像成员方法调用——第 0 参数自动剥离
}
```

**这就够了**——你不需要写任何 `Bind_*.cpp`、不需要修改 Build.cs、不需要在脚本里 import 任何东西。插件启动时 `Bind_Defaults` 阶段自动扫到这条 meta 并完成注入。

### 3.2 含 `this` 写操作：const vs 非 const

第 0 参数的 const 修饰决定 mixin 方法是不是 `const` 成员：

```cpp
// 文件: AngelscriptHitResultLibrary.h
UCLASS(Meta = (ScriptMixin = "FHitResult"))
class UAngelscriptHitResultLibrary : public UObject
{
    GENERATED_BODY()
public:
    // (1) const 第 0 参数 → AS 端是 const 成员方法
    UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial))
    static AActor* GetActor(const FHitResult& HitResult)   // ★ const&
    {
        return HitResult.GetActor();
    }

    // (2) 非 const 第 0 参数 → AS 端是非 const 成员方法（可修改 self）
    UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial))
    static void Reset(FHitResult& HitResult)               // ★ 非 const&
    {
        HitResult.Reset();
    }
};
```

`.as` 端：

```angelscript
const FHitResult Hit = ...;
AActor Owner = Hit.GetActor();   // ✓ const 上下文里能调 const 方法
// Hit.Reset();                  // ✗ 编译错：const FHitResult 不能调非 const 方法

FHitResult MyHit;
MyHit.Reset();                   // ✓ 非 const 上下文 OK
```

### 3.3 多目标 mixin：空格分隔

如果一组函数想同时挂到两个相关类型上（典型场景：值类型 + 持有它的 UObject 包装），用空格分隔目标：

```cpp
// 文件: RuntimeFloatCurveMixinLibrary.h:16-17
UCLASS(meta = (ScriptMixin = "FRuntimeFloatCurve UCurveFloat"))   // ★ 两个目标
class ANGELSCRIPTRUNTIME_API URuntimeFloatCurveMixinLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static float GetFloatValue(const FRuntimeFloatCurve& Curve, float InTime)
    {
        // 实现复用同一份代码——第一个匹配第 0 参数类型的目标胜出
    }
    // 其他函数...
};
```

`.as` 端两种类型都能调：

```angelscript
FRuntimeFloatCurve VarCurve;
float V1 = VarCurve.GetFloatValue(0.5);

UCurveFloat AssetCurve;
float V2 = AssetCurve.GetFloatValue(0.5);   // 同一函数双类型可见
```

### 3.4 在同一 header 里拆 sub-class（每个子类一个目标）

如果一个文件要给多个不相关类型加 mixin，**不要**用 `"A B"` 多目标语法——拆 sub-class 更清晰：

```cpp
// 文件: InputComponentScriptMixinLibrary.h
UCLASS(Meta = (ScriptMixin = "UInputComponent"))
class UInputComponentScriptMixinLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static void BindAction(UInputComponent* Component, /* ... */) { /* ... */ }
};

UCLASS(Meta = (ScriptMixin = "APlayerController"))
class UPlayerControllerInputScriptMixinLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static void PushInputComponent(APlayerController* PC, UInputComponent* Comp) { /* ... */ }
};

UCLASS(Meta = (ScriptMixin = "UPlayerInput"))
class UPlayerInputScriptMixinLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static void AddActionMapping(UPlayerInput* Input, /* ... */) { /* ... */ }
};
```

每个 sub-class 自带独立 `ScriptMixin` meta，互不干扰。

---

## 四、第一参数语义：自动剥离

整个 mixin 机制最关键的语义就一条：**C++ 端写 `static Func(Target& Self, A, B, C)`，AS 端看到的是 `Target.Func(A, B, C)`**——第 0 参数被自动剥离，不出现在脚本签名里。

### 4.1 三种合法第 0 参数类型

```cpp
// 形态 1：值传引用（推荐用于值类型）
static double AsSeconds(const FQualifiedFrameTime& Target);   // ✓

// 形态 2：UObject 裸指针（推荐用于 UObject）
static FVector GetRelativeLocation(const USceneComponent* Component);   // ✓

// 形态 3：非 const 引用（需要修改 self 时）
static void Reset(FHitResult& HitResult);   // ✓

// 形态 4：UObject 指针非 const
static void AddRelativeLocation(USceneComponent* Component, const FVector& Delta);   // ✓
```

详细规则（`Helper_FunctionSignature.h` 的 `IsObjectPointer || IsUnresolvedObjectPointer || bIsReference`）见 `Syntax_Mixin.md` §二.2。

### 4.2 不合法第 0 参数：mixin 静默失效

下列形态会让 mixin 注入**默默失败**（不报错，函数退化成 namespace 静态形式）：

```cpp
// 反面例 1：第 0 参数是值传递（既非引用也非指针）
static int Foo(FVector V, int Multiplier);
// 后果：mixin 不注入；AS 端只能 UFooLib::Foo(V, 2)，看不到 V.Foo(2)

// 反面例 2：第 0 参数类型不在 ScriptMixin 列表里
UCLASS(meta=(ScriptMixin = "FVector"))
class UFooLib : public UObject {
    UFUNCTION(...)
    static int Bar(const FRotator& R);   // ← FRotator 不在 ScriptMixin 列表
};
// 后果：函数被识别为命名空间静态，UFooLib::Bar(R) 可见，R.Bar() 不可见

// 反面例 3：函数没有 BlueprintCallable / BlueprintPure / ScriptCallable
UCLASS(meta=(ScriptMixin = "FVector"))
class UFooLib : public UObject {
    static int Baz(const FVector& V);   // 无 UFUNCTION 标记
};
// 后果：函数压根不进入 AS 反射，连 namespace 形式都没有
```

诊断方法见 §八。

### 4.3 第 0 参数可以是"非 const 引用 / 指针" → 修改 self

跟 C++ 成员方法一样，用 `Type& Target` 或 `Type* Target` 就能修改 self：

```cpp
// 文件: GameplayTagContainerMixinLibrary.h:23-27
UFUNCTION(BlueprintCallable)
static void AddTag(FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToAdd)
{
    GameplayTagContainer.AddTag(TagToAdd);   // ★ 修改 self
}
```

`.as` 端：

```angelscript
FGameplayTagContainer Tags;
Tags.AddTag(GameplayTag::FromName(n"Enemy.Boss"));   // ★ self 被修改
```

---

## 五、调用语法与命名空间

### 5.1 看不出区别：mixin 与原生方法语法相同

```angelscript
USceneComponent Comp = ...;
FVector L = Comp.GetRelativeLocation();        // ← mixin（来自 AngelscriptComponentLibrary）
Comp.SetRelativeLocation(FVector(0, 0, 0));    // ← 同上
bool bAttached = Comp.IsAttachedTo(OtherComp); // ← 同上

bool bRegistered = Comp.IsRegistered();        // ← 原生 BlueprintCallable
```

脚本作者**几乎不需要关心**调用的是 mixin 还是原生方法——`.` 之后的方法名补全、签名提示、热重载都一样。这是 mixin 设计的核心目标。

### 5.2 双向暴露：同一函数也能命名空间静态调用

mixin 注入**不会**关闭命名空间静态调用形式——同一个 helper 既可以 `Target.Method()` 也可以 `Lib::Method(Target, ...)`：

```angelscript
// 两种调用形式同时合法：
FVector L1 = Comp.GetRelativeLocation();
FVector L2 = UAngelscriptComponentLibrary::GetRelativeLocation(Comp);   // 等价
```

绝大多数代码**强烈推荐用成员形式**——更短、与原生方法一致；命名空间形式仅在某些特殊场景（避免 ADL 歧义、明确指明哪个 library）有用。

### 5.3 `ScriptName` meta：在 AS 端用一个不同的名字

C++ 函数名和 AS 期望的方法名可能不同——比如 C++ 端为了区分 `FRotator` / `FQuat` 重载用了 `SetRelativeRotationQuat`，但 AS 端希望两者都叫 `SetRelativeRotation`：

```cpp
// 文件: AngelscriptComponentLibrary.h
UFUNCTION(BlueprintCallable)
static void SetRelativeRotation(USceneComponent* Component, const FRotator& NewRotation);

UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation",   // ★ AS 端别名
                                     NotAngelscriptProperty))
static void SetRelativeRotationQuat(USceneComponent* Component, const FQuat& NewRotation);
```

`.as` 端两个重载共用同一个名字：

```angelscript
USceneComponent Comp = ...;
Comp.SetRelativeRotation(FRotator(0, 90, 0));            // 调 FRotator 版本
Comp.SetRelativeRotation(FQuat(FVector::UpVector, 1.5)); // 调 FQuat 版本（重载）
```

`NotAngelscriptProperty` 阻止 AS 把它当 `Get/Set` 属性对来识别，避免与同名的真属性 setter 冲突。

---

## 六、决策对比：mixin vs 继承 vs BlueprintCallable static

### 6.1 完整对比表

| 维度 | ScriptMixin | 类继承（自定义 subclass） | BlueprintCallable static helper（不挂 mixin） | AS `mixin function`（脚本端） |
|------|-------------|--------------------------|-----------------------------------------------|------------------------------|
| **写在哪** | C++ `FunctionLibraries/<X>Library.h` | 你自己的 .h / .cpp | 任意 `UBlueprintFunctionLibrary` 子类 | `.as` 文件内顶层 |
| **AS 端调用** | `Target.Method(args)` | `Derived.Method()` | `Lib::Method(target, args)` | `Target.Method(args)` |
| **是否需要修改目标类型** | ✗ | ✓（必须能继承） | ✗ | ✗ |
| **是否需要 C++ 编译** | ✓ | ✓ | ✓ | ✗（保存即生效） |
| **能访问 protected 成员** | ✗（只能调 public） | ✓ | ✗ | ✗ |
| **能给 final 类型加方法** | ✓ | ✗ | ✓ | ✓ |
| **能给值类型 USTRUCT 加方法** | ✓ | ✗（USTRUCT 不可继承） | ✓ | ✓ |
| **所有现存实例自动获得新方法** | ✓ | ✗（仅新建的 subclass 实例） | ✓ | ✓ |
| **跨蓝图节点面板可见性** | ✓（蓝图侧也多一个节点） | 部分（subclass 节点） | ✓ | ✗（仅脚本端） |
| **热重载即时生效** | ✗（要重启编辑器） | ✗（要重启 / Live Coding） | ✗（同前） | ✓（保存即生效） |
| **性能** | 与 BlueprintCallable static 等价 | 与原生方法等价（直绑） | 同 ScriptMixin | 直接 free function 调用 |
| **典型用例** | 给 `FVector` / `AActor` / `FHitResult` 加 helper | 自定义 GameplayCharacter 派生 | 简单工具函数集 | 脚本侧本地辅助 |

### 6.2 选什么：场景 → 推荐

```text
我要给一个 UE 内置 USTRUCT (FVector / FHitResult) 加 helper
   → ScriptMixin（继承不可用，BlueprintCallable static 太啰嗦）

我要给一个 UE 内置 UClass (AActor) 加 helper
   → 优先 ScriptMixin；除非 helper 数量极多且与 actor 行为深度耦合，那时考虑做 subclass

我要给我自己的脚本类加 helper
   → 直接成员方法；除非想把 helper 收纳到一个独立文件，那时考虑 AS mixin function

我只想 quick-and-dirty 在 .as 里加一个本地辅助
   → AS mixin function（无需 C++ 编译，热重载快）

我要加的方法需要访问 protected 成员
   → 必须 subclass，ScriptMixin 不行

我的 helper 既要给蓝图也要给脚本用
   → ScriptMixin 自动满足（BlueprintCallable static 也满足）
```

### 6.3 反面：什么时候**不要**写 mixin

- **helper 是 stateful 的**（要持有状态、跨调用累积数据）→ 写一个普通 component 或 subsystem
- **helper 与目标类型耦合非常紧**（需要每次 mixin 库版本与类型版本同步） → 写成员方法或 subclass
- **helper 只在某个特定项目场景下用** → 直接 BlueprintCallable static + namespace 调用就够了，不必污染目标类型的方法名空间

---

## 七、限制：mixin 不能做什么

### 7.1 不能访问私有 / protected 成员

mixin 函数体只是普通 C++ static 函数，**没有任何"友元"特权**——如果要修改的字段是 `private`，你 mixin 也读写不了：

```cpp
// 反面例
UCLASS(meta = (ScriptMixin = "FFoo"))
class UFooMixin : public UObject {
    UFUNCTION(BlueprintCallable)
    static int GetSecret(const FFoo& Self) {
        return Self.SecretValue;   // ✗ 编译错：SecretValue 是 private
    }
};
```

如果非要访问，要么把字段改 public（不优雅），要么走"必须能改源码"路径——这时 ScriptMixin 也帮不了你。

### 7.2 不能 mixin 运算符（`opAdd` / `opEquals` / `opCmp` 等）

AS 引擎里的运算符（`opAdd` / `opMul` / `opAddAssign` / `opEquals` / `opCmp` / `opIndex` 等）走的是**直绑通道**，不在 ScriptMixin 的扫描范围。你可以让 mixin 函数叫 `Add`（用普通方法语法 `A.Add(B)`），但**不能让它对应 `A + B` 这种运算符语法**。

要给类型加运算符必须手写 `Bind_<Type>.cpp`，参 `Guide_ClassBinding.md` §四。

### 7.3 不能 override 已存在的方法

mixin 注入是**追加**——如果目标类型已经有一个同签名的方法（无论是原生 C++ 成员、UFUNCTION、还是另一个 mixin 注入的方法），你的 mixin 注册会触发 `asALREADY_REGISTERED (-13)`，**整个 AS 引擎进入半坏状态**，后续测试全爆。

```cpp
// 反面例：USceneComponent::SetRelativeLocation 已存在原生 BlueprintCallable
UCLASS(meta = (ScriptMixin = "USceneComponent"))
class UMyOverrideMixin : public UObject {
    UFUNCTION(BlueprintCallable)
    static void SetRelativeLocation(USceneComponent* C, const FVector& V) {
        // ★ 与原生方法签名相同 → 注册时 asALREADY_REGISTERED
        C->SetRelativeLocation(V * 2.0);   // 想"魔改"原生行为
    }
};
```

修法：**重命名你的 mixin 方法**（`SetRelativeLocationDoubled` 之类），不要试图覆盖原生行为。

### 7.4 不能 mixin 私有字段做"伪 property"

AS 端的 property 语法（`Comp.RelativeLocation = V`）背后是 `Get_RelativeLocation` / `Set_RelativeLocation` 一对方法。你写一对 mixin 方法**理论上**能合成一个 property——但 fork 里有 `NotAngelscriptProperty` meta 用来阻止"误判 Get/Set 对"，因为这容易污染原生 property 名空间。

如果你的目的就是"加一个伪 property"，请用普通方法名（`GetSafeLocation()` 不要叫 `GetSafe_Location` 触发 property 推断），并加 `Meta = (NotAngelscriptProperty)`：

```cpp
UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeLocation", NotAngelscriptProperty))
static void SetRelativeLocationVariant(USceneComponent* C, const FVector& V);
```

### 7.5 不能 mixin 模板 / 含 `?&` 通配类型的函数

ScriptMixin 走的是 UE 反射 + UHT 通道——UHT 不识别 C++ 模板函数，反射系统也不存模板信息。**含 `?&out` 通配输出类型**这种 fork 特有签名只能手写 `Bind_*.cpp`。

```cpp
// 反面例
UCLASS(meta = (ScriptMixin = "USceneComponent"))
class UMyMixin : public UObject {
    template<typename T>   // ✗ UHT 拒绝
    static T* GetTypedComponent(USceneComponent* C);
};
```

需要 `?&` 模板的场景见 `Guide_ClassBinding.md` §四.3。

### 7.6 第 0 参数必须能匹配 ScriptMixin 列表

§四.2 已经讲过：第 0 参数若不在 `ScriptMixin = "..."` 列出的目标类型里，mixin 静默失效，函数退化成 namespace 静态。这是最常见的"为什么我的 mixin 没生效"原因，**没有报错**——必须主动诊断（§八）。

### 7.7 helper 的命名空间不能完全脱离 ScriptCallable / BlueprintCallable

当前 fork 的实现要求 `static UFUNCTION` 必须挂 `BlueprintCallable` / `BlueprintPure` 之一（或 `ScriptCallable` 历史路径，但生产线上少用）。**纯 C++ static 函数**（无 UFUNCTION 标记）不会被 mixin 路径扫描——必须先把它变成 UFunction 反射才能进入 AS。

副作用：mixin 函数会以 `BlueprintCallable` 节点形式出现在蓝图编辑器面板里，对纯脚本场景下"想要不污染蓝图"的需求支持较弱。这是已知的取舍（详见 `Syntax_Mixin.md` §6.3）。

---

## 八、调试：mixin 没生效怎么办

### 8.1 现象 1：脚本编译错 `'Method GetXxx() not found on type T'`

最常见的故障报告。诊断顺序：

**步骤 1**：在 `Saved/Logs/` 下 grep `LogAngelscript`，看启动期有没有 `Failed to register` 或 `Warning: Method ... has invalid signature`。

```text
LogAngelscript: Warning: Method 'GetSafeLocation' on USceneComponent has invalid signature
```

**步骤 2**：在编辑器命令行执行 `as.DumpEngineState`：

```text
> as.DumpEngineState
[Saved] Saved/AngelscriptStateDump/AS_TypeRegistry.csv
[Saved] Saved/AngelscriptStateDump/AS_GlobalFunctions.csv
... (27 个 CSV)
```

打开 `AS_TypeRegistry.csv`，搜你的目标类型（如 `USceneComponent`）那一行，看它的 `Methods` 列里**有没有你预期的 mixin 方法名**。

- **有** → 可能是 `ScriptName` 别名让你叫错名了
- **没有** → mixin 注入失败，继续步骤 3

**步骤 3**：四个常见原因排查：

```text
原因 A：UCLASS 没挂 ScriptMixin meta，或 meta 字符串拼错
        例: meta=(ScriptMixin="USceneComp")     ← 拼错为 "USceneComp"
        修: meta=(ScriptMixin="USceneComponent")

原因 B：UFUNCTION 没挂 BlueprintCallable / BlueprintPure
        例: static FVector GetSafe(...) { ... } ← 没标 UFUNCTION
        修: 加上 UFUNCTION(BlueprintCallable)

原因 C：第 0 参数类型不匹配 ScriptMixin 列表
        例: meta=(ScriptMixin="USceneComponent")
            static FVector GetSafe(const UActorComponent* C); ← UActorComponent ≠ USceneComponent
        修: 改第 0 参数类型为 USceneComponent，或扩展 meta 为 "USceneComponent UActorComponent"

原因 D：第 0 参数是值传递（非引用 / 非指针）
        例: static int Foo(FVector V, int N);   ← FVector 按值
        修: 改为 const FVector& V 或 FVector& V
```

### 8.2 现象 2：函数被默默"退化"为命名空间静态

`bFoundMixin = false` 分支吞掉错误——函数会变成 `UMyLib::Func(target, args)` 形式可见，但 `target.Func(args)` 不可见。诊断同 §8.1。

简易测试：在 `.as` 里**两种语法都试一下**：

```angelscript
// 试一：成员形式
Comp.GetSafeLocation();        // ← 看错误信息

// 试二：命名空间形式
UMyMixin::GetSafeLocation(Comp);   // ← 如果这条能编译，说明 mixin 退化
```

如果"命名空间形式能编译，成员形式编译错"——铁定是 mixin 注入失败，原因 A/C/D 之一。

### 8.3 现象 3：启动期 `asALREADY_REGISTERED (-13)`

意味着你的 mixin 与某条已有方法（原生成员 / 另一个 mixin / 手写 Bind）签名冲突。`LogAngelscript` 会指出哪条 declaration：

```text
LogAngelscript: Error: Failed to register method 'void SetRelativeLocation(FVector)'
                on USceneComponent: asALREADY_REGISTERED (-13)
```

修法：把你的 mixin 方法**改名**（不要试图与原生方法同名同签名）。

### 8.4 现象 4：参数默认值丢失

mixin 注入时第 0 参数被剥离，跟它绑定的 `meta = (CPP_Default_Xxx="...")` 也会一起丢失。**但因为第 0 参数已是 self、必须由调用方提供**，这无影响。其他参数的默认值不受影响——例 `AttachToComponent(USceneComponent* C, USceneComponent* Parent, FName Socket = NAME_None)` 的 `Socket` 默认值正常保留。

### 8.5 性能诊断：mixin 走了反射兜底还是 UHT 直绑？

跟 §`Guide_ClassBinding.md` §十一.5 同——查 `Plugins/Angelscript/Intermediate/Build/.../UHT/AS_FunctionTable_Summary.json` 的 `DirectBoundCount` / `StubCount`。mixin helper 大部分走 UHT 直绑（只要 helper 库 header 在 `/Public/` 或非 `/Private/`），只有少量走反射兜底（性能慢 3-6 倍）。

---

## 九、AS 端的 `mixin` 关键字（路径①简介）

除了 §三 讲的 C++ 端 `ScriptMixin` meta（路径②），AS 还支持纯**脚本端**的 mixin——`mixin function` 关键字。两条路径**互不依赖、可独立使用**。

### 9.1 最小例子

```angelscript
// 文件: Script/Examples/Core/Example_MixinMethods.as
mixin void ExampleMixinActorMethod(AActor Self, FVector Location)
{
    Print("Mixin invoked on: " + Self.GetClass().GetName());
}

void Example_MixinMethod()
{
    AActor ActorReference;
    ActorReference.ExampleMixinActorMethod(FVector(0.0, 0.0, 100.0));
    //              ^^^^^^^^^^^^^^^^^^^^^^^ 与 C++ ScriptMixin 调用语法一致
}
```

### 9.2 与 C++ ScriptMixin 的差异

| 维度 | C++ `ScriptMixin` meta | AS `mixin function` |
|------|------------------------|--------------------|
| 写在哪 | C++ helper header | `.as` 脚本顶层 |
| 跨模块可见性 | 全局对所有 .as 模块可见 | 仅对 `import` 该模块的 .as 可见 |
| 热重载 | 改了要重启编辑器（C++ 编译） | 改了即时生效 |
| 第 0 参数语义 | 自动剥离（C++ 端必须显式写） | 自动剥离（AS 端必须显式写） |
| 调用语法 | `Target.Method(args)` | `Target.Method(args)`（一致） |
| 限制 | 不能 mixin 私有 / 运算符 / override（§七） | 同左 + 不支持 C++ 端 `ScriptName` 等 meta |

### 9.3 何时用脚本 mixin function

- **`.as` 脚本里 quick-and-dirty 加一个本地辅助** → mixin function（无需 C++ 编译，0 摩擦）
- **辅助逻辑要能在多个 .as 模块复用，且热重载场景** → mixin function（声明在 import 链最上游）
- **辅助逻辑要 C++ 也能用，或要被蓝图节点看见** → C++ `ScriptMixin` meta

`mixin class` 形态在当前 fork **不支持**（已主动砍掉，详见 `Syntax_Mixin.md` §一）。

---

## 附录 A：现有 mixin 库速查

仓库里 `FunctionLibraries/` 目录下当前有 21 份 helper，但**真正挂 ScriptMixin meta 的只有以下几个**。脚本作者只需知道"我的目标类型有没有现成的 helper 库可用"——下表按目标类型组织。

| 目标类型 | mixin 库文件 | 主要 helper 举例 |
|---------|--------------|------------------|
| `AActor` | `AngelscriptActorLibrary.h` | `SetActorRotationQuat` / `SetActorLocationAndRotationQuat` / `GetAttachedActors` |
| `USceneComponent` | `AngelscriptComponentLibrary.h` | `GetRelativeLocation` / `SetRelative*` / `AttachToComponent` / `IsAttachedTo` |
| `UWorld` | `AngelscriptWorldLibrary.h` | `GetStreamingLevels` |
| `ULevelStreaming` | `AngelscriptLevelStreamingLibrary.h` | `GetShouldBeVisibleInEditor`（仅编辑器） |
| `FHitResult` | `AngelscriptHitResultLibrary.h` | `GetActor` / `GetComponent` / `Reset` / `SetbBlockingHit` |
| `FQualifiedFrameTime` | `AngelscriptFrameTimeMixinLibrary.h` | `AsSeconds` |
| `FRuntimeFloatCurve` + `UCurveFloat` | `RuntimeFloatCurveMixinLibrary.h` | `GetFloatValue` / `GetTimeRange` / `AddCurveKey*` |
| `FRuntimeCurveLinearColor` | `RuntimeCurveLinearColorMixinLibrary.h` | `AddDefaultKey` |
| `FGameplayTag` | `GameplayTagMixinLibrary.h` | `MatchesTag` / `RequestDirectParent` / `GetSingleTagContainer` |
| `FGameplayTagContainer` | `GameplayTagContainerMixinLibrary.h` | `AppendTags` / `HasTag` / `RemoveTag` |
| `FGameplayTagQuery` | `GameplayTagQueryMixinLibrary.h` | `Matches` / `IsEmpty` / `GetDescription` |
| `UInputComponent` / `APlayerController` / `UPlayerInput` | `InputComponentScriptMixinLibrary.h`（3 个 sub-class） | `BindAction` / `PushInputComponent` / `AddActionMapping` |
| `UAssetManager` | `UAssetManagerMixinLibrary.h` | `GetPrimaryAsset*` / `CallOrRegister_OnCompletedInitialScan` |
| `UWidget` | `WidgetBlueprintStatics.h`（`UAngelscriptWidgetMixinLibrary` sub-class） | `CreateWidget` / `GetRenderTransform` |

**怎么找未列出的目标的 mixin**：

```text
1. 打开 Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/
2. grep "ScriptMixin = \"<你的类型>\"" 看哪个文件挂着
3. 翻该文件的 UFUNCTION 列表
```

或在编辑器跑 `as.DumpEngineState`，去 `AS_TypeRegistry.csv` 里搜你的目标类型，列出该类型所有方法（含原生 + mixin 注入）。

---

## 附录 B：避坑清单（脚本作者 / mixin 作者视角）

1. **mixin 没生效，脚本编译报"Method not found"** —— 90% 是 §八.1 的四个常见原因之一（meta 拼错 / 未挂 BlueprintCallable / 第 0 参数类型不对 / 第 0 参数按值传递）。先 grep `LogAngelscript`，再 `as.DumpEngineState`。

2. **mixin 与原生方法同签名 → `asALREADY_REGISTERED`** —— 不要试图覆盖原生行为，重命名你的 mixin（如加 `Safe` / `Ext` 后缀）。

3. **第 0 参数默认值"丢了"是正常的** —— 第 0 参数被剥离，跟它绑定的 `CPP_Default_*` 也丢失，但因为它必须由调用方提供，对调用方无影响。

4. **多目标 mixin 的目标顺序敏感** —— `meta=(ScriptMixin="A B")` 第一个匹配第 0 参数类型的目标胜出。如果两个目标都能匹配（极罕见），结果不确定——拆 sub-class。

5. **不要给 final 类型加成员状态** —— mixin 函数是 free function，**不能在目标类型里"塞字段"**。你的"扩展状态"必须存在另一个 component / subsystem 里，或用 `TMap<TWeakObjectPtr<...>, ...>` 维护外部映射。

6. **mixin 不能访问 protected 成员** —— 若必须访问，要么扩展原类型（fork 引擎），要么走 subclass 路径（mixin 帮不上忙）。

7. **mixin 对 USTRUCT method 是首选路径** —— 因为 UHT 不为 USTRUCT 上的 UFUNCTION 自动生成绑定，加 mixin 比手写 `Bind_<Type>.cpp` 简单得多。

8. **改 mixin 库后必须 rebuild C++** —— ScriptMixin meta 的注入发生在 `Bind_Defaults` C++ 静态初始化期，**没有热重载**。改了 helper header 一定要重启编辑器或 rebuild + Live Coding。

9. **mixin 函数会出现在蓝图节点面板** —— 当前 fork 把 helper 标为 `BlueprintCallable`，副作用是蓝图编辑器里多出节点。不想被看见就给目标 mixin 单加 `Meta=(BlueprintInternalUseOnly)` 或迁移到非蓝图通路（成本较高）。

10. **AS `mixin function` 与 C++ `ScriptMixin` 别混用同一签名** —— 两者注册到同一目标的同名同签名方法时也会触发 `asALREADY_REGISTERED`。

11. **测试改动**：改 `FunctionLibraries/` 后跑这两组 automation 验证：
    - `Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures`（守住第 0 参数剥离正确性）
    - `Angelscript.TestModule.FunctionLibraries.*`（守住运行时调用结果）

12. **想给数学类型（FVector / FRotator / FQuat）加 mixin** —— 当前 `AngelscriptMathLibrary.h` 的 mixin 状态较复杂（部分启用 / 部分以 namespace 静态形式存在），新增 mixin 之前先翻 `Syntax_Mixin.md` §6.6 / `Type_FunctionLibrary.md` §1.2，了解历史背景再下手。

---

## 小结

- **ScriptMixin = 非侵入式给已有类型加方法**：C++ 端写 `UCLASS(meta=(ScriptMixin="T"))` + 一组 `static UFUNCTION`，AS 端立即多出 `target.Method(args)` 的成员调用语法。目标类型的源码**完全没动**。

- **第 0 参数语义是核心**：C++ 端 `static Func(T& Self, A, B)` 中的 `Self` 在 AS 端被自动剥离，脚本侧看到 `T.Func(A, B)`。第 0 参数类型必须匹配 `ScriptMixin` meta、必须是引用/指针、`const` 修饰决定方法是否 const。

- **三种"加方法"路径的取舍**：ScriptMixin（最常用，给内置类型加 helper）/ 类继承（要访问 protected 时）/ AS `mixin function`（脚本端 quick fix，热重载即时）。`Guide_QuickStart.md` 案例里你已经见过的 `Vector.Length()` / `Comp.GetRelativeLocation()` 大多是 mixin。

- **不能做什么**：不能 override 已有方法（会触发 `asALREADY_REGISTERED`）、不能访问私有成员、不能做运算符（`opAdd` / `opEquals` 必须手写 Bind）、不能做模板 / `?&out` 通配类型、第 0 参数值传递会让 mixin 静默失效。

- **mixin 没生效的诊断三板斧**：grep `LogAngelscript` 看启动期错误 → `as.DumpEngineState` 看类型方法列表 → 把成员调用与命名空间静态调用都试一次，区分注入失败还是注入成功后名字拼错。

- **下一步导航**：实现细节读 `Syntax_Mixin.md`；21 份 FunctionLibrary 的工程组织读 `Type_FunctionLibrary.md`；C++ 类型暴露的全景三层路径读 `Guide_ClassBinding.md`；脚本端语法心智读 `Guide_SyntaxFeatures.md`。
