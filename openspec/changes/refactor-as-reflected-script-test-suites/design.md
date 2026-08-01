## Context

`AngelscriptRuntime` already owns script test discovery, test execution,
hot-reload batching, commandlet execution, and the UE Automation bridge. The
current protocol is function-oriented, stores executable pointers on module
descriptions, creates implicit World state for unit tests, and puts latent/map
behavior behind a separate integration-test root.

Generated AS classes and their methods are versioned during hot reload. UE
Automation independently caches both registrations and enumerated test names,
and one complex Automation registration supplies one flag mask for all of its
leaves. A class-based replacement therefore needs stable identities,
generation-safe resolution, persistent per-mask Automation bridges, and
explicit cleanup of active latent and World state before old code is replaced.

The production implementation remains part of the standalone `Angelscript`
plugin and must not depend on CQTest. CQTest and the existing
`FAngelscriptTestWorld` remain the C++ regression framework and behavior
reference.

## Goals / Non-Goals

**Goals:**

- Provide CQTest-like AS test classes with explicit metadata-marked methods.
- Keep one public AS suite base, `UAngelscriptTestSuite`, plus two fieldless
  AS value types used as a global environment facade and fluent command
  builder.
- Expose every method as an independently selectable UE Automation leaf with
  exact class-declared Automation flags.
- Provide deterministic lifecycle, fail-fast assertions, expected logs,
  explicit local World/Spawn tools, and concise latent commands.
- Refactor `ULatentAutomationCommand` onto the new execution context without
  requiring authors to use it for ordinary waits.
- Make discovery, callback queues, active World state, and automatic
  hot-reload runs safe across body reload, full reload, metadata/flag changes,
  failed compilation, and rapid consecutive saves.
- Refresh the Editor test list without coupling Runtime to
  AutomationController.

**Non-Goals:**

- Compatibility registration for old global test functions.
- Non-fatal `Expect*` assertions.
- Parameterized/Complex test providers.
- Automatic Integration map selection, PIE startup, or multiplayer topology.
- Public `UAngelscriptTestWorld`, Map, Network, or command-builder UObjects.
- AS function-handle/lambda backports or resumable VM `await`.
- Cross-worker shared instances or one process-global `BeforeAll`.
- A Runtime dependency on CQTest.

## Decisions

### One native public suite base

Add one exported abstract transient UObject:

```cpp
UCLASS(Abstract, Transient)
class ANGELSCRIPTRUNTIME_API UAngelscriptTestSuite : public UObject
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintNativeEvent, Category = "Angelscript Test")
	void BeforeAll();

	UFUNCTION(BlueprintNativeEvent, Category = "Angelscript Test")
	void BeforeEach();

	UFUNCTION(BlueprintNativeEvent, Category = "Angelscript Test")
	void AfterEach();

	UFUNCTION(BlueprintNativeEvent, Category = "Angelscript Test")
	void AfterAll();
};
```

Native lifecycle implementations are no-ops. Script suites override them with
`UFUNCTION(BlueprintOverride)`.

Assertion and expected-log overloads are registered as native AngelScript
methods on this type rather than overloaded UFUNCTIONs. That avoids UHT
overload restrictions while keeping result expectations attached to the
active suite fixture.

No other framework UObject is required for normal use. The suite `GetWorld()`
override remains because it is part of UObject world-context behavior. World
and command authoring instead use fieldless USTRUCT facades; all mutable state
remains in the execution context.

### Metadata-marked methods and exact flags

The UFUNCTION preprocessor recognizes `meta=(AngelscriptTest)` as a marker. It
forces `bBlueprintCallable=false` for the marked method while preserving the
generated UFunction, metadata, and AS source location.

The UCLASS metadata field `AngelscriptTestFlags` contains a semicolon-separated
list of exact `EAutomationTestFlags` names:

```angelscript
UCLASS(meta=(AngelscriptTestFlags=
	"EditorContext;ClientContext;ServerContext;CommandletContext;EngineFilter"))
class URuntimeCompatibleTests : UAngelscriptTestSuite
{
}
```

The parser trims whitespace, rejects empty/duplicate/unknown tokens, ORs the
known values, requires at least one Application Context bit, and requires
exactly one Filter bit. Other supported UE feature, priority, and Disabled
flags retain their engine meanings. An invalid suite is omitted and receives
a source-located diagnostic; there is no silent default.

Flags determine Automation selection only. An AS class that references
Editor-only types still wraps those declarations in `#if EDITOR`.

Discovery considers concrete current AS classes derived from
`UAngelscriptTestSuite`. Only marked methods directly declared by the concrete
class become leaves. A valid method is non-static, has no parameters, and
returns `void`. Unmarked helpers and inherited marked methods are ignored.
Invalid declarations and normalized Automation-name collisions produce
source-located diagnostics and are omitted.

### Stable registry and execution model

The internal model comprises:

- `FAngelscriptScriptTestId`: original module, suite-class, and test-method
  names.
- `FAngelscriptScriptTestDescriptor`: ID, display name, exact flag mask,
  registry generation, source file, and source line; no executable pointer.
- `FAngelscriptScriptTestRegistry`: immutable deterministically sorted
  snapshot plus monotonically increasing generation.
- `FAngelscriptScriptTestExecutionContext`: active leaf, suite instance,
  phase, expected logs, controlled assertion state, command queues, World
  state, tracked objects, and cancellation reason.
- `FAngelscriptScriptTestSectionManager`: per-worker All-hook sessions keyed
  by suite ID and registry generation.
- `FAngelscriptScriptTestRunner`: resolves the active module, most up-to-date
  class, current test/callback method, and invokes lifecycle/commands.

Registry construction iterates active module and class descriptions after
successful class generation. It never uses a global UObject iterator and
never publishes a partially validated snapshot.

Each leaf creates a fresh transient method-scope suite instance. `BeforeEach`,
the marked method, all callback methods, and `AfterEach` run on that same
object. Ordinary member state never crosses leaves.

`BeforeAll` and `AfterAll` run on a separate transient suite-scope instance
tied to the Automation section, worker, and generation. All hooks are
synchronous and cannot create method-local World state, enqueue commands, or
use leaf-bound assertion/expected-log helpers. A thrown `BeforeAll` exception
marks the session setup-failed, causes selected leaves to report the setup
failure without per-method execution, and still attempts `AfterAll`.
`AfterAll` failures are source-located session diagnostics because UE may have
already submitted the final leaf.

### Fail-fast assertions

The native assertion surface is:

- `Fail`
- `AssertTrue`, `AssertFalse`
- `AssertNull`, `AssertNotNull`
- `AssertSame`, `AssertNotSame`
- `AssertEquals`, `AssertNotEquals`
- `AssertNear`
- `AssertLessThan`, `AssertLessThanOrEqual`
- `AssertGreaterThan`, `AssertGreaterThanOrEqual`
- `ExpectError`, `ExpectErrorRegex`

Equality retains the existing supported primitive, string, name, object, and
UE math types and adds `FTransform`. Relational overloads cover integer,
float32, and float64 types. Near uses absolute scalar difference and UE
`Equals` semantics for vector, rotator, quaternion, and transform values.

Assertions record one source-located Automation error and raise a recognizable
controlled AS exception that stops only the current hook/test/callback. The
runner consumes that exception without duplicating it as an ordinary script
exception. A normal AS exception remains a separate failure. Expected-log
rules cannot match away assertion errors.

Assertions and expected logs are valid during `BeforeEach`, the marked test,
ordinary command callbacks, advanced command callbacks, and `AfterEach`.

### Private local World state exposed through a global facade

The method execution context privately owns one optional local test World,
optional GameInstance, tracked actors/components, and strong UObject
references. `USTRUCT(meta=(ForceAngelscriptBind)) FAngelscriptTest` contains
no fields or context pointer. Native global functions are registered inside
the same-name AS namespace, so authors call:

```text
FAngelscriptTest::CreateTestWorld(bool bInitializeGameSubsystems = true)
FAngelscriptTest::DestroyTestWorld()
FAngelscriptTest::GetTestWorld()

FAngelscriptTest::SpawnObject(UClass ObjectClass, UObject Outer = nullptr)
FAngelscriptTest::SpawnActor(TSubclassOf<AActor> ActorClass,
                  FVector Location = FVector::ZeroVector,
                  FRotator Rotation = FRotator::ZeroRotator)
FAngelscriptTest::SpawnComponent(TSubclassOf<UActorComponent> ComponentClass,
                               AActor Owner,
                               bool bRegister = true)

FAngelscriptTest::BeginPlay(AActor Actor)
FAngelscriptTest::BeginPlayAll()
FAngelscriptTest::TickWorld(float32 DeltaSeconds, int32 NumTicks = 1)
FAngelscriptTest::TickActor(AActor Actor, float32 DeltaSeconds, int32 NumTicks = 1)
FAngelscriptTest::TickComponent(UActorComponent Component,
                   float32 DeltaSeconds,
                   int32 NumTicks = 1)
FAngelscriptTest::AdvanceTime(float32 DeltaSeconds, int32 NumTicks = 1)
FAngelscriptTest::DestroyActor(AActor Actor, bool bDrain = true)
```

`CreateTestWorld` is explicit; pure tests pay no World cost. A second creation
without prior destruction fails instead of silently replacing state.
`SpawnObject` uses the suite instance as the default Outer and holds a strong
reference until cleanup. Actor/Component helpers validate ownership, register
the created object, and report failures through the active leaf.

`TickWorld` and `AdvanceTime` drive the World scheduler. `TickActor` and
`TickComponent` directly dispatch exactly `NumTicks` calls for tests that need
precise counts independent of test-World scheduling. `DestroyActor` optionally
ticks one drain frame so EndPlay/Destroyed effects can be asserted.

Cleanup is idempotent and reverse-order: destroy tracked actors/components,
release tracked UObject references, shut down GameInstance state, destroy the
World context, and clear ambient World state. It runs after success,
assertion/exception failure, latent timeout, explicit cancellation, and
hot-reload cancellation.

### Fluent command queue through a fieldless builder

`FAngelscriptTest::Commands()` validates that a method leaf is active and
returns a fieldless
`USTRUCT(meta=(ForceAngelscriptBind)) FAngelscriptTestCommandBuilder`. Its
chainable native AS methods return the builder by value:

```text
FAngelscriptTestCommandBuilder Do(FName Action, FString Description = "")
FAngelscriptTestCommandBuilder Then(FName Action, FString Description = "")
FAngelscriptTestCommandBuilder StartWhen(
	FName Condition, float32 TimeoutSeconds = 5.0, FString Description = "")
FAngelscriptTestCommandBuilder Until(
	FName Condition, float32 TimeoutSeconds = 5.0, FString Description = "")
FAngelscriptTestCommandBuilder WaitDelay(
	float32 Seconds, FString Description = "")
FAngelscriptTestCommandBuilder OnTearDown(
	FName Action, FString Description = "")
FAngelscriptTestCommandBuilder OnCleanup(
	FName Action, FString Description = "")
FAngelscriptTestCommandBuilder AddLatentCommand(
	ULatentAutomationCommand Command, float32 TimeoutSeconds = 5.0)
```

`Do`/`Then`, `StartWhen`/`Until`, and
`OnTearDown`/`OnCleanup` are CQTest-compatible aliases.

Neither facade stores a Suite, World, UObject, shared pointer, weak pointer,
or executable function. Every global or builder call resolves the current
leaf from a game-thread callback-scope stack. Nested calls restore the prior
context on scope exit; multiple waiting leaves are never disambiguated by
scanning the set of active contexts. Calls from `BeforeAll`, `AfterAll`, an
advanced client callback, outside a leaf, or after cancellation fail with a
source-located misuse diagnostic and never access stale state.

Action callbacks are ordinary unmarked, non-static, zero-argument `void`
methods on the current suite. Conditions are ordinary unmarked, non-static,
zero-argument `bool` methods. They do not require `UFUNCTION()`. Enqueue-time
resolution reports missing names, overload ambiguity, and invalid signatures
at the AS call site. The queue stores stable method names and resolves the
method again immediately before invocation.

`BeforeEach` and the marked method run synchronously to construct the main and
teardown queues. Statements after an enqueue call therefore also execute
immediately; work that depends on a wait belongs in a later `Then` callback.

Main commands execute FIFO. `Until` polls once per Automation update.
`WaitDelay` uses monotonic real elapsed time and does not tick a local World;
deterministic World time uses `AdvanceTime`. Default timeout is 5 seconds and
the existing 15-second safety maximum remains. Non-finite, non-positive, or
over-limit values fail at enqueue time.

Queue completion/failure order is:

1. Run or abandon the remaining main queue.
2. Invoke synchronous `AfterEach`.
3. Run teardown callbacks in last-in-first-out order.
4. Automatically clean the local World and tracked objects.

Main commands stop after any leaf error. Teardown commands run despite prior
errors. `OnCleanup` may be registered from `BeforeEach`, the test method, or
`AfterEach`; ordinary main commands and advanced commands are accepted only
while building the main queue. Adding commands from an executing command
callback is rejected, matching CQTest's mutation restriction.

Only the framework's private controlled-assertion exception is consumed as
already reported. An ordinary exception from `AfterEach` or a teardown
callback is independently source-located and appended even when the leaf was
already failed, so a primary failure cannot hide cleanup damage.

### Advanced latent command compatibility

Keep `ULatentAutomationCommand` as the advanced extension point. Replace its
`TSharedPtr<FAngelscriptIntegrationTest>` association with a weak/current
execution-context association established only by `AddLatentCommand`.

Preserve `Before`, `Update`, `After`, descriptions, allowed-timeout behavior,
`BeforeOnClient`, `UpdateOnClient`, `AfterOnClient`, `DescribeOnClient`, and
the client executor state machine. `GetCurrentTest()`/`SetCurrentTest()` are
retired; a safe `GetCurrentSuite()` accessor is available only while the
command is associated with an active leaf.

The execution context owns a strong reference while the command is queued or
running and releases it on every terminal path. Client assertions continue to
forward to the active server leaf. `bAlsoRunOnClient` requires an already
network-capable current World; this change does not start PIE or create
participants. The configured timeout is one overall deadline for
`CreateExecutor` through `FinishClient`. Reaching that deadline finalizes
immediately: server `After` runs at most once, the weak client executor is
destroyed when still valid, and the suite association is cleared. An allowed
timeout suppresses only the timeout failure, not terminal cleanup. Losing the
executor in any post-creation phase is a bounded leaf failure rather than a
null dereference or infinite wait.

### Per-mask UE Automation bridges

One complex Automation registration cannot enumerate leaves with different
flags. Runtime therefore owns a bridge registry keyed by exact
`EAutomationTestFlags` mask.

The first descriptor for a mask lazily creates a uniquely registered bridge.
Every created bridge remains alive until Runtime shutdown; hot reload never
unregisters it. `GetTests()` filters the latest immutable registry snapshot by
that mask and emits:

```text
Angelscript.ScriptTests.<Module>.<Suite>.<Method>
```

The internal bridge registration name contains a stable flag-mask suffix, but
the user-visible beautified leaf name does not. Commands encode the original
stable test ID and generation. A stale command re-resolves the latest
descriptor and fails with a refresh diagnostic if the method no longer
exists. Source lookup returns the AS file and line.

`FAngelscriptScriptTestSectionManager` listens to section enter/leave and
opens/closes matching suite-generation sessions. Lifecycle remains
process-local. Standard validation uses one worker; distributed workers each
own their own All-hook session.

### Hot reload and Editor list refresh

Before compiling an affected active module, the runner reaches a callback
boundary and cancels any affected active leaf while old code remains valid:

1. Mark the leaf canceled and discard remaining main commands.
2. Finalize and detach any active advanced command.
3. Invoke old-generation `AfterEach`.
4. Execute old-generation teardown callbacks.
5. destroy tracked actors, objects, GameInstance, and World.
6. clear resolved suite/class/function references.
7. complete the old leaf with a source-located hot-reload invalidation
   diagnostic.

Compilation cannot re-enter from within a running AS callback; such a request
is queued until the callback boundary. No active suite, callback, command, AS
stack, Actor, or World is migrated across generations.

After successful class generation, build and atomically publish the new
registry, then broadcast its generation. Failed compilation keeps the
last-good snapshot; the next old leaf lazily reopens its All-hook session.

Automatic hot-reload test work stores stable IDs plus generation. A newer
reload cancels and replaces pending/active automatic work from an older
generation. The scheduler supports both synchronous and latent leaves without
blocking the compiler thread.

The same ownership rule applies to explicit engine shutdown. Each active leaf
and All-hook session records the `FAngelscriptEngine` that resolved it.
`Shutdown()` cancels only that engine's leaves and closes only that engine's
session while script functions remain callable, before extension detachment,
context release, and `ShutDownAndRelease()`.

Runtime exports a lightweight registry-changed multicast delegate.
`AngelscriptEditor` subscribes and, only when AutomationController is already
loaded, calls `RequestTests()`. Refresh is coalesced; while a controller
session runs, remember only the newest generation and request once it becomes
idle.

### Legacy removal and settings

Remove old unit/integration discovery, Automation roots, `FUnitTest`,
`FIntegrationTest`, global `GetParam`, and their script-visible mutable
context bindings. Rebind `ULatentAutomationCommand` to the new suite context
before removing its old association.

Retain `bEnableTestDiscovery`, hot-reload enable/limit settings, garbage
collection batching, coverage, and debugging settings. Remove settings used
only by the retired implicit protocols:

- `IntegrationTestMapRoot`
- `IntegrationTestNamingConvention`
- `UnitTestNamingConvention` and its regex
- `UnitTestGameInstanceClass`
- Integration-only network-emulation packet settings

`bEnableTestDiscovery=false` publishes an empty registry snapshot and exposes
no script leaves.

## Risks / Trade-offs

- **Method-name callbacks are less concise than lambdas.**
  → Default the callback object to the current suite, omit `UFUNCTION`, allow
  fluent chaining, and leave a compatible function-handle overload for a
  future language backport.
- **Queued syntax does not suspend the marked method.**
  → Document that the method constructs a queue and require delayed-dependent
  work in `Then`; do not pretend to provide unsupported VM `await`.
- **A World scheduler may not produce exact Actor/Component tick counts.**
  → Expose explicit precise `TickActor` and `TickComponent` helpers alongside
  World scheduling.
- **Hot reload during a leaf invalidates the selected result.**
  → Clean with old code, fail the stale leaf with a rerun diagnostic, publish
  the new generation, and never invoke stale pointers.
- **UE cannot assign flags per complex-test leaf.**
  → Use persistent exact-mask bridges instead of one root or dynamic
  unregister/re-register.
- **Section leave is too late to fail the final leaf from `AfterAll`.**
  → Keep All hooks synchronous/session-scoped and report `AfterAll` failures
  as lifecycle diagnostics.
- **Automation may distribute leaves across processes.**
  → Define All-hook scope per worker and use one worker for supported baseline
  verification.
- **Direct replacement breaks external old-style tests.**
  → Provide pure, World, latent, and advanced-command migration examples; do
  not hide the break with dual registration.

## Migration Plan

1. Add failing CQTest coverage for metadata method discovery and exact class
   flags.
2. Add the native suite, registry, lifecycle runner, and assertions.
3. Add private local World ownership and suite-level Spawn/Tick helpers.
4. Add the ordinary fluent command queue and refactor
   `ULatentAutomationCommand` onto it.
5. Replace the old Automation roots with persistent per-mask bridges and
   route commandlet/hot-reload scheduling through stable IDs.
6. Add generation-safe active cancellation and Editor test-list refresh.
7. Migrate in-repository script examples, remove old contexts/settings, and
   update Chinese documentation first.
8. Run focused, script-root, and complete suite verification.

No data migration or compatibility adapter is required. During development,
reverting the plugin commit and parent gitlink restores the previous protocol.

## Open Questions

None. Public type count, marker syntax, exact flags, lifecycle isolation,
World ownership, queue semantics, advanced command compatibility, hot-reload
cancellation, and excluded await/PIE/parameterization capabilities are fixed
by this change.
