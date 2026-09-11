# UE CQTest 指南与参考

> 本文基于本地 UE 5.8 引擎源码（`Engine/Source/Developer/CQTest`）逐条核验整理，
> 既讲底层原理（宏展开、注册机制、执行时序），也讲实际用法（模板、断言、组件、扩展）。
> 文末附与旧版本/网络资料的差异勘误。

---

## 一、定位与设计哲学

CQTest（Code Quality Test）是 UE5 内置的 C++ 自动化测试框架，自 UE 5.5 起为 Engine Module（`Engine/Source/Developer/CQTest`），无需启用插件，`Build.cs` 添加 `"CQTest"` 依赖即可使用。

它要解决 UE 原有测试方式的两个痛点：

- `IMPLEMENT_SIMPLE_AUTOMATION_TEST`：只有一个 `RunTest` 入口，没有 before/after 钩子，多场景堆在一起，状态污染风险高。
- Spec Test（BDD 风格）：`Describe`/`It` 的 lambda 捕获作用域极易踩坑，且不会自动重置状态。

```
┌──────────────────────────────────────────────────────────────┐
│                  CQTest 三大核心哲学                          │
├──────────────────────────────────────────────────────────────┤
│  1. 原子性（Atomicity）                                       │
│     每个 TEST_METHOD 执行前重新构造测试对象                   │
│     → 成员变量自动归零，测试之间完全隔离                      │
│                                                              │
│  2. 组合优于继承（Composition over Inheritance）              │
│     环境能力通过持有 Test Component 成员变量添加              │
│     而不是强迫用户继承层层嵌套的基类                          │
│                                                              │
│  3. 让简单的事情简单（Make easy things easy）                 │
│     最小测试 = 一个宏 + 一个断言                              │
│     复杂场景通过 WITH_BASE / WITH_ASSERTS 组合宏渐进扩展      │
└──────────────────────────────────────────────────────────────┘
```

断言哲学：不同平台对 C++ 异常支持不一，CQTest 采用 `[[nodiscard]] bool` 返回值 + `ASSERT_THAT` 宏做提前 return，兼顾跨平台与书写体验。

### 在 UE 测试体系中的位置

```
速度快 ◄────────────────────────────────────────► 真实度高

 LowLevel Tests        CQTest              Gauntlet
  (Catch2)         (FAutomationTestBase    (RunUAT / 跨机器)
     │              扩展，编辑器内运行)         │
  纯 C++，不启动引擎   依赖引擎模块            依赖完整构建
  毫秒级              秒级，支持延迟命令       分钟级
  单元测试            功能 / 集成测试          端到端测试
```

CQTest 定位：引擎内 C++ 的功能性/集成性测试——单元逻辑、Actor 生命周期、网络复制、UI 响应等。

---

## 二、快速上手

```cpp
#include "CQTest.h"

// 最简单：单个无状态测试
TEST(MySimpleTest, "Game.MyModule")
{
    ASSERT_THAT(IsTrue(1 + 1 == 2));
}

// 带 fixture：多方法共享 setup，状态自动隔离
TEST_CLASS(MyFixtureTests, "Game.MyModule")
{
    int32 Counter = 0;                       // 每个 TEST_METHOD 前自动重置为 0

    BEFORE_EACH() { Counter = 10; }
    AFTER_EACH()  { /* 即使断言失败也会执行 */ }

    TEST_METHOD(Increment_FromTen_IsEleven)
    {
        Counter++;
        ASSERT_THAT(AreEqual(11, Counter));
    }

    TEST_METHOD(Decrement_FromTen_IsNine)
    {
        Counter--;
        ASSERT_THAT(AreEqual(9, Counter));   // 不受上一个方法影响
    }
};
```

测试全名 = `路径.类名.方法名`，如 `Game.MyModule.MyFixtureTests.Increment_FromTen_IsEleven`。
路径参数可用 `GenerateTestDirectory` 常量（或内嵌 `[GenerateTestDirectory]`）按源文件路径自动生成目录。

---

## 三、宏体系与底层原理

### 3.1 宏家族速查

```
单个无状态测试                    TEST(Name, "Path")
多方法共享 fixture                TEST_CLASS(Name, "Path")
指定 AutomationTestFlags          TEST_CLASS_WITH_FLAGS(Name, "Path", Flags)
继承自定义基类                    TEST_CLASS_WITH_BASE(Name, "Path", TBase)
自定义断言器                      TEST_CLASS_WITH_ASSERTS(Name, "Path", FAsserter)
基类 + 断言器                     TEST_CLASS_WITH_BASE_AND_ASSERTS(Name, "Path", TBase, FAsserter)
基类 + Flags                     TEST_CLASS_WITH_BASE_AND_FLAGS(Name, "Path", TBase, Flags)
过滤标签                          TEST_WITH_TAGS / TEST_CLASS_WITH_TAGS / TEST_METHOD_WITH_TAGS
组合规律                          ..._AND_FLAGS / ..._AND_TAGS / ..._AND_FLAGS_AND_TAGS
网络测试（PIE Server+Client）      NETWORK_TEST_CLASS(Name, "Path")
                                  = TEST_CLASS_WITH_FLAGS(Name, "Path",
                                        EditorContext | ProductFilter)
```

所有变体最终汇聚到底层宏 `_TEST_CLASS_IMPL_EXT(_ClassName, _TestDir, _BaseClass, _AsserterType, _TestFlags, _TestTags)`。

默认 flags：`EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::ProductFilter`。
底层宏内有两条 `static_assert` 硬校验：**必须含至少一个 Application Context flag，且必须恰好指定一种 Filter**（Smoke/Engine/Product/Perf/Stress/Negative 之一），配置错误直接编译失败。

### 3.2 `TEST_CLASS` 展开原理（核心魔法）

```
TEST_CLASS(MyTest, "Game.Dir") { ... };
    │
    ▼ 展开为两样东西：

  ┌─────────────────────────────────────────────────────────┐
  │ [1] Runner 静态单例（程序启动时注册进 UE 测试框架）        │
  │                                                         │
  │ struct FMyTest_Runner : TTestRunner<FNoDiscardAsserter> │
  │ { ... static_assert 校验 flags ... };                   │
  │ FMyTest_Runner MyTest_RunnerInstance;   ← 全局静态对象   │
  │ // TTestRunner 继承 FAutomationTestBase，                │
  │ // 构造时自动注册到 FAutomationTestFramework             │
  └─────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────┐
  │ [2] 用户 fixture struct（CRTP 继承）                     │
  │                                                         │
  │ struct MyTest : TTest<MyTest, FNoDiscardAsserter>       │
  │ {                                                       │
  │     // 你的成员变量、BEFORE_EACH、TEST_METHOD 都在这里   │
  │     // TTest 静态成员（整个 class 共享）：               │
  │     //   static TMap<FString, TestMethod> Methods;      │
  │     //   static TTestRunner<...>* TestRunner;           │
  │ };                                                      │
  └─────────────────────────────────────────────────────────┘
```

`TEST_METHOD(Foo)` 在 struct 内展开为「成员函数 + 静态自注册对象」：

```cpp
// 宏源码（5.8 实测）：
#define TEST_METHOD_WITH_TAGS(_MethodName, _TestTags)                             \
    FFunctionRegistrar reg##_MethodName{ FString(#_MethodName),                   \
        &DerivedType::_MethodName, __LINE__, _TestTags };                         \
    void _MethodName()
```

`FFunctionRegistrar` 是普通成员变量，但 fixture 对象在 Runner 构造期间（`bInitializing == true`）会被创建一次，此时每个 registrar 构造函数把函数指针写入静态 `Methods` 表：

```
FFunctionRegistrar 构造做的事：
    TestRunner->TestNames.Add("Foo");
    Methods.Add("Foo", &MyTest::Foo);        ← 自注册：测试自动发现
    TestRunner->TestLineNumbers.Add("Foo", __LINE__);
    （有 tags 时再注册到 FAutomationTestFramework 的 tag 表）
```

### 3.3 生命周期宏的展开映射

| 你写的宏 | 展开为 | 调用时机 |
|---|---|---|
| `BEFORE_EACH() { ... }` | `virtual void Setup() override` | 每个 TEST_METHOD 前 |
| `AFTER_EACH() { ... }` | `virtual void TearDown() override` | 每个 TEST_METHOD 后（失败也执行） |
| `BEFORE_ALL() { ... }` | `static void BeforeAll(const FString&)` | 整个 class 首个方法前一次 |
| `AFTER_ALL() { ... }` | `static void AfterAll(const FString&)` | 整个 class 全部方法后一次 |

`BEFORE_ALL`/`AFTER_ALL` 通过 C++20 concept 在编译期零开销检测：

```cpp
template <typename T>
concept HasBeforeAll = requires(T t) { { T::BeforeAll(FString()) }; };

TTest() {
    if constexpr (HasBeforeAll<Derived>)  { this->BeforeAllFunc = Derived::BeforeAll; }
    if constexpr (HasAfterAll<Derived>)   { this->AfterAllFunc  = Derived::AfterAll;  }
}
```

检测到后挂到 `FAutomationTestFramework` 的 `OnEnteringTestSection` / `OnLeavingTestSection` 委托上，由框架在进入/离开该测试 section 时触发。

### 3.4 状态隔离原理：工厂函数

`TTestRunner` 持有工厂函数指针，指向 `TTest<Derived>::CreateTestClass`：

```cpp
static TUniquePtr<TBaseTest<AsserterType>> CreateTestClass(TTestRunner<AsserterType>& Runner)
{
    DerivedType::TestRunner = &Runner;
    return MakeUnique<DerivedType>();   // ← 每个 TEST_METHOD 都 new 一个全新实例
}
```

`TTestRunner::RunTest(TestName)` 每次先 `CurrentTestPtr = TestInstanceFactory(*this)` 重建实例——**成员变量自动回到初始值，这就是状态隔离的全部实现**。

### 3.5 类层次总览

```
FAutomationTestBase                (UE 原生自动化测试基类)
        │
        └─ TTestRunner<AsserterType>       调度器：注册/GetTests/RunTest/flags/tags
                │ （组合持有 CurrentTestPtr）
                ▼
           TBaseTest<AsserterType>          能力基类：Assert 成员、TestCommandBuilder、
                │                           Setup/TearDown 虚函数、AddError/Warning/Info
                └─ TTest<Derived, AsserterType>   ← CRTP
                        │   静态 Methods 表 + CreateTestClass 工厂 + FFunctionRegistrar
                        └─ 用户测试 struct（宏展开生成）
```

---

## 四、执行时序（含 GC 细节）

```
[程序启动] 静态初始化
  ├─ Runner 静态单例构造 → 注册到 FAutomationTestFramework
  │    构造期间创建一次 fixture 实例（bInitializing = true）
  │    → 各 FFunctionRegistrar 把 TEST_METHOD 写入 Methods 表
  └─ bInitializing = false

[运行测试] 每个 TEST_METHOD 是一次独立的 RunTest 调用
  │
  ├─ BeforeAll()                ← 进入该 class 的 section 时触发一次
  │
  │   ┌────────── 单个 TEST_METHOD 的四步命令 ──────────────┐
  │   │ ① TBeforeTestCommand                                │
  │   │     GEngine->DelayGarbageCollection()  ← 测试期间禁 GC│
  │   │     Setup()（BEFORE_EACH）                           │
  │   │     flush 本阶段积累的延迟命令                        │
  │   │ ② TRunTestCommand                                    │
  │   │     若 Setup 已有错误 → 跳过方法体                    │
  │   │     Methods[Name] 查表调用方法体                      │
  │   │     flush 延迟命令                                    │
  │   │ ③ TAfterTestCommand                                  │
  │   │     TearDown()（AFTER_EACH，失败也执行）              │
  │   │     flush OnTearDown 队列（逆序）+ 延迟命令           │
  │   │ ④ TTearDownRunner                                    │
  │   │     CurrentTestPtr = nullptr  ← 析构 fixture          │
  │   │     GEngine->ForceGarbageCollection() ← 强制 GC       │
  │   └──────────────────────────────────────────────────────┘
  │
  └─ AfterAll()                 ← 离开该 class 的 section 时触发一次
```

要点：

- 每个阶段产生的延迟命令都会 **flush 完才进入下一阶段**（通过 `FRunSequence::Prepend` 插队实现）。
- 测试期间延迟 GC、结束后强制 GC——测试里创建的 UObject 不会中途被回收，也不会泄漏到下一个测试。
- `AFTER_EACH` 与 `OnTearDown` 即使测试失败也执行（`ECQTestFailureBehavior::Run`）。

---

## 五、断言体系

### 5.1 原理

```cpp
#define ASSERT_THAT(_assertion) if (!this->Assert._assertion) { return; }
#define ASSERT_FAIL(_Msg)       this->Assert.Fail(_Msg); return;
```

`ASSERT_THAT(IsTrue(X))` 实际是调用 `Assert.IsTrue(X)`——`Assert` 是 `TBaseTest` 持有的断言器成员（默认 `FNoDiscardAsserter`）。断言方法返回 `[[nodiscard]] bool`，失败时内部 `AddError` 并返回 false，宏负责提前 `return` 跳出当前阶段（Setup / 方法体 / TearDown 各自独立）。不抛 C++ 异常，跨平台安全。

### 5.2 断言速查（UE 5.8 实测）

```
ASSERT_THAT( <ConditionFn> )        # 每个方法都有可选的 FailureMessage 尾参
│
├─ 布尔
│   ├─ IsTrue(bCondition)
│   └─ IsFalse(bCondition)
│
├─ 相等 / 不等（任意可比较类型；浮点被 static_assert 禁止，见下）
│   ├─ AreEqual(Expected, Actual)
│   ├─ AreNotEqual(Expected, Actual)
│   ├─ AreEqualIgnoreCase(ExpectedStr, ActualStr)      # FString
│   └─ AreNotEqualIgnoreCase(ExpectedStr, ActualStr)
│
├─ 数值近似（浮点比较唯一正道）
│   └─ IsNear(Expected, Actual, Epsilon)
│
├─ 指针 / 智能指针（raw / TSharedPtr / TUniquePtr）
│   ├─ IsNull(TargetPtr)
│   └─ IsNotNull(TargetPtr)
│
├─ 直接失败
│   └─ ASSERT_FAIL(TEXT("Message"))                    # 记错误并立即 return
│
└─ 反向断言（声明"接下来必然产生错误"，错误被消费则测试通过）
    Assert.ExpectError(TEXT("Expected message"));       # 子串匹配（Contains）
    Assert.ExpectError(TEXT("Expected message"), N);    # 期待出现 N 次
    Assert.ExpectErrorRegex(TEXT("Pattern.*"), N);      # 正则匹配
```

三个重要事实：

1. **浮点禁止用 `AreEqual`**——5.8 源码有 `static_assert(!std::is_floating_point ...)`，提示改用 `IsNear()`；确要精确比较用 `IsTrue(A == B)`。
2. **`IsNearlyEqual` 不是断言器方法**。它们在 `CQTestCondition` 命名空间（float/double/FVector/FRotator/FTransform 各重载，默认容差 `UE_KINDA_SMALL_NUMBER`），是 `IsNear`/`AreEqual` 的底层实现，也可自己组合：
   `ASSERT_THAT(IsTrue(CQTestCondition::IsNearlyEqual(VecA, VecB)))`。
3. **`ExpectError` 底层是 `FAutomationTestBase::AddExpectedError`**，语义是"预期日志中出现该错误"——既可用于测试防御性代码（非法输入必须报错），也用于框架自测。

自定义类型的失败消息可读性由 `CQTestConvert::ToString` 决定（`Assert/CQTestConvert.h`），可为自己的类型特化。

### 5.3 断言之外：直接日志方法（来自 TBaseTest）

```
ASSERT_THAT(...)         → 失败立即 return，后续代码不执行
AddError(Msg)            → 记错误（最终判 FAIL），但继续执行
AddErrorIfFalse(b, Msg)  → 条件记错误，返回 bool 供手动控制流程
AddWarning(Msg)          → 警告，不影响通过 / 失败判定
AddInfo(Msg)             → 纯日志
```

适合"收集多个失败点后统一报告"的场景。另有 `TestRunner.SetSuppressLogWarnings()` / `SetSuppressLogErrors()` 控制日志抑制行为。

---

## 六、延迟命令（TestCommandBuilder）

引擎中大量操作是跨帧异步的（加载关卡、等待复制、等待 UI 刷新），不能同步断言。`TestCommandBuilder` 是 `TBaseTest` 内置成员，提供链式命令队列；每个 API 都有带 `Description` 前缀参数的重载（会输出到日志，强烈建议网络/地图测试写上）。

```cpp
TEST_METHOD(AsyncFeature_WhenTriggered_Completes)
{
    TestCommandBuilder
        .Do(TEXT("Trigger operation"), [this]() { /* 触发异步操作 */ })
        .Until(TEXT("Wait complete"), [this]() { return /* 轮询条件 */; })
        .Then([this]() { ASSERT_THAT(IsTrue(/* 结果验证 */)); })
        .OnTearDown([this]() { /* 清理，逆序执行 */ });
}
```

| API | 行为 |
|-----|------|
| `.Do(Fn)` / `.Then(Fn)` | 执行一次（`Then` 是 `Do` 的别名，用于链式可读性） |
| `.Until(Pred, Timeout)` | 每帧轮询直到 true；超时判失败 |
| `.StartWhen(Pred, Timeout)` | `Until` 的别名，语义为"前置条件门控" |
| `.WaitDelay(Timespan)` | 固定时间等待（官方注释警告有 flaky 风险，优先 `Until`） |
| `.DoAsync<T>(Fn, [ResultCb], Timeout)` | 后台线程执行 `TAsyncResult<T>`，可带结果回调 |
| `.ThenAsync<T>(...)` | `DoAsync` 别名 |
| `.UntilAsync<T>(Fn, Pred, T1, T2)` | 异步执行 + 对结果轮询判定 |
| `.OnTearDown(Fn)` / `.CleanUpWith(Fn)` | 清理回调，**逆序**执行，失败也执行 |

原理与限制：

- 队列在每个阶段（Setup / 方法体 / TearDown）结束时被 `Build()` 成 `FRunSequence` 插入 UE latent 系统，flush 完才进入下一阶段。
- 一旦 `TestRunner.HasAnyErrors()`，后续入队的命令直接跳过（错误快速短路）。
- **不能在 latent 命令内部再添加 latent 命令**——析构时 `checkf(CommandQueue.IsEmpty(), ...)` 直接 check 掉。
- 需要更底层控制时可用 `AddCommand(IAutomationLatentCommand*)` 直接入队自定义命令。

### 超时配置（UCQTestSettings）

```
CVar                                            5.8 默认值
TestFramework.CQTest.CommandTimeout             10s   ← Until 等普通命令
TestFramework.CQTest.CommandTimeout.Network     30s   ← PIENetworkComponent
TestFramework.CQTest.CommandTimeout.MapTest     30s   ← 地图加载等待
```

- ini 持久化：`Config/DefaultEngine.ini` 的 `[/Script/CQTest.CQTestSettings]` 段（`CommandTimeout=` / `NetworkTimeout=` / `MapTestTimeout=`）；编辑器路径 `Project Settings → Engine → CQ Test Settings`。
- 单测试临时改超时（RAII，作用域结束自动恢复）：

```cpp
TSharedPtr<FScopedTestEnvironment> ScopedTimeout =
    UCQTestSettings::SetTestClassTimeouts(FTimespan::FromSeconds(60.0));
```

---

## 七、测试组件（Test Components）

组件以成员变量方式持有，随 fixture 一起重建/析构，"组合优于继承"。

### 组件选型速查

```
生成 Actor/UObject，不需要真实关卡？
  └─ FActorTestSpawner                （最轻量，创建最小 UWorld）

需要真实关卡（NavMesh / GameMode / 地形）？
  └─ FMapTestSpawner
       ├─ 已有地图  → 构造函数 + AddWaitUntilLoadedCommand
       └─ 临时空关卡 → CreateFromTempLevel（自动处理等待）

需要 Server + N 个 Client 的 PIE 网络仿真？
  └─ NETWORK_TEST_CLASS + FPIENetworkComponent<State> + FNetworkComponentBuilder

需要按属性名参数化构造 Actor/UObject？
  └─ TObjectBuilder<T>                （反射 SetParam + 延迟 FinishSpawning）

需要等待 Slate UI 刷新？
  └─ FCQTestSlateComponent + HaveTicksElapsed(N)

需要模拟玩家输入（EnhancedInput）？
  └─ FInputTestActions                （独立插件 CQTestEnhancedInput，仅 EditorContext）

需要按名字查蓝图类 / 资产？
  └─ CQTestAssetHelper 命名空间        （需 EditorContext）
```

### 7.1 FSpawnHelper（基类，不直接用）

`FActorTestSpawner` / `FMapTestSpawner` 的共同基类，提供：

```cpp
ActorType&  SpawnActor<ActorType>(SpawnParams = {}, UClass* Class = nullptr);   // 返回引用，内部 check 非空
ActorType&  SpawnActorAt<ActorType>(Location, Rotation, ...);                   // 指定位置生成
ObjectType& SpawnObject<ObjectType>();    // static_assert：必须 UObject 派生且非 AActor
UWorld&     GetWorld();
```

所有生成物被追踪，析构时自动清理，无需手动管理。

### 7.2 FActorTestSpawner（轻量测试世界）

不加载任何关卡，内部创建最小 UWorld。适合 Actor/组件逻辑单元测试。

```cpp
TEST_CLASS(MyActorTests, "Game.Unit")
{
    FActorTestSpawner Spawner;                       // 直接做成员即可

    TEST_METHOD(Spawn_MyActor_Initializes)
    {
        AMyActor& Actor = Spawner.SpawnActor<AMyActor>();
        ASSERT_THAT(IsTrue(Actor.IsInitialized()));
    }
};
```

需要 GameInstance/子系统时调用 `Spawner.InitializeGameSubsystems()`，然后 `Spawner.GetGameInstance()`（`UTestGameInstance`）。

### 7.3 FMapTestSpawner（真实关卡 / PIE）

```cpp
#include "Components/MapTestSpawner.h"

TEST_CLASS(MyMapTests, "Game.Integration")   // 地图测试通常需要 EditorContext flags
{
    TUniquePtr<FMapTestSpawner> Spawner;
    APawn* PlayerPawn = nullptr;

    BEFORE_EACH()
    {
        // 模式一：加载已有地图（官方样板：等待命令就写在 BEFORE_EACH 里）
        Spawner = MakeUnique<FMapTestSpawner>(TEXT("/Game/Maps"), TEXT("TestLevel"));
        Spawner->AddWaitUntilLoadedCommand(TestRunner);
        // 模式二：临时空关卡（内部已处理等待，无需再调 AddWaitUntilLoadedCommand）
        // Spawner = FMapTestSpawner::CreateFromTempLevel(TestCommandBuilder);
    }

    TEST_METHOD(PlayerPawn_AfterLoad_Found)
    {
        TestCommandBuilder
            .StartWhen([this]() {
                PlayerPawn = Spawner->FindFirstPlayerPawn();
                return PlayerPawn != nullptr;
            })
            .Then([this]() { ASSERT_THAT(IsNotNull(PlayerPawn)); });
    }
};
```

注意：`AddWaitUntilLoadedCommand` 必须在 **latent 命令之外**调用（`BEFORE_EACH` 本体或方法体开头均可，不能在 `.Do(...)` 内），超时默认取 MapTest CVar。

### 7.4 TObjectBuilder（参数化构造）

`ObjectBuilder.h`，按属性名反射赋值 + 延迟构造，适合准备复杂初始状态：

```cpp
#include "ObjectBuilder.h"

// UObject：直接构造
UMyData& Data = TObjectBuilder<UMyData>()
    .SetParam(FName("MaxHealth"), 100)
    .SetParam(FName("DisplayName"), FString(TEXT("Boss")))
    .Spawn();

// Actor：配合 SpawnHelper 走 bDeferConstruction，Spawn() 时才 FinishSpawning
AMyActor& Actor = TObjectBuilder<AMyActor>(Spawner)
    .SetParam(FName("bInvincible"), true)
    .AddComponentTo<UMyComponent>()
    .Spawn(SpawnTransform);
```

`SetParam` 支持数值/bool/FName/FString/FVector/枚举/UObject 指针/TObjectPtr/TArray/TSet/TMap/结构体，类型不匹配输出错误日志而不是崩溃。**只能在 `Spawn()` 前设置参数，且只能 Spawn 一次**。

### 7.5 FPIENetworkComponent（网络多端仿真）

最重的组件：启动真实 PIE 会话，模拟 Server + N Clients。三层结构：

```
┌────────────────────────────────────────────────────────────────┐
│ Layer 1 · State（每端各持一份独立实例，互不共享）                 │
│   struct FMyState : FBasePIENetworkComponentState               │
│   { AMyActor* ReplicatedActor = nullptr; ... };                 │
│   基类自带：World / ClientConnections / ClientIndex /            │
│             ClientCount / bIsDedicatedServer                    │
├────────────────────────────────────────────────────────────────┤
│ Layer 2 · Component（链式命令，全部入队延迟执行）                 │
│   FPIENetworkComponent<FMyState> Network{                       │
│       TestRunner, TestCommandBuilder, bInitializing };          │
├────────────────────────────────────────────────────────────────┤
│ Layer 3 · Builder（BEFORE_EACH 中配置并 Build）                  │
│   FNetworkComponentBuilder<FMyState>()                          │
│       .WithClients(2)              // 不含 server                │
│       .AsDedicatedServer()         // 或 .AsListenServer()       │
│       .WithGameMode(AMyGameMode::StaticClass())                 │
│       .WithGameInstanceClass(FSoftClassPath(...))               │
│       .WithPacketSimulationSettings(&PacketSettings)            │
│       .Build(Network);                                          │
└────────────────────────────────────────────────────────────────┘
```

`Build` 内部自动入队启动链：StopPie → CreateNewMap → StartPie → 等待 Worlds 就绪 → 应用丢包设置 → 连接 Clients → 等待就绪，并注册 `RestoreState` 清理（`FPIENetworkTestStateRestorer` 还原编辑器状态）。

官方样板（源自 5.8 头文件）：

```cpp
#include "Components/PIENetworkComponent.h"
#if ENABLE_PIE_NETWORK_TEST                       // WITH_EDITOR && Automation

NETWORK_TEST_CLASS(MyNetworkTests, "Game.Network")
{
    struct DerivedState : public FBasePIENetworkComponentState
    {
        APawn* ReplicatedPawn = nullptr;
    };

    FPIENetworkComponent<DerivedState> Network{ TestRunner, TestCommandBuilder, bInitializing };

    BEFORE_EACH()
    {
        FNetworkComponentBuilder<DerivedState>()
            .WithClients(2)
            .WithGameInstanceClass(UGameInstance::StaticClass())
            .WithGameMode(AGameModeBase::StaticClass())
            .Build(Network);
    }

    TEST_METHOD(SpawnAndReplicatePawn_WithReplicatedPawn_ProvidesPawnToClients)
    {
        Network.SpawnAndReplicate<APawn, &DerivedState::ReplicatedPawn>()
            .ThenServer([this](DerivedState& ServerState) {
                ASSERT_THAT(IsNotNull(ServerState.ReplicatedPawn));
            })
            .ThenClients([this](DerivedState& ClientState) {
                ASSERT_THAT(IsNotNull(ClientState.ReplicatedPawn));
            });
    }
};
#endif
```

链式 API 速查（均有带 `Description` 的重载；Until 系列可传 Timeout，默认取 Network CVar）：

```
执行端                     API
──────────────────────────────────────────────────────────────
Server 执行一步            .ThenServer([](State&){...})
所有 Client 各执行一步      .ThenClients([](State&){...})
指定 Client[i] 执行        .ThenClient(i, [](State&){...})
等待 Server 条件           .UntilServer([](State&)->bool{...}, Timeout)
等待所有 Client 条件        .UntilClients(...)
等待指定 Client 条件        .UntilClient(i, ...)
中途动态加入新 Client       .ThenClientJoins(Timeout)
Server 生成并等复制完成     .SpawnAndReplicate<AActor, &State::Ptr>()
                             重载：(SpawnParams) / (BeforeReplicateFn) / (两者)
无网络上下文的通用步骤      .Then / .Do / .Until / .StartWhen（继承自基类）
```

项目级封装模式：把高频的多步 `Until/Then` 链收敛成语义方法（参考 Lyra `FShooterTestsNetworkComponent`）：

```cpp
// 测试代码从 4~6 步样板链简化为：
Network.WaitForServerPlayerSpawn()
       .WaitForClientPlayerSpawn()
       .ThenServer(TEXT("Actual test logic"), ...);
```

### 7.6 FCQTestSlateComponent（Slate Tick 同步）

构造时强制 `Slate.AllowSlateToSleep=0` 并挂 `OnPostTick` 计数；析构自动还原。

```cpp
TUniquePtr<FCQTestSlateComponent> SlateComponent;   // BEFORE_EACH 中 MakeUnique

TestCommandBuilder
    .Do([this]() { /* 触发 UI 更新 */ })
    .StartWhen([this]() { return SlateComponent->HaveTicksElapsed(2); })
    .Then([this]() { ASSERT_THAT(IsTrue(/* UI 状态验证 */)); });
```

`HaveTicksElapsed(N)` 是单次等待语义（内部设一次 `ExpectedTick`，达到即重置），只应作为 `Until`/`StartWhen` 谓词中的唯一语句。

### 7.7 FInputTestActions（输入注入）

在独立插件 `Engine/Plugins/Tests/CQTestEnhancedInput`（5.5 起 CQTest 升为 Engine Module 后无法反向引用插件，故拆出）。仅 EditorContext。

```cpp
FInputTestActions InputActions(Pawn);         // 绑定目标 Pawn

FTestAction MoveAction;
MoveAction.InputActionName  = TEXT("IA_Move");
MoveAction.InputActionValue = FInputActionValue(FVector2D(0.f, 1.f));
InputActions.PerformAction(MoveAction);       // 注入一次输入
// ... .Until(移动完成) ...
InputActions.StopAllActions();
```

### 7.8 CQTestAssetHelper（资产查询，EditorContext）

工具命名空间（非组件），替代 5.5 移除的 `FCQTestBlueprintHelper`：

```cpp
#include "Helpers/CQTestAssetHelper.h"

FARFilter Filter = CQTestAssetHelper::FAssetFilterBuilder()
    .WithPackagePath(TEXT("/Game/Data"))
    .Build();

UClass*  BpClass = CQTestAssetHelper::GetBlueprintClass(Filter, TEXT("BP_MyChar"));
UObject* Data    = CQTestAssetHelper::FindDataBlueprint(Filter, TEXT("DA_Config"));
ASSERT_THAT(IsNotNull(BpClass));
```

另有 `FindAssetPackagePathByName` / `FindAssetsByFilter` / `GetBlueprintClasses` / `FindDataBlueprints`。
**若在构造函数中调用，必须先判 `bInitializing == false`**——注册阶段插件资产可能尚未加载（见 8.3）。

---

## 八、扩展框架

三个正交维度：**组件解决环境搭建，自定义基类解决逻辑复用，自定义断言器解决领域语义**。

### 8.1 自定义断言器

```cpp
struct FMyAsserter : public FNoDiscardAsserter
{
    FMyAsserter(FAutomationTestBase& TestRunner) : FNoDiscardAsserter(TestRunner) {}

    [[nodiscard]] bool IsValidHealth(int32 Health)
    {
        return IsTrue(Health >= 0 && Health <= 100,
            FString::Printf(TEXT("Health %d out of range [0,100]"), Health));
    }
};

#define MY_TEST_CLASS(_ClassName, _TestDir) \
    TEST_CLASS_WITH_ASSERTS(_ClassName, _TestDir, FMyAsserter)

MY_TEST_CLASS(CharacterTests, "Game.Character")
{
    TEST_METHOD(Spawn_FullHealth_IsValid)
    {
        ASSERT_THAT(IsValidHealth(100));   // 自定义断言
        ASSERT_THAT(IsTrue(true));         // 基类断言仍可用
    }
};
```

### 8.2 自定义基类（TEST_CLASS_WITH_BASE）

模板签名必须严格为 `template<typename Derived, typename AsserterType>`：

```cpp
template <typename Derived, typename AsserterType>
struct TMyGameTestBase : public TTest<Derived, AsserterType>
{
    inline static UMySubsystem* SharedSubsystem = nullptr;   // 跨实例共享
    FActorTestSpawner Spawner;                               // 每实例独立（组合组件）

    BEFORE_ALL() { SharedSubsystem = GEngine->GetEngineSubsystem<UMySubsystem>(); }
    AFTER_ALL()  { SharedSubsystem = nullptr; }

    AMyActor& SpawnMyActor() { return Spawner.SpawnActor<AMyActor>(); }
};

#define MY_GAME_TEST(_ClassName, _TestDir) \
    TEST_CLASS_WITH_BASE(_ClassName, _TestDir, TMyGameTestBase)

MY_GAME_TEST(CombatTests, "Game.Combat")
{
    // 派生类若也声明 BEFORE_ALL，会遮蔽基类版本，必须手动链式调用：
    BEFORE_ALL()
    {
        TMyGameTestBase::BeforeAll(FString());
        // ... 派生类自己的一次性初始化 ...
    }

    TEST_METHOD(Damage_ReducesHealth)
    {
        AMyActor& Actor = SpawnMyActor();      // 直接用基类辅助方法
        Actor.TakeDamage(10.f);
        ASSERT_THAT(IsNear(90.f, Actor.GetHealth(), 0.001f));
    }
};
```

### 8.3 bInitializing 守卫

fixture 会在**程序启动注册阶段**被构造一次（用于收集 TEST_METHOD），此时不能访问 World/资产/子系统。构造函数中需要昂贵初始化时必须区分：

```cpp
TMyGameTestBase()
{
    if (!this->bInitializing)
    {
        // 只有真正运行测试时才执行：此时插件已加载、AssetRegistry 就绪
        CachedAsset = CQTestAssetHelper::FindDataBlueprint(TEXT("BP_MyAsset"));
    }
}
```

---

## 九、抽象模板（按场景选择）

```
只验证一个逻辑点，无状态？          → 模板 1  TEST
多场景共享 setup/teardown？        → 模板 2  TEST_CLASS + TEST_METHOD
需要跨帧 / 轮询 / 异步等待？        → 模板 3  TestCommandBuilder 链
需要 Server/Client 网络验证？      → 7.5 的 NETWORK_TEST_CLASS 样板
```

**模板 1 —— 单个无状态测试**

```cpp
#include "CQTest.h"

TEST(FeatureSimpleTest, "Game.Module.Feature")
{
    // [Arrange]
    auto Input = /* 构造输入 */;
    // [Act]
    auto Result = /* 调用被测函数(Input) */;
    // [Assert]
    ASSERT_THAT(AreEqual(/* ExpectedValue */, Result));
}
```

**模板 2 —— 标准 Fixture**

```cpp
#include "CQTest.h"

TEST_CLASS(FeatureTests, "Game.Module.Feature")
{
    // 共享成员：每个 TEST_METHOD 前自动重置为初始值
    /* FFooSystem* SystemUnderTest = nullptr; */

    BEFORE_EACH() { /* SystemUnderTest = NewObject<...>(); Init(...); */ }
    AFTER_EACH()  { /* 清理；即使断言失败也会执行 */ }

    TEST_METHOD(WhenConditionA_ExpectResultX)
    {
        /* auto Result = SystemUnderTest->DoSomething(ConditionA); */
        ASSERT_THAT(AreEqual(/* ExpectedX */, /* Result */));
    }

    TEST_METHOD(WhenInvalidInput_ExpectRejected)
    {
        /* bool bAccepted = SystemUnderTest->TryProcess(InvalidValue); */
        ASSERT_THAT(IsFalse(/* bAccepted */));
    }
};
```

**模板 3 —— 异步 / 跨帧**

```cpp
TEST_METHOD(WhenAsyncOpCompletes_ExpectSuccess)
{
    TestCommandBuilder
        .Do(TEXT("Start operation"),  [this]() { /* AsyncOp->Start(); */ })
        .Until(TEXT("Wait complete"), [this]() { return /* AsyncOp->IsComplete() */; })
        .Then([this]() { ASSERT_THAT(IsTrue(/* AsyncOp->Succeeded() */)); })
        .OnTearDown([this]() { /* AsyncOp->Cancel(); */ });
}
```

---

## 十、运行测试

CQTest 注册的就是标准 UE Automation Test，所有原生入口都可用：

```bash
# 编辑器内：Window → Session Frontend（Test Automation）→ 按前缀过滤 → Start Tests

# 命令行（CI / 无头，最常用）
UnrealEditor-Cmd.exe MyProject.uproject ^
    -ExecCmds="Automation RunTests Game.Module; Quit" ^
    -unattended -nullrhi -nosound -log ^
    -ReportOutputPath="TestResults/"

# 只跑单个测试类 / 方法（前缀匹配）
-ExecCmds="Automation RunTests Game.Module.FeatureTests; Quit"
```

过滤前缀 = `TEST_CLASS` 第二个参数拼上类名。Flags 决定哪些上下文能发现该测试：默认 `ApplicationContextMask | ProductFilter` 覆盖编辑器与命令行；仅编辑器用 `EditorContext | ProductFilter`（网络/地图/资产测试基本都需要）。

> 本项目内请通过 `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` 运行，详见 `Documents/Guides/Test.md`。

---

## 十一、源码地图（UE 5.8）

```
Engine/Source/Developer/CQTest/Public/
  CQTest.h                          ← 宏 / TTest / TTestRunner / TBaseTest（顶部含官方样板）
  Impl/CQTest.inl                   ← RunTest 四步命令、GC 策略、注册实现
  CQTestSettings.h                  ← 超时 CVar / UCQTestSettings / SetTestClassTimeouts
  ObjectBuilder.h                   ← TObjectBuilder 参数化构造
  TestGameInstance.h                ← UTestGameInstance（ActorTestSpawner 用）
  Assert/
    NoDiscardAsserter.h / .inl      ← 断言器全部方法与实现
    CQTestCondition.h               ← IsEqual / IsNearlyEqual 等条件函数
    CQTestConvert.h                 ← 失败消息 ToString（可特化）
  Commands/
    TestCommandBuilder.h            ← Do/Until/StartWhen/DoAsync/OnTearDown 全部 API
    TestCommands.h                  ← FExecute / FWaitUntil / FWaitDelay / FRunSequence
    TestMacros.h                    ← 延迟命令辅助宏
  Components/
    SpawnHelper.h                   ← SpawnActor / SpawnActorAt / SpawnObject
    ActorTestSpawner.h              ← 最小 UWorld
    MapTestSpawner.h                ← 关卡加载 / 临时关卡
    PIENetworkComponent.h           ← 网络组件 + Builder + NETWORK_TEST_CLASS
    PIENetworkTestStateRestorer.h   ← PIE 状态还原
    CQTestSlateComponent.h          ← Slate tick 计数
    CQTestBlueprintHelper.h         ← 旧蓝图助手（已废弃，用 CQTestAssetHelper）
  Helpers/
    CQTestAssetHelper.h             ← 资产 / 蓝图查询 + FAssetFilterBuilder

Engine/Plugins/Tests/CQTestEnhancedInput/     ← FInputTestActions（输入注入）
Engine/Plugins/Tests/CQTest/Source/CQTestTests/ ← 框架自测 = 最全的用法示例
Samples/Games/Lyra/.../ShooterTests/          ← FPIENetworkComponent 项目级封装范例
```

---

## 十二、版本差异勘误（对照网络资料时注意）

以下几点常见于基于 ue5-main 早期版本的资料，与 UE 5.8 实际源码不符：

1. **没有 `Assert.ExpectError(AnyError)`**。5.8 的 `ExpectError(FString, Count)` 为子串匹配，正则用 `ExpectErrorRegex`；不存在 `AnyError` 常量。
2. **`IsNearlyEqual` / `IsNotNearlyEqual` 不能直接放进 `ASSERT_THAT`**。它们是 `CQTestCondition` 命名空间函数，不是断言器方法；断言器提供的是 `IsNear(Expected, Actual, Epsilon)`。
3. **`AreEqual` / `AreNotEqual` 禁用浮点**（`static_assert`），浮点必须 `IsNear`。
4. **默认超时为 10s / 30s / 30s**（Command / Network / MapTest），不是 30/120/120。
5. **`AddWaitUntilLoadedCommand` 可以且推荐在 `BEFORE_EACH` 中调用**（官方样板即如此）；真正的限制是"不能在 latent 命令内部调用"。
6. `BEFORE_ALL`/`AFTER_ALL` 签名为 `static void BeforeAll(const FString&)`，通过测试 section 委托触发，链式调用基类时写 `TBase::BeforeAll(FString())`。
