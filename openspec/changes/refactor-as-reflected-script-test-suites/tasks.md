## 1. OpenSpec Record

- [x] 1.1 <!-- Non-TDD --> Rewrite `proposal.md`, `research.md`, `design.md`, and `specs/as-script-test-suite-runner/spec.md` to record the final one-base-class, exact-flags, explicit-World, fluent-latent, advanced-command, and hot-reload contract.
- [x] 1.2 <!-- Non-TDD --> Strictly validate the revised record with `openspec validate refactor-as-reflected-script-test-suites --type change --strict --no-interactive`.

## 2. Native Base, Metadata, Flags, and Registry

- [x] 2.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/Testing/AngelscriptScriptTestDiscoveryTests.cpp` under prefix `Angelscript.TestModule.Testing.ScriptTestFramework.Discovery`, with inline `ASTEST_AS` suites proving marked arbitrary names, unmarked helpers, abstract/non-derived classes, inherited marked methods, invalid signatures, normalized collisions, and Blueprint-callable suppression.
- [x] 2.2 <!-- TDD --> Extend the same discovery tests with valid multi-context masks, supported feature/priority/Disabled flags, unknown/empty/duplicate tokens, missing context/filter, multiple filters, and `#if EDITOR` versus `EditorContext` behavior.
- [x] 2.3 <!-- TDD --> Add `Testing/AngelscriptTestSuite.h/.cpp` in `AngelscriptRuntime` with the abstract transient `UAngelscriptTestSuite`, no-op BlueprintNativeEvent lifecycle hooks, and no public World/command helper UObject types.
- [x] 2.4 <!-- TDD --> Extend UFUNCTION preprocessing/class generation so `meta=(AngelscriptTest)` preserves reflection/source metadata while clearing ordinary Blueprint-callable exposure, and extend class metadata handling for `AngelscriptTestFlags`.
- [x] 2.5 <!-- TDD --> Add `Testing/AngelscriptScriptTestRegistry.h/.cpp` with stable `(Module, Suite, Method)` IDs, exact flag masks, source locations, immutable generation snapshots, active-module/latest-class discovery, deterministic sorting, collision diagnostics, and the `bEnableTestDiscovery` empty-snapshot behavior.
- [x] 2.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Discovery" -Label script-test-discovery -TimeoutMs 600000` and record exact pass/fail/skip counts before starting lifecycle work.

## 3. Lifecycle, Execution Context, and Assertions

- [x] 3.1 <!-- TDD --> Add `AngelscriptScriptTestLifecycleTests.cpp` under the ScriptTestFramework prefix for fresh method instances, separate All-hook instances, All/Each ordering, single-leaf selection, per-worker/per-generation sessions, `BeforeAll` exception handling, forbidden All-hook leaf operations, guaranteed `AfterEach`, and teardown ordering.
- [x] 3.2 <!-- TDD --> Add `Testing/AngelscriptScriptTestRunner.h/.cpp` with the method execution context, current active phase, suite association, current-object/latest-method resolution, CQTest-style section manager, and controlled terminal cleanup state machine.
- [x] 3.3 <!-- TDD --> Complete `AngelscriptScriptTestAssertionTests.cpp` coverage for ordinary exceptions from `BeforeEach`, the marked method, and `AfterEach`, plus expected-error contains/regex/count finalization in detached Commandlet and automatic hot-reload execution.
- [x] 3.4 <!-- TDD --> Implement native assertion/expected-log bindings on `UAngelscriptTestSuite`, including `FTransform` equality, numeric/UE math near behavior, relational overloads, controlled exception consumption, and protection against expecting away assertion failures.
- [x] 3.5 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Lifecycle+Angelscript.TestModule.Testing.ScriptTestFramework.Assertions" -Label script-test-lifecycle-assertions -TimeoutMs 600000` and record exact counts.

## 4. Explicit Local World and Spawn Tools

- [x] 4.1 <!-- TDD --> Add `AngelscriptScriptTestWorldTests.cpp`, reusing `FAngelscriptTestWorld` expectations, for pure-test no-World behavior, World creation, optional GameInstance/subsystem initialization, duplicate creation rejection, ambient context, and explicit/idempotent destruction.
- [x] 4.2 <!-- TDD --> Extend World tests for `SpawnObject`, `SpawnActor`, and `SpawnComponent`, including invalid classes/owners, default Outer, registration/activation, correct World ownership, and tracked strong-reference lifetime.
- [x] 4.3 <!-- TDD --> Extend World tests for idempotent BeginPlay, BeginPlayAll, scheduler World tick, exact Actor/Component tick counts, `AdvanceTime`, destroy-and-drain, `EndPlay`/`Destroyed`, and wrong-World arguments.
- [x] 4.4 <!-- TDD --> Add private `Testing/AngelscriptScriptTestWorld.h/.cpp` execution state and native suite bindings for `CreateTestWorld`, `DestroyTestWorld`, `GetTestWorld`, Spawn, BeginPlay, Tick, `AdvanceTime`, and destruction without linking Runtime to CQTest.
- [x] 4.5 <!-- TDD --> Route every leaf terminal path—success, assertion, ordinary exception, timeout, explicit cancellation, and reload invalidation—through reverse-order Actor/Component/UObject/GameInstance/World cleanup and verify that no tracked UObject, root object, World context, or ambient context remains even when no World was created.
- [x] 4.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.World" -Label script-test-world -TimeoutMs 600000` and record exact counts.

## 5. Fluent Commands and Advanced Latent Compatibility

- [x] 5.1 <!-- TDD --> Add `AngelscriptScriptTestCommandTests.cpp` for fluent return/chaining, `Do`/`Then` FIFO aliases, `StartWhen`/`Until` aliases, monotonic `WaitDelay`, success polling, 5-second default, 15-second maximum, invalid timeout values, and source-located timeout diagnostics.
- [x] 5.2 <!-- TDD --> Extend command tests for ordinary unmarked callback resolution, missing/ambiguous/static/parameterized/wrong-return helpers, immediate queue-construction semantics, assertions/exceptions in callbacks, rejection of queue mutation from active callbacks, and main-command skipping after failure.
- [x] 5.3 <!-- TDD --> Extend command tests for `OnTearDown`/`OnCleanup` aliases, LIFO order, registration from `AfterEach`, execution despite prior failure, and ordering before automatic World cleanup.
- [x] 5.4 <!-- TDD --> Add private `Testing/AngelscriptScriptTestCommands.h/.cpp`, native chainable suite bindings, stable callback names, FIFO main/LIFO teardown queues, Automation-update scheduling, timeout/progress reporting, and callback-boundary phase guards.
- [x] 5.5 <!-- TDD --> Add advanced-command tests for `Before`/`Update`/`After`, descriptions, allowed timeout, command retention/release on all terminal paths, `GetCurrentSuite`, unassociated access, and local-World rejection of client-enabled commands.
- [x] 5.6 <!-- TDD --> Refactor `LatentAutomationCommand.*`, `LatentAutomationCommandClientExecutor.*`, and their IntegrationTest bindings from `FAngelscriptIntegrationTest` association to the new execution context while preserving supported server/client phase synchronization and assertion forwarding.
- [x] 5.7 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Commands" -Label script-test-commands -TimeoutMs 600000` and record exact counts.

## 6. UE Automation Bridges and Legacy Routing

- [x] 6.1 <!-- TDD --> Add `AngelscriptScriptTestAutomationTests.cpp` for independent leaf paths, exact-mask bridge separation/reuse, persistent empty bridges, deterministic order, source lookup, selective execution, stale command safety, and flags moving buckets after reload.
- [x] 6.2 <!-- TDD --> Add `Testing/AngelscriptScriptTestAutomation.h/.cpp` with one persistent bridge per encountered exact `EAutomationTestFlags` mask, unique internal names, stable public leaf paths, current snapshot enumeration, and section-manager integration under `WITH_DEV_AUTOMATION_TESTS`.
- [x] 6.3 <!-- TDD --> Route commandlet and automatic hot-reload selection through registry descriptors and the same synchronous/latent runner; keep generation and stable IDs in pending work instead of module/function pointers.
- [x] 6.4 <!-- TDD --> Remove global unit/integration/Complex discovery, `Angelscript.UnitTests`, `Angelscript.IntegrationTests`, `FUnitTest`, `FIntegrationTest`, global `GetParam`, old mutable-current-test APIs, implicit map/PIE startup, and obsolete context bindings after the class-based routes pass.
- [x] 6.5 <!-- TDD --> Remove settings used only by the retired protocol (`IntegrationTestMapRoot`, both naming conventions/regex, `UnitTestGameInstanceClass`, and Integration network-emulation packet settings) while retaining discovery, hot-reload, GC batching, coverage, and debugging settings.
- [x] 6.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Automation" -Label script-test-automation -TimeoutMs 600000` and verify the retired Automation roots are absent from the generated report.

## 7. Hot Reload and Editor Refresh

- [x] 7.1 <!-- TDD --> Complete `AngelscriptScriptTestHotReloadTests.cpp` coverage for an active Automation Suite section across reload: close the old-generation All-hook instance before compile and lazily open the new-generation `BeforeAll` before the next leaf even when UE does not re-enter the same section.
- [x] 7.2 <!-- TDD --> Extend hot-reload tests with an active ordinary wait and an active `ULatentAutomationCommand`, proving callback-boundary deferral, old-generation `AfterEach`, LIFO teardown, advanced-command release, World cleanup, stale-leaf rerun diagnostic, and compile only after cleanup.
- [x] 7.3 <!-- TDD --> Convert the automatic hot-reload test runner to an asynchronous game-thread scheduler that supports latent leaves, cancels/replaces older-generation pending or active work on rapid saves, and never migrates suite/command/World state.
- [x] 7.4 <!-- TDD --> Publish registry snapshots only after successful class generation, retain last-good snapshots on failure, broadcast the newest generation, and resolve every test/callback against the active module and `GetMostUpToDateClass()`.
- [x] 7.5 <!-- TDD --> Add Editor tests for immediate, deferred, coalesced, and unloaded-controller refresh; implement the `AngelscriptEditor` listener and private AutomationController dependency without adding AutomationController or CQTest to Runtime.
- [x] 7.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.HotReload" -Label script-test-hotreload -TimeoutMs 600000` and record exact counts.

## 8. Examples and Chinese-First Documentation

- [x] 8.1 <!-- Non-TDD --> Add or migrate AS examples under `Script/Tests` for a pure class test, explicit World/Spawn/Tick test, fluent `WaitDelay`/`Until`/`Then` test, advanced `ULatentAutomationCommand`, exact Runtime flags, and `#if EDITOR` plus `EditorContext`.
- [x] 8.2 <!-- Non-TDD --> Update `Documents/Guides/Test.md` in Chinese first with declaration, lifecycle isolation, exact flags, editor-versus-runtime compilation, assertions, queue-construction versus await semantics, explicit World ownership, cleanup, hot reload, commandlet execution, and old-global migration.
- [x] 8.3 <!-- Non-TDD --> Update the Chinese Wiki script-test tiddler and plugin consumer README with the same public contract, without modifying deprecated `Documents/Plans` or archived OpenSpec history.
- [x] 8.4 <!-- Non-TDD --> Document explicit non-goals and migration boundaries: no parameterized provider, no automatic Map/PIE/network session, no lambda/function-handle callback, and no resumable VM `await`.

## 9. Verification and Review

- [x] 9.1 <!-- Non-TDD --> Build through `Tools\RunBuild.ps1 -Label as-script-test-framework -TimeoutMs 1800000 -NoXGE` and record the result.
- [x] 9.2 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework" -Label script-test-framework -TimeoutMs 600000` and record exact pass/fail/skip/timeout counts.
- [x] 9.3 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.ScriptTests" -Label script-tests -TimeoutMs 600000` and record exact counts for pure, World, fluent latent, and advanced-command example leaves.
- [x] 9.4 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix as-test-framework-all -TimeoutMs 600000 -ContinueOnFail` and record every prefix result.
- [x] 9.5 <!-- Non-TDD --> Repair the second-review Critical/Important findings: Automation All-hook generation cancellation, detached-runner exception/expected-log accounting, and non-Editor runtime discovery; then rerun affected focused tests.
- [x] 9.6 <!-- Non-TDD --> Re-run `openspec validate refactor-as-reflected-script-test-suites --type change --strict --no-interactive` after the remediation and replace stale final evidence with fresh build/test counts.

## 10. Second-Review Hardening

- [x] 10.1 <!-- TDD --> Surface source-located `BeforeAll`/`AfterAll` lifecycle entries to the leaf or session diagnostic instead of discarding the private lifecycle result.
- [x] 10.2 <!-- TDD --> Make the automatic hot-reload scheduler consume a completed failure once so an idle runner does not request repeated per-tick diagnostics.
- [x] 10.3 <!-- TDD --> Move script-test discovery and successful-reload registry publication from `WITH_EDITOR` to the supported development-automation/runtime-test boundary, then validate an Editor build plus a non-Editor Game target build.
- [x] 10.4 <!-- Non-TDD --> Add Commandlet selected/executed/passed/failed counts, fail validation when no eligible tests execute, and record a run proving at least one reflected Commandlet leaf ran.
- [x] 10.5 <!-- Non-TDD --> Keep hard removal of the legacy global protocol as the current OpenSpec decision; do not add an adapter without an explicit compatibility decision.
- [x] 10.6 <!-- TDD --> Keep `failed` limited to executed leaves, represent `BeforeAll`/startup failures through `selected != executed`, and enforce `passed + failed == executed` in the synchronous-run success predicate.
- [x] 10.7 <!-- TDD --> Separate the hot-reload callback guard from direct-context exception-log suppression so ordinary exceptions thrown through advanced-command `ProcessEvent` callbacks fail both attached and detached results instead of being silently consumed.
- [x] 10.8 <!-- TDD --> Report every ordinary `AfterEach` or registered-cleanup exception with its script source even when the leaf already contains a primary assertion/error; suppress only the framework's controlled assertion exception.
- [x] 10.9 <!-- TDD --> Enforce the advanced command timeout as one overall deadline through client setup, polling, and `FinishClient`; terminally finalize allowed timeouts and fail safely if the weak client executor disappears.
- [x] 10.10 <!-- TDD --> Track each active leaf and All-hook session by owning `FAngelscriptEngine`, then cancel/close them before that engine releases script functions during `Shutdown()`.
- [x] 10.11 <!-- Non-TDD --> Remove the registry convenience lookup that returned a pointer after releasing its snapshot owner, and make local World/GameInstance creation roll back without leaking a WorldContext or initialized GameInstance on failure.

## 11. Consumer Example Completion

- [x] 11.1 <!-- Non-TDD --> Extend the runnable AS example with two lifecycle/state-isolation leaves, contains/regex expected-error leaves, and a pure UObject `SpawnObject` leaf that proves no World is created.
- [x] 11.2 <!-- Non-TDD --> Add a runnable `CreateTestWorld(true)` example proving that the optional GameInstance/subsystem context is initialized without introducing public World, Map, or Network wrapper types.
- [x] 11.3 <!-- Non-TDD --> Update the Chinese guide first, then the plugin README and Chinese Wiki, with the new examples, script-module-to-Automation-path mapping, exact-leaf selection, and the script `StaticClass()` Editor compilation boundary.
- [x] 11.4 <!-- Non-TDD --> Run the complete reflected example prefix, focused Wiki contracts, strict OpenSpec validation, and parent/plugin/Wiki diff checks; record exact evidence.

## 12. Stateless Test Tool Facade and Command Builder

- [x] 12.1 <!-- Non-TDD --> Revise the proposal, design, delta spec, and tasks to keep lifecycle/assertion/expected-error methods on `UAngelscriptTestSuite` while moving environment tools to `FAngelscriptTest` and latent authoring to `FAngelscriptTestCommandBuilder`.
- [x] 12.2 <!-- TDD --> Add red/green API tests proving namespace-global World/Spawn/Tick tools, value-style command chaining, unchanged inherited assertions, removed suite environment aliases, and `GetWorld()` compatibility.
- [x] 12.3 <!-- TDD --> Add a callback-scoped active execution-context stack and tests for nested/global helper calls, multiple waiting leaves, lifecycle misuse, cancellation, hot reload, and advanced server/client boundaries.
- [x] 12.4 <!-- TDD --> Implement fieldless force-bound `FAngelscriptTest` and `FAngelscriptTestCommandBuilder` USTRUCTs, move native environment/command bindings out of `UAngelscriptTestSuite`, and hard-migrate all repository call sites.
- [x] 12.5 <!-- Non-TDD --> Update the Chinese guide first, runnable AS example, plugin README, and Chinese Wiki with the facade/builder API and old-to-new migration table.
- [x] 12.6 <!-- Non-TDD --> Run focused framework tests, full ScriptTestFramework and example prefixes, Editor and Game builds, commandlet, All suite, Wiki contracts, strict OpenSpec validation, and parent/plugin/Wiki diff checks; append exact evidence.
