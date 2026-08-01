# Research Notes

## Current plugin behavior

- `DiscoverTests.cpp` scans global module functions named `Test_*`,
  `ComplexUnitTest_*`, `IntegrationTest_*`, and
  `ComplexIntegrationTest_*`, then stores executable function pointers on
  `FAngelscriptModuleDesc`.
- `UnitTest.cpp` registers `Angelscript.UnitTests`, creates an implicit
  Package/GameInstance/World environment, exposes mutable `FUnitTest`, and
  drives automatic hot-reload batches.
- `IntegrationTest.cpp` registers `Angelscript.IntegrationTests`, opens a map
  derived from `IntegrationTestMapRoot`, starts PIE, queues
  `ULatentAutomationCommand`, and coordinates optional server/client command
  phases.
- `ULatentAutomationCommand` exposes `Before`, `Update`, `After`,
  `BeforeOnClient`, `UpdateOnClient`, `AfterOnClient`, descriptions,
  timeout policy, and `bAlsoRunOnClient`. It currently keeps a shared
  `FAngelscriptIntegrationTest` context and may be rooted until cleanup.
- Successful `FAngelscriptEngine::CompileModules` runs discovery after
  compilation. `FHotReloadTestRunner` queues shared module descriptors rather
  than stable identities.
- Existing project script roots contain little active use of the old global
  protocol, but external plugin users still receive an intentional breaking
  migration.

## CQTest command behavior used as the model

- `FTestCommandBuilder::Do` and `Then` are aliases that append an execute
  command to a FIFO queue.
- `StartWhen` and `Until` are aliases that poll a boolean query on subsequent
  Automation updates until success or timeout.
- `WaitDelay` is an explicit real-time delay; CQTest warns that condition
  waits are preferable because fixed delays can be flaky.
- `OnTearDown` and `CleanUpWith` build a separate queue that is reversed
  before execution, so cleanup is last-in-first-out and runs after ordinary
  failures.
- CQTest rejects adding latent actions from inside a latent action. The AS
  design keeps this restriction rather than mutating a queue while it is
  executing.
- CQTest uses lambdas/TFunction callbacks. The AS-facing equivalent cannot use
  that syntax on this fork, so it uses an ordinary unmarked suite method name,
  resolved against the current suite generation.
- CQTest remains a test-only reference. Production Runtime code must reproduce
  the required semantics without depending on the Developer-only module.

## Existing World/Spawn evidence

- `AngelscriptTest/Shared/AngelscriptTestWorld.h` composes CQTest's
  `FActorTestSpawner`, initializes game subsystems, creates a test World, and
  exposes script-actor spawn, BeginPlay, world tick, precise Actor/Component
  tick, and destroy-and-drain behavior.
- `AngelscriptTestWorldTests.cpp`, `Template_WorldTick.cpp`, and
  `Template_GameLifetime.cpp` already lock down the C++ harness behavior.
- That harness lives in `AngelscriptTest` and cannot become a production
  dependency of `AngelscriptRuntime`. The Runtime suite therefore owns an
  equivalent private World state implemented with Engine APIs, while the
  existing harness is reused for regression expectations and test setup.
- The public AS surface does not need `UAngelscriptTestWorld`: one active
  method execution context can track the World, GameInstance, spawned actors,
  components, and strong UObject references behind `UAngelscriptTestSuite`.

## AngelScript callable and await constraints

- Dynamic Unreal delegates are available to AS, but constructing and binding a
  delegate for every step would require extra declarations and
  `BindUFunction(this, n"...")`, which is too verbose for the primary test API.
- Native AngelScript `funcdef`/function-pointer syntax is explicitly covered
  as unsupported on the current branch. Lambda behavior remains Disabled
  under `#as-v238-backport`.
- Although the third-party compiler contains newer lambda-related code, the
  active fork does not expose a supported function-handle contract.
- `asIScriptContext::Suspend()` currently returns `asERROR`; the Runtime
  context pool also asserts that contexts are not suspended when released.
- A synchronous-looking `Wait(); Continue();` API would therefore require a
  separate VM suspension/resumption, stack lifetime, debugger, GC, and hot
  reload project. This change intentionally uses a fluent callback queue
  instead and leaves a future function-handle overload compatible with the
  same command semantics.

## UE Automation flags and registration findings

- `FAutomationTestBase::GetTestFlags()` applies to the complete simple or
  complex test registration. `GenerateTestNames()` cannot provide a different
  flag mask for each leaf under one complex root.
- A single static `Angelscript.ScriptTests` complex root therefore cannot
  correctly mix Editor, Client, Server, Commandlet, feature, priority, and
  filter flags declared by separate AS suites.
- Runtime must group descriptors by exact `EAutomationTestFlags` mask and keep
  one bridge instance per encountered mask. Bridge instances stay registered
  until module shutdown; reload only changes immutable descriptor snapshots.
- Internal bridge registration names must be unique, while beautified leaf
  names remain
  `Angelscript.ScriptTests.<Module>.<Suite>.<Method>`.
- A valid suite mask has at least one Application Context bit and exactly one
  Filter bit. Unknown names or invalid mask composition must be source-located
  diagnostics rather than silent defaults.
- `#if EDITOR` already controls compilation of editor-only AS blocks and marks
  reflected types/functions editor-only. Automation `EditorContext` controls
  selection and does not make an editor-only dependency compile safely by
  itself.

## UE Automation and hot-reload findings

- AutomationController caches the test list. Added, removed, renamed,
  re-marked, or re-flagged script methods are not visible until
  `RequestTests()` is issued.
- Section enter occurs before a leaf starts. Section leave for the final leaf
  occurs after its result has been submitted, so `AfterAll` cannot reliably
  alter that final result and is a lifecycle/session diagnostic.
- Section notifications and suite sessions are process-local. A distributed
  controller can split leaves; All hooks are therefore per worker.
- `UASClass::GetMostUpToDateClass()` follows `NewerVersion`. Long-lived
  `UClass*`, `UFunction*`, `asIScriptFunction*`, and module-descriptor
  references are unsafe across reload.
- Discovery must use active module/class descriptions, not a global UObject
  iterator, or replaced generated classes may be rediscovered.
- `GetPreCompile()` is the last point where an affected old-generation suite,
  callbacks, advanced commands, and World can be cleaned while their code is
  valid.
- Knot inspection of CQTest PIE/network components confirms the same ordering
  principle: stop active sessions, restore editor/network state, and release
  World references before replacing code or starting another session.
- Failed compilation must retain the last-good registry. A later run lazily
  opens the old generation again.
- Rapid hot reload must replace pending automatic test work with the latest
  generation; it must never migrate an active AS stack, suite object, command,
  Actor, or World to new code.

## Resulting constraints

- Stable test identity is the original
  `(ModuleName, SuiteClassName, TestMethodName)` tuple. Display normalization
  never replaces execution identity.
- Stable callback identity is the active test identity plus the ordinary
  helper method `FName`; queues do not retain executable function pointers.
- Registry publication, World ownership, command updates, and callback
  invocation occur on the game thread.
- A test remains pure until it explicitly calls `CreateTestWorld()`.
- A method execution owns at most one local test World.
- Assertions are valid in `BeforeEach`, the marked method, `AfterEach`, and
  command callbacks while a leaf is active. All hooks are synchronous
  suite-session setup/cleanup and cannot own method-local World or latent
  work.
- This change preserves the advanced command protocol but does not create a
  map, PIE session, or multiplayer topology for it.
- Parameterized/Complex providers, automatic Map/PIE/network orchestration,
  function-handle/lambda support, and VM `await` remain separate capabilities.
