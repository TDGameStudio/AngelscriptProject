## 1. OpenSpec Record

- [x] 1.1 <!-- Non-TDD --> Rewrite `proposal.md`, `research.md`, `design.md`, and `specs/as-script-test-suite-runner/spec.md` to record the final one-base-class, exact-flags, explicit-World, fluent-latent, advanced-command, and hot-reload contract.
- [x] 1.2 <!-- Non-TDD --> Strictly validate the revised record with `openspec validate refactor-as-reflected-script-test-suites --type change --strict --no-interactive`.

## 2. Native Base, Metadata, Flags, and Registry

- [ ] 2.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/Testing/AngelscriptScriptTestDiscoveryTests.cpp` under prefix `Angelscript.TestModule.Testing.ScriptTestFramework.Discovery`, with inline `ASTEST_AS` suites proving marked arbitrary names, unmarked helpers, abstract/non-derived classes, inherited marked methods, invalid signatures, normalized collisions, and Blueprint-callable suppression.
- [ ] 2.2 <!-- TDD --> Extend the same discovery tests with valid multi-context masks, supported feature/priority/Disabled flags, unknown/empty/duplicate tokens, missing context/filter, multiple filters, and `#if EDITOR` versus `EditorContext` behavior.
- [ ] 2.3 <!-- TDD --> Add `Testing/AngelscriptTestSuite.h/.cpp` in `AngelscriptRuntime` with the abstract transient `UAngelscriptTestSuite`, no-op BlueprintNativeEvent lifecycle hooks, and no public World/command helper UObject types.
- [ ] 2.4 <!-- TDD --> Extend UFUNCTION preprocessing/class generation so `meta=(AngelscriptTest)` preserves reflection/source metadata while clearing ordinary Blueprint-callable exposure, and extend class metadata handling for `AngelscriptTestFlags`.
- [ ] 2.5 <!-- TDD --> Add `Testing/AngelscriptScriptTestRegistry.h/.cpp` with stable `(Module, Suite, Method)` IDs, exact flag masks, source locations, immutable generation snapshots, active-module/latest-class discovery, deterministic sorting, collision diagnostics, and the `bEnableTestDiscovery` empty-snapshot behavior.
- [ ] 2.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Discovery" -Label script-test-discovery -TimeoutMs 600000` and record exact pass/fail/skip counts before starting lifecycle work.

## 3. Lifecycle, Execution Context, and Assertions

- [ ] 3.1 <!-- TDD --> Add `AngelscriptScriptTestLifecycleTests.cpp` under the ScriptTestFramework prefix for fresh method instances, separate All-hook instances, All/Each ordering, single-leaf selection, per-worker/per-generation sessions, `BeforeAll` exception handling, forbidden All-hook leaf operations, guaranteed `AfterEach`, and teardown ordering.
- [ ] 3.2 <!-- TDD --> Add `Testing/AngelscriptScriptTestRunner.h/.cpp` with the method execution context, current active phase, suite association, current-object/latest-method resolution, CQTest-style section manager, and controlled terminal cleanup state machine.
- [ ] 3.3 <!-- TDD --> Add `AngelscriptScriptTestAssertionTests.cpp` for all assertion families and overloads, custom messages/source lines, fail-fast termination, no duplicate controlled exception, ordinary exceptions, lifecycle misuse, assertions in callbacks, and expected-error contains/regex/count behavior.
- [ ] 3.4 <!-- TDD --> Implement native assertion/expected-log bindings on `UAngelscriptTestSuite`, including `FTransform` equality, numeric/UE math near behavior, relational overloads, controlled exception consumption, and protection against expecting away assertion failures.
- [ ] 3.5 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Lifecycle+Angelscript.TestModule.Testing.ScriptTestFramework.Assertions" -Label script-test-lifecycle-assertions -TimeoutMs 600000` and record exact counts.

## 4. Explicit Local World and Spawn Tools

- [ ] 4.1 <!-- TDD --> Add `AngelscriptScriptTestWorldTests.cpp`, reusing `FAngelscriptTestWorld` expectations, for pure-test no-World behavior, World creation, optional GameInstance/subsystem initialization, duplicate creation rejection, ambient context, and explicit/idempotent destruction.
- [ ] 4.2 <!-- TDD --> Extend World tests for `SpawnObject`, `SpawnActor`, and `SpawnComponent`, including invalid classes/owners, default Outer, registration/activation, correct World ownership, and tracked strong-reference lifetime.
- [ ] 4.3 <!-- TDD --> Extend World tests for idempotent BeginPlay, BeginPlayAll, scheduler World tick, exact Actor/Component tick counts, `AdvanceTime`, destroy-and-drain, `EndPlay`/`Destroyed`, and wrong-World arguments.
- [ ] 4.4 <!-- TDD --> Add private `Testing/AngelscriptScriptTestWorld.h/.cpp` execution state and native suite bindings for `CreateTestWorld`, `DestroyTestWorld`, `GetTestWorld`, Spawn, BeginPlay, Tick, `AdvanceTime`, and destruction without linking Runtime to CQTest.
- [ ] 4.5 <!-- TDD --> Route every leaf terminal path—success, assertion, ordinary exception, timeout, explicit cancellation, and reload invalidation—through reverse-order Actor/Component/UObject/GameInstance/World cleanup and verify that no root object, World context, or ambient context remains.
- [ ] 4.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.World" -Label script-test-world -TimeoutMs 600000` and record exact counts.

## 5. Fluent Commands and Advanced Latent Compatibility

- [ ] 5.1 <!-- TDD --> Add `AngelscriptScriptTestCommandTests.cpp` for fluent return/chaining, `Do`/`Then` FIFO aliases, `StartWhen`/`Until` aliases, monotonic `WaitDelay`, success polling, 5-second default, 15-second maximum, invalid timeout values, and source-located timeout diagnostics.
- [ ] 5.2 <!-- TDD --> Extend command tests for ordinary unmarked callback resolution, missing/ambiguous/static/parameterized/wrong-return helpers, immediate queue-construction semantics, assertions/exceptions in callbacks, rejection of queue mutation from active callbacks, and main-command skipping after failure.
- [ ] 5.3 <!-- TDD --> Extend command tests for `OnTearDown`/`OnCleanup` aliases, LIFO order, registration from `AfterEach`, execution despite prior failure, and ordering before automatic World cleanup.
- [ ] 5.4 <!-- TDD --> Add private `Testing/AngelscriptScriptTestCommands.h/.cpp`, native chainable suite bindings, stable callback names, FIFO main/LIFO teardown queues, Automation-update scheduling, timeout/progress reporting, and callback-boundary phase guards.
- [ ] 5.5 <!-- TDD --> Add advanced-command tests for `Before`/`Update`/`After`, descriptions, allowed timeout, command retention/release on all terminal paths, `GetCurrentSuite`, unassociated access, and local-World rejection of client-enabled commands.
- [ ] 5.6 <!-- TDD --> Refactor `LatentAutomationCommand.*`, `LatentAutomationCommandClientExecutor.*`, and their IntegrationTest bindings from `FAngelscriptIntegrationTest` association to the new execution context while preserving supported server/client phase synchronization and assertion forwarding.
- [ ] 5.7 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Commands" -Label script-test-commands -TimeoutMs 600000` and record exact counts.

## 6. UE Automation Bridges and Legacy Routing

- [ ] 6.1 <!-- TDD --> Add `AngelscriptScriptTestAutomationTests.cpp` for independent leaf paths, exact-mask bridge separation/reuse, persistent empty bridges, deterministic order, source lookup, selective execution, stale command safety, and flags moving buckets after reload.
- [ ] 6.2 <!-- TDD --> Add `Testing/AngelscriptScriptTestAutomation.h/.cpp` with one persistent bridge per encountered exact `EAutomationTestFlags` mask, unique internal names, stable public leaf paths, current snapshot enumeration, and section-manager integration under `WITH_DEV_AUTOMATION_TESTS`.
- [ ] 6.3 <!-- TDD --> Route commandlet and automatic hot-reload selection through registry descriptors and the same synchronous/latent runner; keep generation and stable IDs in pending work instead of module/function pointers.
- [ ] 6.4 <!-- TDD --> Remove global unit/integration/Complex discovery, `Angelscript.UnitTests`, `Angelscript.IntegrationTests`, `FUnitTest`, `FIntegrationTest`, global `GetParam`, old mutable-current-test APIs, implicit map/PIE startup, and obsolete context bindings after the class-based routes pass.
- [ ] 6.5 <!-- TDD --> Remove settings used only by the retired protocol (`IntegrationTestMapRoot`, both naming conventions/regex, `UnitTestGameInstanceClass`, and Integration network-emulation packet settings) while retaining discovery, hot-reload, GC batching, coverage, and debugging settings.
- [ ] 6.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.Automation" -Label script-test-automation -TimeoutMs 600000` and verify the retired Automation roots are absent from the generated report.

## 7. Hot Reload and Editor Refresh

- [ ] 7.1 <!-- TDD --> Add `AngelscriptScriptTestHotReloadTests.cpp` for body reload, marker add/remove, method rename, flag-bucket migration, failed compile last-good registry, old class/function rejection, and lazy All-hook reopening.
- [ ] 7.2 <!-- TDD --> Extend hot-reload tests with an active ordinary wait and an active `ULatentAutomationCommand`, proving callback-boundary deferral, old-generation `AfterEach`, LIFO teardown, advanced-command release, World cleanup, stale-leaf rerun diagnostic, and compile only after cleanup.
- [ ] 7.3 <!-- TDD --> Convert the automatic hot-reload test runner to an asynchronous game-thread scheduler that supports latent leaves, cancels/replaces older-generation pending or active work on rapid saves, and never migrates suite/command/World state.
- [ ] 7.4 <!-- TDD --> Publish registry snapshots only after successful class generation, retain last-good snapshots on failure, broadcast the newest generation, and resolve every test/callback against the active module and `GetMostUpToDateClass()`.
- [ ] 7.5 <!-- TDD --> Add Editor tests for immediate, deferred, coalesced, and unloaded-controller refresh; implement the `AngelscriptEditor` listener and private AutomationController dependency without adding AutomationController or CQTest to Runtime.
- [ ] 7.6 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework.HotReload" -Label script-test-hotreload -TimeoutMs 600000` and record exact counts.

## 8. Examples and Chinese-First Documentation

- [ ] 8.1 <!-- Non-TDD --> Add or migrate AS examples under `Script/Tests` for a pure class test, explicit World/Spawn/Tick test, fluent `WaitDelay`/`Until`/`Then` test, advanced `ULatentAutomationCommand`, exact Runtime flags, and `#if EDITOR` plus `EditorContext`.
- [ ] 8.2 <!-- Non-TDD --> Update `Documents/Guides/Test.md` in Chinese first with declaration, lifecycle isolation, exact flags, editor-versus-runtime compilation, assertions, queue-construction versus await semantics, explicit World ownership, cleanup, hot reload, commandlet execution, and old-global migration.
- [ ] 8.3 <!-- Non-TDD --> Update the Chinese Wiki script-test tiddler and plugin consumer README with the same public contract, without modifying deprecated `Documents/Plans` or archived OpenSpec history.
- [ ] 8.4 <!-- Non-TDD --> Document explicit non-goals and migration boundaries: no parameterized provider, no automatic Map/PIE/network session, no lambda/function-handle callback, and no resumable VM `await`.

## 9. Verification and Review

- [ ] 9.1 <!-- Non-TDD --> Build through `Tools\RunBuild.ps1 -Label as-script-test-framework -TimeoutMs 1800000 -NoXGE` and record the result.
- [ ] 9.2 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework" -Label script-test-framework -TimeoutMs 600000` and record exact pass/fail/skip/timeout counts.
- [ ] 9.3 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.ScriptTests" -Label script-tests -TimeoutMs 600000` and record exact counts for pure, World, fluent latent, and advanced-command example leaves.
- [ ] 9.4 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix as-test-framework-all -TimeoutMs 600000 -ContinueOnFail` and record every prefix result.
- [ ] 9.5 <!-- Non-TDD --> Perform an independent full-diff specification and code-quality review, repair all Critical/Important findings, rerun affected focused tests, and update checkboxes only from fresh evidence.
- [ ] 9.6 <!-- Non-TDD --> Re-run `openspec validate refactor-as-reflected-script-test-suites --type change --strict --no-interactive` after implementation and record final build/test evidence in the change directory.
