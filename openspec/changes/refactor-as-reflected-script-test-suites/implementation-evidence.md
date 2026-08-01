# Implementation Evidence

## Scope and Isolation

- Change: `refactor-as-reflected-script-test-suites`
- Parent branch: `refactor-as-reflected-script-test-suites`
- `Plugins/Angelscript` submodule branch:
  `refactor-as-reflected-script-test-suites`
- Isolated physical worktree:
  `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-reflected-script-test-suites`
- Short UE build path: `D:\ASWT\reflected-tests`
- The pre-existing dirty main checkout was not used for implementation,
  build, or test execution.

## Implemented Contract

The implementation replaces the global `Test_*` /
`IntegrationTest_*` protocol with reflected AngelScript test classes:

- `UAngelscriptTestSuite` is the one native base class.
- A zero-parameter `void` instance method becomes a leaf only when its
  `UFUNCTION` metadata contains `AngelscriptTest`.
- Suite metadata supplies one exact `EAutomationTestFlags` mask; multiple
  contexts may be combined with one filter.
- Registry descriptors use the stable identity
  `(Module, Suite, Method)` and are published as immutable generations only
  after successful class generation.
- Every leaf gets a fresh suite instance. `BeforeAll` / `AfterAll` use a
  separate per-suite session instance and cannot use leaf-bound APIs.
- Assertions, expected-error matching, explicit local World ownership,
  Spawn/BeginPlay/Tick/AdvanceTime helpers, fluent latent commands, advanced
  `ULatentAutomationCommand`, teardown, and cleanup share one runner.
- UE Automation uses persistent bridges partitioned by exact flag mask and
  publishes leaves below
  `Angelscript.ScriptTests.<Module>.<Suite>.<Method>`.
- Hot reload cancels affected old-generation work at a script callback
  boundary, performs old-generation cleanup, publishes only successful
  generations, and refreshes an already-loaded AutomationController without
  forcing the Editor module to load it.
- The commandlet and automatic hot-reload paths select registry descriptors
  and execute through the same runner.
- The retired global Unit/Integration protocol and its implicit Map/PIE
  settings were removed. Runtime has no CQTest dependency.

Primary implementation files:

- `Testing/AngelscriptTestSuite.*`
- `Testing/AngelscriptScriptTestRegistry.*`
- `Testing/AngelscriptScriptTestRunner.*`
- `Testing/AngelscriptScriptTestWorld.*`
- `Testing/AngelscriptScriptTestCommands.*`
- `Testing/AngelscriptScriptTestAutomation.*`
- `Testing/AngelscriptScriptTestHotReloadRunner.*`
- `AngelscriptEditor/HotReload/AngelscriptScriptTestAutomationRefresh.*`
- `Script/Tests/Test_ReflectedScriptSuites.as`

## Focused Native Framework Tests

The latest complete framework run was:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Testing.ScriptTestFramework" `
  -Label script-test-facade-final-framework-v3 `
  -TimeoutMs 600000
```

Result: **55 passed, 0 failed, 0 skipped, 0 timed out**.
Report:
`Saved\Tests\script-test-facade-final-framework-v3\20260801_121541_878_b022fc01\Report\index.json`.

| Prefix | Passed | Failed | Skipped |
|---|---:|---:|---:|
| Discovery | 6 | 0 | 0 |
| Lifecycle | 2 | 0 | 0 |
| Assertions | 6 | 0 | 0 |
| World | 7 | 0 | 0 |
| Commands | 8 | 0 | 0 |
| Automation | 6 | 0 | 0 |
| HotReload | 20 | 0 | 0 |
| **Total** | **55** | **0** | **0** |

The final aggregate includes the second-review remediation regressions:

- an active Automation section is closed before its owning generation
  reloads and lazily reopens the new-generation `BeforeAll` before the next
  leaf, even when UE keeps the same Automation section active;
- ordinary exceptions and expected errors are captured and finalized outside
  an active UE Automation test, including both synchronous Commandlet and
  automatic hot-reload execution;
- the detached log scope proxies `GWarn` as an `FFeedbackContext`, because
  Error/Warning/Display messages are routed there by UE, and only falls back
  to `GLog` when no feedback context exists;
- a suite-only `AfterAll` failure is source-located and changes the summary
  from a passed leaf to a failed execution, preserving
  `passed + failed == executed`;
- a `BeforeAll`/startup failure leaves the leaf selected but unexecuted and
  does not inflate `failed`; incomplete work is rejected through
  `selected != executed`, while `failed` remains a strict subset of executed
  leaves;
- the hot-reload callback guard is independent from exception-log
  suppression: direct AngelScript contexts suppress the global duplicate
  only while their caller checks `asEXECUTION_EXCEPTION`, whereas advanced
  command `ProcessEvent` callbacks keep ordinary exceptions visible to the
  attached or detached result;
- ordinary `AfterEach` and registered-cleanup exceptions remain separately
  source-located after an earlier primary leaf failure; only the private
  controlled-assertion exception is consumed as already reported;
- the client-enabled advanced command timeout now covers every phase through
  `FinishClient`; allowed timeouts still run server `After`, destroy the
  executor, clear their suite association, and terminate, while an executor
  lost after creation becomes a bounded phase-specific failure;
- each active leaf and Automation All-hook session records its owning
  `FAngelscriptEngine`; shutdown cancels/closes only that engine's state
  before extension detachment and script-function release;
- the engine-owned automatic hot-reload runner is also destroyed before
  extension detachment, so its independent All-hook session executes
  `AfterAll` exactly once while extensions and the old script generation
  remain usable;
- automatic hot-reload failures are consumed once instead of being reported
  again on every idle tick;
- success, assertion failure, ordinary exception, timeout, and explicit
  cancellation all release tracked UObject, Actor, Component, GameInstance,
  World, World-context, and ambient-context state; reload invalidation and
  advanced-command release remain covered by the HotReload group.

Latest focused checkpoints represented by the final aggregate passed:

- Assertions: 6/6, including ordinary secondary cleanup exceptions;
- Commands: 7/7, including allowed client timeout finalization;
- HotReload: 19/19, including active leaf and All-hook session cancellation
  during owning-engine shutdown;
- World: 6/6, including the terminal cleanup matrix.

## Reflected AngelScript Examples

The latest example run was:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.ScriptTests" `
  -Label as-script-test-consumer-examples-fixed `
  -TimeoutMs 600000
```

Result: **12 passed, 0 failed, 0 skipped, 0 timed out**.

The leaves cover a pure assertion test, two fresh-fixture/state-isolation
tests with lifecycle/cleanup ordering, contains and regex/count expected
errors, World-free `SpawnObject`, `CreateTestWorld(true)` GameInstance and
subsystem initialization, explicit local World/Spawn/Tick, fluent
`WaitDelay` / `Until` / `Then`, an advanced latent command, an exact
multi-context runtime-capable mask, and an Editor-compiled EditorContext
suite.

The exported report proves the concrete module path is
`Tests.Test_ReflectedScriptSuites`, for example:

```text
Angelscript.ScriptTests.Tests.Test_ReflectedScriptSuites.UReflectedFixtureScriptTests.FirstLeafGetsFreshFixtureState
```

An initial consumer-example run exposed a real compilation-boundary pitfall:
calling a script class's `StaticClass()` outside `#if EDITOR` failed initial
script compilation and the unattended process then waited on the startup
retry modal until the runner timeout. The pure UObject example was moved
inside `#if EDITOR`; the next complete run finished in 29.8 seconds with all
12 leaves passing. This is now documented separately from `EditorContext`,
which controls execution eligibility rather than compilation.

The direct commandlet route was also run:

```powershell
Tools\RunCommandlet.ps1 `
  -Commandlet AngelscriptTest `
  -Label as-script-test-green-final-review-commandlet-v3 `
  -TimeoutMs 600000
```

Result: process exit 0, commandlet exit 0, no timeout, and the reflected-test
summary reported **selected=1, executed=1, passed=1, failed=0**. The
runtime-capable example is the only example leaf with `CommandletContext`;
Editor-only leaves are filtered by their exact flags. An empty eligible
registry, incomplete execution, any leaf failure, or an All-hook lifecycle
failure returns a non-zero validation result.

## Build

Final Editor build:

```powershell
Tools\RunBuild.ps1 `
  -Label as-script-test-final-review-build-v3 `
  -TimeoutMs 1800000 `
  -NoXGE
```

Result: **Succeeded**, recompiled and relinked `AngelscriptRuntime`,
process/final exit code 0.

Final non-Editor target validation:

```powershell
dotnet UnrealBuildTool.dll `
  AngelscriptProject Win64 Development `
  -Project=D:\ASWT\reflected-tests\AngelscriptProject.uproject `
  -architecture=x64 `
  -NoMutex -NoEngineChanges -NoXGE
```

Result: **Succeeded**. UBT recompiled `AngelscriptRuntime`, linked
`AngelscriptProject.exe`, and wrote the Game target metadata. This verifies
that discovery and successful-generation snapshot publication compile at the
development-automation/runtime-test boundary without an Editor or CQTest
dependency.

Because the final hardening also changed the shared
`FAngelscriptEngine::Shutdown()` order, the complete Engine integration prefix
was rerun:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Engine" `
  -Label as-script-test-final-review-engine-lifecycle `
  -TimeoutMs 600000
```

Result: **101 passed, 0 failed, 0 skipped, 0 timed out**.

Two isolated baseline compile repairs were necessary before the new
framework could be validated:

- restored missing native-module test includes in
  `AngelscriptNativeModuleSectionTests.cpp` and
  `AngelscriptNativeModuleStateTableTests.cpp`;
- normalized inline AngelScript formatting in
  `AngelscriptTestMacros.h`.

These changes are test-build prerequisites and do not alter the public
script-test contract.

## Full Configured Suite

The configured full-suite entry point was:

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -LabelPrefix as-test-framework-all `
  -TimeoutMs 600000 `
  -ContinueOnFail
```

The facade follow-up read the exact 35-prefix `All` definition from
`Tools/Shared/TestSuiteDefinitions.ps1`. The suite wrapper completed the
first six prefixes before its outer host process was terminated; the
remaining formal prefixes were continued through the same `RunTests.ps1`
entry point and report format. This produced reports for every configured
prefix under `Saved\Tests\script-test-facade-all_*`.

The first StaticJIT attempt reproduced a stale generated-AOT/cache mismatch
in `ConsoleCommandFunctionPaths` (`PrecompiledData.cpp:2002`) before it could
write an Automation report. This is the repository's paired-artifact
workflow rather than a script-test result: the new facade bindings changed
the saved type-reference surface while the checked-out local AOT fixture was
from the preceding build. The prescribed command was therefore run:

```powershell
Tools\RunStaticJITTests.ps1 `
  -LabelPrefix script-test-facade-staticjit-paired `
  -BuildTimeoutMs 1800000 `
  -CommandletTimeoutMs 600000 `
  -TestTimeoutMs 900000
```

Its replacement StaticJIT report passed **30/30** at
`Saved\Tests\script-test-facade-staticjit-paired_04_tests\20260801_114518_912_926937e4\Summary.json`.
Combining the other 34 formal-prefix reports with that prescribed paired-AOT
result gives **35/35 prefixes and 2404/2404 tests passed**, with **0 failed,
0 skipped, and 0 timed out**. Machine-address-dependent generated fixture
changes and the temporary config redirect were not retained in the source
diff.

| # | Prefix | Final result |
|---:|---|---:|
| 1 | Editor | 74/74 |
| 2 | GAS | 248/248 |
| 3 | GameplayTags | 12/12 |
| 4 | Template | 32/32 |
| 5 | Actor | 52/52 |
| 6 | AngelScriptSDK | 691/691 |
| 7 | Bindings | 244/244 |
| 8 | Blueprint | 11/11 |
| 9 | Generator | 92/92 |
| 10 | Compiler | 81/81 |
| 11 | Component | 20/20 |
| 12 | Core | 52/52 |
| 13 | Debugger | 38/38 |
| 14 | Delegate | 13/13 |
| 15 | Dump | 12/12 |
| 16 | TestModuleEditor | 12/12 |
| 17 | Engine | 101/101 |
| 18 | FileSystem | 22/22 |
| 19 | Functional | 127/127 |
| 20 | FunctionLibraries | 17/17 |
| 21 | GameInstanceSubsystem | 1/1 |
| 22 | GC | 11/11 |
| 23 | HotReload | 122/122 |
| 24 | Inheritance | 3/3 |
| 25 | Interface | 11/11 |
| 26 | Memory | 7/7 |
| 27 | Networking | 6/6 |
| 28 | Parity | 15/15 |
| 29 | Performance | 4/4 |
| 30 | Preprocessor | 60/60 |
| 31 | Shared | 33/33 |
| 32 | StaticJIT | 30/30 after required AOT preparation |
| 33 | Syntax | 140/140 |
| 34 | Validation | 7/7 |
| 35 | WorldSubsystem | 3/3 |

## Documentation Validation

Updated:

- Chinese-first `Documents/Guides/Test.md`
- plugin consumer `README.md`
- Chinese Wiki tiddler
  `docs/zh-Hans/testing-diagnostics-release/script-tests.tid`

Focused Wiki validation:

```powershell
node --test `
  scripts/document-content-contract.test.mjs `
  scripts/document-resolution.test.mjs
```

Result: **40 passed, 0 failed**.

A broader three-file Wiki run produced 46/47 because an unrelated,
pre-existing generated `AS_ByteCode.md` file has CRLF/LF drift. The changed
script-test tiddler passed the repository content contract. `pnpm` and
`corepack` were unavailable on this machine; direct Node execution was used.
The installed Node is v25.5.0 while the Wiki declares `>=24 <25`, so the
focused result is recorded without claiming a package-manager/toolchain
match.

## Final Review

The full diff and OpenSpec contract were reviewed again after the
second-review remediation. Important findings repaired across both reviews:

- network client-side advanced-command callbacks are now inside the
  script-test callback scope, so reload cannot replace code mid-callback;
- a dedicated active-advanced-command reload regression now proves
  `After`, old-generation teardown, and GC release; the regression initially
  exposed that direct cancellation entered `AfterEach` before finalizing the
  active command, so `Cancel()` now finalizes the current advanced command
  first, matching the asynchronous failure path;
- All-hook execution now uses the current generated AngelScript override,
  captures ordinary exceptions in a dedicated lifecycle result, skips leaves
  after `BeforeAll` failure, still runs `AfterAll`, and rejects leaf-only
  helpers even when an assertion predicate would otherwise pass;
- Automation All-hook sessions owned by a changing module are now closed
  before compilation, and the next leaf lazily opens the new-generation
  session even if UE does not re-enter the Automation section;
- detached execution now captures UE Error/Warning/Display messages from
  `GWarn` without classifying unrelated Verbose output as errors, so ordinary
  exceptions and `ExpectedError` contains/regex/count semantics are identical
  in Automation, Commandlet, and automatic hot-reload routes;
- `BeforeAll`/`AfterAll` diagnostics retain script source locations,
  automatic hot-reload failure is sticky for exactly one consumer, and an
  `AfterAll`-only failure is represented in the four-count summary;
- successful discovery snapshots are published for supported development
  runtime builds, and the real Commandlet fails empty or incomplete
  execution instead of reporting a vacuous success;
- terminal resource cleanup has a GC-backed matrix covering assertion,
  ordinary exception, timeout, and explicit cancellation in addition to the
  existing success and reload-invalidation coverage;
- selected-but-unstarted leaves are no longer counted as failed executions;
  a red/green `BeforeAll` regression protects the documented four-count
  invariant and the success predicate enforces it;
- ordinary exceptions from advanced-command `ProcessEvent` callbacks are no
  longer hidden by the hot-reload callback scope; a red/green detached-runner
  regression proves that the exception reaches the leaf result and stops the
  command sequence;
- cleanup callbacks no longer hide a second ordinary exception after the
  primary failure; both `AfterEach` and registered teardown paths have
  red/green detached-runner coverage;
- client-enabled advanced commands have a finite state machine through
  `FinishClient`: an allowed timeout still finalizes server cleanup and
  destroys its executor, and a missing weak executor fails without a null
  dereference;
- engine shutdown cancels active leaves and closes the owning All-hook
  session before releasing AS functions; the regression proves the cleanup
  callback ran and the session was cleared;
- the unsafe registry raw-pointer convenience lookup was removed, and World
  creation now rolls back GameInstance/WorldContext state on failure;
- validation-generated StaticJIT/config artifacts were removed from the
  source diff.

Post-repair reruns passed:

- Assertions: 6/6;
- World: 7/7;
- Commands: 8/8;
- HotReload: 20/20;
- complete native ScriptTestFramework: 55/55;
- Engine integration/lifecycle prefix: 101/101;
- reflected AngelScript examples: 12/12;
- final Editor build: succeeded;
- final Development Game build: succeeded after recompiling Runtime;
- commandlet: selected 1, executed 1, passed 1, failed 0;
- focused Wiki content/resolution tests: 40/40;
- strict OpenSpec validation: passed.

Static checks:

- parent, plugin, and Wiki `git diff --check`: clean;
- retired live protocol symbol scan: no matches;
- CQTest/macro dependency scan in Runtime Testing: no matches;
- temporary detached-capture diagnostics: no matches.

## Stateless Facade Follow-up (2026-08-01)

The final API responsibility split is:

- `UAngelscriptTestSuite`: reflected lifecycle, assertions,
  expected-error registration, and compatibility `GetWorld()`;
- fieldless `FAngelscriptTest`: callback-scoped World, Spawn, BeginPlay,
  Tick, time-advance, destroy, and `Commands()` entry points exposed as
  same-name AngelScript namespace globals;
- fieldless value-style `FAngelscriptTestCommandBuilder`: fluent latent
  queue authoring without retaining a suite or execution-context pointer.

Each facade/builder call resolves only the top entry of the runner's
callback-context stack. Ordinary and advanced server callbacks push their
leaf context; All hooks and advanced client callbacks push an explicit null
barrier. There is no fallback scan across waiting leaves, so nested helpers,
concurrent waiting leaves, hot reload, cancellation, and server/client
boundaries cannot reuse an unrelated suite.

TDD API evidence:

- RED discovery/API run: **11 passed and 2 failed as expected** before the
  facade types/bindings existed, at
  `Saved\Tests\script-test-facade-red\20260801_103615_306_b0260a62\Report\index.json`;
- focused facade API green run: **2/2 passed** at
  `Saved\Tests\script-test-facade-green-api-2\20260801_105221_469_ffdaf705\Report\index.json`;
- shutdown-order RED: the new automatic-session regression reached the
  intended assertion and failed because the runner still existed during
  extension detach, at
  `Saved\Tests\script-test-shutdown-order-red-target\20260801_120444_471_d006d348\Report\index.json`;
- after moving engine-owned automatic-runner destruction before extension
  detach, the strengthened regression proves successful `AfterAll` execution
  exactly once and passed **1/1** at
  `Saved\Tests\script-test-shutdown-order-exactly-once-v2\20260801_121505_176_2326bd49\Report\index.json`.

Final builds:

- Development Editor: succeeded via `Tools\RunBuild.ps1`, final up-to-date
  confirmation at
  `Saved\Build\script-test-facade-final-editor-v3\20260801_121702_692_121c2feb`;
- Development Game: succeeded after **5 actions**, including recompiling
  `AngelscriptRuntime` and linking `AngelscriptProject.exe`, at
  `Saved\Build\script-test-facade-final-game-v3\20260801_121641_306_afc016cc`.
  The worktree-local `AgentConfig.ini` target was restored to
  `AngelscriptProjectEditor` immediately afterward.

Final test evidence:

- native `ScriptTestFramework`: **55 passed, 0 failed, 0 skipped, 0 timed
  out**, report
  `Saved\Tests\script-test-facade-final-framework-v3\20260801_121541_878_b022fc01\Report\index.json`;
- runnable reflected AngelScript examples: **12 passed, 0 failed, 0 skipped,
  0 timed out**, report
  `Saved\Tests\script-test-facade-final-examples-v2\20260801_120844_729_c945c416\Report\index.json`;
- real Commandlet route: **selected 1, executed 1, passed 1, failed 0**, log
  `Saved\Commandlet\script-test-facade-final-commandlet-v2\20260801_121111_654_0b1b21b4\Commandlet.log`;
- configured `All` suite: the other 34 prefixes passed **2374/2374** and the
  prescribed paired StaticJIT generation/build/test flow passed **30/30**,
  for a combined **35/35 prefixes and 2404/2404 tests**, with zero failures,
  skips, and timeouts;
- focused Wiki content/resolution contracts: **40/40 passed**.

Final record validation passed:

- `openspec validate refactor-as-reflected-script-test-suites --type change
  --strict --no-interactive`;
- parent, plugin, and Wiki `git diff --check`;
- Runtime Testing dependency scan: no CQTest or AutomationController match;
- retired protocol/suite-tool scan: no live match.

No machine-address-dependent StaticJIT generated changes or temporary
`DefaultEngine.ini` redirect is included in the semantic source diff.

The final independent read-only review reported **no Critical or Important
findings** and a **Ready** verdict after inspecting the shutdown order,
exactly-once cleanup, test-only observer boundary, and the fresh 1/1 plus
55/55 reports.

## Main Integration Verification (2026-08-02)

The completed feature branch was integrated with the later standalone and
coverage commits already present on `main`. The plugin merge retained the
maintained `NormalizeInlineASSourcePreserveLines` helper used by native SDK
coverage while dropping the feature branch's unreferenced ANSI preserve-lines
helper and macros. The parent merge retains the existing `Wiki` gitlink at
`6ebec23f1eaed7050661ff986617e2316cba21f2`; no Wiki source or gitlink change
from this feature was integrated.

Fresh integration evidence:

- Development Editor build: succeeded, report
  `Saved\Build\reflected-script-suites-main-merge\20260801_235724_534_456cd5ec`;
- native `ScriptTestFramework`: **55/55 passed**, report
  `Saved\Tests\reflected-script-suites-main-framework\20260801_235945_799_563f355b\Report\index.json`;
- runnable reflected AngelScript examples: **12/12 passed**, report
  `Saved\Tests\reflected-script-suites-main-examples\20260802_000201_295_24a832f1\Report\index.json`;
- real Commandlet route: **selected 1, executed 1, passed 1, failed 0**, log
  `Saved\Commandlet\reflected-script-suites-main-commandlet\20260802_000234_834_cf16d3e3\Commandlet.log`;
- strict OpenSpec validation: passed with all four schema artifacts complete.

The configured `All` suite completed all 35 prefixes. Its first pass exposed
one deterministic stale Syntax expectation: the pre-existing negative case
expected `void Foo(int)` to fail, while standalone commit `b7c9ce9` had already
backported the upstream grammar in which parameter names are optional. The
reflected-suite merge did not modify the Syntax, Language, parser, or compiler
paths responsible for that behavior. The stale negative case was moved to the
positive `Params_UnnamedParameter` coverage without changing runtime code.

- the other 34 prefixes passed **2274/2274**, including Engine **101/101**,
  AngelScriptSDK **691/691**, HotReload **122/122**, and StaticJIT **30/30**;
- after the test-only reconciliation, the full Syntax prefix passed
  **141/141**, report
  `Saved\Tests\reflected-script-suites-main-syntax-fixed\20260802_004950_037_db3669ac\Report\index.json`;
- the combined final configured scope is therefore **35/35 prefixes and
  2415/2415 tests**, with zero failures, skips, and timeouts.

The orchestration tool's 30-minute console wait expired while the suite was
running, but the underlying `RunTestSuite.ps1` process continued normally and
produced all 35 reports. Every per-prefix `RunMetadata.json` recorded exit code
zero after substituting the fresh, corrected Syntax run.
