## ADDED Requirements

### Requirement: Script functional tests SHALL be independent reflected AS suites
Project script behavior tests SHALL live under `Script/Tests/<Theme>/`, derive from `UAngelscriptTestSuite`, and expose each executable leaf through a valid `UFUNCTION(meta=(AngelscriptTest))` method.

#### Scenario: Theme test is discovered
- **WHEN** a valid suite is added under `Script/Tests/Math`, `Script/Tests/Containers`, `Script/Tests/Actor`, or another approved theme
- **THEN** its leaves are discoverable beneath `Angelscript.ScriptTests.Tests.<Theme>`
- **AND** each marked method is independently selectable

#### Scenario: Helper method supports a test
- **WHEN** a suite needs setup or a callback helper that is not itself a test
- **THEN** the helper remains unmarked
- **AND** it is not registered as an Automation leaf

### Requirement: Script tests SHALL assert observable behavior rather than compilation alone
Every positive script-test leaf SHALL assert a return, value, identity, mutation, lifecycle transition, callback payload, object state, World state, or other externally observable result.

#### Scenario: Stable API call compiles and executes
- **WHEN** a stable user-visible API is covered by a script test
- **THEN** the test executes the relevant call path
- **AND** an `Assert*` method checks the expected behavior

#### Scenario: Unsupported behavior is characterized
- **WHEN** the current fork intentionally rejects or cannot execute a scenario
- **THEN** the row/test records a specific unsupported or environment-bound reason
- **AND** a successful compile placeholder is not presented as runtime coverage

### Requirement: Script tests SHALL create only the World state required by their behavior
Pure tests SHALL run without a World, while UObject, Actor, Component, World, subsystem, timer, collision, and related tests SHALL explicitly create and drive the smallest fixture that exposes the behavior.

#### Scenario: Pure Math or container test runs
- **WHEN** a test only needs language values, FMath, containers, strings, names, text, or deterministic reflection-free logic
- **THEN** it does not call `CreateTestWorld`
- **AND** `FAngelscriptTest::GetTestWorld()` remains null

#### Scenario: Actor or Component lifecycle is tested
- **WHEN** a test needs spawn, ownership, BeginPlay, Tick, EndPlay, or Destroyed behavior
- **THEN** it creates a test World, spawns the real script class, drives the required lifecycle, and asserts state/order
- **AND** it destroys or releases the fixture through the supported helpers

#### Scenario: Exact Tick count is the oracle
- **WHEN** an Actor or Component callback must execute an exact number of times
- **THEN** the test uses direct `TickActor` or `TickComponent` dispatch
- **AND** it does not infer exact counts from scheduler-driven World ticks

#### Scenario: Timer or subsystem scheduling is the oracle
- **WHEN** the test validates World scheduling, timers, GameInstance, or subsystem behavior
- **THEN** it uses `TickWorld` or `AdvanceTime` and creates GameInstance context when required
- **AND** it asserts the scheduled state transition rather than only logging it

### Requirement: Script tests SHALL use assertions as the oracle and logs as diagnostic context
Script tests SHALL determine pass/fail through suite assertions, exceptions, and expected-log rules; ordinary logs SHALL be bounded diagnostic breadcrumbs only.

#### Scenario: Complex lifecycle emits diagnostics
- **WHEN** a multi-step World, native interop, or network test benefits from intermediate diagnostics
- **THEN** logs use a stable scenario prefix and identify meaningful state
- **AND** final assertions independently verify the result

#### Scenario: Expected error is exercised
- **WHEN** a negative test intentionally emits an error
- **THEN** it registers `ExpectError` or `ExpectErrorRegex` before the operation
- **AND** expected-log matching does not suppress assertion failures

### Requirement: Native interop tests SHALL execute real reflected parameter paths
The test module SHALL provide bounded test-only reflected fixtures for scalar, string/name, math, enum, UObject, struct, container, out/inout, static function, WorldContext, and delegate marshalling where pure AS cannot prove the native boundary.

#### Scenario: UFUNCTION round trip is tested
- **WHEN** a script test calls a test-only native UFUNCTION
- **THEN** it asserts returned values, mutated arguments, object identity, or observable fixture properties after the call
- **AND** compilation or reflection metadata alone is insufficient

#### Scenario: Struct container crosses the boundary
- **WHEN** `FAngelscriptScriptInteropRecord` or a collection of records crosses a native UFUNCTION boundary
- **THEN** the test asserts the ID, label, position, ordering, and mutation semantics after the round trip
- **AND** C++ behavior coverage verifies the same reflected path at its owning layer

#### Scenario: Delegate payload crosses the boundary
- **WHEN** native code invokes AS or AS invokes native code through the interop delegate
- **THEN** the receiver is actually bound and invoked
- **AND** the payload fields and side-effect count are asserted

### Requirement: C++ test-module gaps SHALL be routed to the correct existing layer
The capability audit SHALL distinguish bind-entry coverage from semantic, functional, function-library, compiler, and SDK coverage and SHALL plan missing behavior in the established owner rather than accumulating unrelated tests in Bindings.

#### Scenario: Bind entry lacks callable proof
- **WHEN** an AS-facing manual bind has no representative compile-and-call contract
- **THEN** a focused Bindings test is planned for declaration and native-path reachability
- **AND** large value or state matrices remain outside Bindings

#### Scenario: Bound operation lacks semantic coverage
- **WHEN** a supported container, value, error, boundary, or type-matrix behavior has only a bind smoke test
- **THEN** the missing behavior is planned in Coverage and its matrix
- **AND** the AS project test references that behavior where it adds project-script signal

#### Scenario: World-backed behavior lacks functional coverage
- **WHEN** a stable UObject, Actor, Component, interface, subsystem, GC, or lifecycle behavior is not asserted in C++
- **THEN** a test is planned in the corresponding existing Functional/theme directory using the shared World harness
- **AND** it asserts runtime behavior rather than compilation only

### Requirement: The audit SHALL map the complete core binding surface to user capabilities or explicit dispositions
The change SHALL inspect all core manual bind providers and representative generated/reflected/function-library surfaces and SHALL map each to a thematic scenario, internal-only reason, unsupported boundary, environment-bound row, or out-of-scope disposition.

#### Scenario: Manual provider is audited
- **WHEN** the matrix reconciliation checks the current 204-file `Bind_*.cpp` baseline
- **THEN** every binding source file is assigned to a logical provider family and every family has at least one matrix reference or a recorded non-corpus disposition
- **AND** the audit does not equate file or provider-family count with required example count

#### Scenario: Existing C++ method is evaluated
- **WHEN** Coverage, Bindings, Functional, FunctionLibraries, or Syntax contains multiple methods for the same user operation
- **THEN** the methods are normalized into user-capability evidence
- **AND** they are not mechanically duplicated into separate AS leaves

#### Scenario: Bindings and FunctionLibraries test sources are reconciled
- **WHEN** the audit processes the 87-file Bindings and 18-file FunctionLibraries planning baselines
- **THEN** every source maps to one or more domain, `BPLIB-*`, or `BIND-*` rows as contract/behavior evidence or receives an explicit support/internal-only disposition
- **AND** test-source count is not treated as a required AS-test count

### Requirement: BlueprintLibraries and Bindings SHALL have independent AS behavior suites
The project SHALL place library workflows under `Script/Tests/BlueprintLibraries/` and binding-semantics behavior under `Script/Tests/Bindings/`, using the same reflected suite and assertion rules as other themes.

#### Scenario: Blueprint library behavior executes through project script
- **WHEN** a supported static, namespace, receiver-mixin, callback, or WorldContext library workflow is covered
- **THEN** the corresponding AS suite executes the published AS call path and asserts its result, mutation, callback, identity, or World state
- **AND** existing C++ FunctionLibraries tests remain the native signature/parity/guard evidence

#### Scenario: Binding route detail is C++-only
- **WHEN** a Bindings C++ test proves native form, generic call convention, generated provenance, cache identity, or engine-local registration details
- **THEN** the AS suite asserts only the stable public call behavior
- **AND** it does not expose implementation route names as script API

#### Scenario: Library or binding needs an unavailable environment
- **WHEN** execution needs an asset, LocalPlayer, device input, editor, RHI, physics scene, async service, or other unavailable environment
- **THEN** the AS suite preserves the strongest deterministic contract and records the exact `EnvironmentBound` remainder
- **AND** it does not replace runtime behavior with a compile-only success claim

### Requirement: Corpus validation and script tests SHALL have standard runner entry points
The project SHALL add a `ScriptCorpus` suite containing the script functional-test root and the corpus convention validation prefix, and SHALL include the script functional-test root in the configured `All` suite.

#### Scenario: Maintainer runs the focused corpus suite
- **WHEN** `Tools\RunTestSuite.ps1 -Suite ScriptCorpus` is invoked
- **THEN** it runs `Angelscript.ScriptTests.Tests` and `Angelscript.TestModule.Validation.ScriptCorpus`
- **AND** results are reported through the standard suite runner

#### Scenario: Maintainer runs one theme
- **WHEN** a maintainer filters `Angelscript.ScriptTests.Tests.<Theme>` through `Tools\RunTests.ps1`
- **THEN** only that theme's script suites are selected
- **AND** the prefix is documented in `Script/Tests/README.md`

### Requirement: Script test and corpus convention coverage SHALL remain build-gated and maintainable
New C++ test registrations SHALL honor `WITH_ANGELSCRIPT_UNITTESTS`, use current CQTest conventions, and keep support types compilable when registration is disabled unless a documented technical constraint requires otherwise.

#### Scenario: Unit-test registration is disabled
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** new corpus validation and C++ behavior tests do not register Automation leaves
- **AND** necessary test-support reflected types still compile without relying on CQTest registration side effects

#### Scenario: New C++ behavior test is reviewed
- **WHEN** the change adds or refactors a C++ test
- **THEN** it uses scenario-specific `TEST_METHOD`s, class-level engine lifecycle where applicable, `ASTEST_AS` for inline script, matcher assertions, and local cleanup
- **AND** its verification uses `Tools\RunTests.ps1`, `Tools\RunBuild.ps1`, or `Tools\RunTestSuite.ps1`

### Requirement: Network script coverage SHALL use a real network-capable path
Server, client, multicast, validation, replication, role, and authority behavior SHALL NOT be claimed from a local single-World direct call.

#### Scenario: RPC route is covered
- **WHEN** a script test claims Server, Client, or NetMulticast execution behavior
- **THEN** the test uses the project's network-capable test infrastructure and asserts participant-visible effects
- **AND** compile-only RPC declaration coverage remains separately identified

#### Scenario: Network environment is unavailable
- **WHEN** a behavior cannot run reliably in the supported headless environment
- **THEN** its matrix row is marked `EnvironmentBound` with the exact missing topology or engine capability
- **AND** the test suite does not substitute a misleading local call
