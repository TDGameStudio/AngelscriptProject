# UE CQTest Guide & Reference

> Every fact in this document has been verified line-by-line against the local UE 5.8 engine
> source (`Engine/Source/Developer/CQTest`). It covers both the underlying mechanics
> (macro expansion, registration, execution timeline) and practical usage (templates,
> assertions, components, extension points). Corrections against older/online material
> are listed at the end.

---

## 1. Positioning & Design Philosophy

CQTest (Code Quality Test) is UE5's built-in C++ automation test framework. Since UE 5.5 it is an Engine Module (`Engine/Source/Developer/CQTest`) — no plugin to enable; just add `"CQTest"` to your `Build.cs` dependencies.

It addresses two pain points of the existing UE test styles:

- `IMPLEMENT_SIMPLE_AUTOMATION_TEST`: a single `RunTest` entry point, no before/after hooks, multiple scenarios pile up in one function, high risk of state pollution.
- Spec Tests (BDD style): `Describe`/`It` lambda-capture scoping is a notorious trap, and state is never reset automatically.

```
┌──────────────────────────────────────────────────────────────┐
│                 CQTest — three core philosophies             │
├──────────────────────────────────────────────────────────────┤
│  1. Atomicity                                                │
│     The test object is re-constructed before every           │
│     TEST_METHOD → members reset automatically,               │
│     tests are fully isolated from each other                 │
│                                                              │
│  2. Composition over Inheritance                             │
│     Environment capabilities are added by holding            │
│     Test Component member variables,                         │
│     not by forcing users through layered base classes        │
│                                                              │
│  3. Make easy things easy                                    │
│     Minimal test = one macro + one assertion                 │
│     Complex scenarios grow incrementally via                 │
│     WITH_BASE / WITH_ASSERTS combination macros              │
└──────────────────────────────────────────────────────────────┘
```

Assertion philosophy: C++ exception support varies across platforms, so CQTest uses `[[nodiscard]] bool` return values plus an early-return `ASSERT_THAT` macro — cross-platform safety with good ergonomics.

### Where CQTest sits in the UE testing landscape

```
Fast ◄──────────────────────────────────────────► High fidelity

 LowLevel Tests        CQTest              Gauntlet
  (Catch2)         (FAutomationTestBase    (RunUAT / multi-machine)
     │              extension, in-editor)      │
  Pure C++, no engine   Needs engine modules   Needs full builds
  Milliseconds          Seconds, latent-aware  Minutes
  Unit tests            Functional/integration End-to-end tests
```

CQTest's sweet spot: functional/integration testing of engine-side C++ — unit logic, Actor lifecycles, network replication, UI responses, etc.

---

## 2. Quick Start

```cpp
#include "CQTest.h"

// Simplest form: a single stateless test
TEST(MySimpleTest, "Game.MyModule")
{
    ASSERT_THAT(IsTrue(1 + 1 == 2));
}

// With fixture: multiple methods sharing setup, state isolated automatically
TEST_CLASS(MyFixtureTests, "Game.MyModule")
{
    int32 Counter = 0;                       // reset to 0 before every TEST_METHOD

    BEFORE_EACH() { Counter = 10; }
    AFTER_EACH()  { /* runs even if an assertion failed */ }

    TEST_METHOD(Increment_FromTen_IsEleven)
    {
        Counter++;
        ASSERT_THAT(AreEqual(11, Counter));
    }

    TEST_METHOD(Decrement_FromTen_IsNine)
    {
        Counter--;
        ASSERT_THAT(AreEqual(9, Counter));   // unaffected by the previous method
    }
};
```

Full test name = `Path.ClassName.MethodName`, e.g. `Game.MyModule.MyFixtureTests.Increment_FromTen_IsEleven`.
The path argument can be the `GenerateTestDirectory` constant (or embed `[GenerateTestDirectory]`) to derive the directory from the source file path automatically.

---

## 3. The Macro System & Its Internals

### 3.1 Macro family quick reference

```
Single stateless test              TEST(Name, "Path")
Multiple methods sharing fixture   TEST_CLASS(Name, "Path")
Custom AutomationTestFlags         TEST_CLASS_WITH_FLAGS(Name, "Path", Flags)
Custom base class                  TEST_CLASS_WITH_BASE(Name, "Path", TBase)
Custom asserter                    TEST_CLASS_WITH_ASSERTS(Name, "Path", FAsserter)
Base + asserter                    TEST_CLASS_WITH_BASE_AND_ASSERTS(Name, "Path", TBase, FAsserter)
Base + flags                       TEST_CLASS_WITH_BASE_AND_FLAGS(Name, "Path", TBase, Flags)
Filter tags                        TEST_WITH_TAGS / TEST_CLASS_WITH_TAGS / TEST_METHOD_WITH_TAGS
Combination pattern                ..._AND_FLAGS / ..._AND_TAGS / ..._AND_FLAGS_AND_TAGS
Network test (PIE Server+Clients)  NETWORK_TEST_CLASS(Name, "Path")
                                   = TEST_CLASS_WITH_FLAGS(Name, "Path",
                                         EditorContext | ProductFilter)
```

All variants converge on the lowest-level macro `_TEST_CLASS_IMPL_EXT(_ClassName, _TestDir, _BaseClass, _AsserterType, _TestFlags, _TestTags)`.

Default flags: `EAutomationTestFlags_ApplicationContextMask | EAutomationTestFlags::ProductFilter`.
The base macro contains two hard `static_assert` checks: **you must include at least one application-context flag, and exactly one filter type** (Smoke/Engine/Product/Perf/Stress/Negative). Misconfigured flags fail to compile.

### 3.2 How `TEST_CLASS` expands (the core magic)

```
TEST_CLASS(MyTest, "Game.Dir") { ... };
    │
    ▼ expands into two things:

  ┌─────────────────────────────────────────────────────────┐
  │ [1] Static runner singleton (registers with the UE      │
  │     test framework at program start)                    │
  │                                                         │
  │ struct FMyTest_Runner : TTestRunner<FNoDiscardAsserter> │
  │ { ... static_asserts validating flags ... };            │
  │ FMyTest_Runner MyTest_RunnerInstance;  ← global static  │
  │ // TTestRunner derives from FAutomationTestBase and     │
  │ // registers itself with FAutomationTestFramework       │
  └─────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────┐
  │ [2] The user fixture struct (CRTP inheritance)          │
  │                                                         │
  │ struct MyTest : TTest<MyTest, FNoDiscardAsserter>       │
  │ {                                                       │
  │     // your members, BEFORE_EACH, TEST_METHODs go here  │
  │     // TTest statics (shared by the whole class):       │
  │     //   static TMap<FString, TestMethod> Methods;      │
  │     //   static TTestRunner<...>* TestRunner;           │
  │ };                                                      │
  └─────────────────────────────────────────────────────────┘
```

`TEST_METHOD(Foo)` expands inside the struct into "member function + static self-registration object":

```cpp
// Actual macro source (verified in 5.8):
#define TEST_METHOD_WITH_TAGS(_MethodName, _TestTags)                             \
    FFunctionRegistrar reg##_MethodName{ FString(#_MethodName),                   \
        &DerivedType::_MethodName, __LINE__, _TestTags };                         \
    void _MethodName()
```

`FFunctionRegistrar` is an ordinary member, but the fixture object is constructed once while the runner is being built (`bInitializing == true`), and at that moment every registrar constructor writes its function pointer into the static `Methods` map:

```
What the FFunctionRegistrar constructor does:
    TestRunner->TestNames.Add("Foo");
    Methods.Add("Foo", &MyTest::Foo);        ← self-registration: automatic test discovery
    TestRunner->TestLineNumbers.Add("Foo", __LINE__);
    (with tags: also registers with FAutomationTestFramework's tag table)
```

### 3.3 Lifecycle macro expansion mapping

| What you write | Expands to | When it runs |
|---|---|---|
| `BEFORE_EACH() { ... }` | `virtual void Setup() override` | before each TEST_METHOD |
| `AFTER_EACH() { ... }` | `virtual void TearDown() override` | after each TEST_METHOD (even on failure) |
| `BEFORE_ALL() { ... }` | `static void BeforeAll(const FString&)` | once, before the class's first method |
| `AFTER_ALL() { ... }` | `static void AfterAll(const FString&)` | once, after the class's last method |

`BEFORE_ALL`/`AFTER_ALL` are detected at compile time with zero overhead via C++20 concepts:

```cpp
template <typename T>
concept HasBeforeAll = requires(T t) { { T::BeforeAll(FString()) }; };

TTest() {
    if constexpr (HasBeforeAll<Derived>)  { this->BeforeAllFunc = Derived::BeforeAll; }
    if constexpr (HasAfterAll<Derived>)   { this->AfterAllFunc  = Derived::AfterAll;  }
}
```

Once detected, they are attached to `FAutomationTestFramework`'s `OnEnteringTestSection` / `OnLeavingTestSection` delegates and fire when the framework enters/leaves the class's test section.

### 3.4 State isolation: the factory function

`TTestRunner` holds a factory function pointer, aimed at `TTest<Derived>::CreateTestClass`:

```cpp
static TUniquePtr<TBaseTest<AsserterType>> CreateTestClass(TTestRunner<AsserterType>& Runner)
{
    DerivedType::TestRunner = &Runner;
    return MakeUnique<DerivedType>();   // ← a brand-new instance for every TEST_METHOD
}
```

`TTestRunner::RunTest(TestName)` starts with `CurrentTestPtr = TestInstanceFactory(*this)` — **members return to their initial values, and that is the entire state-isolation implementation**.

### 3.5 Class hierarchy overview

```
FAutomationTestBase                (native UE automation base class)
        │
        └─ TTestRunner<AsserterType>       scheduler: registration/GetTests/RunTest/flags/tags
                │ (owns CurrentTestPtr by composition)
                ▼
           TBaseTest<AsserterType>          capability base: Assert member, TestCommandBuilder,
                │                           Setup/TearDown virtuals, AddError/Warning/Info
                └─ TTest<Derived, AsserterType>   ← CRTP
                        │   static Methods map + CreateTestClass factory + FFunctionRegistrar
                        └─ user test struct (generated by macro expansion)
```

---

## 4. Execution Timeline (including GC details)

```
[Program start] static initialization
  ├─ Runner static singleton constructed → registered with FAutomationTestFramework
  │    a fixture instance is created once during construction (bInitializing = true)
  │    → each FFunctionRegistrar writes its TEST_METHOD into the Methods map
  └─ bInitializing = false

[Test run] each TEST_METHOD is one independent RunTest invocation
  │
  ├─ BeforeAll()                ← fired once when entering the class's section
  │
  │   ┌────────── the four command steps of a single TEST_METHOD ─────────┐
  │   │ ① TBeforeTestCommand                                              │
  │   │     GEngine->DelayGarbageCollection()  ← no GC during the test    │
  │   │     Setup()  (BEFORE_EACH)                                        │
  │   │     flush latent commands accumulated in this phase               │
  │   │ ② TRunTestCommand                                                 │
  │   │     if Setup already produced errors → skip the method body       │
  │   │     look up Methods[Name], invoke the method body                 │
  │   │     flush latent commands                                         │
  │   │ ③ TAfterTestCommand                                               │
  │   │     TearDown()  (AFTER_EACH — runs even on failure)               │
  │   │     flush OnTearDown queue (reverse order) + latent commands      │
  │   │ ④ TTearDownRunner                                                 │
  │   │     CurrentTestPtr = nullptr  ← destruct the fixture              │
  │   │     GEngine->ForceGarbageCollection()  ← forced GC                │
  │   └───────────────────────────────────────────────────────────────────┘
  │
  └─ AfterAll()                 ← fired once when leaving the class's section
```

Key points:

- Latent commands produced in each phase are **fully flushed before entering the next phase** (implemented via `FRunSequence::Prepend` queue-jumping).
- GC is delayed during the test and forced afterwards — UObjects created in a test are neither collected mid-run nor leaked into the next test.
- `AFTER_EACH` and `OnTearDown` run even when the test failed (`ECQTestFailureBehavior::Run`).

---

## 5. The Assertion System

### 5.1 How it works

```cpp
#define ASSERT_THAT(_assertion) if (!this->Assert._assertion) { return; }
#define ASSERT_FAIL(_Msg)       this->Assert.Fail(_Msg); return;
```

`ASSERT_THAT(IsTrue(X))` is really a call to `Assert.IsTrue(X)` — `Assert` is the asserter member held by `TBaseTest` (default `FNoDiscardAsserter`). Assertion methods return `[[nodiscard]] bool`; on failure they internally `AddError` and return false, and the macro performs the early `return`, exiting the current phase (Setup / method body / TearDown are independent). No C++ exceptions — cross-platform safe.

### 5.2 Assertion quick reference (verified against UE 5.8)

```
ASSERT_THAT( <ConditionFn> )        # every method has an optional trailing FailureMessage
│
├─ Boolean
│   ├─ IsTrue(bCondition)
│   └─ IsFalse(bCondition)
│
├─ Equality / inequality (any comparable type; floats are blocked by static_assert, see below)
│   ├─ AreEqual(Expected, Actual)
│   ├─ AreNotEqual(Expected, Actual)
│   ├─ AreEqualIgnoreCase(ExpectedStr, ActualStr)      # FString
│   └─ AreNotEqualIgnoreCase(ExpectedStr, ActualStr)
│
├─ Numeric approximation (the only sanctioned way to compare floats)
│   └─ IsNear(Expected, Actual, Epsilon)
│
├─ Pointers / smart pointers (raw / TSharedPtr / TUniquePtr)
│   ├─ IsNull(TargetPtr)
│   └─ IsNotNull(TargetPtr)
│
├─ Direct failure
│   └─ ASSERT_FAIL(TEXT("Message"))                    # record error and return immediately
│
└─ Reverse assertions (declare "an error is expected next"; consumed error = test passes)
    Assert.ExpectError(TEXT("Expected message"));       # substring match (Contains)
    Assert.ExpectError(TEXT("Expected message"), N);    # expect it N times
    Assert.ExpectErrorRegex(TEXT("Pattern.*"), N);      # regex match
```

Three important facts:

1. **Never use `AreEqual` for floats** — the 5.8 source has `static_assert(!std::is_floating_point ...)` telling you to use `IsNear()`; for a deliberate exact comparison use `IsTrue(A == B)`.
2. **`IsNearlyEqual` is not an asserter method.** Those functions live in the `CQTestCondition` namespace (overloads for float/double/FVector/FRotator/FTransform, default tolerance `UE_KINDA_SMALL_NUMBER`); they are the underlying implementation of `IsNear`/`AreEqual`, and you can compose them yourself:
   `ASSERT_THAT(IsTrue(CQTestCondition::IsNearlyEqual(VecA, VecB)))`.
3. **`ExpectError` is backed by `FAutomationTestBase::AddExpectedError`** — semantics: "this error is expected to appear in the log". Useful both for testing defensive code (invalid input must raise an error) and for framework self-tests.

Failure-message readability for custom types is governed by `CQTestConvert::ToString` (`Assert/CQTestConvert.h`) — you can specialize it for your own types.

### 5.3 Beyond assertions: direct logging methods (from TBaseTest)

```
ASSERT_THAT(...)         → returns immediately on failure; subsequent code does not run
AddError(Msg)            → records an error (final verdict FAIL) but keeps executing
AddErrorIfFalse(b, Msg)  → conditional error, returns bool for manual flow control
AddWarning(Msg)          → warning; does not affect pass/fail
AddInfo(Msg)             → plain log
```

Useful for "collect several failure points, report them together" scenarios. `TestRunner.SetSuppressLogWarnings()` / `SetSuppressLogErrors()` control log-suppression behavior.

---

## 6. Latent Commands (TestCommandBuilder)

Many engine operations span frames (level loading, waiting for replication, UI refreshes) and cannot be asserted synchronously. `TestCommandBuilder` is a built-in member of `TBaseTest` providing a chained command queue; every API has an overload with a `Description` first parameter (logged — strongly recommended for network/map tests).

```cpp
TEST_METHOD(AsyncFeature_WhenTriggered_Completes)
{
    TestCommandBuilder
        .Do(TEXT("Trigger operation"), [this]() { /* start async operation */ })
        .Until(TEXT("Wait complete"), [this]() { return /* polling condition */; })
        .Then([this]() { ASSERT_THAT(IsTrue(/* verify result */)); })
        .OnTearDown([this]() { /* cleanup, reverse order */ });
}
```

| API | Behavior |
|-----|----------|
| `.Do(Fn)` / `.Then(Fn)` | Execute once (`Then` is an alias of `Do` for chain readability) |
| `.Until(Pred, Timeout)` | Poll every frame until true; failure on timeout |
| `.StartWhen(Pred, Timeout)` | Alias of `Until`, semantically a "precondition gate" |
| `.WaitDelay(Timespan)` | Fixed-time wait (official comment warns of flakiness — prefer `Until`) |
| `.DoAsync<T>(Fn, [ResultCb], Timeout)` | Run `TAsyncResult<T>` on a background thread, optional result callback |
| `.ThenAsync<T>(...)` | Alias of `DoAsync` |
| `.UntilAsync<T>(Fn, Pred, T1, T2)` | Async execution + polling predicate on the result |
| `.OnTearDown(Fn)` / `.CleanUpWith(Fn)` | Cleanup callbacks, executed in **reverse** order, run even on failure |

Mechanics and constraints:

- At the end of each phase (Setup / method body / TearDown) the queue is `Build()`-ed into an `FRunSequence` and enqueued into the UE latent system; it is fully flushed before the next phase starts.
- Once `TestRunner.HasAnyErrors()` is true, subsequently enqueued commands are skipped (fast error short-circuit).
- **You cannot add latent commands from inside a latent command** — the destructor's `checkf(CommandQueue.IsEmpty(), ...)` will trip.
- For lower-level control, `AddCommand(IAutomationLatentCommand*)` enqueues a custom command directly.

### Timeout configuration (UCQTestSettings)

```
CVar                                            5.8 default
TestFramework.CQTest.CommandTimeout             10s   ← ordinary commands such as Until
TestFramework.CQTest.CommandTimeout.Network     30s   ← PIENetworkComponent
TestFramework.CQTest.CommandTimeout.MapTest     30s   ← waiting for map loads
```

- ini persistence: the `[/Script/CQTest.CQTestSettings]` section of `Config/DefaultEngine.ini` (`CommandTimeout=` / `NetworkTimeout=` / `MapTestTimeout=`); editor path `Project Settings → Engine → CQ Test Settings`.
- Temporary per-test timeout override (RAII, restored when the scope ends):

```cpp
TSharedPtr<FScopedTestEnvironment> ScopedTimeout =
    UCQTestSettings::SetTestClassTimeouts(FTimespan::FromSeconds(60.0));
```

---

## 7. Test Components

Components are held as member variables and are rebuilt/destroyed together with the fixture — composition over inheritance.

### Component selection cheat sheet

```
Spawn Actors/UObjects without a real level?
  └─ FActorTestSpawner                (lightest; creates a minimal UWorld)

Need a real level (NavMesh / GameMode / landscape)?
  └─ FMapTestSpawner
       ├─ existing map  → constructor + AddWaitUntilLoadedCommand
       └─ temp empty level → CreateFromTempLevel (handles the wait itself)

Need PIE network simulation with a Server + N Clients?
  └─ NETWORK_TEST_CLASS + FPIENetworkComponent<State> + FNetworkComponentBuilder

Need parameterized Actor/UObject construction by property name?
  └─ TObjectBuilder<T>                (reflective SetParam + deferred FinishSpawning)

Need to wait for Slate UI refreshes?
  └─ FCQTestSlateComponent + HaveTicksElapsed(N)

Need to simulate player input (EnhancedInput)?
  └─ FInputTestActions                (separate CQTestEnhancedInput plugin, EditorContext only)

Need to find Blueprint classes / assets by name?
  └─ CQTestAssetHelper namespace       (requires EditorContext)
```

### 7.1 FSpawnHelper (base class, not used directly)

Shared base of `FActorTestSpawner` / `FMapTestSpawner`, providing:

```cpp
ActorType&  SpawnActor<ActorType>(SpawnParams = {}, UClass* Class = nullptr);   // returns a reference, checks non-null
ActorType&  SpawnActorAt<ActorType>(Location, Rotation, ...);                   // spawn at a location
ObjectType& SpawnObject<ObjectType>();    // static_assert: must derive UObject, must not be an AActor
UWorld&     GetWorld();
```

Everything spawned is tracked and cleaned up automatically on destruction — no manual management.

### 7.2 FActorTestSpawner (lightweight test world)

Loads no level; creates a minimal internal UWorld. Ideal for Actor/component logic unit tests.

```cpp
TEST_CLASS(MyActorTests, "Game.Unit")
{
    FActorTestSpawner Spawner;                       // plain member is enough

    TEST_METHOD(Spawn_MyActor_Initializes)
    {
        AMyActor& Actor = Spawner.SpawnActor<AMyActor>();
        ASSERT_THAT(IsTrue(Actor.IsInitialized()));
    }
};
```

When you need a GameInstance/subsystems, call `Spawner.InitializeGameSubsystems()` and then `Spawner.GetGameInstance()` (`UTestGameInstance`).

### 7.3 FMapTestSpawner (real level / PIE)

```cpp
#include "Components/MapTestSpawner.h"

TEST_CLASS(MyMapTests, "Game.Integration")   // map tests usually need EditorContext flags
{
    TUniquePtr<FMapTestSpawner> Spawner;
    APawn* PlayerPawn = nullptr;

    BEFORE_EACH()
    {
        // Mode 1: load an existing map (official boilerplate places the wait command right here)
        Spawner = MakeUnique<FMapTestSpawner>(TEXT("/Game/Maps"), TEXT("TestLevel"));
        Spawner->AddWaitUntilLoadedCommand(TestRunner);
        // Mode 2: temporary empty level (wait handled internally, no AddWaitUntilLoadedCommand)
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

Note: `AddWaitUntilLoadedCommand` must be called **outside any latent command** (the body of `BEFORE_EACH` or the start of the method body is fine — never inside a `.Do(...)`); the timeout defaults to the MapTest CVar.

### 7.4 TObjectBuilder (parameterized construction)

`ObjectBuilder.h`: reflective assignment by property name + deferred construction. Great for preparing complex initial state:

```cpp
#include "ObjectBuilder.h"

// UObject: construct directly
UMyData& Data = TObjectBuilder<UMyData>()
    .SetParam(FName("MaxHealth"), 100)
    .SetParam(FName("DisplayName"), FString(TEXT("Boss")))
    .Spawn();

// Actor: pairs with a SpawnHelper via bDeferConstruction; FinishSpawning happens at Spawn()
AMyActor& Actor = TObjectBuilder<AMyActor>(Spawner)
    .SetParam(FName("bInvincible"), true)
    .AddComponentTo<UMyComponent>()
    .Spawn(SpawnTransform);
```

`SetParam` supports numeric types/bool/FName/FString/FVector/enums/UObject pointers/TObjectPtr/TArray/TSet/TMap/structs; type mismatches log an error instead of crashing. **Parameters can only be set before `Spawn()`, and Spawn can only happen once.**

### 7.5 FPIENetworkComponent (multi-endpoint network simulation)

The heaviest component: launches real PIE sessions simulating a Server + N Clients. Three layers:

```
┌────────────────────────────────────────────────────────────────┐
│ Layer 1 · State (each endpoint holds its own instance,          │
│                  never shared)                                  │
│   struct FMyState : FBasePIENetworkComponentState               │
│   { AMyActor* ReplicatedActor = nullptr; ... };                 │
│   Base provides: World / ClientConnections / ClientIndex /      │
│                  ClientCount / bIsDedicatedServer               │
├────────────────────────────────────────────────────────────────┤
│ Layer 2 · Component (chained commands, all enqueued as latent)  │
│   FPIENetworkComponent<FMyState> Network{                       │
│       TestRunner, TestCommandBuilder, bInitializing };          │
├────────────────────────────────────────────────────────────────┤
│ Layer 3 · Builder (configure and Build inside BEFORE_EACH)      │
│   FNetworkComponentBuilder<FMyState>()                          │
│       .WithClients(2)              // excluding the server      │
│       .AsDedicatedServer()         // or .AsListenServer()      │
│       .WithGameMode(AMyGameMode::StaticClass())                 │
│       .WithGameInstanceClass(FSoftClassPath(...))               │
│       .WithPacketSimulationSettings(&PacketSettings)            │
│       .Build(Network);                                          │
└────────────────────────────────────────────────────────────────┘
```

`Build` automatically enqueues the startup chain — StopPie → CreateNewMap → StartPie → wait for Worlds → apply packet settings → connect Clients → wait until ready — and registers `RestoreState` for cleanup (`FPIENetworkTestStateRestorer` restores the editor state).

Official boilerplate (from the 5.8 header):

```cpp
#include "Components/PIENetworkComponent.h"
#if ENABLE_PIE_NETWORK_TEST                       // WITH_EDITOR && automation

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

Chained API quick reference (all have `Description` overloads; Until variants take a Timeout defaulting to the Network CVar):

```
Endpoint                        API
──────────────────────────────────────────────────────────────
One step on the server          .ThenServer([](State&){...})
One step on every client        .ThenClients([](State&){...})
One step on client[i]           .ThenClient(i, [](State&){...})
Wait for a server condition     .UntilServer([](State&)->bool{...}, Timeout)
Wait for all client conditions  .UntilClients(...)
Wait for client[i] condition    .UntilClient(i, ...)
Late-join a new client          .ThenClientJoins(Timeout)
Spawn on server + replicate     .SpawnAndReplicate<AActor, &State::Ptr>()
                                  overloads: (SpawnParams) / (BeforeReplicateFn) / (both)
Generic step, no net context    .Then / .Do / .Until / .StartWhen (inherited from base)
```

Project-level wrapping pattern: collapse frequently repeated multi-step `Until/Then` chains into semantic methods (see Lyra's `FShooterTestsNetworkComponent`):

```cpp
// Test code shrinks from a 4–6 step boilerplate chain to:
Network.WaitForServerPlayerSpawn()
       .WaitForClientPlayerSpawn()
       .ThenServer(TEXT("Actual test logic"), ...);
```

### 7.6 FCQTestSlateComponent (Slate tick synchronization)

The constructor forces `Slate.AllowSlateToSleep=0` and hooks `OnPostTick` for counting; the destructor restores everything.

```cpp
TUniquePtr<FCQTestSlateComponent> SlateComponent;   // MakeUnique inside BEFORE_EACH

TestCommandBuilder
    .Do([this]() { /* trigger UI update */ })
    .StartWhen([this]() { return SlateComponent->HaveTicksElapsed(2); })
    .Then([this]() { ASSERT_THAT(IsTrue(/* verify UI state */)); });
```

`HaveTicksElapsed(N)` has single-wait semantics (sets an internal `ExpectedTick` once and resets when reached) and should be the only statement inside an `Until`/`StartWhen` predicate.

### 7.7 FInputTestActions (input injection)

Lives in the separate plugin `Engine/Plugins/Tests/CQTestEnhancedInput` (split out when CQTest became an Engine Module in 5.5, since engine modules cannot reference plugins). EditorContext only.

```cpp
FInputTestActions InputActions(Pawn);         // bind the target Pawn

FTestAction MoveAction;
MoveAction.InputActionName  = TEXT("IA_Move");
MoveAction.InputActionValue = FInputActionValue(FVector2D(0.f, 1.f));
InputActions.PerformAction(MoveAction);       // inject one input
// ... .Until(movement finished) ...
InputActions.StopAllActions();
```

### 7.8 CQTestAssetHelper (asset lookup, EditorContext)

A utility namespace (not a component), replacing `FCQTestBlueprintHelper` which was removed in 5.5:

```cpp
#include "Helpers/CQTestAssetHelper.h"

FARFilter Filter = CQTestAssetHelper::FAssetFilterBuilder()
    .WithPackagePath(TEXT("/Game/Data"))
    .Build();

UClass*  BpClass = CQTestAssetHelper::GetBlueprintClass(Filter, TEXT("BP_MyChar"));
UObject* Data    = CQTestAssetHelper::FindDataBlueprint(Filter, TEXT("DA_Config"));
ASSERT_THAT(IsNotNull(BpClass));
```

Also available: `FindAssetPackagePathByName` / `FindAssetsByFilter` / `GetBlueprintClasses` / `FindDataBlueprints`.
**If called from a constructor, check `bInitializing == false` first** — plugin assets may not be loaded yet during the registration phase (see 8.3).

---

## 8. Extending the Framework

Three orthogonal dimensions: **components solve environment setup, custom base classes solve logic reuse, custom asserters solve domain semantics**.

### 8.1 Custom asserter

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
        ASSERT_THAT(IsValidHealth(100));   // custom assertion
        ASSERT_THAT(IsTrue(true));         // base assertions still available
    }
};
```

### 8.2 Custom base class (TEST_CLASS_WITH_BASE)

The template signature must be exactly `template<typename Derived, typename AsserterType>`:

```cpp
template <typename Derived, typename AsserterType>
struct TMyGameTestBase : public TTest<Derived, AsserterType>
{
    inline static UMySubsystem* SharedSubsystem = nullptr;   // shared across instances
    FActorTestSpawner Spawner;                               // per-instance (composed component)

    BEFORE_ALL() { SharedSubsystem = GEngine->GetEngineSubsystem<UMySubsystem>(); }
    AFTER_ALL()  { SharedSubsystem = nullptr; }

    AMyActor& SpawnMyActor() { return Spawner.SpawnActor<AMyActor>(); }
};

#define MY_GAME_TEST(_ClassName, _TestDir) \
    TEST_CLASS_WITH_BASE(_ClassName, _TestDir, TMyGameTestBase)

MY_GAME_TEST(CombatTests, "Game.Combat")
{
    // If the derived class also declares BEFORE_ALL, it shadows the base version —
    // you must chain the call manually:
    BEFORE_ALL()
    {
        TMyGameTestBase::BeforeAll(FString());
        // ... derived class's own one-time initialization ...
    }

    TEST_METHOD(Damage_ReducesHealth)
    {
        AMyActor& Actor = SpawnMyActor();      // use base-class helpers directly
        Actor.TakeDamage(10.f);
        ASSERT_THAT(IsNear(90.f, Actor.GetHealth(), 0.001f));
    }
};
```

### 8.3 The bInitializing guard

The fixture is constructed once during the **program-start registration phase** (to collect TEST_METHODs); at that point World/assets/subsystems must not be touched. Constructors doing expensive initialization must distinguish:

```cpp
TMyGameTestBase()
{
    if (!this->bInitializing)
    {
        // Only runs when the test actually executes: plugins are loaded,
        // AssetRegistry is ready
        CachedAsset = CQTestAssetHelper::FindDataBlueprint(TEXT("BP_MyAsset"));
    }
}
```

---

## 9. Abstract Templates (pick by scenario)

```
Verifying a single logic point, stateless?      → Template 1  TEST
Multiple scenarios sharing setup/teardown?      → Template 2  TEST_CLASS + TEST_METHOD
Cross-frame / polling / async waits?            → Template 3  TestCommandBuilder chain
Server/Client network verification?             → NETWORK_TEST_CLASS boilerplate in 7.5
```

**Template 1 — single stateless test**

```cpp
#include "CQTest.h"

TEST(FeatureSimpleTest, "Game.Module.Feature")
{
    // [Arrange]
    auto Input = /* build input */;
    // [Act]
    auto Result = /* call function under test(Input) */;
    // [Assert]
    ASSERT_THAT(AreEqual(/* ExpectedValue */, Result));
}
```

**Template 2 — standard fixture**

```cpp
#include "CQTest.h"

TEST_CLASS(FeatureTests, "Game.Module.Feature")
{
    // Shared members: reset to initial values before each TEST_METHOD
    /* FFooSystem* SystemUnderTest = nullptr; */

    BEFORE_EACH() { /* SystemUnderTest = NewObject<...>(); Init(...); */ }
    AFTER_EACH()  { /* cleanup; runs even if an assertion failed */ }

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

**Template 3 — async / cross-frame**

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

## 10. Running Tests

CQTest registers standard UE Automation Tests, so every native entry point works:

```bash
# In-editor: Window → Session Frontend (Test Automation) → filter by prefix → Start Tests

# Command line (CI / headless, most common)
UnrealEditor-Cmd.exe MyProject.uproject ^
    -ExecCmds="Automation RunTests Game.Module; Quit" ^
    -unattended -nullrhi -nosound -log ^
    -ReportOutputPath="TestResults/"

# Run a single test class / method (prefix match)
-ExecCmds="Automation RunTests Game.Module.FeatureTests; Quit"
```

Filter prefix = the second argument of `TEST_CLASS` plus the class name. Flags determine in which contexts the test is discovered: the default `ApplicationContextMask | ProductFilter` covers both editor and command line; editor-only tests use `EditorContext | ProductFilter` (network/map/asset tests almost always need it).

> Within this project, run tests via `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` — see `Documents/Guides/Test.md`.

---

## 11. Source Map (UE 5.8)

```
Engine/Source/Developer/CQTest/Public/
  CQTest.h                          ← macros / TTest / TTestRunner / TBaseTest (official boilerplate at the top)
  Impl/CQTest.inl                   ← the four RunTest command steps, GC policy, registration internals
  CQTestSettings.h                  ← timeout CVars / UCQTestSettings / SetTestClassTimeouts
  ObjectBuilder.h                   ← TObjectBuilder parameterized construction
  TestGameInstance.h                ← UTestGameInstance (used by ActorTestSpawner)
  Assert/
    NoDiscardAsserter.h / .inl      ← all asserter methods and implementations
    CQTestCondition.h               ← condition functions: IsEqual / IsNearlyEqual / ...
    CQTestConvert.h                 ← failure-message ToString (specializable)
  Commands/
    TestCommandBuilder.h            ← Do/Until/StartWhen/DoAsync/OnTearDown — the full API
    TestCommands.h                  ← FExecute / FWaitUntil / FWaitDelay / FRunSequence
    TestMacros.h                    ← latent-command helper macros
  Components/
    SpawnHelper.h                   ← SpawnActor / SpawnActorAt / SpawnObject
    ActorTestSpawner.h              ← minimal UWorld
    MapTestSpawner.h                ← map loading / temp level
    PIENetworkComponent.h           ← network component + builder + NETWORK_TEST_CLASS
    PIENetworkTestStateRestorer.h   ← PIE state restoration
    CQTestSlateComponent.h          ← Slate tick counter
    CQTestBlueprintHelper.h         ← legacy Blueprint helper (deprecated; use CQTestAssetHelper)
  Helpers/
    CQTestAssetHelper.h             ← asset / Blueprint lookup + FAssetFilterBuilder

Engine/Plugins/Tests/CQTestEnhancedInput/       ← FInputTestActions (input injection)
Engine/Plugins/Tests/CQTest/Source/CQTestTests/ ← framework self-tests = the most complete usage examples
Samples/Games/Lyra/.../ShooterTests/            ← FPIENetworkComponent project-level wrapping example
```

---

## 12. Version-Difference Errata (when cross-checking online material)

The following claims are common in material based on early ue5-main revisions and do not match the actual UE 5.8 source:

1. **There is no `Assert.ExpectError(AnyError)`.** In 5.8, `ExpectError(FString, Count)` is a substring match; use `ExpectErrorRegex` for regex. No `AnyError` constant exists.
2. **`IsNearlyEqual` / `IsNotNearlyEqual` cannot be used directly inside `ASSERT_THAT`.** They are free functions in the `CQTestCondition` namespace, not asserter methods; the asserter provides `IsNear(Expected, Actual, Epsilon)`.
3. **`AreEqual` / `AreNotEqual` reject floating-point types** (`static_assert`); floats must use `IsNear`.
4. **Default timeouts are 10s / 30s / 30s** (Command / Network / MapTest), not 30/120/120.
5. **`AddWaitUntilLoadedCommand` can — and by official boilerplate should — be called inside `BEFORE_EACH`**; the real restriction is "never call it from inside a latent command".
6. The `BEFORE_ALL`/`AFTER_ALL` signature is `static void BeforeAll(const FString&)`, triggered via test-section delegates; chain the base-class call as `TBase::BeforeAll(FString())`.
