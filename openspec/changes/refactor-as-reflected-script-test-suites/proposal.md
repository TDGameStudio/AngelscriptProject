## Why

The current script test protocol discovers module-level `Test_*` and
`IntegrationTest_*` functions that receive mutable test-context parameters.
That shape does not provide class-owned setup/teardown, concise latent
commands, independently selectable UE Automation methods, or safe identities
across AngelScript class hot reload.

Replace it with reflected AngelScript test-suite classes whose marked methods,
lifecycle, assertions, explicit test-world tools, latent command queue,
Automation registration, and hot-reload behavior are owned by the standalone
`Angelscript` plugin.

## What Changes

- Add one abstract transient native `UAngelscriptTestSuite` base that script
  test classes inherit; no separate World, Map, Network, or command-builder
  UObject becomes part of the public AS API.
- Discover arbitrary zero-argument `void` instance methods marked with
  `UFUNCTION(meta=(AngelscriptTest))`; test names no longer use a `Test_*`
  convention or `UFUNCTION(Test)`.
- Read exact UE Automation flags from class metadata such as
  `meta=(AngelscriptTestFlags="EditorContext;EngineFilter")`, validate their
  context/filter shape, and expose each flag mask through a persistent
  Automation bridge.
- Add overridable `BeforeAll`, `BeforeEach`, `AfterEach`, and `AfterAll`
  lifecycle hooks with a fresh suite instance per test method.
- Implement fail-fast `Assert*`, failure, and expected-log helpers in C++,
  exposed without a mutable test-context parameter.
- Add explicit local test-world helpers directly on the suite base for World
  creation, UObject/Actor/Component spawning, BeginPlay, world and precise
  object ticking, time advancement, destruction, and automatic cleanup.
- Add a CQTest-style fluent latent queue directly on the suite base:
  `Do`/`Then`, `StartWhen`/`Until`, `WaitDelay`,
  `OnTearDown`/`OnCleanup`, and `AddLatentCommand`.
- Preserve and refactor `ULatentAutomationCommand` as the advanced extension
  point, including its existing server/client command protocol when the
  caller already supplies a network-capable World.
- Register every script test method as an independent
  `Angelscript.ScriptTests.<Module>.<Suite>.<Method>` UE Automation leaf.
- Rebuild a generation-tagged registry after successful compilation, resolve
  current classes and callback methods at execution time, cancel affected
  active leaves with old-generation cleanup before compilation, and refresh
  the Editor Automation list after hot reload.
- Route commandlet and automatic hot-reload execution through the same
  registry, lifecycle, World, and latent runner.
- **BREAKING**: Remove discovery and execution of global
  `Test_*(FUnitTest&)`, `IntegrationTest_*(FIntegrationTest&)`, and Complex
  entrypoints, including their old Automation roots and mutable context
  bindings.
- **BREAKING**: Do not retain the old implicit World/GameInstance creation or
  automatic Integration map/PIE startup. A suite explicitly calls
  `CreateTestWorld()` when it needs a local test World.
- Keep parameterized test providers, automatic Map/PIE/multiplayer session
  orchestration, AS function-handle/lambda backports, and VM-style
  `await`/Suspend outside this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `as-script-test-suite-runner`: Replace the archived naming-, fixture-, and
  suite-command design with metadata-marked methods, exact Automation flags,
  independent leaves, fail-fast assertions, explicit World/Spawn tools,
  CQTest-style latent commands, advanced command compatibility, and
  generation-safe hot reload.

## Impact

- Runtime test protocol, public suite base, test-world ownership, command
  execution, and compilation integration under
  `Plugins/Angelscript/Source/AngelscriptRuntime/Testing` and
  `AngelscriptRuntime/Core`.
- AngelScript UCLASS/UFUNCTION preprocessing and class generation for
  `AngelscriptTestFlags`, `AngelscriptTest`, source locations, and
  Blueprint-callable suppression.
- Existing `ULatentAutomationCommand` and client executor associations.
- Editor-only AutomationController list-refresh integration.
- CQTest-based regression coverage in `AngelscriptTest`, reusing the existing
  `FAngelscriptTestWorld` harness as behavioral evidence.
- Script examples and Chinese-first testing documentation.
- `AngelscriptRuntime` remains independent of the Developer-only CQTest
  module and does not gain an AutomationController dependency.
