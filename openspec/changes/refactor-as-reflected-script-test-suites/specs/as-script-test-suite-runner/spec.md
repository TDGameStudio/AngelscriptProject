## MODIFIED Requirements

### Requirement: Script tests inherit a native suite base
The AngelScript test framework SHALL discover script-side tests only from
concrete AngelScript classes that inherit the native script test suite base.

#### Scenario: Concrete derived suite class is discovered
- **WHEN** an active compiled script module contains a concrete script class derived from `UAngelscriptTestSuite`
- **THEN** the framework considers methods declared by that class for script test discovery

#### Scenario: Abstract derived suite class is ignored
- **WHEN** an active compiled script module contains an abstract class derived from `UAngelscriptTestSuite`
- **THEN** the framework does not register Automation leaves for that class

#### Scenario: Non-derived class is ignored
- **WHEN** a compiled script module contains a class with marked or test-like methods that does not derive from `UAngelscriptTestSuite`
- **THEN** the framework does not register that class as a script test suite

#### Scenario: Global test function is ignored
- **WHEN** a compiled script module contains a module-level `Test_*(FUnitTest& T)`, `IntegrationTest_*(FIntegrationTest& T)`, or Complex test function
- **THEN** the script suite runner does not register it as a test

### Requirement: Suite methods use fixed lifecycle names
The AngelScript test framework SHALL expose optional no-argument
`BeforeAll`, `BeforeEach`, `AfterEach`, and `AfterAll` native lifecycle events
that script suites override using `UFUNCTION(BlueprintOverride)`.

#### Scenario: Lifecycle methods run around selected leaves
- **WHEN** one or more methods from a suite are selected on one Automation worker
- **THEN** the runner executes `BeforeAll` once for that worker and generation, `BeforeEach` and `AfterEach` around each selected method, and `AfterAll` once when the suite section closes

#### Scenario: Each leaf uses an isolated method instance
- **WHEN** two methods from the same suite run sequentially
- **THEN** each method receives a fresh suite instance shared only by its `BeforeEach`, method body, callbacks, and `AfterEach`

#### Scenario: All hooks use a separate instance
- **WHEN** a suite section opens
- **THEN** the runner creates a separate suite-scope instance for `BeforeAll` and `AfterAll` and does not copy its ordinary member state into method instances

#### Scenario: All hooks reject method-local operations
- **WHEN** `BeforeAll` or `AfterAll` creates a local test World, queues a latent command, or calls a leaf-bound assertion or expected-log helper
- **THEN** the framework reports source-located lifecycle misuse and does not retain method-local state

#### Scenario: BeforeAll throws
- **WHEN** `BeforeAll` throws an ordinary script exception
- **THEN** selected leaves report the suite setup failure without running per-method hooks and the framework still attempts `AfterAll`

#### Scenario: Method failure still tears down
- **WHEN** `BeforeEach`, a test method, or a latent callback fails
- **THEN** the runner still invokes `AfterEach`, teardown callbacks, and automatic World cleanup

#### Scenario: Reload changes the lifecycle generation
- **WHEN** a suite is successfully recompiled between selected methods
- **THEN** the runner closes or cancels the old generation and runs the new generation's `BeforeAll` before its next leaf

#### Scenario: AfterAll fails after the final leaf
- **WHEN** `AfterAll` throws after UE Automation has submitted the final leaf result
- **THEN** the framework emits a source-located lifecycle/session diagnostic without retroactively changing a submitted leaf

### Requirement: Test methods are inherited-base instance methods
The AngelScript test framework SHALL register only directly declared,
non-static, zero-argument suite instance methods that return `void` and carry
`UFUNCTION(meta=(AngelscriptTest))`.

#### Scenario: Arbitrarily named marked method is registered
- **WHEN** a concrete suite directly declares `UFUNCTION(meta=(AngelscriptTest)) void AdditionProducesExpectedValue()`
- **THEN** the runner registers that method without requiring a `Test_*` name or `UFUNCTION(Test)`

#### Scenario: Unmarked helper is ignored
- **WHEN** a suite declares an unmarked helper method
- **THEN** the runner does not register the helper as a test leaf

#### Scenario: Unmarked helper remains callable by commands
- **WHEN** a suite queues a valid ordinary helper method by `FName`
- **THEN** the command runner may invoke that helper without requiring it to be a UFUNCTION or a test leaf

#### Scenario: Inherited marked method is not duplicated
- **WHEN** a concrete suite inherits a marked test method from a script base class
- **THEN** the runner does not register that inherited method as a leaf for the concrete suite

#### Scenario: Invalid method signature is rejected
- **WHEN** a marked method is static, has parameters, or returns a non-void type
- **THEN** the runner omits it and reports a source-located discovery diagnostic

#### Scenario: Marked method is not Blueprint callable
- **WHEN** the class generator processes an `AngelscriptTest` method
- **THEN** it preserves the reflected function, marker metadata, and source location while clearing ordinary Blueprint-callable exposure

#### Scenario: Normalized method names collide
- **WHEN** two marked methods in one suite normalize to the same Automation path segment
- **THEN** the suite omits the conflicting leaves and reports both source locations

### Requirement: Native base exposes test helper methods
The native script test suite base SHALL provide C++-implemented script-callable
helpers for failure, truth, null, identity, equality, near, relational, and
expected-log operations without requiring a mutable context parameter. A
fieldless `FAngelscriptTest` USTRUCT SHALL expose local World, object spawn,
BeginPlay, tick, time advancement, destruction, and command-builder entry
points as same-name namespace-global functions.

#### Scenario: Test calls inherited assertion
- **WHEN** a marked method calls an inherited helper such as `AssertEquals`
- **THEN** the helper reports through the currently active Automation leaf

#### Scenario: Test creates a local World
- **WHEN** `BeforeEach` or a marked method calls `FAngelscriptTest::CreateTestWorld`
- **THEN** the execution context creates one transient local test World and makes it available through `FAngelscriptTest::GetTestWorld`

#### Scenario: Test spawns tracked objects
- **WHEN** a leaf uses the `FAngelscriptTest::SpawnObject`, `SpawnActor`, or `SpawnComponent` global facade
- **THEN** the framework validates the requested type and ownership and tracks the created object for terminal cleanup

#### Scenario: Test dispatches lifecycle and ticks
- **WHEN** a leaf calls BeginPlay, World tick, precise Actor tick, precise Component tick, time advancement, or destroy-and-drain helpers
- **THEN** the framework performs the operation in the active test World and reports misuse through the active leaf

#### Scenario: Expected log is matched
- **WHEN** a leaf configures `ExpectError` or `ExpectErrorRegex` with an occurrence count and matching errors are emitted
- **THEN** the expected errors do not fail the leaf

#### Scenario: Assertion errors cannot be expected away
- **WHEN** an expected-log pattern would also match a framework assertion error
- **THEN** the assertion still fails the leaf

#### Scenario: Helper is called outside an active leaf
- **WHEN** a suite assertion or `FAngelscriptTest` facade/builder operation that requires an execution context is called without an active method leaf
- **THEN** the framework reports lifecycle misuse and does not access stale test state

#### Scenario: Environment helpers are not inherited suite methods
- **WHEN** a suite attempts to call a World, Spawn, Tick, or command helper without the `FAngelscriptTest` facade
- **THEN** script compilation rejects the removed inherited API while inherited assertions and `GetWorld()` remain available

### Requirement: Native base is a transient UClass
The native script test suite base SHALL be an abstract transient native
`UCLASS` derived from `UObject`, exported by `AngelscriptRuntime`, usable as
the code superclass for generated AngelScript test classes, and the only
framework test class required by ordinary AS authors.

#### Scenario: Script suite derives from native UClass
- **WHEN** a script declares `class UExampleTests : UAngelscriptTestSuite`
- **THEN** the generated script class uses `UAngelscriptTestSuite` as its native superclass

#### Scenario: Runner creates a fresh method instance
- **WHEN** the runner executes a marked method
- **THEN** it creates a fresh transient suite instance and associates it with one execution context

#### Scenario: Method state does not leak
- **WHEN** one method changes suite member state
- **THEN** a later method starts from a newly constructed suite instance

#### Scenario: Normal test does not require another framework object
- **WHEN** an AS author writes a pure, World-backed, or ordinary latent test
- **THEN** the author can express it through inherited suite assertions and fieldless `FAngelscriptTest` value facades without constructing a framework World or command-builder UObject

### Requirement: Fixture selection is explicit
The AngelScript test framework SHALL execute suites without a World by default
and SHALL create local World/GameInstance state only when the active method
explicitly calls `CreateTestWorld`.

#### Scenario: Pure test is the default
- **WHEN** a suite method never calls `FAngelscriptTest::CreateTestWorld`
- **THEN** the runner executes it without creating a test World or GameInstance

#### Scenario: Local World is explicit
- **WHEN** a method execution calls `FAngelscriptTest::CreateTestWorld`
- **THEN** the runner creates and owns a local World for that method execution only

#### Scenario: Game subsystems are optional
- **WHEN** `FAngelscriptTest::CreateTestWorld` requests game-subsystem initialization
- **THEN** the framework creates and initializes the corresponding test GameInstance before returning

#### Scenario: Duplicate World creation is rejected
- **WHEN** one method execution calls `FAngelscriptTest::CreateTestWorld` twice without destroying the first World
- **THEN** the second call fails the leaf and does not replace or leak the first World

#### Scenario: World is automatically cleaned
- **WHEN** a World-backed leaf succeeds, asserts, throws, times out, is canceled, or is invalidated by hot reload
- **THEN** the framework destroys tracked actors and components, releases tracked objects, shuts down GameInstance state, destroys the World context, and clears ambient World state

#### Scenario: Map and PIE are not created implicitly
- **WHEN** a suite uses the new local World helpers
- **THEN** the framework does not derive an Integration map name, open a map, start PIE, or create network participants

### Requirement: Assertions distinguish fatal and non-fatal failures
The native script test suite base SHALL expose one fail-fast `Assert*` family
and `Fail`, with no separate non-fatal expectation assertion family.

#### Scenario: Assertion stops the active script call
- **WHEN** an `Assert*` helper or `Fail` fails inside `BeforeEach`, a marked test method, `AfterEach`, or a command callback
- **THEN** the framework records one source-located Automation error and stops subsequent statements in that active script call

#### Scenario: Teardown runs after assertion failure
- **WHEN** `BeforeEach`, a marked test method, or a command callback terminates through a controlled assertion failure
- **THEN** the runner consumes the controlled exception without a duplicate error and still runs `AfterEach` and terminal cleanup

#### Scenario: Ordinary script exception remains distinct
- **WHEN** a lifecycle method, marked method, or callback throws an exception not created by the assertion framework
- **THEN** the runner reports it as an ordinary source-located script exception

#### Scenario: Relational and near overloads preserve type semantics
- **WHEN** a test uses relational or near assertions on a supported numeric or UE math type
- **THEN** the native helper compares values with the documented type-specific tolerance and ordering behavior

### Requirement: Automation registration preserves suite lifecycle
The AngelScript test framework SHALL expose every marked script method as an
independent UE Automation leaf while using persistent bridge registrations
grouped by exact Automation flag mask.

#### Scenario: Method is an independent Automation leaf
- **WHEN** UE Automation requests the script test list
- **THEN** each marked method is enumerated as `Angelscript.ScriptTests.<Module>.<Suite>.<Method>`

#### Scenario: Exact flag mask selects a bridge
- **WHEN** two suites declare different valid Automation flag masks
- **THEN** their descriptors are enumerated by distinct persistent bridge registrations that return the corresponding masks

#### Scenario: Same flag mask reuses a bridge
- **WHEN** multiple suites declare the same valid flag mask
- **THEN** the framework enumerates all of their leaves through one bridge for that exact mask

#### Scenario: Bridge survives reload
- **WHEN** script reload removes all current leaves for an already encountered flag mask
- **THEN** the bridge remains registered until Runtime shutdown and enumerates no leaves for that mask

#### Scenario: Test list order is deterministic
- **WHEN** the same registry content is enumerated repeatedly
- **THEN** leaf paths are ordered deterministically by module, suite, source location, and method

#### Scenario: Leaf exposes script source
- **WHEN** Automation queries a script test's source location
- **THEN** the leaf returns the declaring AngelScript file and method line

#### Scenario: Stale command is safe
- **WHEN** Automation executes a cached command for a method removed or renamed by reload
- **THEN** the command fails with a refresh diagnostic and never invokes an old class or function

### Requirement: Old script test entrypoints are retired
The AngelScript test framework SHALL NOT expose old script-side global unit,
integration, or Complex test entrypoints through the new runner.

#### Scenario: Old unit test entrypoint is not exposed
- **WHEN** UE Automation enumerates script suite tests
- **THEN** global `Test_*(FUnitTest& T)` and `ComplexUnitTest_*` functions are absent

#### Scenario: Old integration test entrypoint is not exposed
- **WHEN** UE Automation enumerates script suite tests
- **THEN** global `IntegrationTest_*(FIntegrationTest& T)` and `ComplexIntegrationTest_*` functions are absent

#### Scenario: Old mutable context types are unavailable
- **WHEN** script bindings initialize after the migration
- **THEN** `FUnitTest`, `FIntegrationTest`, their global `GetParam` protocol, and manual current-test association APIs are not exposed

#### Scenario: Advanced command type remains available
- **WHEN** a class-based suite needs behavior beyond the ordinary fluent commands
- **THEN** it can still derive and enqueue `ULatentAutomationCommand` through `AddLatentCommand`

## ADDED Requirements

### Requirement: Test suites declare exact UE Automation flags
Every concrete script test suite SHALL declare its UE Automation execution
flags through `UCLASS` metadata named `AngelscriptTestFlags`.

#### Scenario: Valid flags are parsed
- **WHEN** a suite declares semicolon-separated supported `EAutomationTestFlags` names with at least one Application Context and exactly one Filter
- **THEN** the registry stores the exact combined flag mask on every descriptor from that suite

#### Scenario: Multiple application contexts are valid
- **WHEN** a runtime-compatible suite declares Client, Server, Commandlet, and Editor context flags with one Filter
- **THEN** the suite remains one logical suite and is selectable in each declared context

#### Scenario: Unknown flag is rejected
- **WHEN** `AngelscriptTestFlags` contains an unknown or empty token
- **THEN** the suite is omitted and receives a source-located diagnostic naming the invalid token

#### Scenario: Context or filter shape is invalid
- **WHEN** a suite declares no Application Context, no Filter, or more than one Filter
- **THEN** the suite is omitted and receives a source-located diagnostic describing the required mask shape

#### Scenario: Flags do not replace editor compile guards
- **WHEN** a suite references an Editor-only type
- **THEN** the script must still place the reference in an `#if EDITOR` block even if the suite declares `EditorContext`

#### Scenario: Flags change during reload
- **WHEN** successful reload changes a suite's flag metadata
- **THEN** the new registry generation moves its descriptors to the new exact-mask bridge without destroying either bridge

### Requirement: Global facade exposes a fluent latent command queue
`FAngelscriptTest::Commands()` SHALL return a fieldless value-style builder
that exposes chainable `Do`/`Then`, `StartWhen`/`Until`, `WaitDelay`, and
`OnTearDown`/`OnCleanup` commands whose callbacks are ordinary methods on the
active suite instance.

#### Scenario: Action commands run FIFO
- **WHEN** a test queues multiple `Do` or `Then` action methods
- **THEN** the runner resolves and invokes them in enqueue order after the marked method finishes constructing the queue

#### Scenario: Condition waits until true
- **WHEN** `Until` names a valid zero-argument bool helper that initially returns false and later returns true
- **THEN** the runner polls it once per Automation update and advances only after it returns true

#### Scenario: Condition times out
- **WHEN** an `Until` or `StartWhen` condition remains false until its timeout
- **THEN** the leaf fails once with the command description, timeout, and AS definition location and proceeds to teardown

#### Scenario: Delay spans Automation updates
- **WHEN** a test queues `WaitDelay` with a valid duration
- **THEN** the runner waits for monotonic real elapsed time without blocking the game thread or advancing the local test World

#### Scenario: Timeout is invalid
- **WHEN** a command specifies a non-finite, non-positive, or greater-than-15-second timeout
- **THEN** enqueue fails immediately at the AS call site

#### Scenario: Callback method is invalid
- **WHEN** an action or condition name is missing, ambiguous, static, parameterized, or has the wrong return type
- **THEN** enqueue fails the leaf with a source-located signature diagnostic

#### Scenario: Teardown is LIFO
- **WHEN** a test registers multiple `OnTearDown` or `OnCleanup` actions
- **THEN** the runner invokes those actions in reverse registration order after `AfterEach`

#### Scenario: Prior failure does not skip teardown
- **WHEN** setup, the marked method, an ordinary command, an assertion, or a timeout fails
- **THEN** remaining main commands are skipped but `AfterEach`, teardown actions, and automatic World cleanup still run

#### Scenario: Cleanup exceptions remain independently visible
- **WHEN** `AfterEach` or a registered teardown callback throws an ordinary script exception after the leaf already recorded a primary failure
- **THEN** the runner also reports that cleanup exception once with its script source location instead of suppressing it as a duplicate assertion

#### Scenario: Callback cannot mutate the active queue
- **WHEN** a running action, condition, or advanced command callback tries to enqueue another main command
- **THEN** the framework rejects the mutation and reports command-lifecycle misuse

#### Scenario: Delayed-dependent work uses Then
- **WHEN** a marked method queues a wait and then continues executing ordinary statements
- **THEN** those statements execute while constructing the queue and only work placed in a later `Then` callback executes after the wait

### Requirement: Advanced latent commands use the class-based execution context
`ULatentAutomationCommand` SHALL remain available as an advanced class-based
extension point and SHALL associate with the active suite execution context
instead of the retired `FIntegrationTest`.

#### Scenario: Advanced command executes its phases
- **WHEN** a suite enqueues a valid advanced command
- **THEN** the runner calls `Before` once, polls `Update` until completion or timeout, calls `After` once, and reports through the active leaf

#### Scenario: Command is retained only while active
- **WHEN** an advanced command is queued or running
- **THEN** the execution context keeps it alive and releases its strong/root association on every terminal path

#### Scenario: Command accesses its current suite
- **WHEN** an associated advanced command calls `GetCurrentSuite`
- **THEN** it receives the active `UAngelscriptTestSuite` instance

#### Scenario: Unassociated command cannot access a suite
- **WHEN** an advanced command calls `GetCurrentSuite` before enqueue or after terminal cleanup
- **THEN** the framework reports lifecycle misuse without returning a stale suite

#### Scenario: Existing client protocol is preserved
- **WHEN** `bAlsoRunOnClient` is enabled and the current test World already provides supported server/client networking
- **THEN** the existing client executor coordinates client phases and forwards client assertion failures to the active server leaf

#### Scenario: Client command deadline includes finalization
- **WHEN** a client-enabled command does not finish setup, polling, or `AfterOnClient` before its timeout
- **THEN** the timeout terminates the command, runs server-side `After` once, destroys the client executor, clears the suite association, and completes the leaf without waiting forever

#### Scenario: Allowed client timeout still terminates
- **WHEN** the same client-enabled command allows timeout
- **THEN** the leaf does not gain a timeout failure but still performs terminal server cleanup and releases the executor

#### Scenario: Client executor disappears
- **WHEN** the weak client executor becomes invalid after creation and before the command reaches `Done`
- **THEN** the runner fails the leaf with the current client phase and finalizes the command without dereferencing the missing executor

#### Scenario: Framework does not create network participants
- **WHEN** a suite enqueues a client-enabled advanced command in a local non-networked test World
- **THEN** the command fails with a clear environment diagnostic rather than starting PIE or creating clients

### Requirement: Test registry and active state are generation-safe across hot reload
The AngelScript test framework SHALL publish immutable generation-tagged
registry snapshots after successful compilation, resolve executable objects
from stable identities immediately before use, and fully clean affected
active execution state before old code is replaced.

#### Scenario: Successful body reload executes new code
- **WHEN** a suite method body is successfully soft-reloaded
- **THEN** the next execution resolves and runs the new function body

#### Scenario: Metadata reload changes discovery
- **WHEN** a successful full reload adds, removes, or moves the `AngelscriptTest` marker or renames a marked method
- **THEN** the next registry generation reflects the new test set

#### Scenario: Failed compile preserves last-good registry
- **WHEN** script compilation fails after precompile cleanup
- **THEN** the previous registry remains available and its suite lifecycle is reopened lazily on the next execution

#### Scenario: Old pointers are not invoked
- **WHEN** a generated suite class has a newer hot-reload version
- **THEN** descriptors, Automation commands, callback queues, and automatic test work resolve the active module, latest class, and current method instead of invoking cached executable pointers

#### Scenario: Active latent leaf is invalidated before compile
- **WHEN** reload affects a module whose suite currently owns queued commands, advanced commands, objects, actors, or a World
- **THEN** the framework abandons remaining main work, runs old-generation `AfterEach` and teardown, releases commands, destroys World state, clears executable references, fails the stale leaf with a rerun diagnostic, and only then permits compilation

#### Scenario: Reload is requested inside a callback
- **WHEN** compilation is requested re-entrantly from an executing test callback
- **THEN** the framework defers the request until the callback boundary and does not retain a suspended AS context

#### Scenario: Newer generation replaces automatic test work
- **WHEN** another reload occurs while older-generation automatic hot-reload tests remain queued or active
- **THEN** the runner cleans the old work and rebuilds the queue from the latest successful generation

#### Scenario: Active state is never migrated
- **WHEN** a suite reloads during a test session
- **THEN** no suite object, callback frame, advanced command, World, Actor, component, or tracked UObject is transferred to the new generation

#### Scenario: Owning engine shuts down with active test state
- **WHEN** an AngelScript engine begins shutdown while it owns an active latent leaf or suite-level All-hook session
- **THEN** the framework cancels the leaf, runs its old-engine cleanup, closes the All-hook session, and releases all script-backed test state before the engine detaches extensions or releases script functions

### Requirement: Editor refreshes cached Automation tests
The Editor integration SHALL request a new Automation test list when the
Runtime script test registry changes, without adding AutomationController or
CQTest dependencies to `AngelscriptRuntime`.

#### Scenario: Idle loaded controller refreshes immediately
- **WHEN** the registry generation changes while AutomationController is loaded and idle
- **THEN** `AngelscriptEditor` requests a new test list

#### Scenario: Running controller defers refresh
- **WHEN** one or more registry generations are published during an active Automation session
- **THEN** the Editor coalesces them and requests the test list once after the controller becomes idle

#### Scenario: Unloaded controller remains unloaded
- **WHEN** the registry changes while AutomationController is not loaded
- **THEN** the Editor does not load the controller solely to refresh the test list

#### Scenario: Runtime remains CQTest-independent
- **WHEN** production script-test code is linked
- **THEN** `AngelscriptRuntime` implements its registry, World, command, and Automation behavior without a dependency on the Developer-only CQTest module
