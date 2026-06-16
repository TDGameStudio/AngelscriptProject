## Context

The existing script test runner is function-centric. Discovery scans module-level functions named `Test_*`, `ComplexUnitTest_*`, `IntegrationTest_*`, and `ComplexIntegrationTest_*`. Running a unit test always creates a transient `UGameInstance`, initializes a `UnitTestWorld`, and loads the game instance class from `UAngelscriptTestSettings::UnitTestGameInstanceClass`. Assertions report errors but do not distinguish fatal and non-fatal failures.

The requested replacement is suite-centric: Angelscript tests should look more like CQTest classes, with suite-level setup/teardown and per-test setup/teardown. C++ CQTest itself expands to a class inheriting a test base (`TTest<...>`), so the Angelscript-side design follows the same shape: script tests inherit a native test suite base class instead of being plain convention-only classes. The new design intentionally does not preserve the old global-function script test API.

## Goals / Non-Goals

**Goals:**

- Discover Angelscript test suites from classes that inherit the native script test suite base rather than global functions.
- Provide deterministic `BeforeAll`, `BeforeEach`, `AfterEach`, and `AfterAll` execution.
- Make fixture requirements explicit and local to the suite.
- Support pure script tests without implicitly creating `World` or `GameInstance`.
- Provide separate fatal and non-fatal assertion APIs.
- Register suite-level UE Automation tests so lifecycle semantics stay clear.

**Non-Goals:**

- No compatibility layer for global `Test_*(FUnitTest&)` script tests.
- No first-pass parameterized tests.
- No first-pass PIE/map integration fixture.
- No parallel script test execution.
- No change to C++ CQTest usage in `AngelscriptTest`.

## Decisions

### Native Base Class

Add a native UObject-style test base class, tentatively `UAngelscriptTestSuite`, and expose it to Angelscript. This class should be a real native `UCLASS`, not an AngelScript value class or plain C++ helper struct:

```cpp
UCLASS(Abstract, Blueprintable, Transient)
class ANGELSCRIPTRUNTIME_API UAngelscriptTestSuite : public UObject
{
    GENERATED_BODY()

public:
    virtual UWorld* GetWorld() const override;

protected:
    void InitializeForTestRun(const FAngelscriptScriptTestRunState& InRunState);
    void ClearTestRun();

private:
    TWeakObjectPtr<UWorld> ActiveWorld;
    TWeakObjectPtr<UGameInstance> ActiveGameInstance;
    FAngelscriptScriptTestRunState* ActiveRunState = nullptr;
};
```

The native class should live in the runtime testing area and be exported with `ANGELSCRIPTRUNTIME_API` so generated Angelscript classes can use it as their code superclass. It should be `Abstract` to prevent accidental direct use as a concrete test suite, `Blueprintable` so the existing script class generator treats it like other scriptable `UObject` bases, and `Transient` because test suite instances are runner-owned temporary objects.

Script tests must inherit this base:

```angelscript
class UExampleTests : UAngelscriptTestSuite
{
    FScriptTestFixture Configure()
    {
        return FScriptTestFixture::Pure();
    }

    void BeforeAll()
    {
    }

    void BeforeEach()
    {
    }

    void AfterEach()
    {
    }

    void AfterAll()
    {
    }

    void Test_Add()
    {
        RequireEquals(2, 1 + 1, "addition should work");
    }
}
```

The base class provides script-callable methods such as `Expect*`, `Require*`, `Fail`, `GetWorld`, `GetGameInstance`, and fixture-aware world helpers. The runner installs the active reporter and fixture state on the base object before invoking lifecycle or test methods.

This avoids a required `FScriptTestContext& T` parameter on every method, keeps the API close to C++ CQTest, and gives Angelscript methods through normal inheritance.

The base should not inherit from `UObjectInWorld`. `UObjectInWorld` exposes generic mutation helpers such as `SetWorld`, `SetWorldContext`, and `DestroyObject`; test suite world state should be injected and owned by the runner so fixture boundaries remain deterministic.

Assertion methods with many overloads should be bound onto `UAngelscriptTestSuite` via `FAngelscriptBinds::ExistingClass("UAngelscriptTestSuite")`, following the current `FUnitTest` assertion binding pattern. Simple UObject-facing helpers may be `UFUNCTION`s if reflection binding is sufficient, but overload-heavy APIs should use explicit Angelscript binds.

Suite instances should be created from the generated AS `UClass`:

```cpp
UAngelscriptTestSuite* Suite = NewObject<UAngelscriptTestSuite>(
    Outer,
    SuiteDesc.GeneratedClass,
    NAME_None,
    RF_Transient);
```

The runner must call `InitializeForTestRun` before `Configure`, lifecycle, or test methods, and `ClearTestRun` after `AfterAll` finishes or when execution aborts.

### Class-Based Discovery

Discovery will scan compiled script classes and register only classes whose generated `UClass` is a child of `UAngelscriptTestSuite`. A naming convention such as `*Tests` or `*TestSuite` may still be required for clarity, but inheritance is the authoritative eligibility check. A test method must be an instance method named `Test_*` with signature `void Method()`.

Lifecycle methods are optional and use fixed no-argument names:

```angelscript
void BeforeAll()
void BeforeEach()
void AfterEach()
void AfterAll()
```

This keeps the script authoring model close to CQTest while avoiding a script macro system.

### Suite-Level Automation Registration

UE Automation will expose one command per script suite. The runner executes all `Test_*` methods inside that suite command. This is less granular than one automation command per method, but it gives correct `BeforeAll` and `AfterAll` semantics even when users run a single suite from the automation UI.

Method-level filtering can be added later as a runner option without changing the core suite contract.

### Explicit Fixtures

Suites are pure by default. A suite can optionally define:

```angelscript
FScriptTestFixture Configure()
```

The initial fixture kinds are:

- `Pure`: no `World`, no `GameInstance`.
- `World`: creates a transient test world and may use an explicit game instance class.

`World` fixtures default to per-test isolation. Suite-scoped world fixtures can be added only if a concrete need appears.

### Failure Semantics

The native base class separates failures that continue the current method from failures that stop it:

- `Expect*`: record a failure and continue.
- `Require*`: record a failure and stop the current test method.
- `Fail`: record a fatal failure and stop the current test method.

Fatal failures should be implemented through a controlled runner-visible stop signal, such as a handled script exception, so the current Angelscript method stops while `AfterEach` / `AfterAll` cleanup still runs.

Lifecycle failure handling:

- `BeforeAll` fatal failure skips all test methods and still attempts `AfterAll`.
- `BeforeEach` fatal failure fails the current method, skips the method body, and still attempts `AfterEach`.
- `Test_*` fatal failure stops only the current method and still attempts `AfterEach`.
- `AfterEach` failure marks the current method failed.
- `AfterAll` failure marks the suite failed.

### Old Runner Removal

The old global-function discovery and automation registration should be removed or disabled as part of implementation. The old `FUnitTest` / `FIntegrationTest` bindings may remain temporarily only if C++ compilation dependencies require a staged cleanup, but they must not register script tests in the new framework.

## Risks / Trade-offs

- **Loss of method-level Automation UI selection** -> Use suite-level registration for v1, then add internal method filtering later if needed.
- **Breaking existing script tests** -> Current repository has no meaningful `void Test_*(FUnitTest&)` script corpus, so breakage is acceptable and intentional.
- **UObject-backed suite instances add more engine coupling than plain script objects** -> The coupling is intentional because inheritance is needed for script-visible helper methods and matches C++ CQTest's base-class model.
- **Fixture API may grow too early** -> Limit v1 to `Pure` and `World` with optional game instance class.
