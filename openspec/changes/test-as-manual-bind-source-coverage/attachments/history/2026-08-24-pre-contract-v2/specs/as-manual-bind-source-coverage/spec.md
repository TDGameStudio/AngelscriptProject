## ADDED Requirements

### Requirement: Complete manual Bind inventory

The TestSource plan SHALL account for every physical `Bind_*.cpp` file under the core AngelscriptRuntime Binds directory and SHALL normalize `_Type` and `_Functions` shards into stable logical Bind units.

#### Scenario: Physical and logical counts reconcile

- **WHEN** the inventory is generated from the current source baseline
- **THEN** all 204 physical files are assigned exactly once to 127 logical units
- **AND** every logical unit has one primary matrix and one explicit disposition

#### Scenario: Non-callable shard is reviewed

- **WHEN** a shard implements type adaptation, debugger/default conversion, CppForm, helper, thunk, or registration infrastructure without its own AS call
- **THEN** it is recorded in the native-only review with its logical owner and reason
- **AND** no artificial `.as` file is planned solely to satisfy a file count

### Requirement: AS-facing surface traceability

The plan SHALL enumerate each documented or explicitly registered AS-facing constructor, operator, method, property, namespace/global function, conversion, iterator, or type declaration with a stable SurfaceId and source reference.

#### Scenario: Callable surface maps to source

- **WHEN** a surface is marked `PlannedSource`
- **THEN** it maps to at least one unique TaskId and exact target `.as` path
- **AND** that task lists the SurfaceId and AS-facing signature

#### Scenario: Current C++ evidence exists

- **WHEN** representative current tests exist
- **THEN** the reference records the exact path, TEST_CLASS, and TEST_METHOD
- **AND** the planned source task links the corresponding ReferenceId

#### Scenario: No current test exists

- **WHEN** exact-name and owned-type inspection finds no representative TEST_METHOD
- **THEN** the reference is explicitly marked `NoCurrentTest`
- **AND** the current Bind source remains the authoritative reference

### Requirement: One focused scenario family per AS file

Each planned Bind source SHALL live at `TestSource/Bindings/<LogicalBindName>/Test_<ScenarioCategory>_<Part>.as` and SHALL cover one bounded semantic scenario family.

#### Scenario: Large API family is split

- **WHEN** a logical Bind category contains more than ten documented related surfaces
- **THEN** the plan creates ordered part files with unique TaskIds and target paths
- **AND** every surface remains assigned exactly once

#### Scenario: Multiple physical shards publish one logical API

- **WHEN** `Bind_X.cpp`, `Bind_X_Type.cpp`, or `Bind_X_Functions.cpp` contribute to the same logical type
- **THEN** their script tests live under one `TestSource/Bindings/X/` directory
- **AND** no shard-named TestSource directory is created

### Requirement: Observable behavior depth

Every planned source SHALL define how results or effects are observed; compilation or successful invocation alone SHALL NOT satisfy coverage.

#### Scenario: Runner-readable observation channel

- **WHEN** a planned Bind callable is authored
- **THEN** its exact callable signature and observation mode are recorded for `TaskId + PlannedSymbol`
- **AND** it publishes a result through a non-void return, out/inout observation, identified host-visible state, or C++-checked expected diagnostic
- **AND** a function-local variable, log line, or successful return from a `void` function does not count as a published result

#### Scenario: Non-void result

- **WHEN** a listed surface returns a value
- **THEN** the task consumes and compares the exact semantic result
- **AND** it identifies applicable default, boundary, false/empty/null, or failure observations

#### Scenario: Void and writeback behavior

- **WHEN** a surface returns void or has out/inout parameters
- **THEN** the task records receiver or external state before and after the call
- **AND** verifies every applicable writeback, callback, diagnostic, or lifecycle effect

#### Scenario: Reference or object handle result

- **WHEN** a surface returns a reference or UObject-like handle
- **THEN** the task covers alias/identity semantics
- **AND** covers null and non-null states when both are reachable

#### Scenario: Container result

- **WHEN** a surface returns or mutates a container
- **THEN** the task covers applicable size, values, ordering, duplicate, empty, and invalid-access behavior
- **AND** records why any adjacent dimension is not applicable

#### Scenario: Oracle rejects exhaustive truth forms

- **WHEN** a scenario compares an actual result with its expected result
- **THEN** the comparison can distinguish at least one incorrect result from the expected result
- **AND** Boolean-complement disjunctions, null/non-null exhaustions, self-equality, complementary equality/inequality, and equivalent tautologies are rejected

#### Scenario: Required fixture is absent

- **WHEN** a World, Actor, Component, asset, subsystem, network, or other required fixture cannot be created or supplied
- **THEN** the runner records setup failure or an explicit unsupported disposition
- **AND** the scenario does not treat `Fixture == nullptr` as successful behavior coverage

### Requirement: Per-callable observation contract

Every planned callable SHALL have a mechanically joinable contract keyed by `TaskId + PlannedSymbol` before its source task can be completed.

#### Scenario: Contract row is complete

- **WHEN** a Bind `Observe_*` or `ExerciseExpectedFailure` symbol is implemented
- **THEN** the contract records `CallableSignature`, `ObservationMode`, `RunnerInputs`, `SetupOwner`, `ExpectedResultOrEffect`, `CleanupOwner`, `CleanupAction`, `ExecutionPolicy`, and `ExternalOracle`
- **AND** the implementation matches that contract

#### Scenario: Multiple values must be observed

- **WHEN** one scenario needs several values, writebacks, identities, phases, or collection elements
- **THEN** it returns an observation record, writes explicit out/inout observations, or exposes identified state for C++ inspection
- **AND** it does not collapse the scenario into an unreported local Boolean

#### Scenario: Existing per-file verification is applied

- **WHEN** a planned path and planned declarations exist
- **THEN** that is recorded as structural materialization only
- **AND** the task remains unchecked until every applicable observation-contract and semantic-review gate passes

### Requirement: Fixture and lifecycle ownership

Every environment-dependent or mutating source SHALL identify setup and cleanup ownership for all success, failure, expected-diagnostic, and early-exit paths.

#### Scenario: Runner-owned fixture

- **WHEN** the tested API is not itself an object-construction or spawn API
- **THEN** the runner creates the deterministic World/object/component/resource fixture and supplies the required callable inputs
- **AND** the runner performs teardown after observation

#### Scenario: Construction or spawn is the tested API

- **WHEN** the source directly creates an actor, object, timer, registration, delegate, file, or global state because creation is the behavior under test
- **THEN** the created identity or cleanup handle is returned to the declared cleanup owner
- **AND** deferred construction is explicitly finished or aborted
- **AND** cleanup restores the pre-test state

### Requirement: Execution safety classification

Every planned callable with host, process, editor, map, platform, file, clipboard, URL, global, console, or network side effects SHALL have an execution policy before any generic runner may invoke it.

#### Scenario: Default execution is safe

- **WHEN** a callable is classified `DefaultSafe`
- **THEN** it is deterministic under its declared inputs and does not leave persistent host or external state
- **AND** all owned resources are restored or destroyed

#### Scenario: High-impact operation requires isolation

- **WHEN** a callable can request process exit, travel the World, launch an external URL, mutate the clipboard, or comparably invalidate the current host
- **THEN** it is classified `FixtureIsolated`, `SubprocessOnly`, `DiagnosticOnly`, or `CompileOnlyPendingHarness` as appropriate
- **AND** it is excluded from default execution
- **AND** a compile-only disposition is not counted as functional behavior coverage

### Requirement: Knowledge-oriented AS comments

Every future TestSource file SHALL use English comments that explain the test knowledge needed to understand its behavior without imposing a rigid metadata template.

#### Scenario: File and primary scenario are documented

- **WHEN** a `.as` source is authored from a task
- **THEN** its comments explain purpose, relevant AS-facing API, input choice, expected result or effect, and important boundary or ownership rule
- **AND** major scenario functions explain what they verify

#### Scenario: Generic scenario name needs nearby knowledge

- **WHEN** a callable is named `Observe_SurfaceNNN_*` or exercises a non-obvious out/inout, alias, identity, ownership, diagnostic, World, latent, network, or platform boundary
- **THEN** a nearby natural-language comment explains the AS surface, selected input, exact oracle, and important ownership or failure meaning
- **AND** a repeated file-level card alone is not sufficient

#### Scenario: Simple helper remains readable

- **WHEN** a helper is self-explanatory and has no non-obvious order or ownership behavior
- **THEN** no ceremonial comment is required
- **AND** the file remains free of mandatory tag blocks such as `@covers`

### Requirement: Test framework conformance corpus

The plan SHALL provide independent TestFramework sources for Discovery, Assertions, Lifecycle, Commands, World, Automation, HotReload, and SelfHosted behavior.

#### Scenario: Framework API tests itself

- **WHEN** framework sources use UAngelscriptTestSuite, FAngelscriptTest, assertions, expected errors, fluent commands, or ULatentAutomationCommand
- **THEN** the tested subject is the framework protocol rather than the incidental arithmetic/string/World payload
- **AND** ordinary Bind sources do not inherit or call the framework

#### Scenario: Assertions and latent commands are covered

- **WHEN** the framework task inventory is complete
- **THEN** it includes assertion pass/fail/overload/message/location/fail-fast behavior
- **AND** includes Do, Then, StartWhen, Until, WaitDelay, teardown, cleanup, advanced command lifecycle, timeout, and client policy

#### Scenario: External oracle prevents circular proof

- **WHEN** a self-hosted or expected-failure framework source is eventually executed
- **THEN** C++ verifies exact discovered/pass/fail counts, diagnostics, source locations, phase order, and cleanup
- **AND** the AS framework does not rely only on its own assertions to prove its correctness

#### Scenario: Framework source is materialized before its oracle

- **WHEN** a TestFramework source contains the planned reflected methods and assertion payload but the independent C++ oracle is not implemented
- **THEN** it is recorded as `ProvisionalExternalOracle`
- **AND** its per-file task remains unchecked

### Requirement: Source-only phase isolation and truthful status

This change SHALL keep source authoring/review separate from compiler, runner, code-generation, and release integration, and SHALL report structural materialization separately from semantic acceptance.

#### Scenario: Implementation review is delivered

- **WHEN** existing `TestSource/**/*.as` implementation is reviewed
- **THEN** the review may update only this OpenSpec and its generated review inventory
- **AND** it does not silently rewrite TestSource, plugin source, Script source, runner, build script, or code generator files
- **AND** compilation and UE Automation execution remain deferred

#### Scenario: Status is not inferred from presence

- **WHEN** all planned files and declarations are present
- **THEN** the record reports them as materialized
- **AND** it separately reports source-semantic acceptance, compilation, execution, and external-oracle verification

#### Scenario: Code generation remains separate

- **WHEN** generation, C++ inline export, runner integration, or release-only synchronization is considered
- **THEN** it is routed to a later independent OpenSpec
- **AND** no such implementation task appears in this change

### Requirement: Planning-data consistency

The inventory CSVs, matrices, and tasks SHALL form a mechanically checkable closed set.

#### Scenario: IDs and paths are unique

- **WHEN** consistency validation runs
- **THEN** BindId, SurfaceId, ReferenceId, TaskId, and target path uniqueness checks pass
- **AND** every planned source CSV row has exactly one checkbox task

#### Scenario: Review disposition covers every planned path

- **WHEN** the implementation audit runs
- **THEN** `inventory/testsource-implementation-review.csv` contains exactly one row for every planned source row
- **AND** it records structural drift, issue IDs, severity, disposition, and required action
- **AND** the summary distinguishes structurally complete Bind sources, unsafe Bind sources, provisional TestFramework sources, and planned-but-not-yet-materialized theme sources

#### Scenario: OpenSpec validates strictly

- **WHEN** the record is ready for review
- **THEN** `openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive` succeeds
- **AND** proposal, design, specs, and tasks artifacts are reported done
