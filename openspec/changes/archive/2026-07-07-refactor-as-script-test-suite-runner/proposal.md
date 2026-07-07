## Why

The current Angelscript-side test framework discovers global `Test_*(FUnitTest&)` and `IntegrationTest_*(FIntegrationTest&)` functions, then implicitly creates a unit-test `World` and selects `GameInstanceClass` from global settings. This makes script unit tests depend on hidden engine state, prevents clean suite-level lifecycle hooks, and blurs pure script tests, world-backed tests, and integration tests.

## What Changes

- **BREAKING** Replace the Angelscript-side global-function test entrypoints with class-based script test suites that inherit from a native C++ test suite base class.
- Add CQTest-like suite lifecycle hooks: `BeforeAll`, `BeforeEach`, `AfterEach`, and `AfterAll`.
- Add a new script-facing native `UCLASS`, tentatively `UAngelscriptTestSuite`, that provides assertion, failure, fixture, and world helper methods to Angelscript subclasses.
- Add explicit script fixture selection, tentatively `FScriptTestFixture::Pure()` and `FScriptTestFixture::World()`, with optional per-suite `GameInstanceClass`.
- Stop using global `UnitTestGameInstanceClass` as the default environment for new script tests.
- Register script tests at the suite level in UE Automation so `BeforeAll` and `AfterAll` have deterministic semantics.
- Retire old `ComplexUnitTest_*` and `ComplexIntegrationTest_*` script patterns; parameterized suite cases can be introduced later as a separate capability.

## Capabilities

### New Capabilities

- `as-script-test-suite-runner`: Defines class-based Angelscript test suites, lifecycle execution, fixture selection, failure semantics, and automation registration.

### Modified Capabilities

- None.

## Impact

- Runtime testing infrastructure under `Plugins/Angelscript/Source/AngelscriptRuntime/Testing`.
- New abstract transient native `UCLASS` test base exposed to Angelscript subclasses and exported from `AngelscriptRuntime`.
- Test discovery storage currently represented by `FAngelscriptTestDesc` and module `UnitTestFunctions` / `IntegrationTestFunctions`.
- UE Automation registration currently exposed as `Angelscript.UnitTests` and `Angelscript.IntegrationTests`.
- Script test authoring conventions under `Script/Tests` and test documentation under `Documents/Guides`.
- Existing script-side global test entrypoints are intentionally not kept compatible in this change.
