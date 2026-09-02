# 会话记录 - UnrealEngine/UnrealEngine

## 🙋 用户（2026/08/27 19:18:21）

帮我分析下ue 的cqtest 的框架是怎么样的, 梳理出一些ascii 图示, 相关的宏是怎么实现的

## 🤖 AI 助手（2026/08/27 19:18:21）

我来帮你分析 UE 的 CQTest 框架。先并行检索相关代码和文档。
很好，已经获得了 CQTest 框架的概况。现在进一步检索宏实现细节和 TTest 模板类的相关代码。
已经收集到足够信息，现在整理完整分析。

---

## CQTest 框架分析

### 一、概述

**CQTest**（Code Quality Tests）是 UE5 内置的 C++ 自动化测试框架，其核心动机是：在 UE 原生 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 和 Spec Test 的基础上，增加每个 test case 的 before/after 生命周期钩子，并**自动重置测试状态**，保证每个测试的原子性。[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Why CQTest?)

从 UE 5.5 开始，CQTest 核心已从 Plugin 提升为 **Engine Module**，位于 `Engine/Source/Developer/CQTest`，不再需要显式启用插件。[[2]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md/Extending the framework/Test Components/Notable Changes#5.5)

---

### 二、模块目录结构

```
Engine/Source/Developer/CQTest/       ← 核心 Engine Module
├── CQTest.Build.cs                   ← 模块依赖声明
├── README.md                         ← 官方文档
├── Public/
│   ├── CQTest.h                      ← 核心头：TBaseTest/TTestRunner/TTest
│   ├── CQTestSettings.h              ← 超时配置 UCQTestSettings
│   ├── Assert/
│   │   ├── CQTestAssert.h            ← ASSERT_THAT 断言基础
│   │   └── CQTestConvert.h           ← ToString 工具类
│   └── Commands/
│       └── TestMacros.h              ← 延迟命令宏定义
└── Private/
    ├── CQTestSettings.cpp
    └── Components/                   ← 扩展组件
        ├── CQTestSlateComponent      ← Slate 测试环境管理
        ├── PIENetworkComponent       ← PIE 网络测试
        └── MapTestSpawner            ← 地图测试 Actor 生成

Engine/Plugins/Tests/CQTest/          ← 验证框架自身的测试 Plugin（已 deprecated）
└── Source/CQTestTests/
    └── Private/
        ├── CQTestTests.cpp           ← 核心功能单元测试
        ├── ExtensionTests.cpp        ← 扩展示例
        └── Helpers/
            └── CQTestAssetHelperTests.cpp
```

---

### 三、核心类层次结构

[[3]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

```
FAutomationTestBase   (UE 原生自动化测试基类)
        │
        └─── TTestRunner<AsserterType>
                    │   管理测试名称注册、执行调度、
                    │   flags/tags/超时配置
                    │
                    └─── TBaseTest<AsserterType>
                                │   持有 Assert 成员、
                                │   AddCommand/LatentAction 等通用能力
                                │
                                └─── TTest<Derived, AsserterType>  ← CRTP
                                            │   通过 FFunctionRegistrar 注册
                                            │   每个 TEST_METHOD 到静态 Methods 表
                                            │
                                            └─── UserTestClass  (由宏展开生成)
                                                      包含 BEFORE_EACH/AFTER_EACH
                                                      以及所有 TEST_METHOD 方法体
```

`TTest` 使用 **CRTP（Curiously Recurring Template Pattern）** 模式，`Derived` 是用户的测试结构体，`AsserterType` 默认为 `FNoDiscardAsserter`，可替换为自定义断言器。

---

### 四、单次测试执行流程

```
FAutomationTestFramework::RunTests()
        │
        ▼
TTestRunner::RunTest(TestName)
        │
        ├─[1] BEFORE_ALL()  ── 仅首次执行，static，对该 class 全部 methods 只调一次
        │
        │   ┌─────────────────── 每个 TEST_METHOD 循环 ──────────────────┐
        │   │                                                              │
        │   ├─[2] new DerivedClass()  ← 每次都重新构造，自动重置成员状态   │
        │   │                                                              │
        │   ├─[3] BEFORE_EACH()       ← 支持 AddCommand 延迟动作          │
        │   │        │                                                     │
        │   │        └── flush all latent commands                        │
        │   │                                                              │
        │   ├─[4] TEST_METHOD body    ← 支持 AddCommand / TestCommandBuilder│
        │   │        │                                                     │
        │   │        └── flush all latent commands                        │
        │   │                                                              │
        │   ├─[5] AFTER_EACH()        ← 即使 TEST_METHOD 有断言失败也执行  │
        │   │        │                                                     │
        │   │        └── flush all latent commands                        │
        │   │                                                              │
        │   └─[6] ~DerivedClass()     ← 析构，OnTearDown 逆序执行         │
        │                                                                  │
        └──────────────── 完成所有 methods 后 ────────────────────────────┘
                │
                └─[7] AFTER_ALL()    ← 所有 methods 全部完成后调用一次
```

---

### 五、核心宏实现解析

**`TEST`（单体测试，无 fixture）** [[4]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

```cpp
TEST(MinimalTest, "Game.MyGame")
{
    ASSERT_THAT(IsTrue(true));
}
// 宏展开后等效于：
// 1. 定义一个继承 TTest 的匿名结构体
// 2. 定义唯一的 RunTest 方法（包含测试体）
// 3. 通过静态初始化注册到 FAutomationTestFramework
```

**`TEST_CLASS` / `TEST_METHOD`（多方法 fixture）**

```cpp
TEST_CLASS(MyFixture, "Game.MyGame")
{
    // 成员变量  ← 每次 TEST_METHOD 执行时通过 new 重新构造，自动归零
    uint32 SomeNumber = 0;

    BEFORE_EACH()  { SomeNumber++; }    // 每个方法前调用
    AFTER_EACH()   { /* teardown */ }  // 每个方法后调用
    BEFORE_ALL()   { /* 仅一次 */ }    // 可选，static
    AFTER_ALL()    { /* 仅一次 */ }    // 可选，static

    TEST_METHOD(SomeTest) { ASSERT_THAT(AreEqual(1, SomeNumber)); }
};
// 宏展开后：定义 struct MyFixture : TTest<MyFixture, FNoDiscardAsserter>
// 每个 TEST_METHOD 通过 FFunctionRegistrar 静态对象在全局初始化期间注册到
// DerivedType::Methods 映射表中
```

**宏家族全貌** [[5]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

| 宏 | 作用 |
|---|---|
| `TEST` | 最简单的单体测试 |
| `TEST_CLASS` | 带 fixture 的测试类 |
| `TEST_METHOD` | 类内注册一个测试方法 |
| `TEST_CLASS_WITH_BASE` | 继承自定义基类（用于共享逻辑） |
| `TEST_CLASS_WITH_FLAGS` | 指定 `EAutomationTestFlags` |
| `TEST_CLASS_WITH_ASSERTS` | 使用自定义断言器 |
| `TEST_WITH_TAGS` / `TEST_CLASS_WITH_TAGS` / `TEST_METHOD_WITH_TAGS` | 添加过滤标签 |
| `_TEST_CLASS_IMPL_EXT` | 所有上述宏的底层实现宏，统一入口 |

默认 flags 为 `EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::ProductFilter`。

---

### 六、延迟命令系统（Latent Commands）

`AddCommand` / `TestCommandBuilder` 提供异步友好的顺序步骤执行能力，每个 phase（BEFORE_EACH → TEST_METHOD → AFTER_EACH）执行完毕后都会 flush 完所有 pending 命令再继续。[[4]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

```
TestCommandBuilder
  .Do(lambda)                  → FExecute        一次性执行
  .Until(pred)                 → FWaitUntil      轮询等待（推荐代替 WaitDelay）
  .WaitDelay(duration)         → FWaitDelay      时间等待（有 flakiness 风险）
  .DoAsync / .ThenAsync        → TAsyncExecute   异步任务，不阻塞 GameThread
  .OnTearDown(lambda)          → 逆序执行的清理回调
```

---

### 七、扩展框架

继承 `TTest<Derived, AsserterType>` 即可创建自定义基类，再配合 `TEST_CLASS_WITH_BASE` 宏复用：[[6]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/ExtensionTests.cpp#ExtensionTests.cpp)

```cpp
template<typename Derived, typename AsserterType>
struct TMyBaseTest : public TTest<Derived, AsserterType> {
    BEFORE_ALL() { /* shared setup */ }
    void SharedHelper() { ASSERT_THAT(IsTrue(something)); }
};

#define MY_TEST(_ClassName, _Dir) TEST_CLASS_WITH_BASE(_ClassName, _Dir, TMyBaseTest)

MY_TEST(MyDerivedTest, "Game.MyTests")
{
    TEST_METHOD(CanUseHelper) { SharedHelper(); }
};
```

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/README.md#Why CQTest?](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Why CQTest?)

[2]. [Engine/Source/Developer/CQTest/README.md/Extending the framework/Test Components/Notable Changes#5.5](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md/Extending the framework/Test Components/Notable Changes#5.5)

[3]. [Engine/Source/Developer/CQTest/Public/CQTest.h#TTest](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

[4]. [Engine/Source/Developer/CQTest/README.md#Examples](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

[5]. [Engine/Source/Developer/CQTest/README.md#Examples](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

[6]. [Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/ExtensionTests.cpp#ExtensionTests.cpp](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/ExtensionTests.cpp#ExtensionTests.cpp)

## 🙋 用户（2026/08/27 19:42:23）

cqtest 这些宏都什么搞的, 能否给我详细解释解释, 最好绘制相关的ascii 映射来说明下, 

## 🤖 AI 助手（2026/08/27 19:42:23）

我来检索 CQTest 宏的具体源码实现。
太好了，拿到了 `TTest` 和 `FFunctionRegistrar` 的真实源码。现在整合所有信息给出完整的宏展开分析。

---

## CQTest 宏详细解析

### 一、宏家族全貌与继承关系

所有公开宏最终都汇聚到两个底层宏 `_TEST_CLASS_IMPL` / `_TEST_CLASS_IMPL_EXT`，其关系如下：[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

```
用户宏                           底层实现宏
─────────────────────────────────────────────────────────────────────
TEST(Name, Dir)               ──► _TEST_CLASS_IMPL(Name, Dir,
                                      FNoDiscardAsserter, TTest, DefaultFlags, "")
                                  + 单方法特化（直接把 body 注入为唯一 TEST_METHOD）

TEST_CLASS(Name, Dir)         ──► _TEST_CLASS_IMPL(Name, Dir,
                                      FNoDiscardAsserter, TTest, DefaultFlags, "")

TEST_CLASS_WITH_FLAGS(N,D,F)  ──► _TEST_CLASS_IMPL_EXT(N,D,
                                      FNoDiscardAsserter, TTest, F, "")

TEST_CLASS_WITH_BASE(N,D,B)   ──► _TEST_CLASS_IMPL(N,D,
                                      FNoDiscardAsserter, B, DefaultFlags, "")

TEST_CLASS_WITH_TAGS(N,D,T)   ──► _TEST_CLASS_IMPL_EXT(N,D,
                                      FNoDiscardAsserter, TTest, DefaultFlags, T)

TEST_CLASS_WITH_ASSERTS(N,D,A)──► _TEST_CLASS_IMPL(N,D,
                                      A, TTest, DefaultFlags, "")

TEST_CLASS_WITH_BASE_AND_FLAGS_AND_TAGS(N,D,B,F,T)
                              ──► _TEST_CLASS_IMPL_EXT(N,D,
                                      FNoDiscardAsserter, B, F, T)

_TEST_CLASS_IMPL_EXT(N,D,A,Base,Flags,Tags)   ← 最终底层，所有变体归一
```

---

### 二、`TEST_CLASS` 展开过程（最核心）

[[2]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

你写的代码：
```cpp
TEST_CLASS(MyNeatTest, "Game.MyGame")
{
    uint32 SomeNumber = 0;
    BEFORE_EACH() { SomeNumber++; }
    TEST_METHOD(DoSomething) { ASSERT_THAT(AreEqual(1, SomeNumber)); }
};
```

经过宏展开后，等效于：

```
TEST_CLASS(MyNeatTest, "Game.MyGame") { ... }
    │
    ▼ 展开为 _TEST_CLASS_IMPL(MyNeatTest, "Game.MyGame", FNoDiscardAsserter, TTest, DefaultFlags, "")
    │
    ▼ 展开为以下两个东西：

  ┌──────────────────────────────────────────────────────┐
  │  [1] TTestRunner 静态单例 (注册进 UE 测试框架)         │
  │                                                       │
  │  static TTestRunner<FNoDiscardAsserter>               │
  │      MyNeatTest_Runner(                               │
  │          "Game.MyGame.MyNeatTest",  // 测试全名        │
  │          DefaultFlags,              // 测试标志        │
  │          __FILE__, __LINE__         // 源文件定位      │
  │      );                                               │
  │  // TTestRunner 继承自 FAutomationTestBase            │
  │  // 构造时自动注册到 FAutomationTestFramework          │
  └──────────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────┐
  │  [2] 用户的 fixture struct (继承 TTest<Derived>)      │
  │                                                       │
  │  struct MyNeatTest                                    │
  │      : public TTest<MyNeatTest, FNoDiscardAsserter>   │
  │  {                                                    │
  │      // 你的成员变量                                   │
  │      uint32 SomeNumber = 0;                           │
  │                                                       │
  │      // BEFORE_EACH() 展开为：                         │
  │      void Setup() override { SomeNumber++; }          │
  │                                                       │
  │      // TEST_METHOD(DoSomething) 展开为：（见下节）    │
  │      void DoSomething() { ASSERT_THAT(...); }         │
  │      static inline FFunctionRegistrar                 │
  │          _Reg_DoSomething {                           │
  │              "DoSomething",                           │
  │              &MyNeatTest::DoSomething,                │
  │              __LINE__,                                │
  │              ""  // 无 tags                           │
  │          };                                           │
  │                                                       │
  │      // TTest 的静态成员（整个 class 共享）            │
  │      static TMap<FString, TestMethod> Methods;        │
  │      static TTestRunner<...>* TestRunner;             │
  │  };                                                   │
  └──────────────────────────────────────────────────────┘
```

---

### 三、`TEST_METHOD` 的注册机制（关键魔法）

[[3]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

`TEST_METHOD(DoSomething)` 会生成两个东西：

```
TEST_METHOD(DoSomething) { 测试体 }
    │
    ├─► [1] 普通成员函数声明+定义
    │       void DoSomething() { 测试体 }
    │
    └─► [2] 一个 static inline 的 FFunctionRegistrar 对象
            （利用 C++ 静态初始化在程序启动时自动执行构造函数）

            static inline FFunctionRegistrar _Reg_DoSomething {
                "DoSomething",               // 方法名
                &MyNeatTest::DoSomething,    // 函数指针
                __LINE__,                    // 行号
                ""                           // tags
            };

FFunctionRegistrar 构造函数做了什么？
────────────────────────────────────────────
    DerivedType::TestRunner->TestNames.Add("DoSomething");
    DerivedType::Methods.Add("DoSomething", &MyNeatTest::DoSomething);
    DerivedType::TestRunner->TestLineNumbers.Add("DoSomething", lineNo);
    // 如果有 tags，还注册到 FAutomationTestFramework
```

这就是所谓的**自注册模式**：每个 `TEST_METHOD` 在程序启动时就把自己的函数指针写入 `static TMap<FString, TestMethod> Methods`，运行时只需遍历这张表。

---

### 四、生命周期宏的展开映射

| 你写的宏 | 展开为 |
|---|---|
| `BEFORE_EACH() { ... }` | `void Setup() override { ... }` |
| `AFTER_EACH() { ... }` | `void TearDown() override { ... }` |
| `BEFORE_ALL() { ... }` | `static void BeforeAll() { ... }` |
| `AFTER_ALL() { ... }` | `static void AfterAll() { ... }` |

`TTest` 构造函数中用 `if constexpr (HasBeforeAll<Derived>)` 检测 `static void BeforeAll()` 是否存在，有则赋给 `BeforeAllFunc` 函数指针。

---

### 五、完整执行时序 ASCII 图

```
程序启动期（static 初始化）
═══════════════════════════════════════════════════════════
  TTestRunner 构造 → 注册到 FAutomationTestFramework
  FFunctionRegistrar 构造 × N → Methods 表填充完毕
═══════════════════════════════════════════════════════════

运行期（点击 Start Tests）
═══════════════════════════════════════════════════════════
TTestRunner::RunTest()
  │
  ├─► [可选] BEFORE_ALL() ──── 整个 class 只执行一次
  │
  │   ┌──────── 遍历 Methods 表，每个方法循环一次 ──────────┐
  │   │                                                     │
  │   │  ① new DerivedType()    ← 构造新实例，成员初始化    │
  │   │         │                                           │
  │   │  ② Setup()              ← BEFORE_EACH 展开          │
  │   │         │ flush latent commands                     │
  │   │         ↓                                           │
  │   │  ③ 如果 Setup 中断言失败 ──► 跳到 ⑤ (仍执行)       │
  │   │         │                                           │
  │   │  ④ DoSomething()        ← TEST_METHOD 体            │
  │   │         │ flush latent commands                     │
  │   │         ↓                                           │
  │   │  ⑤ TearDown()           ← AFTER_EACH 展开           │
  │   │         │ flush latent commands                     │
  │   │         ↓                                           │
  │   │  ⑥ ~DerivedType()       ← 析构，OnTearDown 逆序    │
  │   │                                                     │
  │   └─────────────────────────────────────────────────────┘
  │
  └─► [可选] AFTER_ALL() ───── 全部方法跑完后执行一次
═══════════════════════════════════════════════════════════
```

---

### 六、`TEST`（无 fixture 版）的展开对比

```
TEST(MinimalTest, "Game.MyGame") { ASSERT_THAT(IsTrue(true)); }
    │
    ├─► 等效于 TEST_CLASS + 单个匿名 TEST_METHOD
    │
    └─► struct MinimalTest : TTest<MinimalTest, FNoDiscardAsserter>
        {
            // body 直接作为唯一 TEST_METHOD
            void Run() { ASSERT_THAT(IsTrue(true)); }
            static inline FFunctionRegistrar _Reg{"Run", &MinimalTest::Run, __LINE__, ""};
        };
        // 同样创建一个 TTestRunner 静态单例
```

---

### 七、`ASSERT_THAT` 宏

```cpp
ASSERT_THAT(IsTrue(condition))
    │
    └─► Assert.IsTrue(condition)
        // Assert 是 TBaseTest 中持有的 AsserterType 成员
        // 默认 AsserterType = FNoDiscardAsserter
        // 断言失败时：记录错误 + 抛出 ECQTestAbortType 跳出当前 phase
```

---

### 八、宏与底层类的整体映射

```
用户代码层                 宏生成层               运行时层
──────────────────────────────────────────────────────────────────
TEST_CLASS(Foo, "A.B")  → struct Foo              注册到
BEFORE_EACH()           →   void Setup()          FAutomationTestFramework
AFTER_EACH()            →   void TearDown()
BEFORE_ALL()            →   static void BeforeAll
AFTER_ALL()             →   static void AfterAll
TEST_METHOD(Bar)        →   void Bar()          ─┐
                        →   FFunctionRegistrar   ─┤ Methods["Bar"] = &Foo::Bar
                            (static 自注册)      ─┘

TEST_CLASS(Foo, ...)    → TTestRunner<AsserterType>  ──► FAutomationTestBase
                          (静态单例，代表整个 class)       (UE 测试系统)

ASSERT_THAT(...)        → Assert.Check(...)
                          Assert 类型 = FNoDiscardAsserter (默认)
                                     或自定义 (TEST_CLASS_WITH_ASSERTS)
```

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/README.md#Examples](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Examples)

[2]. [Engine/Source/Developer/CQTest/Public/CQTest.h#TTest](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

[3]. [Engine/Source/Developer/CQTest/Public/CQTest.h/TTest#FFunctionRegistrar](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h/TTest#FFunctionRegistrar)

## 🙋 用户（2026/08/27 20:27:04）

帮我看看这些都有哪些的断言方式? 都是怎么进行断言的, 都有什么断言的宏可以使用, 帮我整理一个表格出来

## 🤖 AI 助手（2026/08/27 20:27:04）

并行检索断言相关源码。
现在再补充检索 `IsNear`、`IsNearlyEqual` 和 `ExpectError` 相关的断言方法，以及 `CQTestCondition.h` 的完整内容。
现在已经拿到了所有断言方法的完整信息，整理成表格。

---

## CQTest 断言体系详解

### 一、断言调用方式

所有断言都通过 `ASSERT_THAT(条件函数(...))` 这一统一宏完成。**`ASSERT_THAT` 本身不是断言函数，而是将条件函数的 `bool` 返回值传递给 `Assert` 对象进行校验**。[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.h/FNoDiscardAsserter#ExpectError)

```
ASSERT_THAT(条件函数(参数...))
    │
    ├─ 条件函数 ─────────────────────────────────────────
    │   定义在 CQTestCondition.h 中，返回 bool
    │   例：IsTrue(x) / AreEqual(a, b) / IsNull(p)
    │
    └─ Assert 对象（FNoDiscardAsserter）
        ├─ 接收 bool 返回值
        ├─ 如果 false → 调用 TestRunner->AddError()
        └─ 如果 false → 抛出 ECQTestAbortType 终止当前 phase
```

---

### 二、断言条件函数完整表格

**布尔断言**

| 断言写法 | 通过条件 | 说明 |
|---|---|---|
| `ASSERT_THAT(IsTrue(expr))` | `expr == true` | 基础真值断言 |
| `ASSERT_THAT(IsTrue(expr, "msg"))` | `expr == true` | 失败时附带自定义错误消息 |
| `ASSERT_THAT(IsFalse(expr))` | `expr == false` | 基础假值断言 |
| `ASSERT_THAT(IsFalse(expr, "msg"))` | `expr == false` | 失败时附带自定义错误消息 |

**相等断言（支持 int/float/FString/FText/自定义类型）**

| 断言写法 | 通过条件 | 说明 |
|---|---|---|
| `ASSERT_THAT(AreEqual(a, b))` | `a == b` | 精确相等，支持任意可比较类型 |
| `ASSERT_THAT(AreEqual(a, b, "msg"))` | `a == b` | 失败时附带自定义消息 |
| `ASSERT_THAT(AreNotEqual(a, b))` | `a != b` | 精确不等 |
| `ASSERT_THAT(AreNotEqual(a, b, "msg"))` | `a != b` | 失败时附带自定义消息 |

**字符串大小写不敏感断言（支持 FString / FText / TCHAR\*）**

| 断言写法 | 通过条件 | 说明 |
|---|---|---|
| `ASSERT_THAT(AreEqualIgnoreCase(a, b))` | 忽略大小写后 `a == b` | FString / TCHAR* 混用均可 |
| `ASSERT_THAT(AreNotEqualIgnoreCase(a, b))` | 忽略大小写后 `a != b` | FString / TCHAR* 混用均可 |

**浮点数近似比较（支持 float/double）**

| 断言写法 | 通过条件 | 说明 |
|---|---|---|
| `ASSERT_THAT(IsNear(a, b, tol))` | `|a - b| <= tol` | 通用数值近似相等 |
| `ASSERT_THAT(IsNearlyEqual(a, b))` | `FMath::IsNearlyEqual` | 默认 `UE_KINDA_SMALL_NUMBER` 容差 |
| `ASSERT_THAT(IsNearlyEqual(a, b, tol))` | 自定义容差 | `double` 精度，委托 `FMath` |
| `ASSERT_THAT(IsNotNearlyEqual(a, b))` | `!IsNearlyEqual` | 近似不等 |
| `ASSERT_THAT(IsNotNearlyEqual(a, b, tol))` | 自定义容差 | 近似不等 |

**UE 数学类型近似比较（含容差，默认 `UE_KINDA_SMALL_NUMBER`）**

| 断言写法 | 通过条件 | 适用类型 |
|---|---|---|
| `ASSERT_THAT(IsNearlyEqual(va, vb))` | `va.Equals(vb, tol)` | `FVector` |
| `ASSERT_THAT(IsNearlyEqual(ra, rb))` | `ra.Equals(rb, tol)` | `FRotator` |
| `ASSERT_THAT(IsNearlyEqual(ta, tb))` | `ta.Equals(tb, tol)` | `FTransform` |
| `ASSERT_THAT(IsNotNearlyEqual(va, vb))` | `!va.Equals(vb, tol)` | `FVector` |
| `ASSERT_THAT(IsNotNearlyEqual(ra, rb))` | `!ra.Equals(rb, tol)` | `FRotator` |
| `ASSERT_THAT(IsNotNearlyEqual(ta, tb))` | `!ta.Equals(tb, tol)` | `FTransform` |

**指针/智能指针断言（支持原始指针、`TSharedPtr`、`TUniquePtr`）**

| 断言写法 | 通过条件 | 说明 |
|---|---|---|
| `ASSERT_THAT(IsNull(ptr))` | `ptr == nullptr` | 支持 raw ptr / TSharedPtr / TUniquePtr |
| `ASSERT_THAT(IsNull(ptr, "msg"))` | `ptr == nullptr` | 失败附带消息 |
| `ASSERT_THAT(IsNotNull(ptr))` | `ptr != nullptr` | 支持 raw ptr / TSharedPtr / TUniquePtr |
| `ASSERT_THAT(IsNotNull(ptr, "msg"))` | `ptr != nullptr` | 失败附带消息 |

---

### 三、`Assert.ExpectError`：反向断言（测试失败路径）

这是 CQTest 独有的"负向测试"机制，用于**验证某个断言确实会失败**。[[2]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.h/FNoDiscardAsserter#ExpectError)

```cpp
// 用法：先声明期待错误，再调用会失败的断言
Assert.ExpectError("Expected 42 to equal 0");     // 声明预期错误
ASSERT_THAT(AreEqual(42, 0));                      // 断言会失败，但被 ExpectError 拦截 → 测试通过

// 也可以期待任意错误
Assert.ExpectError(AnyError);    // AnyError = 匹配任意错误字符串
ASSERT_THAT(IsTrue(false));      // 产生任意错误 → 被拦截 → 测试通过

// Count 参数：期待错误发生 N 次
Assert.ExpectError("some error", 3);  // 期待同一错误发生 3 次
```

```
Assert.ExpectError("msg")
    │
    └─► FNoDiscardAsserter 内部维护一个 ExpectedErrors 队列
          当后续断言失败时：
          ├─ 匹配成功 → 消费该期望，测试继续（不记录为失败）
          └─ 未匹配 → 记录为真正失败
```

---

### 四、自定义断言器

继承 `FNoDiscardAsserter` 可以扩展新的断言方法，然后配合 `TEST_CLASS_WITH_ASSERTS` 宏使用：[[3]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/ExtensionTests.cpp#FCustomAsserter)

```cpp
struct FCustomAsserter : public FNoDiscardAsserter {
    FCustomAsserter(FAutomationTestBase& testRunner)
        : FNoDiscardAsserter(testRunner) {}

    bool Custom(bool In) { return In; }  // 自定义断言函数
};

TEST_CLASS_WITH_ASSERTS(MyTest, "Game.MyTests", FCustomAsserter)
{
    TEST_METHOD(TestSomething)
    {
        ASSERT_THAT(Custom(true));   // 使用自定义断言
        ASSERT_THAT(IsTrue(true));   // 仍可使用基类断言
    }
};
```

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.h/FNoDiscardAsserter#FNoDiscardAsserter](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.h/FNoDiscardAsserter#FNoDiscardAsserter)

[2]. [Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.h/FNoDiscardAsserter#ExpectError](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.h/FNoDiscardAsserter#ExpectError)

[3]. [Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/ExtensionTests.cpp#FCustomAsserter](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/ExtensionTests.cpp#FCustomAsserter)

[4]. [Engine/Source/Developer/CQTest/Public/Assert/CQTestCondition.h#IsNearlyEqual](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Assert/CQTestCondition.h/CQTestCondition#IsNearlyEqual)

## 🙋 用户（2026/08/27 20:38:47）

所有断言都帮我梳理成一个ascii 的那种简单 list 出来, 放到 代码块中共?

## 🤖 AI 助手（2026/08/27 20:38:47）

```
CQTest 断言速查表 (ASSERT_THAT + 条件函数)
===========================================

[布尔]
  ASSERT_THAT(IsTrue(expr))                   -- expr 为 true
  ASSERT_THAT(IsTrue(expr, "msg"))             -- expr 为 true，失败附带消息
  ASSERT_THAT(IsFalse(expr))                  -- expr 为 false
  ASSERT_THAT(IsFalse(expr, "msg"))            -- expr 为 false，失败附带消息

[相等 / 不等]
  ASSERT_THAT(AreEqual(a, b))                 -- a == b（任意可比较类型）
  ASSERT_THAT(AreEqual(a, b, "msg"))          -- a == b，失败附带消息
  ASSERT_THAT(AreNotEqual(a, b))              -- a != b
  ASSERT_THAT(AreNotEqual(a, b, "msg"))       -- a != b，失败附带消息

[字符串大小写不敏感]
  ASSERT_THAT(AreEqualIgnoreCase(a, b))       -- 忽略大小写 a == b（FString/TCHAR*）
  ASSERT_THAT(AreNotEqualIgnoreCase(a, b))    -- 忽略大小写 a != b

[浮点数近似比较]
  ASSERT_THAT(IsNear(a, b, tol))              -- |a - b| <= tol
  ASSERT_THAT(IsNearlyEqual(a, b))            -- FMath::IsNearlyEqual，默认容差
  ASSERT_THAT(IsNearlyEqual(a, b, tol))       -- 自定义容差
  ASSERT_THAT(IsNotNearlyEqual(a, b))         -- !IsNearlyEqual，默认容差
  ASSERT_THAT(IsNotNearlyEqual(a, b, tol))    -- !IsNearlyEqual，自定义容差

[UE 数学类型近似比较（FVector / FRotator / FTransform）]
  ASSERT_THAT(IsNearlyEqual(va, vb))          -- va.Equals(vb)，默认容差
  ASSERT_THAT(IsNearlyEqual(va, vb, tol))     -- va.Equals(vb, tol)
  ASSERT_THAT(IsNotNearlyEqual(va, vb))       -- !va.Equals(vb)
  ASSERT_THAT(IsNotNearlyEqual(va, vb, tol))  -- !va.Equals(vb, tol)

[指针 / 智能指针（raw ptr / TSharedPtr / TUniquePtr）]
  ASSERT_THAT(IsNull(ptr))                    -- ptr == nullptr
  ASSERT_THAT(IsNull(ptr, "msg"))             -- ptr == nullptr，失败附带消息
  ASSERT_THAT(IsNotNull(ptr))                 -- ptr != nullptr
  ASSERT_THAT(IsNotNull(ptr, "msg"))          -- ptr != nullptr，失败附带消息

[反向断言（期待某断言必须失败）]
  Assert.ExpectError(AnyError)                -- 期待下一个断言产生任意错误
  Assert.ExpectError("specific msg")          -- 期待产生指定错误字符串
  Assert.ExpectError("msg", N)               -- 期待同一错误发生 N 次
```

## 🙋 用户（2026/08/27 20:39:26）

现在帮我梳理下cqtest 的整体是怎么样的, 比如整体要解决什么问题, 要怎么应用, 底层设计哲学是什么?

## 🤖 AI 助手（2026/08/27 20:39:26）

基于前几轮对话积累的 CQTest 知识，加上补充检索，给你做一个完整的整体梳理。
信息已经很充足，现在给你一个全面、有深度的整体梳理。

---

## **CQTest 整体梳理**

### 一、要解决什么问题

UE 原有两种测试方式都有明显痛点：[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Why%20CQTest?)

**`IMPLEMENT_SIMPLE_AUTOMATION_TEST`（简单宏）**：极简，但整个测试类只有一个 `RunTest` 入口，没有 before/after 钩子，多个测试场景只能堆到一起，状态污染风险高。

**Spec Test（BDD 风格）**：支持 `Describe` / `It` 嵌套，受 BDD 启发，但 lambda 捕获 + `Describe` 内部变量的作用域问题极易踩坑（变量出作用域后成垃圾值），且不会自动重置状态。

**CQTest 的核心动机**：在以上框架基础上增加每个 test case 独立的 before/after 生命周期，同时**每次执行 test method 时重新构造测试对象**，从而自动归零所有成员变量，彻底消除测试间状态污染。设计原则只有一句话：**make easy things easy**。

---

### 二、底层设计哲学

```
┌──────────────────────────────────────────────────────────────┐
│                  CQTest 三大核心哲学                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. 原子性（Atomicity）                                       │
│     每个 TEST_METHOD 执行时 new 一次测试对象               │
│     → 成员变量自动归零，测试之间完全隔离                    │
│                                                              │
│  2. 组合优于继承（Composition over Inheritance）             │
│     扩展能力通过 Test Components（组件）来添加              │
│     而不是强迫用户继承层层嵌套的基类                        │
│                                                              │
│  3. 让简单的事情简单（Make easy things easy）                │
│     最小测试只需一行宏 + 一个断言                          │
│     复杂场景通过 TEST_CLASS_WITH_BASE 等组合宏渐进扩展      │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

关于异常处理哲学：不同平台对 C++ 异常的支持程度不同，CQTest 选择了 `[[nodiscard]] bool` 方案（而非直接 throw），再配合 `ASSERT_THAT` 宏做早期 return，兼顾了跨平台兼容性和开发体验。[[2]](https://git.woa.com/tencent-git/docs/UE5/blob/master/测试并优化你的内容/自动化系统概述/CQTest.md)

---

### 三、在 UE 测试体系中的位置

```
UE 测试体系全景
══════════════════════════════════════════════════════
 低层 ◄─────────────────────────────────────► 高层
══════════════════════════════════════════════════════

  LowLevel Tests        CQTest               Gauntlet
  (Catch2)         (FAutomationTestBase     (跨机器/平台
  纯 C++单元测试    扩展，编辑器内运行)      端到端测试)
       │                  │                     │
  不依赖引擎         依赖引擎模块            依赖完整构建
  最快              中速，支持延迟           最慢，最真实
  最轻量            支持 PIE/网络            CI 集成

  CQTest 定位：引擎 C++ 的功能性/集成性测试
  典型场景：单元逻辑 + Actor生命周期 + 网络复制 + 动画
```

[[3]](https://git.woa.com/tencent-git/docs/UE5/blob/master/测试并优化你的内容/自动化系统概述/CQTest.md)

---

### 四、如何应用（从简单到复杂）

**Step 1：在 Build.cs 中添加依赖**
```cs
PrivateDependencyModuleNames.AddRange(new string[] { "CQTest" });
```

**Step 2：选择合适的测试入口宏**

```
用户需求                          对应宏
──────────────────────────────────────────────────────
单个场景，无状态                 TEST
多个场景，共享状态/setup         TEST_CLASS
继承自定义基类复用逻辑           TEST_CLASS_WITH_BASE
指定特定平台/上下文 flags        TEST_CLASS_WITH_FLAGS
同时继承 + 自定义 flags          TEST_CLASS_WITH_BASE_AND_FLAGS
自定义断言器                     TEST_CLASS_WITH_ASSERTS
```

**Step 3：按需挂载 Test Components（组合扩展）**

```
TEST_CLASS 中 new 一个 Component，生命周期由框架管理
──────────────────────────────────────────────────────
ActorTestSpawner    → 创建最小 UWorld，生成 Actor
MapTestSpawner      → 打开指定关卡，在真实关卡内测试
PIENetworkComponent → 模拟 Server + Client PIE，测网络同步
InputTestActions    → 向 Pawn 注入 InputAction
CQTestSlateComponent→ 监听 UI 刷新事件
```

[[4]](https://git.woa.com/tencent-git/docs/UE5/blob/master/测试并优化你的内容/自动化系统概述/CQTest.md)

**Step 4：用 TestCommandBuilder 处理异步逻辑**

引擎里很多操作是帧间异步的（加载关卡、等待动画完成等），不能直接同步断言，这时用流式命令链：
```cpp
TestCommandBuilder
    .Do([&]() { StartSomeOperation(); })
    .Until([&]() { return OperationIsDone(); })   // 轮询等待，不 hardcode 时间
    .Then([&]() { ASSERT_THAT(IsTrue(Result)); });
```

---

### 五、整体架构总览

```
╔═══════════════════════════════════════════════════════════════╗
║                     用户代码层                                ║
║  TEST / TEST_CLASS / TEST_CLASS_WITH_BASE / ...               ║
║  宏展开 → struct UserTest : TTest<UserTest, AsserterType>     ║
╠═══════════════════════════════════════════════════════════════╣
║                     框架核心层                                ║
║  TTest<Derived, Asserter>   ← CRTP                           ║
║    ├─ FFunctionRegistrar    ← 静态自注册 TEST_METHOD          ║
║    ├─ TBaseTest             ← Assert 成员 + AddCommand        ║
║    └─ TTestRunner           ← 注册到 FAutomationTestFramework ║
╠═══════════════════════════════════════════════════════════════╣
║                     扩展组件层                                ║
║  ActorTestSpawner / MapTestSpawner / PIENetworkComponent /   ║
║  InputTestActions / CQTestSlateComponent                     ║
╠═══════════════════════════════════════════════════════════════╣
║                     UE 原生测试层                             ║
║  FAutomationTestBase  ←  所有 UE 测试的最终基类               ║
╚═══════════════════════════════════════════════════════════════╝

测试执行时序：
  [程序启动] 静态初始化 → FFunctionRegistrar 注册所有 TEST_METHOD
  [运行测试] TTestRunner::RunTest
               ├─ BEFORE_ALL (一次)
               ├─ for each method:
               │    new UserTestObj → BEFORE_EACH → method → AFTER_EACH → delete
               └─ AFTER_ALL (一次)
```

---

### 六、一句话总结设计哲学

> CQTest 的本质是：**用 CRTP + 静态自注册解决测试发现问题，用「每次重新构造对象」解决状态隔离问题，用「组件组合」解决扩展问题，用 `[[nodiscard]] bool + ASSERT_THAT`解决跨平台断言问题**，让 UE C++ 测试的书写体验对齐现代测试框架（类似 Google Test 的 Fixture 风格）。

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/README.md#Why CQTest?](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/README.md#Why%20CQTest?)

[2]. [测试并优化你的内容/自动化系统概述/CQTest.md#Handling Exceptions](https://git.woa.com/tencent-git/docs/UE5/blob/master/测试并优化你的内容/自动化系统概述/CQTest.md)

[3]. [测试并优化你的内容/自动化系统概述/CQTest.md](https://git.woa.com/tencent-git/docs/UE5/blob/master/测试并优化你的内容/自动化系统概述/CQTest.md)

[4]. [测试并优化你的内容/自动化系统概述/CQTest.md#Test Components](https://git.woa.com/tencent-git/docs/UE5/blob/master/测试并优化你的内容/自动化系统概述/CQTest.md)

## 🙋 用户（2026/08/27 20:44:38）

反向断言（期待某断言必须失败）, 这个是什么, 为什么会有这个玩意?

## 🤖 AI 助手（2026/08/27 20:44:38）

先检索一下 `ExpectError` 的具体实现和文档说明。
已有足够的代码证据，直接给你解释清楚。

---

## `Assert.ExpectError` 是什么？

一句话理解：**它是"测试断言器本身"的测试工具，用来验证"某段代码应该触发断言失败"**。

---

### 为什么会有这个玩意？

CQTest 框架有一个很特殊的问题：**它需要测试自己**。

当框架作者要验证 `ASSERT_THAT(IsTrue(false))` 确实会报错、`ASSERT_THAT(AreEqual(42, 0))` 确实会产生错误信息时，面临一个悖论：

```
我想测试"断言失败"这件事
但断言失败会让测试本身失败
那测试就永远是红的 ——> 根本没法验证"应当失败"的行为
```

`Assert.ExpectError` 就是为了打破这个悖论而存在的，它的语义是：

> **"我预先声明：接下来这个断言应该失败，如果它真的失败了，不算测试失败，反而算测试通过。"**

---

### 工作机制

```
正常断言流程：
  ASSERT_THAT(IsTrue(false))
       │
       └──> 断言器记录错误 ──> 测试标记为 FAIL  ← 红叉

ExpectError 流程：
  Assert.ExpectError(AnyError)        ← 第一步：告知断言器"我期待一个错误"
  ASSERT_THAT(IsTrue(false))
       │
       └──> 断言器记录错误
              │
              └──> 发现有未消费的 ExpectError ──> 匹配 ──> 错误被"吃掉"
                                                           测试标记为 PASS ← 绿勾
```

[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Assert/AssertionTests.cpp)

---

### 实际代码示例

```cpp
// 验证 "IsTrue(false) 会产生任意错误"
TEST_METHOD(AssertTrue_WithFalse_AddsError)
{
    Assert.ExpectError(AnyError);          // 预期：接下来会有一个错误（任意内容）
    ASSERT_THAT(IsTrue(false));            // 故意失败 → 因为被 ExpectError 接住，测试通过
}

// 验证 "AreEqual(42, 0) 会产生指定的错误消息"
TEST_METHOD(AssertEqual_WithDifferentIntsAndErrorMessage_AddsSpecificError)
{
    Assert.ExpectError(ExpectedError);                    // 预期：产生特定的错误字符串
    ASSERT_THAT(AreEqual(42, 0, ExpectedError));          // 故意失败 + 带特定消息 → 匹配 → 通过
}

// 验证 "ASSERT_FAIL 只产生第一条错误，后续代码不会执行"
TEST_METHOD(AssertFail_Macro_AddsErrorAndExits)
{
    Assert.ExpectError(ExpectedError);
    ASSERT_FAIL(ExpectedError);                           // 触发错误 + 早期 return
    ASSERT_FAIL(TEXT("这行永远不会执行"));                 // 死代码，验证上面确实 exit 了
}
```

[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Assert/AssertionTests.cpp)

---

### 两种匹配模式

```
Assert.ExpectError(AnyError)         → 接受任意错误内容，只要有错误产生即可
Assert.ExpectError("specific msg")  → 要求错误消息与指定字符串精确匹配
Assert.ExpectError("msg", N)        → 要求同一错误精确出现 N 次
```

---

### 实际业务场景中用得到吗？

平时写游戏逻辑测试基本**用不到**，它主要服务于以下两种场景：

1. **测试框架自身**：CQTest 框架用它来验证断言器的行为符合预期（即 `CQTestTests` 里的测试）。
2. **测试防御性代码**：当你的 API 有参数校验逻辑，期望输入非法参数时"必须触发断言报错"，可以用它来确保这个安全保护没有被意外移除。

---

**参考来源**

[1]. [Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Assert/AssertionTests.cpp#TEST_METHOD](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Assert/AssertionTests.cpp)

## 🙋 用户（2026/08/27 20:46:46）

帮我梳理下cqtest 的宏实现层, 是怎么做到他的设计目标的

## 🤖 AI 助手（2026/08/27 20:46:46）

并行检索宏实现的核心源码。
已拿到核心源码，现在再补充检索 `TTestRunner::RunTest` 实现细节和 `BEFORE_ALL`/`AFTER_ALL` 的 concept 检测机制。
现在已拿到所有关键源码，可以做完整的分析了。

---

## CQTest 宏实现层：如何达成设计目标

CQTest 有三大核心设计目标：**测试自动发现**、**测试间状态隔离**、**可选的 Before/After All 生命周期**。宏实现层通过三套相互配合的 C++ 技术来实现这三点。[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

---

### 目标一：测试自动发现（`TEST_CLASS` + `TEST_METHOD` 如何注册）

**技术：CRTP + 静态自注册（Static Self-Registration）**

`TEST_CLASS(MyTest, "Game.Dir")` 展开后会生成两样东西：

```
[程序启动时静态初始化阶段]

  ① TTestRunner<FNoDiscardAsserter> MyTest_Runner(
         "MyTest", __LINE__, __FILE__, TestDir,
         DefaultFlags,
         &TTest<MyTest, ...>::CreateTestClass,  ← 工厂函数
         ""
     );
     构造函数内调用 FAutomationTestFramework::Get().RegisterAutomationTest(...)
     ↓
     MyTest 名字注册进 UE 自动化测试框架

  ② struct MyTest : TTest<MyTest, FNoDiscardAsserter>
     {
         // 用户写的成员变量、BEFORE_EACH、AFTER_EACH、TEST_METHOD 都在这里
     };
```

`TEST_METHOD(DoSomething)` 展开后在 struct 内生成：

```cpp
// 1. 函数体本身
void DoSomething();

// 2. 静态 FFunctionRegistrar，构造时自动执行注册
inline static TTest<MyTest,...>::FFunctionRegistrar
    _Registrar_DoSomething{ "DoSomething", &MyTest::DoSomething, __LINE__, "" };
```

`FFunctionRegistrar` 的构造函数在程序启动时被调用，将函数指针写入 `TTest<MyTest>::Methods`（一个静态 `TMap<FString, TestMethod>`）。[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

```
整体静态初始化流程：
┌─────────────────────────────────────────────────────┐
│  程序启动                                            │
│                                                      │
│  ① MyTest_Runner 构造                               │
│     └─> FAutomationTestFramework::RegisterTest()    │
│         TestRunner.bInitializing = true             │
│                                                      │
│  ② TTest<MyTest>::Methods 静态初始化                │
│                                                      │
│  ③ FFunctionRegistrar("DoSomething", ...) 构造      │
│     └─> Methods["DoSomething"] = &MyTest::DoSomething│
│     └─> TestRunner.TestNames.Add("DoSomething")     │
│                                                      │
│  ④ bInitializing = false  (所有 method 注册完毕)    │
└─────────────────────────────────────────────────────┘
```

---

### 目标二：状态隔离（每次 `TEST_METHOD` 重新构造对象）

**技术：工厂函数 + `TUniquePtr` 每次 `MakeUnique<DerivedType>()`**

`TTestRunner` 内持有一个工厂函数指针 `TTestInstanceGenerator Factory`，它指向 `TTest<Derived>::CreateTestClass`：

```cpp
static TUniquePtr<TBaseTest<AsserterType>> CreateTestClass(TTestRunner<AsserterType>& Runner)
{
    DerivedType::TestRunner = &Runner;
    return MakeUnique<DerivedType>();   // ← 每次都 new 一个全新实例
}
```

每次执行一个 `TEST_METHOD`，`TTestRunner::RunTest` 会调用工厂重新创建实例。[[2]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTestRunner)

```
TTestRunner::RunTest(RequestedTestName) 伪流程：

  for 每个 TEST_METHOD:
  ┌────────────────────────────────────────────────┐
  │  CurrentTestPtr = Factory(*this)               │← new DerivedType()
  │       所有成员变量重新初始化（默认值）           │← 状态隔离在这里实现
  │                                                │
  │  AddCommand(Setup)    ← BEFORE_EACH            │
  │  flush latent commands                         │
  │                                                │
  │  AddCommand(RunMethod)  ← TEST_METHOD body     │
  │  flush latent commands                         │
  │                                                │
  │  AddCommand(TearDown)  ← AFTER_EACH           │
  │  flush latent commands                         │
  │                                                │
  │  CurrentTestPtr.Reset()  ← 析构，触发清理      │
  └────────────────────────────────────────────────┘
```

`BEFORE_EACH()` 宏展开后就是 `virtual void Setup() override { ... }`，`AFTER_EACH()` 展开为 `virtual void TearDown() override { ... }`，两者均是虚函数，通过多态调用。[[3]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TBaseTest)

---

### 目标三：可选的 BEFORE_ALL / AFTER_ALL（零开销检测）

**技术：C++17 `if constexpr` + Concepts（编译期特性检测）**

用户如果写了 `BEFORE_ALL()` 宏，展开后生成：

```cpp
static void BeforeAll();  // 静态成员函数
```

`TTest` 的构造函数用 `if constexpr` 在**编译期**检测 `Derived` 是否存在该静态函数：

```cpp
TTest()
{
    if constexpr (HasBeforeAll<Derived>)   // ← 编译期，没有运行时开销
    {
        this->BeforeAllFunc = Derived::BeforeAll;  // 写入函数指针
    }
    if constexpr (HasAfterAll<Derived>)
    {
        this->AfterAllFunc = Derived::AfterAll;
    }
}
```

`HasBeforeAll<T>` 是一个 C++ Concept，大致为：

```cpp
template<typename T>
concept HasBeforeAll = requires { T::BeforeAll(); };
```

如果用户没写 `BEFORE_ALL()`，`BeforeAllFunc` 保持 `nullptr`，框架跳过该调用，**编译期消除，无运行时检查**。[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

---

### bInitializing 标志位的作用

`TTestRunner` 中有一个 `bool bInitializing{ true }` 标志，它在静态初始化期间为 `true`，所有方法注册完毕后变为 `false`。`FFunctionRegistrar` 的构造依赖这个标志来区分"注册阶段"和"运行阶段"，避免重复注册。[[2]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTestRunner)

---

### 整体宏层架构映射

```
用户写的代码                  宏展开后的 C++ 结构             运行时角色
─────────────────────────────────────────────────────────────────────────
TEST_CLASS(MyTest, "Dir")  → struct MyTest                  fixture 对象
                             : TTest<MyTest, Asserter>      (每次 new)
                           + TTestRunner<Asserter>          向 UE 注册测试
                             MyTest_Runner(...)             (静态单例)

BEFORE_EACH() { ... }      → virtual void Setup() override  每 method 前调用

AFTER_EACH()  { ... }      → virtual void TearDown() override 每 method 后调用

BEFORE_ALL()  { ... }      → static void BeforeAll()        通过 HasBeforeAll
                                                            concept 检测后挂载

TEST_METHOD(Foo)           → void Foo();                    函数体
                           + static FFunctionRegistrar      启动时自注册
                             _Reg_Foo{"Foo", &MyTest::Foo}  到 Methods 表
```

[[1]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest) [[2]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTestRunner) [[3]](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TBaseTest)

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/Public/CQTest.h#TTest](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTest)

[2]. [Engine/Source/Developer/CQTest/Public/CQTest.h#TTestRunner](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TTestRunner)

[3]. [Engine/Source/Developer/CQTest/Public/CQTest.h#TBaseTest](http://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h#TBaseTest)

## 🙋 用户（2026/08/27 20:50:55）

cq test 哪些宏声明的测试, 一般都是怎么被启动的? 

## 🤖 AI 助手（2026/08/27 20:50:55）

这个问题基于前面对话已有足够的上下文，结合之前检索到的 `TTestRunner`、`FAutomationTestFramework` 注册机制，可以直接完整回答。

---

## CQTest 测试的启动方式

CQTest 声明的测试本质上就是 **UE 原生自动化测试（Automation Test）**，因为宏最终将 `TTestRunner` 注册到了 `FAutomationTestFramework`，所以所有 UE 的标准启动方式都能用。

---

**启动入口全景**

```
CQTest 宏注册的测试
        │
        ▼
FAutomationTestFramework (全局单例)
        │
        ├─── 方式 1: 编辑器内 Session Frontend
        │           Window → Session Frontend → Automation
        │           勾选 → Start Tests
        │
        ├─── 方式 2: 命令行直接跑（无头模式，CI 常用）
        │           UnrealEditor-Cmd.exe  MyProject.uproject
        │               -ExecCmds="Automation RunTests Game.MyTests; Quit"
        │               -nullrhi -nosound -unattended
        │
        ├─── 方式 3: RunUAT / UAT 自动化脚本（CI/CD 集成）
        │           RunUAT.bat RunUnreal
        │               -project=MyProject.uproject
        │               -run=Automation
        │               -TestFilter="Game.MyTests"
        │
        └─── 方式 4: Python / 蓝图 (编辑器内脚本驱动)
                    import unreal
                    controller = unreal.AutomationLibrary
                    controller.run_editor_automation_test(...)
```

---

**方式 2 最常用的完整命令行示例**

```bash
# 跑所有 CQTest 注册的测试（路径前缀过滤）
Engine/Binaries/Win64/UnrealEditor-Cmd.exe \
    MyProject/MyProject.uproject \
    -ExecCmds="Automation RunTests MyGame.; Quit" \
    -nullrhi -nosound -unattended -log \
    -ReportOutputPath="TestResults/"

# 只跑单个测试
-ExecCmds="Automation RunTest MyGame.Combat.DamageTest; Quit"
```

`MyGame.` 就是 `TEST_CLASS(MyTest, "MyGame")` 中第二个参数对应的 **路径前缀**，框架通过这个前缀过滤要运行哪些测试。

---

**链路完整流程**

```
程序启动
  │
  ├─ 静态初始化：TTestRunner 构造
  │     └─> FAutomationTestFramework::Get().RegisterAutomationTest(Name, Runner)
  │         Name = "MyGame.Combat.DamageTest"（路径 + 类名拼接）
  │
  ├─ 引擎主循环就绪
  │
  ├─ 收到启动信号（编辑器点击 / 命令行 ExecCmd）
  │     └─> FAutomationTestFramework::RunTests(Filter)
  │           按 Filter 前缀匹配已注册的 Name
  │
  └─> 匹配到 → TTestRunner::RunTest(TestName) 被调用
            │
            ├─ BEFORE_ALL
            ├─ for each method:
            │    new DerivedClass()
            │    BEFORE_EACH → TEST_METHOD → AFTER_EACH
            │    delete
            └─ AFTER_ALL
```

---

**测试 Flags 决定在哪些上下文能跑**

`TEST_CLASS_WITH_FLAGS` 的第三个参数控制测试能在哪里被启动：

```
EAutomationTestFlags::EditorContext    → 只在编辑器内跑
EAutomationTestFlags::ClientContext    → 游戏客户端内跑
EAutomationTestFlags::CommandletContext→ 命令行 Cmd 跑（CI 最常用）
EAutomationTestFlags::ProductFilter    → 出现在 Product 过滤分组
EAutomationTestFlags::SmokeFilter     → 快速冒烟测试分组
```

默认的 `TEST_CLASS` 使用 `ApplicationContextMask | ProductFilter`，覆盖编辑器 + 命令行两个上下文，是最通用的配置。

## 🙋 用户（2026/08/27 20:54:29）

帮我整体性的梳理下整个的架构

## 🤖 AI 助手（2026/08/27 20:54:29）

基于本次对话中已经深度分析过的所有内容，直接给你一个完整的整体架构梳理。

---

## CQTest 整体架构

### 一、纵向分层视图

```
╔══════════════════════════════════════════════════════════════════╗
║                         用户代码层                                ║
║                                                                  ║
║  TEST(...)          TEST_CLASS(...)      TEST_CLASS_WITH_BASE    ║
║  TEST_METHOD(...)   BEFORE_EACH/AFTER_EACH   BEFORE_ALL/AFTER_ALL║
║  ASSERT_THAT(IsTrue/AreEqual/IsNull/...)                         ║
╚══════════════════════╤═══════════════════════════════════════════╝
                       │ 宏展开
╔══════════════════════▼═══════════════════════════════════════════╗
║                      宏生成层（编译期）                            ║
║                                                                  ║
║  struct UserTest : TTest<UserTest, FNoDiscardAsserter>           ║
║  {                                                               ║
║    // TEST_METHOD → 成员函数 + FFunctionRegistrar 静态自注册      ║
║    // BEFORE_EACH → virtual Setup() override                     ║
║    // AFTER_EACH  → virtual TearDown() override                  ║
║    // BEFORE_ALL  → static BeforeAll() (if constexpr 检测)       ║
║    // AFTER_ALL   → static AfterAll()  (if constexpr 检测)       ║
║  };                                                              ║
║  static TTestRunner<UserTest> GTestRunner_UserTest(...);         ║
╚══════════════════════╤═══════════════════════════════════════════╝
                       │ 继承 / 模板实例化
╔══════════════════════▼═══════════════════════════════════════════╗
║                     框架核心层（CQTest Engine Module）             ║
║                                                                  ║
║  ┌──────────────────────────────────────────────────────────┐   ║
║  │  TTestRunner<Derived>     （调度器）                       │   ║
║  │    - 构造时注册到 FAutomationTestFramework                 │   ║
║  │    - 持有 Factory = &TTest<Derived>::CreateTestClass      │   ║
║  │    - RunTest() → 按序执行所有 TEST_METHOD                  │   ║
║  └──────────────────┬───────────────────────────────────────┘   ║
║                     │ 继承                                       ║
║  ┌──────────────────▼───────────────────────────────────────┐   ║
║  │  TBaseTest<AsserterType>  （能力基类）                     │   ║
║  │    - Assert 成员（FNoDiscardAsserter）                     │   ║
║  │    - AddCommand / TestCommandBuilder（延迟命令队列）        │   ║
║  │    - virtual Setup() / TearDown()                         │   ║
║  └──────────────────┬───────────────────────────────────────┘   ║
║                     │ 继承（CRTP）                               ║
║  ┌──────────────────▼───────────────────────────────────────┐   ║
║  │  TTest<Derived, AsserterType>  （CRTP 模板基类）           │   ║
║  │    - static TMap<FName, TestFunc> Methods  ← 方法注册表   │   ║
║  │    - static CreateTestClass()  ← 工厂函数                 │   ║
║  │    - FFunctionRegistrar        ← 自注册工具类             │   ║
║  └──────────────────────────────────────────────────────────┘   ║
║                                                                  ║
║  ┌──────────────────────────────────────────────────────────┐   ║
║  │  断言层 FNoDiscardAsserter / CQTestAssert.h               │   ║
║  │    IsTrue / IsFalse / AreEqual / AreNotEqual              │   ║
║  │    IsNearlyEqual / IsNull / IsNotNull / ...               │   ║
║  │    [[nodiscard]] bool → ASSERT_THAT 宏消费                 │   ║
║  └──────────────────────────────────────────────────────────┘   ║
║                                                                  ║
║  ┌──────────────────────────────────────────────────────────┐   ║
║  │  延迟命令层 TestCommandBuilder / IAutomationLatentCommand  │   ║
║  │    .Do() → FExecute                                       │   ║
║  │    .Until() → FWaitUntil （轮询，推荐）                    │   ║
║  │    .WaitDelay() → FWaitDelay （时间等待）                  │   ║
║  │    .DoAsync() → TAsyncExecute （不阻塞 GameThread）        │   ║
║  │    .OnTearDown() → 逆序清理回调                            │   ║
║  └──────────────────────────────────────────────────────────┘   ║
╚══════════════════════╤═══════════════════════════════════════════╝
                       │ 注册 / 调用
╔══════════════════════▼═══════════════════════════════════════════╗
║               扩展组件层（Test Components，组合扩展）              ║
║                                                                  ║
║   ActorTestSpawner     → 创建最小 UWorld，生成 Actor             ║
║   MapTestSpawner       → 打开真实关卡内测试                       ║
║   PIENetworkComponent  → 模拟 Server+Client PIE，测网络          ║
║   InputTestActions     → 向 Pawn 注入 InputAction               ║
║   CQTestSlateComponent → 监听 UI 刷新事件                        ║
║                                                                  ║
║   使用方式：TEST_CLASS_WITH_BASE + 自定义基类中组合使用            ║
╚══════════════════════╤═══════════════════════════════════════════╝
                       │ 继承自 / 注册到
╔══════════════════════▼═══════════════════════════════════════════╗
║                    UE 原生自动化测试层                             ║
║                                                                  ║
║   FAutomationTestBase        ← 所有 UE 测试的最终基类             ║
║   FAutomationTestFramework   ← 全局注册表 + 调度中心              ║
║                                                                  ║
║   启动入口：                                                      ║
║     编辑器 Session Frontend  →  UI 点击 Start Tests              ║
║     命令行 -ExecCmds          →  CI/CD 无头跑                    ║
║     RunUAT / Gauntlet         →  跨平台端到端测试                 ║
╚══════════════════════════════════════════════════════════════════╝
```

---

### 二、横向关注点视图

```
┌────────────────────┬──────────────────────────────────────────────┐
│    关注点          │    CQTest 如何解决                            │
├────────────────────┼──────────────────────────────────────────────┤
│ 测试自动发现       │ FFunctionRegistrar 静态自注册                  │
│                    │ 程序启动时写入 TTest::Methods 表              │
│                    │ TTestRunner 构造时注册到 FAutomation框架       │
├────────────────────┼──────────────────────────────────────────────┤
│ 测试间状态隔离     │ 每个 TEST_METHOD 执行前 MakeUnique<Derived>   │
│                    │ 重新构造对象 → 成员变量自动归零               │
├────────────────────┼──────────────────────────────────────────────┤
│ Before/After 钩子  │ BEFORE_EACH → virtual Setup()                │
│                    │ AFTER_EACH  → virtual TearDown()             │
│                    │ BEFORE_ALL/AFTER_ALL → if constexpr 编译期   │
│                    │ 检测静态函数是否存在，零开销                   │
├────────────────────┼──────────────────────────────────────────────┤
│ 断言              │ [[nodiscard]] bool 返回值方案                  │
│                    │ ASSERT_THAT 宏：失败时 return 跳出当前 phase  │
│                    │ 跨平台兼容（不依赖 C++ 异常）                  │
├────────────────────┼──────────────────────────────────────────────┤
│ 异步/延迟测试      │ TestCommandBuilder 链式 API                   │
│                    │ 每个 phase 完成后 flush 所有 pending 命令      │
├────────────────────┼──────────────────────────────────────────────┤
│ 能力扩展          │ 组合而非继承：Test Components                   │
│                    │ TEST_CLASS_WITH_BASE 自定义基类共享逻辑        │
├────────────────────┼──────────────────────────────────────────────┤
│ 框架自测          │ Assert.ExpectError 反向断言                    │
│                    │ 验证断言器本身的失败行为                       │
└────────────────────┴──────────────────────────────────────────────┘
```

---

### 三、单次测试完整生命周期

```
[程序启动] ──静态初始化──────────────────────────────────────────────
                │
                ├─ FFunctionRegistrar 构造  → Methods 表写入函数指针
                └─ TTestRunner 构造         → 注册到 FAutomationFramework

[触发测试] ──RunTest(Filter)────────────────────────────────────────
                │
                ├─ [1] BeforeAll()  （若存在，整个 class 仅一次）
                │
                │   ┌── 每个 TEST_METHOD 循环 ──────────────────────┐
                │   │                                               │
                │   ├─ [2] MakeUnique<DerivedClass>()               │
                │   │        所有成员变量重新初始化                   │
                │   │                                               │
                │   ├─ [3] Setup() / BEFORE_EACH                    │
                │   │        flush latent commands                  │
                │   │                                               │
                │   ├─ [4] TEST_METHOD 方法体                       │
                │   │        ASSERT_THAT 失败 → return 跳出         │
                │   │        flush latent commands                  │
                │   │                                               │
                │   ├─ [5] TearDown() / AFTER_EACH                  │
                │   │        即使 [4] 失败也执行                     │
                │   │        flush latent commands                  │
                │   │                                               │
                │   └─ [6] ~DerivedClass()  析构，OnTearDown 逆序   │
                │                                                   │
                └───────────────────────────────────────────────────┘
                │
                └─ [7] AfterAll()  （若存在，所有 method 完成后）

[结果汇报] ──报告到 FAutomationTestFramework → 编辑器 UI / 日志文件
```

---

### 四、与 UE 其他测试方案的定位对比

```
速度快 ◄────────────────────────────────────────► 真实度高

 LowLevel Tests        CQTest              Gauntlet
  (Catch2)          (CQTest宏)          (RunUAT/平台)
     │                  │                    │
  纯 C++            依赖引擎              完整构建
  不启动引擎        编辑器/命令行          跨机器/平台
  毫秒级            秒级                  分钟级
  单元测试          功能/集成测试          端到端测试
```

## 🙋 用户（2026/08/27 20:59:04）

你现在帮我整理一个skill 吧, 作为ue cqtest 的指南

## 🤖 AI 助手（2026/08/27 20:59:04）

基于我们整个对话积累的知识，下面是一份完整的 CQTest Skill 指南，可以直接作为 prompt skill 使用：

---

```markdown
# UE CQTest 指南 Skill

## 角色定位
你是 UE5 CQTest 自动化测试框架的专家助手。当用户询问 CQTest
相关问题时，基于以下知识库直接给出准确、具体的答案。

---

## 一、框架定位

CQTest（Code Quality Test）是 UE5 内置的 C++ 自动化测试框架，
位于 Engine/Source/Developer/CQTest（UE5.5 起升为 Engine Module）。

核心解决的问题：
- UE 原生 IMPLEMENT_SIMPLE_AUTOMATION_TEST 没有 before/after 钩子
- Spec Test 的 lambda 捕获作用域问题导致状态污染
- CQTest 通过「每次重新构造测试对象」自动隔离测试间状态

设计哲学：make easy things easy
- 原子性：每个 TEST_METHOD 独立构造对象，成员变量自动归零
- 组合优于继承：能力通过 Test Components 组合，不强迫层层继承
- 跨平台兼容：[[nodiscard]] bool 断言方案，不依赖 C++ 异常

---

## 二、接入方式

在 Build.cs 中添加：
  PrivateDependencyModuleNames.AddRange(new string[] { "CQTest" });

---

## 三、宏速查

### 测试声明宏

| 宏 | 用途 |
|---|---|
| TEST(Name, "Path") | 单体测试，无 fixture，最简写法 |
| TEST_CLASS(Name, "Path") | 带 fixture 的多方法测试类 |
| TEST_METHOD(Name) | 类内注册一个测试方法 |
| TEST_CLASS_WITH_BASE(Name, "Path", BaseClass) | 继承自定义基类 |
| TEST_CLASS_WITH_FLAGS(Name, "Path", Flags) | 指定 AutomationTestFlags |
| TEST_CLASS_WITH_ASSERTS(Name, "Path", Asserter) | 自定义断言器 |
| TEST_WITH_TAGS / TEST_CLASS_WITH_TAGS / TEST_METHOD_WITH_TAGS | 添加过滤标签 |

### 生命周期宏（TEST_CLASS 内部使用）

| 宏 | 展开为 | 调用时机 |
|---|---|---|
| BEFORE_EACH() | virtual Setup() | 每个 TEST_METHOD 执行前 |
| AFTER_EACH() | virtual TearDown() | 每个 TEST_METHOD 执行后（失败也执行）|
| BEFORE_ALL() | static BeforeAll() | 整个 class 所有 method 前，仅一次 |
| AFTER_ALL() | static AfterAll() | 整个 class 所有 method 后，仅一次 |

### 最小示例

```cpp
// 最简单：无状态单体测试
TEST(MySimpleTest, "Game.MyGame")
{
    ASSERT_THAT(IsTrue(1 + 1 == 2));
}

// 带 fixture：多方法共享状态
TEST_CLASS(MyFixtureTest, "Game.MyGame")
{
    int32 Counter = 0;

    BEFORE_EACH() { Counter = 10; }
    AFTER_EACH()  { Counter = 0; }

    TEST_METHOD(IncrementWorks)
    {
        Counter++;
        ASSERT_THAT(AreEqual(11, Counter));
    }

    TEST_METHOD(DecrementWorks)
    {
        Counter--;
        ASSERT_THAT(AreEqual(9, Counter));
    }
};
```

---

## 四、断言速查

所有断言通过 ASSERT_THAT(条件函数(...)) 使用。
失败时不抛异常，返回 [[nodiscard]] bool，ASSERT_THAT 宏负责 return。

```
// ── 布尔 ────────────────────────────────────────
ASSERT_THAT(IsTrue(expr))
ASSERT_THAT(IsFalse(expr))
ASSERT_THAT(IsTrue(expr, "失败时的消息"))

// ── 相等 / 不等（任意可比较类型）────────────────
ASSERT_THAT(AreEqual(expected, actual))
ASSERT_THAT(AreNotEqual(a, b))
ASSERT_THAT(AreEqual(a, b, "消息"))

// ── 字符串大小写不敏感（FString / TCHAR*）────────
ASSERT_THAT(AreEqualIgnoreCase(a, b))
ASSERT_THAT(AreNotEqualIgnoreCase(a, b))

// ── 浮点近似（float / double）───────────────────
ASSERT_THAT(IsNear(a, b, tolerance))
ASSERT_THAT(IsNearlyEqual(a, b))           // 默认 UE_KINDA_SMALL_NUMBER
ASSERT_THAT(IsNearlyEqual(a, b, tol))
ASSERT_THAT(IsNotNearlyEqual(a, b))

// ── UE 数学类型（FVector / FRotator / FTransform）
ASSERT_THAT(IsNearlyEqual(va, vb))         // 内部调用 .Equals()
ASSERT_THAT(IsNearlyEqual(va, vb, tol))
ASSERT_THAT(IsNotNearlyEqual(va, vb))

// ── 指针 / 智能指针（raw / TSharedPtr / TUniquePtr）
ASSERT_THAT(IsNull(ptr))
ASSERT_THAT(IsNotNull(ptr))
ASSERT_THAT(IsNotNull(ptr, "消息"))

// ── 反向断言（测试框架自身 / 防御性代码）────────
Assert.ExpectError(AnyError);              // 期待下一个断言必须失败
Assert.ExpectError("specific error msg");  // 期待特定错误消息
Assert.ExpectError("msg", 2);             // 期待失败 N 次
ASSERT_THAT(IsFalse(true));               // 这次失败被"吃掉"，测试仍 PASS
```

---

## 五、延迟命令 / 异步测试

使用 TestCommandBuilder 处理需要等待的异步操作：

```cpp
TEST_METHOD(AsyncOperationTest)
{
    TestCommandBuilder
        .Do([&]() {
            StartAsyncOperation();
        })
        .Until([&]() {
            return AsyncOperation.IsDone();   // 轮询，不 hardcode 时间
        })
        .Then([&]() {
            ASSERT_THAT(IsTrue(AsyncOperation.Succeeded()));
        })
        .OnTearDown([&]() {
            CleanupOperation();               // 逆序执行清理
        });
}
```

链式 API：
- .Do(lambda)        → 一次性执行
- .Until(pred)       → 轮询等待，推荐替代 WaitDelay
- .WaitDelay(sec)    → 时间等待（有 flakiness 风险，谨慎使用）
- .DoAsync(lambda)   → 在工作线程执行，不阻塞 GameThread
- .OnTearDown(lambda)→ 逆序执行的清理，类似 RAII

---

## 六、扩展组件（Test Components）

通过 TEST_CLASS_WITH_BASE 组合使用，无需层层继承：

| 组件 | 用途 |
|---|---|
| ActorTestSpawner | 创建最小 UWorld，生成并管理 Actor 生命周期 |
| MapTestSpawner | 打开指定关卡，在真实场景内测试 |
| PIENetworkComponent | 模拟 Server + Client PIE，测试网络同步逻辑 |
| InputTestActions | 向 Pawn 注入 EnhancedInput InputAction |
| CQTestSlateComponent | 监听 Slate UI 刷新事件 |

自定义基类示例：

```cpp
template<typename Derived, typename AsserterType>
struct TMyGameBaseTest : public TTest<Derived, AsserterType>
{
    ActorTestSpawner Spawner;   // 组合组件

    BEFORE_ALL() { /* 共享的 static 初始化 */ }

    AMyActor* SpawnMyActor()
    {
        return Spawner.SpawnActor<AMyActor>();
    }
};

#define MY_TEST(ClassName, Dir) \
    TEST_CLASS_WITH_BASE(ClassName, Dir, TMyGameBaseTest)

MY_TEST(CombatTest, "Game.Combat")
{
    TEST_METHOD(DamageApplied)
    {
        AMyActor* Actor = SpawnMyActor();
        Actor->TakeDamage(10.f);
        ASSERT_THAT(AreEqual(90.f, Actor->GetHealth()));
    }
};
```

---

## 七、测试执行时序

```
[程序启动] 静态初始化
  ├─ FFunctionRegistrar 构造 → TEST_METHOD 写入 Methods 表
  └─ TTestRunner 构造        → 注册到 FAutomationTestFramework

[运行测试] TTestRunner::RunTest
  ├─ [1] BEFORE_ALL()           （仅一次）
  │
  │  ┌── 每个 TEST_METHOD 循环 ─────────────────────┐
  │  ├─ [2] new DerivedClass()  成员变量自动归零     │
  │  ├─ [3] BEFORE_EACH()       flush latent cmds  │
  │  ├─ [4] TEST_METHOD 体      flush latent cmds  │
  │  ├─ [5] AFTER_EACH()        失败也执行          │
  │  └─ [6] ~DerivedClass()     OnTearDown 逆序    │
  │                                                 │
  └─ [7] AFTER_ALL()            （仅一次）
```

---

## 八、启动方式

```bash
# 命令行（CI 最常用）
UnrealEditor-Cmd.exe MyProject.uproject \
    -ExecCmds="Automation RunTests Game.MyGame.; Quit" \
    -nullrhi -nosound -unattended -log

# 只跑单个测试
-ExecCmds="Automation RunTest Game.MyGame.CombatTest; Quit"
```

编辑器内：Window → Session Frontend → Automation → 勾选 → Start Tests

测试路径前缀 = TEST_CLASS 第二个参数，如 "Game.MyGame" 匹配所有
以 Game.MyGame 开头的测试。

---

## 九、常见 AutomationTestFlags

```cpp
// 默认（TEST_CLASS 使用）
EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::ProductFilter

// 仅编辑器
EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter

// 快速冒烟测试（CI 优先跑）
EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::SmokeFilter

// 指定方式
TEST_CLASS_WITH_FLAGS(MyTest, "Game.MyGame",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)
```

---

## 十、核心文件位置参考

```
Engine/Source/Developer/CQTest/
├── Public/
│   ├── CQTest.h              ← TTest / TTestRunner / TBaseTest 核心模板
│   ├── CQTestSettings.h      ← 超时配置 UCQTestSettings
│   └── Assert/
│       └── CQTestAssert.h    ← 所有断言函数定义
└── Private/
    └── Components/           ← ActorTestSpawner / PIENetworkComponent 等
```
```

---

这份 skill 涵盖了：
- 接入方式
- 所有宏的用法和生命周期
- 完整断言速查表（代码块格式）
- 延迟命令 API
- 扩展组件用法
- 执行时序
- 启动命令
- 核心文件位置

可以直接复制作为 Prompt Skill 的内容使用。

## 🙋 用户（2026/08/27 21:00:18）

不要求接入方式, 就说明下怎么使用, 并且给出示例模板, 模板要抽象点, 有些逻辑用一些占位符性质的就行

## 🤖 AI 助手（2026/08/27 21:00:18）

三个使用场景对应三个模板，从简到繁。

---

**模板 1：最简单，单个无状态测试**

```cpp
#include "CQTest.h"

// TEST(测试名, "路径.分组")
TEST(FooFeatureSimpleTest, "Game.Module.Feature")
{
    // [Arrange] 准备数据
    auto Input = /* 构造输入值 */;

    // [Act] 执行被测逻辑
    auto Result = /* 调用被测函数(Input) */;

    // [Assert] 验证结果
    ASSERT_THAT(AreEqual(/* ExpectedValue */, Result));
}
```

适用场景：纯函数、工具类、单次逻辑验证，不需要共享状态。

---

**模板 2：标准 Fixture，多个方法共享 setup**

```cpp
#include "CQTest.h"

// TEST_CLASS(测试类名, "路径.分组")
TEST_CLASS(FooFeatureTests, "Game.Module.Feature")
{
    // ── 共享成员（每个 TEST_METHOD 执行前自动重置为初始值）──
    /* FooSystem* SystemUnderTest = nullptr; */
    /* int32 SomeSharedCounter   = 0;        */

    // ── 每个 TEST_METHOD 前调用 ──
    BEFORE_EACH()
    {
        // SystemUnderTest = new FooSystem();
        // SystemUnderTest->Init(/* 初始参数 */);
    }

    // ── 每个 TEST_METHOD 后调用（即使测试失败也会执行）──
    AFTER_EACH()
    {
        // delete SystemUnderTest;
        // SystemUnderTest = nullptr;
    }

    // ── 可选：整个 class 所有 method 运行前，仅执行一次 ──
    BEFORE_ALL()
    {
        // 加载全局资源 / 注册静态数据
    }

    // ── 可选：整个 class 所有 method 运行后，仅执行一次 ──
    AFTER_ALL()
    {
        // 卸载全局资源
    }

    // ── 正向测试：验证预期行为 ──
    TEST_METHOD(WhenConditionA_ExpectResultX)
    {
        // [Arrange]
        /* SystemUnderTest->SetState(/* 条件A */); */

        // [Act]
        /* auto Result = SystemUnderTest->DoSomething(); */

        // [Assert]
        ASSERT_THAT(AreEqual(/* ExpectedX */, /* Result */));
        ASSERT_THAT(IsTrue(/* 其他附加条件 */));
    }

    // ── 边界测试 ──
    TEST_METHOD(WhenEdgeCase_ExpectSafeResult)
    {
        /* auto Result = SystemUnderTest->DoSomething(/* 边界值 */); */
        ASSERT_THAT(IsNotNull(/* Result */));
        ASSERT_THAT(AreEqual(/* SafeDefault */, /* Result */));
    }

    // ── 负向测试 ──
    TEST_METHOD(WhenInvalidInput_ExpectFalse)
    {
        /* bool bOk = SystemUnderTest->TryProcess(/* 非法值 */); */
        ASSERT_THAT(IsFalse(/* bOk */));
    }
};
```

---

**模板 3：异步 / 需要等待的测试**

```cpp
#include "CQTest.h"

TEST_CLASS(FooAsyncFeatureTests, "Game.Module.Feature")
{
    /* FAsyncOperation* AsyncOp = nullptr; */
    /* bool bOperationDone      = false;   */

    BEFORE_EACH()
    {
        // AsyncOp = new FAsyncOperation();
    }

    AFTER_EACH()
    {
        // delete AsyncOp;
    }

    TEST_METHOD(WhenAsyncOpCompletes_ExpectSuccess)
    {
        TestCommandBuilder
            // Step 1：触发异步操作
            .Do([&]()
            {
                // AsyncOp->Start(/* 参数 */);
            })
            // Step 2：轮询等待完成（替代 hardcode sleep）
            .Until([&]() -> bool
            {
                return /* AsyncOp->IsComplete() */;
            })
            // Step 3：验证结果
            .Then([&]()
            {
                ASSERT_THAT(IsTrue(/* AsyncOp->Succeeded() */));
                ASSERT_THAT(AreEqual(/* ExpectedValue */, /* AsyncOp->GetResult() */));
            })
            // Step 4：清理（逆序执行，类似 RAII）
            .OnTearDown([&]()
            {
                // AsyncOp->Cancel();
            });
    }
};
```

---

**选哪个的判断依据**

```
只需验证一个逻辑点，无状态？
    └─> 模板 1  TEST(...)

多个场景需要共享 setUp/tearDown？
    └─> 模板 2  TEST_CLASS(...) + TEST_METHOD(...)

需要等待帧、等待异步、等待条件满足？
    └─> 模板 3  TEST_CLASS + TestCommandBuilder 链
```

## 🙋 用户（2026/08/27 21:01:11）

扩展组件（Test Components） 这个每个组件你给我详细说说?

## 🤖 AI 助手（2026/08/27 21:01:11）

我来检索每个 Test Component 的详细源码实现。
再补充检索 SpawnHelper、InputTestActions 和 CQTestSlateComponent 的详细实现。
根据已检索到的信息，我来详细整理每个 Test Component 的说明。不过对于 `FCQTestSlateComponent` 的信息还较为有限，我先补充检索一下。
现在信息已经完整，可以输出全面的组件详解了。

---

## CQTest 扩展组件（Test Components）详解

CQTest 的 Test Components 遵循"组合优于继承"的设计哲学——你的测试结构体通过**持有这些组件的成员变量**来获得对应能力，而非继承特定基类。组件之间存在继承关系（FActorTestSpawner / FMapTestSpawner 都继承 FSpawnHelper），但对使用者来说始终是"持有"关系。

---

### 1. FSpawnHelper（基础生成器，不直接使用）

**所在文件：** `Engine/Source/Developer/CQTest/Public/Components/SpawnHelper.h`

这是 Actor/Object 生成能力的基类，FActorTestSpawner 和 FMapTestSpawner 都继承它。一般不直接实例化，但它提供了所有生成相关的核心 API。[[1]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/SpawnHelper.h#FSpawnHelper)

```cpp
// 生成 Actor，返回强引用（断言生成成功）
template <typename ActorType>
ActorType& SpawnActor(const FActorSpawnParameters& SpawnParameters = {},
                      UClass* Class = nullptr);

// 生成 UObject（非 Actor），有 static_assert 保证类型安全
template <typename ObjectType>
ObjectType& SpawnObject();
// ⚠️ static_assert: ObjectType 不能是 AActor 派生，必须是 UObject 派生
```

生成的 Actor/Object 全部被内部追踪，析构时通过 `DestroySpawnedActors()` / `DestroySpawnedObjects()` 自动清理，无需手动管理。[[1]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/SpawnHelper.h#FSpawnHelper)

---

### 2. FActorTestSpawner（轻量测试世界）

**所在文件：** `Engine/Source/Developer/CQTest/Public/Components/ActorTestSpawner.h`

适用于**不需要加载真实地图**的单元测试场景。它在内部创建一个最小化的 UWorld，专供生成 Actor 和 UObject 使用。[[2]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/ActorTestSpawner.h#FActorTestSpawner)

```cpp
struct FActorTestSpawner : public FSpawnHelper {
    virtual ~FActorTestSpawner() override;  // 自动销毁 World 和所有已生成对象

    void InitializeGameSubsystems();        // 初始化 GameInstance 和 GameSubsystem
    UTestGameInstance* GetGameInstance();   // 获取内部测试用 GameInstance

protected:
    virtual UWorld* CreateWorld() override; // 创建最小 UWorld（不加载任何关卡）
};
```

**典型用法：**

```cpp
TEST_CLASS(MyActorUnitTest, "MyGame.Unit")
{
    FActorTestSpawner Spawner;  // 成员变量，每个 TEST_METHOD 前自动重建

    TEST_METHOD(Actor_ShouldInitializeCorrectly)
    {
        AMyActor& Actor = Spawner.SpawnActor<AMyActor>();
        ASSERT_THAT(IsTrue(Actor.IsInitialized()));
    }

    TEST_METHOD(Object_DataShouldBeValid)
    {
        UMyDataObject& Data = Spawner.SpawnObject<UMyDataObject>();
        ASSERT_THAT(IsNotNull(Data.GetConfig()));
    }
};
```

**注意：** 析构时会按序调用 `DestroySpawnedActors()` → `DestroySpawnedObjects()` → `DestroyWorld()`，不需要手动清理。[[2]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/ActorTestSpawner.h#FActorTestSpawner)

---

### 3. FMapTestSpawner（真实关卡测试）

**所在文件：** `Engine/Source/Developer/CQTest/Public/Components/MapTestSpawner.h`

适用于**需要真实关卡环境**的集成测试，支持两种模式：加载已有地图 或 创建临时空关卡。[[3]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/MapTestSpawner.h#FMapTestSpawner)

```cpp
struct FMapTestSpawner : public FSpawnHelper {
    // 模式一：加载已有地图（在 BEFORE_EACH 中构造）
    FMapTestSpawner(const FString& MapDirectory, const FString& MapName);

    // 模式二：创建临时空关卡（静态工厂方法，不需要现有地图资产）
    static TUniquePtr<FMapTestSpawner> CreateFromTempLevel(
        FTestCommandBuilder& InCommandBuilder);

    // ⚠️ 必须调用：向命令队列注入"等待地图加载完成"的延迟命令
    // 须在 BEFORE_EACH 之外调用（通常在测试方法体中首先调用）
    void AddWaitUntilLoadedCommand(
        FAutomationTestBase* TestRunner,
        TOptional<FTimespan> Timeout = CQTest::DefaultTimeout);

    APawn* FindFirstPlayerPawn();  // 获取关卡中第一个 PlayerPawn

protected:
    virtual UWorld* CreateWorld() override;
};
```

**典型用法（加载已有地图）：**

```cpp
TEST_CLASS(MyMapTest, "MyGame.Integration")
{
    TUniquePtr<FMapTestSpawner> MapSpawner;

    BEFORE_EACH() {
        MapSpawner = MakeUnique<FMapTestSpawner>(
            TEXT("/Game/Maps"), TEXT("TestLevel"));
    }

    TEST_METHOD(Map_PlayerShouldSpawnAtStart)
    {
        // 必须先注入等待命令，再做断言
        MapSpawner->AddWaitUntilLoadedCommand(TestRunner);

        TestCommandBuilder.Do([this]() {
            APawn* Pawn = MapSpawner->FindFirstPlayerPawn();
            ASSERT_THAT(IsNotNull(Pawn));
        });
    }
};
```

**典型用法（临时关卡）：**

```cpp
BEFORE_EACH() {
    // CreateFromTempLevel 内部已处理等待逻辑，不需要再调用 AddWaitUntilLoadedCommand
    MapSpawner = FMapTestSpawner::CreateFromTempLevel(TestCommandBuilder);
}
```

**注意：** `AddWaitUntilLoadedCommand` 只能在 `BEFORE_EACH` 外部（即 TEST_METHOD 体内）调用，因为它要向 `TestCommandBuilder` 的命令队列追加延迟命令，而 BEFORE_EACH 本身就是命令执行阶段。[[3]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/MapTestSpawner.h#FMapTestSpawner)

---

### 4. FPIENetworkComponent\<StateType\>（网络多客户端仿真）

**所在文件：** `Engine/Source/Developer/CQTest/Public/Components/PIENetworkComponent.h`
**测试示例：** `Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/PIENetworkComponentTests.cpp`
**限制：** 仅 `EAutomationTestFlags::EditorContext`

这是最复杂的组件，用于模拟服务器+多客户端的 PIE 网络环境。使用专属宏 `NETWORK_TEST_CLASS` 声明，通过 `FNetworkComponentBuilder` 构建环境。[[4]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/PIENetworkComponentTests.cpp#)

**StateType** 的作用：每个 Server/Client 各自持有一份 `StateType` 实例（继承自 `FBasePIENetworkComponentState`），用于在步骤间传递该端私有的测试状态——Server 和 Client 的 State **互不共享**。

```cpp
// 声明网络测试类（替代 TEST_CLASS 宏）
NETWORK_TEST_CLASS(MyNetworkTest, "MyGame.Network")
{
    // 自定义状态，Server 和每个 Client 各持有一份独立实例
    struct DerivedState : public FBasePIENetworkComponentState {
        int32 ReplicatedValue = 0;
        AMyActor* ActorPtr = nullptr;
    };

    FPIENetworkComponent<DerivedState> Network{
        TestRunner, TestCommandBuilder, bInitializing };

    BEFORE_EACH() {
        FNetworkComponentBuilder<DerivedState>()
            .WithClients(2)                                    // 2 个客户端
            .WithGameMode(AMyGameMode::StaticClass())
            .WithGameInstanceClass(UMyGameInstance::StaticClass())
            .Build(Network);
    }

    TEST_METHOD(Server_ShouldReplicateActor_ToClients)
    {
        Network
            // 在 Server 端生成 Actor，等待复制到所有 Client
            .SpawnAndReplicate<AMyActor, &DerivedState::ActorPtr>()

            // Server 端断言
            .ThenServer([this](DerivedState& State) {
                ASSERT_THAT(IsNotNull(State.ActorPtr));
                State.ActorPtr->SetReplicatedValue(42);
            })

            // 等待所有 Client 端满足条件
            .UntilClients([](DerivedState& State) {
                return State.ActorPtr && State.ActorPtr->GetReplicatedValue() == 42;
            })

            // 指定 Client[0] 执行断言
            .ThenClient(0, [](DerivedState& State) {
                // Client 0 专属检查
            })

            // 所有 Client 并发执行
            .ThenClients([](DerivedState& State) {
                // 每个 Client 都会执行
            })

            // 测试中途加入新 Client
            .ThenClientJoins()

            // 回到主线程执行（无 State 参数）
            .Then([this]() {
                ASSERT_THAT(IsTrue(SomeCondition));
            });
    }
};
```

**链式 API 速查：**

| 方法 | 执行端 | 说明 |
|------|--------|------|
| `.ThenServer(lambda)` | Server | Server 端执行一步，lambda 接收 `DerivedState&` |
| `.ThenClient(idx, lambda)` | Client[idx] | 指定索引客户端执行 |
| `.ThenClients(lambda)` | All Clients | 所有客户端并发执行 |
| `.UntilServer(predicate)` | Server | 等待 Server 端谓词为 true |
| `.UntilClients(predicate)` | All Clients | 等待所有客户端谓词为 true |
| `.ThenClientJoins()` | 框架 | 在测试中途动态加入新客户端 |
| `.SpawnAndReplicate<T, &State::Ptr>()` | Server→Client | Server 生成 Actor 并等待复制到所有 Client |
| `.Then(lambda)` | 主线程 | 无网络上下文的通用步骤 |

[[4]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/PIENetworkComponentTests.cpp#)

---

### 5. FInputTestActions（输入注入，独立插件）

**所在文件：** `Engine/Plugins/Tests/CQTestEnhancedInput/Source/CQTestEnhancedInput/Public/Components/InputTestActions.h`
**依赖：** `CQTestEnhancedInput` 插件，需在 `Build.cs` 添加并在 `.uproject` 中启用
**限制：** 仅 `EAutomationTestFlags::EditorContext`

用于向 Pawn 模拟注入 EnhancedInput 输入动作，无需真实的物理输入设备触发。[[5]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTestEnhancedInput/Source/CQTestEnhancedInput/Public/Components/InputTestActions.h#FInputTestActions)

**核心类型：**

```cpp
// 单个输入动作的封装基类
class FTestAction {
public:
    virtual void operator()(const APawn* Pawn);  // 将输入注入到 Pawn
    FString InputActionName;                     // 动作名称（与 InputAction Asset 对应）
    FInputActionValue InputActionValue;          // 注入的值（bool/float/Vector2D/Vector）

private:
    // 从 Pawn 或 PlayerController 的 UEnhancedInputComponent 中查找 UInputAction 资产
    void FindInputAction(const APawn* Pawn);
    const UInputAction* InputAction{ nullptr };
};

// 输入管理器
class FInputTestActions {
public:
    FInputTestActions(APawn* InPawn);     // 绑定目标 Pawn

    void PerformAction(FTestAction& Action);   // 触发一次输入动作
    void StopAllActions();                      // 停止所有持续性输入
    bool HasActiveActions() const;              // 是否有正在进行的输入
    void Reset();                               // 重置所有输入状态
};
```

**典型用法：**

```cpp
TEST_CLASS(MyInputTest, "MyGame.Input",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)
{
    TUniquePtr<FMapTestSpawner> MapSpawner;
    TUniquePtr<FInputTestActions> InputActions;

    BEFORE_EACH() {
        MapSpawner = MakeUnique<FMapTestSpawner>(TEXT("/Game/Maps"), TEXT("InputTestLevel"));
    }

    TEST_METHOD(Input_MoveForward_ShouldMoveCharacter)
    {
        MapSpawner->AddWaitUntilLoadedCommand(TestRunner);

        TestCommandBuilder.Do([this]() {
            APawn* Pawn = MapSpawner->FindFirstPlayerPawn();
            InputActions = MakeUnique<FInputTestActions>(Pawn);
        })
        .Do([this]() {
            FTestAction MoveAction;
            MoveAction.InputActionName = TEXT("IA_Move");
            MoveAction.InputActionValue = FInputActionValue(FVector2D(0.f, 1.f));
            InputActions->PerformAction(MoveAction);
        })
        .Until([this]() {
            // 等待角色移动完成
            return SomeMovementCondition();
        })
        .Do([this]() {
            InputActions->StopAllActions();
        });
    }
};
```

**注意：** UE5.5 后因 CQTest 从 Plugin 升为 Engine Module，不再能引用 Engine Plugin，因此 `FInputTestActions` 被独立到 `CQTestEnhancedInput` 插件中。[[5]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTestEnhancedInput/Source/CQTestEnhancedInput/Public/Components/InputTestActions.h#FInputTestActions)

---

### 6. FCQTestSlateComponent（Slate Tick 同步）

**所在文件：** `Engine/Source/Developer/CQTest/Public/Components/CQTestSlateComponent.h`
**限制：** 需要 Slate 已初始化（即 Editor 或带 Slate 的独立运行时环境）

用于**等待 Slate UI 刷新指定次数**，适合测试依赖 Slate Tick 才会触发响应的 UI 逻辑。[[6]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/CQTestSlateComponent.h#FCQTestSlateComponent)

构造时会：
1. `checkf` 确保 `FSlateApplication::IsInitialized()`
2. 通过控制台变量 `Slate.AllowSlateToSleep=0` **强制禁止 Slate 进入休眠**（保证 Tick 持续运行）
3. 注册 `OnPostTick` 回调，每次 Slate Tick 后原子递增 `TickCounter`

```cpp
class FCQTestSlateComponent {
public:
    FCQTestSlateComponent();
    ~FCQTestSlateComponent();  // 自动注销 Tick 委托，恢复 Slate 休眠设置

    // 检查是否已经过了指定次数的 Slate Tick
    // 设计为配合 Until / FWaitUntil / StartWhen 等延迟命令使用
    bool HaveTicksElapsed(uint32 Ticks);

    // 获取自创建起累计的总 Tick 次数
    uint32 GetTotalElapsedTicks();
};
```

**典型用法：**

```cpp
TEST_CLASS(MySlateTest, "MyGame.UI")
{
    FCQTestSlateComponent SlateComponent;

    TEST_METHOD(Widget_ShouldUpdateAfterTwoTicks)
    {
        TestCommandBuilder
            .Do([this]() {
                // 触发某个会导致 Slate 刷新的操作
                TriggerWidgetUpdate();
            })
            // 等待 Slate 刷新 2 次后再做断言
            .Until([this]() {
                return SlateComponent.HaveTicksElapsed(2);
            })
            .Do([this]() {
                ASSERT_THAT(IsTrue(MyWidget->IsUpdated()));
            });
    }
};
```

**注意：** `HaveTicksElapsed(N)` 每次被调用时会设置内部的 `ExpectedTick` 目标，达到后自动重置——设计为**单次等待**语义，即调用一次就等待一轮，下次调用重新开始计数。[[6]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/CQTestSlateComponent.h#FCQTestSlateComponent)

---

### 组件选型速查

```
需要测试 Actor/Object 逻辑，不需要关卡？
  └─ FActorTestSpawner（最轻量）

需要真实关卡/地形/Navigation/GameMode？
  └─ FMapTestSpawner
       ├─ 已有地图 → 构造函数 + AddWaitUntilLoadedCommand
       └─ 临时空关卡 → CreateFromTempLevel（自动处理等待）

需要测试 Server/Client 网络同步逻辑？
  └─ NETWORK_TEST_CLASS + FPIENetworkComponent<State>
       └─ FNetworkComponentBuilder 配置客户端数量、GameMode

需要模拟玩家按键/摇杆输入？
  └─ FInputTestActions（需要 CQTestEnhancedInput 插件）

需要等待 UI 响应 Slate 刷新？
  └─ FCQTestSlateComponent + HaveTicksElapsed(N)
```

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/Public/Components/SpawnHelper.h#FSpawnHelper](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/SpawnHelper.h#FSpawnHelper)

[2]. [Engine/Source/Developer/CQTest/Public/Components/ActorTestSpawner.h#FActorTestSpawner](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/ActorTestSpawner.h#FActorTestSpawner)

[3]. [Engine/Source/Developer/CQTest/Public/Components/MapTestSpawner.h#FMapTestSpawner](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/MapTestSpawner.h#FMapTestSpawner)

[4]. [Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/PIENetworkComponentTests.cpp](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/PIENetworkComponentTests.cpp)

[5]. [Engine/Plugins/Tests/CQTestEnhancedInput/Source/CQTestEnhancedInput/Public/Components/InputTestActions.h#FInputTestActions](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTestEnhancedInput/Source/CQTestEnhancedInput/Public/Components/InputTestActions.h#FInputTestActions)

[6]. [Engine/Source/Developer/CQTest/Public/Components/CQTestSlateComponent.h#FCQTestSlateComponent](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/CQTestSlateComponent.h#FCQTestSlateComponent)

## 🙋 用户（2026/08/27 22:14:49）

还有扩展组件（Test Components）我感觉现在有点少啊, 用户还有哪些扩展方向什么的?

## 🤖 AI 助手（2026/08/27 22:14:49）

先检索一下官方文档中关于自定义扩展组件的说明，以及 `TEST_CLASS_WITH_BASE` 的扩展模式。
基于已有的完整检索结果，直接整理回答。

---

## CQTest 用户扩展方向

内置的 Test Components 解决的是"运行环境搭建"问题（World、网络、Input、Slate），但 CQTest 框架本身还提供了三个更底层的扩展维度，让你改变**测试类的结构本身**。

---

### 扩展维度一：自定义断言器

**目标**：为特定业务领域添加语义化断言，复用到多个测试类。

继承 `FNoDiscardAsserter`，添加自己的断言方法：

```cpp
struct FMyDomainAsserter : public FNoDiscardAsserter
{
    FMyDomainAsserter(FAutomationTestBase& TestRunner)
        : FNoDiscardAsserter(TestRunner) {}

    // 自定义领域断言（返回 bool，配合 ASSERT_THAT 使用）
    bool IsValidHealth(int32 HP) {
        return AddErrorIfFalse(HP >= 0 && HP <= 100,
            FString::Printf(TEXT("Health %d out of range [0,100]"), HP));
    }

    bool IsActorOnGround(AActor* Actor) {
        return AddErrorIfFalse(
            Actor && FMath::Abs(Actor->GetActorLocation().Z) < 1.f,
            TEXT("Actor is not on the ground"));
    }
};

// 封装成项目专用宏
#define MY_TEST_CLASS(_ClassName, _TestDir) \
    TEST_CLASS_WITH_ASSERTS(_ClassName, _TestDir, FMyDomainAsserter)
```

使用时直接调用自定义断言，同时原有断言（`IsTrue`/`AreEqual` 等）仍然可用：

```cpp
MY_TEST_CLASS(CharacterTests, "Game.Character")
{
    TEST_METHOD(Character_SpawnWithFullHealth_IsValid)
    {
        int32 HP = SpawnCharacter().GetHealth();
        ASSERT_THAT(IsValidHealth(HP));   // 自定义断言
        ASSERT_THAT(IsTrue(HP == 100));   // 原生断言仍可用
    }
};
```

配合 Tags 版本：`TEST_CLASS_WITH_ASSERTS_AND_TAGS(ClassName, Dir, FMyAsserter, "[tag1][tag2]")`

---

### 扩展维度二：自定义基类

**目标**：在多个测试类之间共享成员变量、辅助方法、生命周期钩子。

模板签名必须严格遵循 `template<typename Derived, typename AsserterType>`：

```cpp
template<typename Derived, typename AsserterType>
struct TMySharedBase : public TTest<Derived, AsserterType>
{
    // --- 跨实例共享状态（inline static）---
    inline static UMySubsystem* SharedSubsystem = nullptr;

    // --- 每实例私有状态（普通成员）---
    FMyTestContext Context;

    // --- 共享生命周期（整个测试类只执行一次）---
    BEFORE_ALL() {
        SharedSubsystem = GEngine->GetEngineSubsystem<UMySubsystem>();
    }
    AFTER_ALL() {
        SharedSubsystem = nullptr;
    }

    // --- 可在内部使用 ASSERT_THAT 的辅助方法 ---
    void AssertSubsystemReady() {
        ASSERT_THAT(IsNotNull(SharedSubsystem));
    }

    // --- Setup/TearDown 也可以在基类重写 ---
    void Setup() override {
        Context.Initialize();
    }
};

// 封装成项目专用宏
#define MY_SUBSYSTEM_TEST(_ClassName, _TestDir) \
    TEST_CLASS_WITH_BASE(_ClassName, _TestDir, TMySharedBase)
```

派生类使用：

```cpp
MY_SUBSYSTEM_TEST(SubsystemFeatureTests, "Game.Subsystem")
{
    // 如果派生类也有 BEFORE_ALL，需要手动调用基类的
    BEFORE_ALL() {
        TMySharedBase::BeforeAll(FString()); // 必须手动链式调用
        DerivedValue = SharedSubsystem->GetDefaultValue();
    }

    TEST_METHOD(Subsystem_AfterInit_IsReady) {
        AssertSubsystemReady();              // 直接调用基类辅助方法
        ASSERT_THAT(IsNotNull(SharedSubsystem));
    }
};
```

**宏组合全家族**（WITH_BASE 系列）：

```
TEST_CLASS_WITH_BASE(ClassName, Dir, TBaseClass)
TEST_CLASS_WITH_BASE_AND_FLAGS(ClassName, Dir, TBaseClass, Flags)
TEST_CLASS_WITH_BASE_AND_TAGS(ClassName, Dir, TBaseClass, "[tags]")
TEST_CLASS_WITH_BASE_AND_FLAGS_AND_TAGS(ClassName, Dir, TBaseClass, Flags, "[tags]")
```

---

### 扩展维度三：bInitializing 感知的构造函数

**目标**：在基类构造函数中区分"程序启动注册阶段"和"测试实际运行阶段"，做不同的初始化。

```cpp
template<typename Derived, typename AsserterType>
struct TLazyInitBase : public TTest<Derived, AsserterType>
{
    TLazyInitBase() {
        if (this->bInitializing) {
            // 程序启动时：仅做静态注册，不访问 World/资产/子系统
            // 此时插件可能还未加载，资产 Registry 可能未就绪
        } else {
            // 实际运行测试时：可以安全访问运行时资源
            CachedAsset = CQTestAssetHelper::FindDataBlueprint(TEXT("B_MyAsset"));
        }
    }

    UObject* CachedAsset = nullptr;
};
```

这个机制特别重要的场景是**在构造函数中使用 `CQTestAssetHelper`**——必须先检查 `bInitializing == false`，否则在启动注册阶段调用 AssetRegistry 会因为插件未加载而找不到资产。[[1]](https://km.woa.com/articles/show/0?view_version=1)

---

### 扩展维度四：资产查询助手（CQTestAssetHelper）

这不是一个 Test Component，而是一个**工具命名空间**，专为 Editor 上下文的测试设计，用于替代 5.5 已废弃的 `FCQTestBlueprintHelper`。

```cpp
// 配合 FAssetFilterBuilder 构建过滤条件
FARFilter Filter = CQTestAssetHelper::FAssetFilterBuilder()
    .WithPackagePath(TEXT("/Game/Characters"))
    .WithClass(UBlueprint::StaticClass())
    .Build();

// 查找蓝图类
UClass* CharClass = CQTestAssetHelper::GetBlueprintClass(Filter, TEXT("BP_MyCharacter"));

// 查找 Data Blueprint 实例
UObject* DataAsset = CQTestAssetHelper::FindDataBlueprint(Filter, TEXT("DA_MyData"));

// 批量获取所有符合条件的蓝图类
TArray<UClass*> AllClasses = CQTestAssetHelper::GetBlueprintClasses(Filter);
```

使用时需要 `EditorContext` flag，因为 AssetRegistry 只在编辑器中可用：

```cpp
TEST_CLASS_WITH_FLAGS(AssetTests, "Game.Assets",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)
{
    TEST_METHOD(Asset_BlueprintClass_IsLoadable) {
        UClass* Cls = CQTestAssetHelper::GetBlueprintClass(TEXT("BP_MyChar"));
        ASSERT_THAT(IsNotNull(Cls));
    }
};
```

---

### 三个维度的组合使用

实际项目中这三个维度可以自由组合——比如一个自定义基类（共享 World 引用和辅助方法）+ 一个自定义断言器（业务领域断言）同时作用在同一个测试类上：

```
TEST_CLASS_WITH_ASSERTS → 替换断言器，保持默认基类
TEST_CLASS_WITH_BASE    → 替换基类，保持默认断言器
两者同时定制            → 直接继承 TTest<D,MyAsserter> + TEST_CLASS_WITH_BASE
                         （基类模板参数 AsserterType 会透传自定义断言器）
```

这样，**Test Components 解决"测试环境搭建"**，**自定义基类解决"测试逻辑复用"**，**自定义断言器解决"领域语义表达"**，三个层面正交独立，可按需叠加。

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/README.md#Extending the framework](https://km.woa.com/articles/show/0?view_version=1)

## 🙋 用户（2026/08/27 22:30:36）

你再帮我总计一个cqtest 的skill 主要是指南形式就行, 要英文的

## 🤖 AI 助手（2026/08/27 22:30:36）

Here is a complete English skill guide for UE CQTest, organized as a reference card you can paste directly into a prompt or wiki.

---

# UE CQTest — Developer Guide

## Overview

CQTest is UE5's built-in C++ automation test framework (`Engine/Source/Developer/CQTest`), promoted to an Engine Module in UE 5.5. Its core design goals are:

- **State isolation** — re-construct the test object before every `TEST_METHOD`, so member variables are automatically reset.
- **Per-method lifecycle hooks** — `BEFORE_EACH` / `AFTER_EACH` run around every individual method, not just once per class.
- **Composition over inheritance** — environment capabilities are added by holding Test Component members, not by sub-classing.
- **Make easy things easy** — a minimal test is a single macro + a single assertion.

---

## Quick-Start: Macro Selection

```
Single stateless test
  └─ TEST(TestName, "Path.Dir") { ... }

Multiple methods sharing fixture state
  └─ TEST_CLASS(ClassName, "Path.Dir") { ... }

Custom test flags (e.g. EditorContext only)
  └─ TEST_CLASS_WITH_FLAGS(ClassName, "Path.Dir", EAutomationTestFlags::...)

Shared base class across multiple test classes
  └─ TEST_CLASS_WITH_BASE(ClassName, "Path.Dir", TMyBase)

Custom asserter for domain-specific assertions
  └─ TEST_CLASS_WITH_ASSERTS(ClassName, "Path.Dir", FMyAsserter)

Network simulation (Server + N Clients in PIE)
  └─ NETWORK_TEST_CLASS(ClassName, "Path.Dir")
```

Combination variants follow the pattern:
`TEST_CLASS_WITH_BASE_AND_FLAGS`, `TEST_CLASS_WITH_BASE_AND_TAGS`, `TEST_CLASS_WITH_BASE_AND_FLAGS_AND_TAGS`, `TEST_CLASS_WITH_ASSERTS_AND_TAGS`, etc.

---

## Lifecycle Order

```
[Program Start]  static init → FFunctionRegistrar registers all TEST_METHODs into Methods table
                              → TTestRunner registers class into FAutomationTestFramework

[Run Tests]
  BEFORE_ALL()           ← called once for the entire class (optional, static)
  │
  ├─ for each TEST_METHOD:
  │    new DerivedClass()          ← fresh instance, all members reset to defaults
  │    BEFORE_EACH()               ← flush latent commands
  │    TEST_METHOD body            ← flush latent commands
  │    AFTER_EACH()                ← runs even if test method failed
  │    ~DerivedClass()             ← OnTearDown callbacks fire in reverse order
  │
  └─ AFTER_ALL()          ← called once after all methods complete (optional, static)
```

---

## Assertion Quick Reference

All assertions are called as `ASSERT_THAT(<condition_fn>)`.
Failure records an error and early-returns from the current phase (no C++ exception).

```cpp
// Boolean
ASSERT_THAT(IsTrue(expr))
ASSERT_THAT(IsFalse(expr))

// Equality
ASSERT_THAT(AreEqual(a, b))
ASSERT_THAT(AreNotEqual(a, b))
ASSERT_THAT(AreEqualIgnoreCase(strA, strB))      // FString / TCHAR*
ASSERT_THAT(AreNotEqualIgnoreCase(strA, strB))

// Numeric approximation
ASSERT_THAT(IsNear(a, b, tolerance))
ASSERT_THAT(IsNearlyEqual(a, b))                 // default UE_KINDA_SMALL_NUMBER
ASSERT_THAT(IsNearlyEqual(a, b, tolerance))
ASSERT_THAT(IsNotNearlyEqual(a, b))
ASSERT_THAT(IsNearlyEqual(vecA, vecB))           // FVector / FRotator / FTransform
ASSERT_THAT(IsNotNearlyEqual(vecA, vecB))

// Pointer / smart pointer
ASSERT_THAT(IsNull(ptr))                         // raw / TSharedPtr / TUniquePtr
ASSERT_THAT(IsNotNull(ptr))

// Reverse (expect an assertion to fail — used when testing defensive code)
Assert.ExpectError(AnyError);
ASSERT_THAT(IsTrue(false));   // this failure is now expected → test passes
```

---

## Async / Latent Commands

Use `TestCommandBuilder` when test logic spans multiple frames or requires polling.

```cpp
TEST_METHOD(MyAsyncFeature_ShouldCompleteSuccessfully)
{
    TestCommandBuilder
        .Do([this]()   { /* trigger async operation */ })
        .Until([this]() { return /* polling condition */; })   // preferred over WaitDelay
        .Then([this]() { ASSERT_THAT(IsTrue(/* result */)); })
        .OnTearDown([this]() { /* cleanup, fires in reverse order */ });
}
```

| API | Behaviour |
|-----|-----------|
| `.Do(lambda)` | Execute once |
| `.Until(predicate)` | Poll every tick until `true` |
| `.WaitDelay(duration)` | Fixed time wait (flaky risk, prefer `Until`) |
| `.DoAsync(lambda)` | Run on background thread |
| `.OnTearDown(lambda)` | Cleanup; fires in reverse registration order |

---

## Test Component Selection

Hold components as member variables inside your test class. Each component is destroyed and re-created with the test object.

```
Need to spawn Actors / UObjects without a real level?
  └─ FActorTestSpawner Spawner;
       Spawner.SpawnActor<AMyActor>();
       Spawner.SpawnObject<UMyData>();

Need a real level (NavMesh, GameMode, landscape)?
  └─ TUniquePtr<FMapTestSpawner> Map;
       // Existing map
       BEFORE_EACH() { Map = MakeUnique<FMapTestSpawner>(TEXT("/Game/Maps"), TEXT("TestMap")); }
       // Temp empty level
       BEFORE_EACH() { Map = FMapTestSpawner::CreateFromTempLevel(TestCommandBuilder); }
       // ⚠ Call inside TEST_METHOD body, not BEFORE_EACH:
       Map->AddWaitUntilLoadedCommand(TestRunner);

Need Server + N Clients PIE network simulation?
  └─ NETWORK_TEST_CLASS + FPIENetworkComponent<MyState>
       FNetworkComponentBuilder<MyState>()
           .WithClients(2).WithGameMode(...).Build(Network);
       Network.ThenServer(...).ThenClients(...).SpawnAndReplicate<AActor, &State::Ptr>();

Need to inject player input (EnhancedInput)?
  └─ FInputTestActions (CQTestEnhancedInput plugin, EditorContext only)
       FInputTestActions Input(Pawn);
       Input.PerformAction(MoveAction);

Need to wait for Slate UI to refresh?
  └─ FCQTestSlateComponent Slate;
       TestCommandBuilder.Until([this]() { return Slate.HaveTicksElapsed(2); });
```

---

## Framework Extension Points

**1. Custom Asserter** — add domain-specific assertion methods.

```cpp
struct FMyAsserter : public FNoDiscardAsserter {
    FMyAsserter(FAutomationTestBase& TR) : FNoDiscardAsserter(TR) {}
    bool IsValidHealth(int32 HP) {
        return AddErrorIfFalse(HP >= 0 && HP <= 100,
            FString::Printf(TEXT("Health %d out of [0,100]"), HP));
    }
};
#define MY_TEST(Name, Dir) TEST_CLASS_WITH_ASSERTS(Name, Dir, FMyAsserter)
```

**2. Custom Base Class** — share members, helpers, and lifecycle hooks across classes.

```cpp
template<typename Derived, typename AsserterType>
struct TMyBase : public TTest<Derived, AsserterType> {
    inline static UMySubsystem* Sys = nullptr;
    BEFORE_ALL() { Sys = GEngine->GetEngineSubsystem<UMySubsystem>(); }
    AFTER_ALL()  { Sys = nullptr; }
    void AssertSysReady() { ASSERT_THAT(IsNotNull(Sys)); }
};
#define MY_TEST(Name, Dir) TEST_CLASS_WITH_BASE(Name, Dir, TMyBase)

// If derived class also declares BEFORE_ALL, chain the base manually:
BEFORE_ALL() {
    TMyBase::BeforeAll(FString());
    // ... derived setup ...
}
```

**3. bInitializing guard** — distinguish program-start registration from actual test run.

```cpp
TMyBase() {
    if (this->bInitializing) { /* registration phase — no World/assets yet */ }
    else                     { /* runtime phase — safe to access engine systems */ }
}
```

---

## Asset Helper (Editor Context Only)

Replaces the deprecated `FCQTestBlueprintHelper` (removed in 5.5).

```cpp
FARFilter Filter = CQTestAssetHelper::FAssetFilterBuilder()
    .WithPackagePath(TEXT("/Game/Data"))
    .Build();

UClass*  Cls  = CQTestAssetHelper::GetBlueprintClass(Filter, TEXT("BP_MyChar"));
UObject* Data = CQTestAssetHelper::FindDataBlueprint(Filter, TEXT("DA_Config"));

ASSERT_THAT(IsNotNull(Cls));
ASSERT_THAT(IsNotNull(Data));
```

Requires `EAutomationTestFlags::EditorContext`. If accessed in a constructor, guard with `bInitializing == false`.

---

## Running Tests

**Editor (Session Frontend):**
Open `Window → Test Automation`, filter by path prefix (e.g. `Game.`), click `Start Tests`.

**Command line (CI / headless):**
```bash
UnrealEditor-Cmd.exe MyProject.uproject \
  -ExecCmds="Automation RunTests Game.MyFeature" \
  -unattended -nullrhi -nosplash \
  -ReportOutputPath="./TestResults"
```

**Default flags** (applied unless overridden):
`EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::ProductFilter`

---

## Key Source Locations

```
Engine/Source/Developer/CQTest/
  Public/CQTest.h                        ← TTest / TTestRunner / TBaseTest
  Public/Components/
    SpawnHelper.h                        ← SpawnActor<T> / SpawnObject<T>
    ActorTestSpawner.h                   ← Minimal UWorld spawner
    MapTestSpawner.h                     ← PIE level spawner
    PIENetworkComponent.h                ← Server + Clients PIE network
    CQTestSlateComponent.h               ← Slate tick counter
  Public/Helpers/
    CQTestAssetHelper.h                  ← Asset / blueprint lookup (5.5+)
  README.md                              ← Official documentation

Engine/Plugins/Tests/CQTestEnhancedInput/
  Public/Components/InputTestActions.h   ← Enhanced input injection

Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/
  ExtensionTests.cpp                     ← Official extension examples
  Components/PIENetworkComponentTests.cpp ← Network test examples
```

## 🙋 用户（2026/08/27 22:33:22）

Assertion Quick Reference 那个有没有其他形式的?  你给我展示几个看看? 不要markdown 列表那种的, 你现在的展示形式感觉也怪怪的, 可以 ascii 图list 的那种吗, 或者你多展示几种给我挑选下?

## 🤖 AI 助手（2026/08/27 22:33:22）

给你三种风格，挑一个喜欢的。

---

**Style A — 分组树形，带注释行**

```
ASSERT_THAT( <condition> )
│
├─ Boolean
│   ├─ IsTrue(expr)
│   └─ IsFalse(expr)
│
├─ Equality
│   ├─ AreEqual(a, b)
│   ├─ AreNotEqual(a, b)
│   ├─ AreEqualIgnoreCase(a, b)        # FString / TCHAR*
│   └─ AreNotEqualIgnoreCase(a, b)
│
├─ Numeric / Float
│   ├─ IsNear(a, b, tol)
│   ├─ IsNearlyEqual(a, b)             # default tol = UE_KINDA_SMALL_NUMBER
│   ├─ IsNearlyEqual(a, b, tol)
│   ├─ IsNotNearlyEqual(a, b)
│   └─ IsNotNearlyEqual(a, b, tol)
│
├─ UE Math Types                       # FVector / FRotator / FTransform
│   ├─ IsNearlyEqual(va, vb)
│   ├─ IsNearlyEqual(va, vb, tol)
│   ├─ IsNotNearlyEqual(va, vb)
│   └─ IsNotNearlyEqual(va, vb, tol)
│
├─ Pointer                             # raw / TSharedPtr / TUniquePtr
│   ├─ IsNull(ptr)
│   └─ IsNotNull(ptr)
│
└─ Reverse (expect failure)
    Assert.ExpectError(AnyError);
    Assert.ExpectError("specific message");
    Assert.ExpectError("message", N);   # expect N failures
```

---

**Style B — 对齐表格式，紧凑**

```
┌─────────────────────────────────────────┬──────────────────────────────┐
│  ASSERT_THAT( ... )                     │  notes                       │
├─────────────────────────────────────────┼──────────────────────────────┤
│  IsTrue(expr)                           │  bool                        │
│  IsFalse(expr)                          │  bool                        │
├─────────────────────────────────────────┼──────────────────────────────┤
│  AreEqual(a, b)                         │  any comparable type         │
│  AreNotEqual(a, b)                      │                              │
│  AreEqualIgnoreCase(a, b)               │  FString / TCHAR*            │
│  AreNotEqualIgnoreCase(a, b)            │                              │
├─────────────────────────────────────────┼──────────────────────────────┤
│  IsNear(a, b, tol)                      │  float / double              │
│  IsNearlyEqual(a, b)                    │  tol = UE_KINDA_SMALL_NUMBER │
│  IsNearlyEqual(a, b, tol)               │                              │
│  IsNotNearlyEqual(a, b)                 │                              │
│  IsNotNearlyEqual(a, b, tol)            │                              │
├─────────────────────────────────────────┼──────────────────────────────┤
│  IsNearlyEqual(va, vb)                  │  FVector/FRotator/FTransform │
│  IsNearlyEqual(va, vb, tol)             │                              │
│  IsNotNearlyEqual(va, vb)               │                              │
│  IsNotNearlyEqual(va, vb, tol)          │                              │
├─────────────────────────────────────────┼──────────────────────────────┤
│  IsNull(ptr)                            │  raw/TSharedPtr/TUniquePtr   │
│  IsNotNull(ptr)                         │                              │
├─────────────────────────────────────────┼──────────────────────────────┤
│  Assert.ExpectError(AnyError)           │  expect next assert to fail  │
│  Assert.ExpectError("msg")              │  match specific message      │
│  Assert.ExpectError("msg", N)           │  expect N failures           │
└─────────────────────────────────────────┴──────────────────────────────┘
```

---

**Style C — 扁平带分隔线，最简洁**

```
══ ASSERT_THAT( <condition_fn> ) ══════════════════════════════════════

  [bool]
  IsTrue(expr)                IsFalse(expr)

  [equality]
  AreEqual(a, b)              AreNotEqual(a, b)
  AreEqualIgnoreCase(a, b)    AreNotEqualIgnoreCase(a, b)

  [float / double]
  IsNear(a, b, tol)
  IsNearlyEqual(a, b)         IsNearlyEqual(a, b, tol)
  IsNotNearlyEqual(a, b)      IsNotNearlyEqual(a, b, tol)

  [UE math — FVector / FRotator / FTransform]
  IsNearlyEqual(va, vb)       IsNearlyEqual(va, vb, tol)
  IsNotNearlyEqual(va, vb)    IsNotNearlyEqual(va, vb, tol)

  [pointer — raw / TSharedPtr / TUniquePtr]
  IsNull(ptr)                 IsNotNull(ptr)

  [reverse — expect the next assertion to fail]
  Assert.ExpectError(AnyError)
  Assert.ExpectError("message")
  Assert.ExpectError("message", N)

═══════════════════════════════════════════════════════════════════════
```

---

Style A 适合放进 README，层次清晰；Style B 适合打印或贴墙；Style C 最紧凑，适合嵌在 skill prompt 里。

## 🙋 用户（2026/08/27 22:36:09）

在给我一个中文的skill 出来

## 🤖 AI 助手（2026/08/27 22:36:09）

# UE CQTest — 开发指南

## 概述

CQTest 是 UE5 内置的 C++ 自动化测试框架（`Engine/Source/Developer/CQTest`），UE 5.5 起升级为 Engine Module，无需单独启用插件。核心设计目标：

- **状态隔离** — 每个 `TEST_METHOD` 执行前重新构造测试对象，成员变量自动归零
- **独立生命周期钩子** — `BEFORE_EACH` / `AFTER_EACH` 围绕每个方法单独执行，而非整个类
- **组合优于继承** — 测试环境能力通过持有 Test Component 成员变量来添加
- **让简单的事情简单** — 最小测试 = 一个宏 + 一个断言

---

## 宏选择速查

```
单个无状态测试
  └─ TEST(测试名, "路径.分组") { ... }

多方法共享 fixture 状态
  └─ TEST_CLASS(类名, "路径.分组") { ... }

指定运行上下文 / flag
  └─ TEST_CLASS_WITH_FLAGS(类名, "路径", EAutomationTestFlags::...)

跨多个测试类共享基类逻辑
  └─ TEST_CLASS_WITH_BASE(类名, "路径", TMyBase)

自定义断言器（领域语义断言）
  └─ TEST_CLASS_WITH_ASSERTS(类名, "路径", FMyAsserter)

网络仿真（Server + N 个 Client PIE）
  └─ NETWORK_TEST_CLASS(类名, "路径")
```

组合变体规律：
`TEST_CLASS_WITH_BASE_AND_FLAGS` / `TEST_CLASS_WITH_BASE_AND_TAGS` /
`TEST_CLASS_WITH_BASE_AND_FLAGS_AND_TAGS` / `TEST_CLASS_WITH_ASSERTS_AND_TAGS` 等。

---

## 生命周期执行顺序

```
[程序启动]  静态初始化
              → FFunctionRegistrar 将所有 TEST_METHOD 写入 Methods 表
              → TTestRunner 向 FAutomationTestFramework 注册测试类

[触发运行]
  BEFORE_ALL()              ← 整个类只调用一次（可选，static）
  │
  ├─ 每个 TEST_METHOD 循环:
  │    new DerivedClass()         ← 重新构造，所有成员归零
  │    BEFORE_EACH()              ← flush 延迟命令
  │    TEST_METHOD 方法体         ← flush 延迟命令
  │    AFTER_EACH()               ← 即使方法内有断言失败也执行
  │    ~DerivedClass()            ← OnTearDown 回调逆序执行
  │
  └─ AFTER_ALL()            ← 所有方法完成后调用一次（可选，static）
```

---

## 断言速查

所有断言形式均为 `ASSERT_THAT(<条件函数>)`。
断言失败时记录错误并提前 return，不依赖 C++ 异常，跨平台兼容。

```
ASSERT_THAT( <条件函数> )
│
├─ 布尔
│   ├─ IsTrue(expr)
│   └─ IsFalse(expr)
│
├─ 相等 / 不等
│   ├─ AreEqual(a, b)
│   ├─ AreNotEqual(a, b)
│   ├─ AreEqualIgnoreCase(a, b)         # FString / TCHAR*
│   └─ AreNotEqualIgnoreCase(a, b)
│
├─ 浮点近似
│   ├─ IsNear(a, b, tol)
│   ├─ IsNearlyEqual(a, b)              # 默认容差 UE_KINDA_SMALL_NUMBER
│   ├─ IsNearlyEqual(a, b, tol)
│   ├─ IsNotNearlyEqual(a, b)
│   └─ IsNotNearlyEqual(a, b, tol)
│
├─ UE 数学类型                           # FVector / FRotator / FTransform
│   ├─ IsNearlyEqual(va, vb)
│   ├─ IsNearlyEqual(va, vb, tol)
│   ├─ IsNotNearlyEqual(va, vb)
│   └─ IsNotNearlyEqual(va, vb, tol)
│
├─ 指针 / 智能指针                        # raw / TSharedPtr / TUniquePtr
│   ├─ IsNull(ptr)
│   └─ IsNotNull(ptr)
│
└─ 反向断言（期待某断言必须失败）
    Assert.ExpectError(AnyError);
    Assert.ExpectError("具体错误消息");
    Assert.ExpectError("消息", N);       # 期待 N 次失败
```

---

## 异步 / 延迟命令

当测试逻辑跨帧或需要轮询等待时，使用 `TestCommandBuilder` 链式 API。

```cpp
TEST_METHOD(MyAsyncFeature_ShouldComplete)
{
    TestCommandBuilder
        .Do([this]()    { /* 触发异步操作 */ })
        .Until([this]() { return /* 轮询条件 */; })  // 优先用 Until 代替 WaitDelay
        .Then([this]() { ASSERT_THAT(IsTrue(/* 结果验证 */)); })
        .OnTearDown([this]() { /* 清理，逆序执行 */ });
}
```

| API | 行为 |
|-----|------|
| `.Do(lambda)` | 执行一次 |
| `.Until(predicate)` | 每帧轮询，直到返回 `true` |
| `.WaitDelay(duration)` | 固定时间等待（有不稳定风险，优先用 Until） |
| `.DoAsync(lambda)` | 在后台线程执行 |
| `.OnTearDown(lambda)` | 清理回调，逆序触发 |

---

## 测试组件选择

将组件作为测试类的成员变量持有，随测试对象一起重新构造和销毁。

```
需要生成 Actor / UObject，不需要真实关卡？
  └─ FActorTestSpawner Spawner;
       Spawner.SpawnActor<AMyActor>();
       Spawner.SpawnObject<UMyData>();

需要真实关卡（NavMesh / GameMode / 地形）？
  └─ TUniquePtr<FMapTestSpawner> Map;
       // 加载已有地图
       BEFORE_EACH() { Map = MakeUnique<FMapTestSpawner>(TEXT("/Game/Maps"), TEXT("TestMap")); }
       // 创建临时空关卡
       BEFORE_EACH() { Map = FMapTestSpawner::CreateFromTempLevel(TestCommandBuilder); }
       // ⚠ 等待关卡加载必须在 TEST_METHOD 内调用，不能在 BEFORE_EACH 中：
       Map->AddWaitUntilLoadedCommand(TestRunner);

需要 Server + N 个 Client PIE 网络仿真？
  └─ NETWORK_TEST_CLASS + FPIENetworkComponent<MyState>
       FNetworkComponentBuilder<MyState>()
           .WithClients(2).WithGameMode(...).Build(Network);
       Network.ThenServer(...).ThenClients(...).SpawnAndReplicate<AActor, &State::Ptr>();

需要向玩家注入输入（EnhancedInput）？
  └─ FInputTestActions（需启用 CQTestEnhancedInput 插件，仅限 EditorContext）
       FInputTestActions Input(Pawn);
       Input.PerformAction(MoveAction);

需要等待 Slate UI 刷新？
  └─ FCQTestSlateComponent Slate;
       TestCommandBuilder.Until([this]() { return Slate.HaveTicksElapsed(2); });
```

---

## 框架扩展方向

**1. 自定义断言器** — 为业务领域添加语义化断言方法

```cpp
struct FMyAsserter : public FNoDiscardAsserter {
    FMyAsserter(FAutomationTestBase& TR) : FNoDiscardAsserter(TR) {}
    bool IsValidHealth(int32 HP) {
        return AddErrorIfFalse(HP >= 0 && HP <= 100,
            FString::Printf(TEXT("血量 %d 超出范围 [0,100]"), HP));
    }
};
#define MY_TEST(Name, Dir) TEST_CLASS_WITH_ASSERTS(Name, Dir, FMyAsserter)
```

**2. 自定义基类** — 在多个测试类之间共享成员变量、辅助方法、生命周期钩子

```cpp
template<typename Derived, typename AsserterType>
struct TMyBase : public TTest<Derived, AsserterType> {
    inline static UMySubsystem* Sys = nullptr;
    BEFORE_ALL() { Sys = GEngine->GetEngineSubsystem<UMySubsystem>(); }
    AFTER_ALL()  { Sys = nullptr; }
    void AssertSysReady() { ASSERT_THAT(IsNotNull(Sys)); }
};
#define MY_TEST(Name, Dir) TEST_CLASS_WITH_BASE(Name, Dir, TMyBase)

// 派生类也有 BEFORE_ALL 时，必须手动链式调用基类：
BEFORE_ALL() {
    TMyBase::BeforeAll(FString());  // 手动调用基类
    // ... 派生类自己的初始化 ...
}
```

**3. bInitializing 构造函数守卫** — 区分程序启动注册阶段与测试实际运行阶段

```cpp
TMyBase() {
    if (this->bInitializing) {
        // 注册阶段：插件可能未加载，不能访问 World / 资产 / 子系统
    } else {
        // 运行阶段：可以安全访问引擎运行时资源
        CachedObj = CQTestAssetHelper::FindDataBlueprint(TEXT("B_MyAsset"));
    }
}
```

---

## 资产查询助手（仅限 EditorContext）

替代 UE 5.5 已废弃的 `FCQTestBlueprintHelper`。

```cpp
FARFilter Filter = CQTestAssetHelper::FAssetFilterBuilder()
    .WithPackagePath(TEXT("/Game/Data"))
    .Build();

UClass*  Cls  = CQTestAssetHelper::GetBlueprintClass(Filter, TEXT("BP_MyChar"));
UObject* Data = CQTestAssetHelper::FindDataBlueprint(Filter, TEXT("DA_Config"));

ASSERT_THAT(IsNotNull(Cls));
ASSERT_THAT(IsNotNull(Data));
```

需要 `EAutomationTestFlags::EditorContext`。若在构造函数中调用，必须先判断 `bInitializing == false`。

---

## 运行测试

**编辑器内：**
`Window → Test Automation`，按路径前缀过滤（如 `Game.`），点击 `Start Tests`。

**命令行（CI / 无头模式）：**
```bash
UnrealEditor-Cmd.exe MyProject.uproject \
  -ExecCmds="Automation RunTests Game.MyFeature" \
  -unattended -nullrhi -nosplash \
  -ReportOutputPath="./TestResults"
```

默认 flags：`EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::ProductFilter`

---

## 核心文件位置

```
Engine/Source/Developer/CQTest/
  Public/CQTest.h                         ← TTest / TTestRunner / TBaseTest
  Public/Components/
    SpawnHelper.h                         ← SpawnActor<T> / SpawnObject<T>
    ActorTestSpawner.h                    ← 最小 UWorld 生成器
    MapTestSpawner.h                      ← PIE 关卡生成器
    PIENetworkComponent.h                 ← Server + Client PIE 网络组件
    CQTestSlateComponent.h                ← Slate tick 计数器
  Public/Helpers/
    CQTestAssetHelper.h                   ← 资产 / 蓝图查询（5.5+）
  README.md                               ← 官方文档

Engine/Plugins/Tests/CQTestEnhancedInput/
  Public/Components/InputTestActions.h    ← Enhanced Input 注入

Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/
  ExtensionTests.cpp                      ← 官方扩展示例
  Components/PIENetworkComponentTests.cpp ← 网络测试示例
```

## 🙋 用户（2026/08/28 19:54:37）

看看还有什么遗漏的cqtest 相关的知识点吗

## 🤖 AI 助手（2026/08/28 19:54:37）

让我去检索一下可能遗漏的部分。
基于之前的检索结果，以下是 CQTest 中几个被遗漏的知识点。

---

## 遗漏的 CQTest 知识点

### 1. 超时配置系统（UCQTestSettings）

之前的 Skill 中只提到了 CVar 名字，但完整的配置体系远不止于此。[[1]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTestSettings.h)

**三个超时 CVar：**

```
TestFramework.CQTest.CommandTimeout         ← 普通命令链超时（默认 30s）
TestFramework.CQTest.CommandTimeout.Network ← 网络测试超时（默认 120s）
TestFramework.CQTest.CommandTimeout.MapTest ← 地图加载测试超时（默认 120s）
```

**ini 配置**（持久化到项目配置文件）：

```ini
; Config/DefaultEngine.ini
[/Script/CQTest.CQTestSettings]
CommandTimeout=30.0
NetworkTimeout=120.0
MapTestTimeout=120.0
```

编辑器路径：`Project Settings → Engine → CQ Test Settings`

**运行时动态修改超时（`SetTestClassTimeouts`）：**[[1]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTestSettings.h)

```cpp
// 临时修改超时，TSharedPtr 析构时自动恢复原值
auto ScopedTimeout = UCQTestSettings::SetTestClassTimeouts(FTimespan::FromSeconds(60.0));

TestCommandBuilder
    .Until([this]() { return SlowOperationDone(); })
    .Then([this]() { /* ... */ });

// ScopedTimeout 离开作用域 → 超时恢复
```

这是"以 RAII 控制测试环境"的典型用法，适合需要特殊超时的单个测试用例。

---

### 2. TestCommandBuilder 的 `.StartWhen()`（之前 Skill 遗漏）

之前整理的命令链 API 表中只有 `Until`，但还有语义不同的 `StartWhen`：[[2]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/CQTestSlateComponentTests.cpp)

```
Until(pred)      ← 阻塞直到 pred 为 true，超时则测试失败
StartWhen(pred)  ← 等待 pred 为 true 后继续，不算进超时
```

`StartWhen` 用于"等待前置条件就绪"而不想把等待时间算作测试超时的场景：

```cpp
TestCommandBuilder
    .StartWhen([this]() { return SlateComponent->HaveTicksElapsed(3); })
    .Then([this]() {
        ASSERT_THAT(IsTrue(SlateComponent->GetTotalElapsedTicks() >= 3));
    });
```

典型使用场景：等待 Widget 渲染完成、等待异步初始化、等待网络连接建立后再开始计时。

---

### 3. FPIENetworkComponent 被遗漏的 API

之前 Skill 中 `ThenClients / UntilClients` 只列出了"所有 client"版本，实际还有**单 client 精确操作**和 **SpawnAndReplicate** 系列：[[3]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/PIENetworkComponent.h)

**单 Client 操作（按 Index 定位）：**

```cpp
// 对第 N 个 client 执行操作
ThenClient(int32 ClientIndex, TFunction<void(NetworkDataType&)> Action)

// 等待第 N 个 client 满足条件
UntilClient(int32 ClientIndex, TFunction<bool(NetworkDataType&)> Query,
            TOptional<FTimespan> Timeout = CQTest::DefaultTimeout)
```

**SpawnAndReplicate 四个重载：**

```cpp
// 1. 基本版：在服务端 Spawn Actor，等待同步到所有 Client
SpawnAndReplicate<ActorType, &StateType::ActorPtr>()

// 2. 带 SpawnParameters
SpawnAndReplicate<ActorType, &StateType::ActorPtr>(FActorSpawnParameters Params)

// 3. 带 BeforeReplicate 回调（Spawn 后、同步前执行）
SpawnAndReplicate<ActorType, &StateType::ActorPtr>(
    TFunction<void(ActorType*)> BeforeReplicate)

// 4. 两者都带
SpawnAndReplicate<ActorType, &StateType::ActorPtr>(
    FActorSpawnParameters Params,
    TFunction<void(ActorType*)> BeforeReplicate)
```

`BeforeReplicate` 回调适合"Spawn 后设置初始属性再让客户端收到同步数据"的场景。

**ThenClientJoins：**

```cpp
// 等待一个新 Client 完成 Join（超时可配置）
ThenClientJoins(TOptional<FTimespan> Timeout = CQTest::DefaultTimeout)
```

---

### 4. AddError / AddWarning / AddInfo（直接日志方法）

这三个方法来自 `TBaseTest`，和断言不同——**不触发提前 return，只写入日志**：[[4]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h)

```cpp
// 记录错误（会导致测试最终失败，但不立即中断）
AddError(TEXT("Expected actor to be valid"));

// 记录警告（不影响测试通过/失败判定）
AddWarning(TEXT("Fallback path was taken"));

// 记录信息（纯日志）
AddInfo(TEXT("Actor spawned at position X"));

// 有条件记录错误（返回 bool，可用于手动控制流程）
bool bOk = AddErrorIfFalse(SomeCondition(), TEXT("Condition failed"));
```

与 `ASSERT_THAT` 的区别：

```
ASSERT_THAT(IsTrue(x))  → 失败时立即 return，方法后续代码不执行
AddError(...)           → 失败信息写入报告，但继续执行后续逻辑
```

适合"需要收集多个失败点后统一报告"的场景。

---

### 5. Lyra ShooterTests：FPIENetworkComponent 的真实扩展示例

`Samples/Games/Lyra` 项目中的 `FShooterTestsNetworkComponent` 展示了如何基于 `FPIENetworkComponent` 做项目级定制：[[5]](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Samples/Games/Lyra/Plugins/GameFeatures/ShooterTests/Source/ShooterTests/Public/ShooterTestsNetworkComponent.h)

```cpp
// 自定义 State 携带游戏特有数据
struct FShooterTestsNetworkComponentState : FBasePIENetworkComponentState {
    APlayerController* ServerPlayerController{ nullptr };
    APlayerController* ClientPlayerController{ nullptr };
};

// 继承 FPIENetworkComponent，添加游戏特有等待逻辑
class FShooterTestsNetworkComponent
    : public FPIENetworkComponent<FShooterTestsNetworkComponentState> {
public:
    // 封装"等待 Server 玩家 Spawn 完成"的复合命令链
    FShooterTestsNetworkComponent& PrepareAndWaitForServerPlayerSpawn();

    // 封装"等待 Client 玩家 Spawn 完成"的复合命令链
    FShooterTestsNetworkComponent& PrepareAndWaitForClientPlayerSpawn();
};
```

这个模式值得注意：**将多步 Until/Then 复合逻辑封装成一个语义方法**，测试代码从：

```cpp
Network
    .ThenServer([](auto& s){ /* 设置 ... */ })
    .UntilServer([](auto& s){ return s.ServerPlayerController != nullptr; })
    .ThenClient(0, [](auto& s){ /* 设置 ... */ })
    .UntilClient(0, [](auto& s){ return s.ClientPlayerController != nullptr; })
```

简化为：

```cpp
Network
    .PrepareAndWaitForServerPlayerSpawn()
    .PrepareAndWaitForClientPlayerSpawn()
```

---

**参考来源**

[1]. [Engine/Source/Developer/CQTest/Public/CQTestSettings.h#UCQTestSettings](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTestSettings.h)

[2]. [Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/CQTestSlateComponentTests.cpp#StartWhen usage](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Plugins/Tests/CQTest/Source/CQTestTests/Private/Components/CQTestSlateComponentTests.cpp)

[3]. [Engine/Source/Developer/CQTest/Public/Components/PIENetworkComponent.h#FPIENetworkComponent](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/Components/PIENetworkComponent.h)

[4]. [Engine/Source/Developer/CQTest/Public/CQTest.h#TBaseTest](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Engine/Source/Developer/CQTest/Public/CQTest.h)

[5]. [Samples/Games/Lyra/Plugins/GameFeatures/ShooterTests/Source/ShooterTests/Public/ShooterTestsNetworkComponent.h#FShooterTestsNetworkComponent](https://git.woa.com/UnrealEngine/UnrealEngine/blob/ue5-main/Samples/Games/Lyra/Plugins/GameFeatures/ShooterTests/Source/ShooterTests/Public/ShooterTestsNetworkComponent.h)

## 🙋 用户（2026/08/28 20:03:20）


2026/08/27 22:30:35
任务规划完成
Here is a complete English skill guide for UE CQTest, organized as a reference card you can paste directly into a prompt or wiki.

UE CQTest — Developer Guide
Overview
CQTest is UE5's built-in C++ automation test framework (Engine/Source/Developer/CQTest), promoted to an Engine Module in UE 5.5. Its core design goals are:

State isolation — re-construct the test object before every TEST_METHOD, so member variables are automatically reset.

Per-method lifecycle hooks — BEFORE_EACH / AFTER_EACH run around every individual method, not just once per class.

Composition over inheritance — environment capabilities are added by holding Test Component members, not by sub-classing.

Make easy things easy — a minimal test is a single macro + a single assertion.

Quick-Start: Macro Selection
Single stateless test
  └─ TEST(TestName, "Path.Dir") { ... }

Multiple methods sharing fixture state
  └─ TEST_CLASS(ClassName, "Path.Dir") { ... }

Custom test flags (e.g. EditorContext only)
  └─ TEST_CLASS_WITH_FLAGS(ClassName, "Path.Dir", EAutomationTestFlags::...)

Shared base class across multiple test classes
  └─ TEST_CLASS_WITH_BASE(ClassName, "Path.Dir", TMyBase)

Custom asserter for domain-specific assertions
  └─ TEST_CLASS_WITH_ASSERTS(ClassName, "Path.Dir", FMyAsserter)

Network simulation (Server + N Clients in PIE)
  └─ NETWORK_TEST_CLASS(ClassName, "Path.Dir")
Combination variants follow the pattern:
TEST_CLASS_WITH_BASE_AND_FLAGS, TEST_CLASS_WITH_BASE_AND_TAGS, TEST_CLASS_WITH_BASE_AND_FLAGS_AND_TAGS, TEST_CLASS_WITH_ASSERTS_AND_TAGS, etc.

Lifecycle Order
[Program Start]  static init → FFunctionRegistrar registers all TEST_METHODs into Methods table
                              → TTestRunner registers class into FAutomationTestFramework

[Run Tests]
  BEFORE_ALL()           ← called once for the entire class (optional, static)
  │
  ├─ for each TEST_METHOD:
  │    new DerivedClass()          ← fresh instance, all members reset to defaults
  │    BEFORE_EACH()               ← flush latent commands
  │    TEST_METHOD body            ← flush latent commands
  │    AFTER_EACH()                ← runs even if test method failed
  │    ~DerivedClass()             ← OnTearDown callbacks fire in reverse order
  │
  └─ AFTER_ALL()          ← called once after all methods complete (optional, static)
Assertion Quick Reference
All assertions are called as ASSERT_THAT(<condition_fn>).
Failure records an error and early-returns from the current phase (no C++ exception).

// Boolean
ASSERT_THAT(IsTrue(expr))
ASSERT_THAT(IsFalse(expr))


宏选择速查,还是用原来第 这个形式吧, 只不过expr 什么的感觉不是很ue 啊, 可能需要首字母大写这样

## 🤖 AI 助手（2026/08/28 20:03:20）

明白，保持 Style A 树形格式，占位符改成 UE 风格的 PascalCase。

```
ASSERT_THAT( <ConditionFn> )
│
├─ Boolean
│   ├─ IsTrue(bCondition)
│   └─ IsFalse(bCondition)
│
├─ Equality
│   ├─ AreEqual(Expected, Actual)
│   ├─ AreNotEqual(Expected, Actual)
│   ├─ AreEqualIgnoreCase(ExpectedStr, ActualStr)     # FString / TCHAR*
│   └─ AreNotEqualIgnoreCase(ExpectedStr, ActualStr)
│
├─ Numeric / Float
│   ├─ IsNear(Expected, Actual, Tolerance)
│   ├─ IsNearlyEqual(Expected, Actual)                # default = UE_KINDA_SMALL_NUMBER
│   ├─ IsNearlyEqual(Expected, Actual, Tolerance)
│   ├─ IsNotNearlyEqual(Expected, Actual)
│   └─ IsNotNearlyEqual(Expected, Actual, Tolerance)
│
├─ UE Math Types                                      # FVector / FRotator / FTransform
│   ├─ IsNearlyEqual(ExpectedVec, ActualVec)
│   ├─ IsNearlyEqual(ExpectedVec, ActualVec, Tolerance)
│   ├─ IsNotNearlyEqual(ExpectedVec, ActualVec)
│   └─ IsNotNearlyEqual(ExpectedVec, ActualVec, Tolerance)
│
├─ Pointer                                            # raw / TSharedPtr / TUniquePtr
│   ├─ IsNull(TargetPtr)
│   └─ IsNotNull(TargetPtr)
│
└─ Reverse (expect the next assertion to fail)
    Assert.ExpectError(AnyError);
    Assert.ExpectError(TEXT("ExpectedMessage"));
    Assert.ExpectError(TEXT("ExpectedMessage"), NumExpectedFailures);
```

## 🙋 用户（2026/08/28 20:04:14）

FPIENetworkComponent  这个你再给我总结一个案例, 和这个的抽象的模式 

## 🤖 AI 助手（2026/08/28 20:04:14）

先检索一下 `FPIENetworkComponent` 的官方测试用例，给你一个有实质内容的示例。
好的，基于已掌握的完整信息，直接输出。

---

## FPIENetworkComponent 抽象模式与使用案例

### 三层架构

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 1 · State  数据层（每端独立实例）                          │
│                                                                  │
│  FBasePIENetworkComponentState                                   │
│    └─ UWorld* World                                              │
│         ↑ 派生                                                   │
│  struct FYourNetworkState : FBasePIENetworkComponentState {      │
│    AYourActor* ServerActor = nullptr;   ← Server 端业务数据      │
│    AYourActor* ClientActor = nullptr;   ← Client 端业务数据      │
│    int32       SharedCounter = 0;                                │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
           │ StateType 作为模板参数向上传递
           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Layer 2 · Component  操作层                                     │
│                                                                  │
│  FPIENetworkComponent<FYourNetworkState>  Network               │
│                                                                  │
│  命令链 API（返回 *this，可无限链式）                              │
│  ├─ ThenServer(Label, [](FYourNetworkState& S){...})             │
│  ├─ ThenClients(Label, [](FYourNetworkState& S){...})            │
│  ├─ ThenClient(Index, Label, [](FYourNetworkState& S){...})      │
│  ├─ UntilServer(Label, [](FYourNetworkState& S)->bool{...}, T)   │
│  ├─ UntilClients(Label, [](FYourNetworkState& S)->bool{...}, T)  │
│  ├─ UntilClient(Idx, Label, [](FYourNetworkState& S)->bool{}, T) │
│  ├─ SpawnAndReplicate<AActor, &State::Ptr>(Label, Class, T)      │
│  └─ ThenClientJoins(Label, JoinedCb, JoiningCb)                 │
└─────────────────────────────────────────────────────────────────┘
           │ Build(Network) 注入配置
           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Layer 3 · Builder  配置层（BEFORE_EACH 中构造）                  │
│                                                                  │
│  FNetworkComponentBuilder<FYourNetworkState>()                   │
│    .WithClients(2)                 ← Client 数量，默认 2          │
│    .AsDedicatedServer()            ← 或 .AsListenServer()        │
│    .WithGameMode(AYourGameMode::StaticClass())                   │
│    .WithPacketSimulationSettings(&PacketSettings)                │
│    .Build(Network);                ← 触发内部启动命令链写入        │
└─────────────────────────────────────────────────────────────────┘
```

### 内部启动流程（Builder.Build 触发后自动执行）

```
Build(Network)
  │
  ├─ Do      "Stop PIE"              StopPie()
  ├─ Then    "Create New Map"        FAutomationEditorCommonUtils::CreateNewMap()
  ├─ Then    "Start PIE"             StartPie()
  ├─ Until   "Set Worlds"            SetWorlds()        ← 等待所有 PIE World 就绪
  ├─ Then    "Setup Packet Settings" SetPacketSettings()
  ├─ Then    "Connect Clients"       ConnectClientsToServer()
  ├─ Until   "Await Clients Ready"   AwaitClientsReady()← 等待所有 Client 连入
  │
  └─ OnTearDown "Restore State"      RestoreState()     ← 自动还原编辑器状态
         ↓
  ← 此后你的 ThenServer/ThenClients 命令依次入队执行 →
```

---

### 标准使用案例

下面演示：在 PIE 网络环境中，在 Server 端 Spawn 一个 Actor，验证它在 Client 端完成复制。

```cpp
// ── State 结构体：每端各一份，互不干扰 ──────────────────────────
struct FItemNetworkState : FBasePIENetworkComponentState
{
    AItemActor* SpawnedActor = nullptr;   // Server/Client 各自填写
    bool        bReplicationVerified = false;
};

// ── 测试类 ────────────────────────────────────────────────────────
NETWORK_TEST_CLASS(FItemReplicationTest, "Game.Networking")
{
    FPIENetworkComponent<FItemNetworkState> Network{ TestCommandBuilder, Assert };

    // BEFORE_EACH：配置并启动 PIE 网络环境
    BEFORE_EACH()
    {
        FNetworkComponentBuilder<FItemNetworkState>()
            .WithClients(2)
            .AsDedicatedServer()
            .WithGameMode(AItemGameMode::StaticClass())
            .Build(Network);            // 内部自动写入启动命令链
    }

    // 用例 1：SpawnAndReplicate 快速验证 Actor 复制
    TEST_METHOD(ItemActor_SpawnOnServer_ReplicatesToAllClients)
    {
        // SpawnAndReplicate：在 Server Spawn，等待所有 Client 复制完成
        // 模板参数 <ActorClass, &StateType::成员指针>
        Network.SpawnAndReplicate<AItemActor, &FItemNetworkState::SpawnedActor>(
            TEXT("Spawn ItemActor"),
            AItemActor::StaticClass(),
            FTimespan::FromSeconds(5.0f)
        )
        .ThenServer(TEXT("Verify Server Actor valid"), [this](FItemNetworkState& State)
        {
            ASSERT_THAT(IsNotNull(State.SpawnedActor));
            ASSERT_THAT(IsTrue(State.SpawnedActor->HasAuthority()));
        })
        .ThenClients(TEXT("Verify Client Actor replicated"), [this](FItemNetworkState& State)
        {
            // 每个 Client 各自执行，State 是各自的独立副本
            ASSERT_THAT(IsNotNull(State.SpawnedActor));
            ASSERT_THAT(IsFalse(State.SpawnedActor->HasAuthority()));
        });
    }

    // 用例 2：手动命令链，验证 Server/Client State 互相独立
    TEST_METHOD(ServerAndClient_DoNotShareState)
    {
        Network
        .ThenServer(TEXT("Server writes counter"), [](FItemNetworkState& State)
        {
            State.bReplicationVerified = true;  // 只写 Server 端 State
        })
        .ThenClients(TEXT("Client counter is untouched"), [this](FItemNetworkState& State)
        {
            // Client 端 State 与 Server 端完全隔离
            ASSERT_THAT(IsFalse(State.bReplicationVerified));
        })
        .UntilServer(TEXT("Wait condition on server"), [](FItemNetworkState& State) -> bool
        {
            return State.SpawnedActor != nullptr;    // 超时则失败
        }, FTimespan::FromSeconds(10.0f))
        .ThenClient(0, TEXT("Only client[0] verifies"), [this](FItemNetworkState& State)
        {
            ASSERT_THAT(IsNotNull(State.SpawnedActor));
        });
    }

    // 用例 3：动态加入客户端
    TEST_METHOD(LateJoiningClient_ReceivesReplicatedState)
    {
        Network
        .ThenServer(TEXT("Prepare server state"), [](FItemNetworkState& State)
        {
            // 在第三个 Client 加入前做好服务端准备
        })
        .ThenClientJoins(
            TEXT("Late join client"),
            /*OnJoined=*/  [this](FItemNetworkState& JoinedState)
            {
                ASSERT_THAT(IsNotNull(JoinedState.World));
            },
            /*OnJoining=*/ [](FItemNetworkState& ExistingState)
            {
                // 原有 Client 端的视角
            }
        );
    }
};
```

---

### 高级扩展模式（项目级封装）

当你有大量测试都需要"等玩家在 Server/Client 端完全 Spawn 后才能开始测试逻辑"，把这些重复的 `Until/StartWhen/Then` 链抽成语义方法，参考 Lyra `FShooterTestsNetworkComponent` 的封装思路：

```
┌──────────────────────────────────────────────────────────────────┐
│  项目级封装思路：将重复的多步命令链收敛为单一语义方法               │
│                                                                  │
│  原始写法（每个测试都重复）：                                       │
│    Network                                                       │
│      .StartWhen("Map loaded",  [](S&){ return MapReady(S); })    │
│      .Until("Player spawned",  [](S&){ return PlayerReady(S); }) │
│      .Then("Fetch player ref", [](S&){ FetchPlayer(S); })        │
│      .Until("Pawn ready",      [](S&){ return PawnReady(S); })   │
│      .ThenServer("Your logic", ...);                             │
│                                                                  │
│  封装后（语义化方法）：                                             │
│    Network                                                       │
│      .WaitForServerPlayerSpawn()   ← 内部含上面 4 步             │
│      .WaitForClientPlayerSpawn()                                 │
│      .ThenServer("Your logic", ...);                             │
└──────────────────────────────────────────────────────────────────┘
```

```cpp
// ── 自定义 State ──────────────────────────────────────────────────
struct FGameNetworkState : FBasePIENetworkComponentState
{
    AGameCharacter* LocalPlayer = nullptr;
    bool            bPawnFullySpawned = false;
};

// ── 项目级网络组件封装 ────────────────────────────────────────────
template <typename NetworkActorType = FGameNetworkState>
class FGameNetworkComponent
{
public:
    explicit FGameNetworkComponent(FTestCommandBuilder& Builder, FAsserter& InAssert)
        : Network(Builder, InAssert), CommandBuilder(&Builder) {}

    // 配置入口：替代直接使用 FNetworkComponentBuilder
    FGameNetworkComponent& Start(TSubclassOf<AGameMode> GameMode = nullptr)
    {
        FNetworkComponentBuilder<NetworkActorType>()
            .WithClients(1)
            .AsDedicatedServer()
            .WithGameMode(GameMode)
            .Build(Network);
        return *this;
    }

    // 语义化高阶方法：封装"等 Server 端玩家完全 Spawn"的多步 Until 链
    FGameNetworkComponent& WaitForServerPlayerSpawn()
    {
        Network
        .UntilServer(TEXT("Server map loaded"),
            [](NetworkActorType& S) { return S.World && S.World->bIsWorldInitialized; },
            FTimespan::FromSeconds(30.0f))
        .UntilServer(TEXT("Server player spawned"),
            [](NetworkActorType& S) {
                S.LocalPlayer = GetLocalPlayer<AGameCharacter>(S.World);
                return S.LocalPlayer != nullptr;
            }, FTimespan::FromSeconds(15.0f))
        .UntilServer(TEXT("Server pawn fully ready"),
            [](NetworkActorType& S) { return S.LocalPlayer->IsPawnFullySpawned(); },
            FTimespan::FromSeconds(10.0f));
        return *this;
    }

    // 语义化高阶方法：封装"等 Client 端玩家完全 Spawn"
    FGameNetworkComponent& WaitForClientPlayerSpawn()
    {
        Network
        .UntilClients(TEXT("Client map loaded"),
            [](NetworkActorType& S) { return S.World && S.World->bIsWorldInitialized; },
            FTimespan::FromSeconds(30.0f))
        .UntilClients(TEXT("Client player spawned"),
            [](NetworkActorType& S) {
                S.LocalPlayer = GetLocalPlayer<AGameCharacter>(S.World);
                return S.LocalPlayer != nullptr;
            }, FTimespan::FromSeconds(15.0f));
        return *this;
    }

    // 透传底层 API，测试方法依然能直接调 ThenServer/ThenClients
    template <typename Fn>
    FGameNetworkComponent& ThenServer(const TCHAR* Label, Fn&& Func)
    { Network.ThenServer(Label, Forward<Fn>(Func)); return *this; }

    template <typename Fn>
    FGameNetworkComponent& ThenClients(const TCHAR* Label, Fn&& Func)
    { Network.ThenClients(Label, Forward<Fn>(Func)); return *this; }

private:
    FPIENetworkComponent<NetworkActorType> Network;
    FTestCommandBuilder*                   CommandBuilder;
};

// ── 使用封装后的组件编写测试 ──────────────────────────────────────
NETWORK_TEST_CLASS(FGameplayNetworkTest, "Game.Gameplay")
{
    FGameNetworkComponent<> GameNetwork{ TestCommandBuilder, Assert };

    BEFORE_EACH()
    {
        GameNetwork.Start(AMyGameMode::StaticClass());
    }

    TEST_METHOD(PlayerMovement_ReplicatesToClients)
    {
        GameNetwork
            .WaitForServerPlayerSpawn()
            .WaitForClientPlayerSpawn()
            .ThenServer(TEXT("Move player on server"), [this](FGameNetworkState& S)
            {
                S.LocalPlayer->SetActorLocation(FVector(100, 0, 0));
            })
            .ThenClients(TEXT("Verify position replicated"), [this](FGameNetworkState& S)
            {
                // Client 端验证位置已同步
                ASSERT_THAT(IsNotNull(S.LocalPlayer));
            });
    }
};
```

---

### 模式小结

```
┌───────────────┬──────────────────────────────────────────────────┐
│  关注点         │  对应设计                                         │
├───────────────┼──────────────────────────────────────────────────┤
│  State 隔离    │  Server/Client 各持一份 State 实例，互不干扰       │
│  配置与逻辑分离 │  Builder 负责环境配置，命令链负责测试逻辑            │
│  命令延迟执行   │  所有 Then/Until 都是入队，PIE 启动后顺序执行       │
│  超时语义区分   │  Until=阻塞等待（超时失败），StartWhen=前置门控      │
│  扩展方向       │  封装高频多步链为语义方法，保持测试方法简洁可读       │
└───────────────┴──────────────────────────────────────────────────┘
```
