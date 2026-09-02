## ADDED Requirements

### Requirement: TestSource has one canonical authored theme registry

The system SHALL treat root `TestSource/` as the only authored source of truth for the themes `Bindings`, `Containers`, `Debugger`, `Definitions`, `Feature`, `Gameplay`, `HotReload`, `Language`, `Optional`, `TestFramework`, and `World`; `Generation` SHALL remain the contract/tooling package.

#### Scenario: Current materialized tree is inventoried

- **WHEN** the registry is generated
- **THEN** all current authored `.as` paths are assigned to exactly one theme/leaf
- **AND** the baseline reports 3,041 materialized `.as` files rather than the stale 614-materialized/2,427-planned split
- **AND** empty directories are not created solely to satisfy theme shape

#### Scenario: Downstream consumer needs source

- **WHEN** a plugin fixture, generated C++ function, release mirror, or runner needs authored source
- **THEN** it consumes a reviewed TestSource contract/source result
- **AND** it does not create a second editable source tree

### Requirement: Every theme freezes exact callable design before source edits

Each theme SHALL complete a read-only audit and reviewed full callable contract before modifying its `.as` sources.

#### Scenario: Theme audit is ready

- **WHEN** a theme is about to enter implementation
- **THEN** every current source/callable has an old-to-new mapping, exact declaration, typed vectors, comment facts, fixture/phase/cleanup, and evidence reference
- **AND** the generated task projection exposes those values to the implementation agent
- **AND** source edits are blocked while any mapping is Draft

#### Scenario: Full plan awaits user acceptance

- **WHEN** the read-only audits and normalized full-corpus task projection are complete
- **THEN** every suggested replacement callable is listed as an independent task with semantic name and exact AngelScript declaration
- **AND** every task also records its immediate English comment, concrete typed vectors, fixture/cleanup, body constraints, status, blockers, and literal verification command
- **AND** the task plan contains no deferred `expand later`, `remaining`, placeholder declaration, or hidden 1-to-N split
- **AND** the system stops before source implementation until the user accepts the plan revision

#### Scenario: Independent themes execute in parallel

- **WHEN** agents work concurrently
- **THEN** each agent owns disjoint source and contract paths
- **AND** shared index/task projection regeneration is serialized and deterministic

### Requirement: World and lifecycle themes use current UE fixture semantics

World, Actor, Component, Subsystem, Timer, Delegate, Widget, GC, and spawn stories SHALL encode the current UE 5.7 Angelscript test lifecycle instead of local field writes or ambient-world assumptions.

#### Scenario: DefaultComponent is observed on a runtime actor

- **WHEN** a runner-spawned non-CDO actor declares a DefaultComponent property
- **THEN** the component is required to be materialized and associated with the correct owner/world/class
- **AND** a null DefaultComponent is not a successful default-state oracle

#### Scenario: Lifecycle callback is tested

- **WHEN** BeginPlay, Tick, EndPlay, Destroyed, subsystem initialize/deinitialize, or component dispatch is the behavior
- **THEN** the external fixture owns the dispatch phase
- **AND** source read functions expose actual counts, deltas, reasons, order, owner, and state
- **AND** directly writing fields or calling callbacks does not substitute for framework dispatch

#### Scenario: Timer or delegate behavior is tested

- **WHEN** a timer or delegate is the behavior
- **THEN** acceptance requires real TimerManager advance or real Broadcast respectively
- **AND** direct callback/handler calls are distinct supplemental subcases
- **AND** looping timers and external bindings have explicit cleanup or an intentional destroy-as-cleanup contract

#### Scenario: GC behavior is tested

- **WHEN** reachability or weak invalidation is the behavior
- **THEN** create, retain, release, host-GC, and read phases are distinct
- **AND** global GC cases are FixtureIsolated and ExclusiveGlobalGC
- **AND** only the GC API's own case invokes global collection inside script as the tested operation

### Requirement: UObject, Blueprint, inheritance, and HotReload preserve identity contracts

Object and reflected-type themes SHALL expose raw identity and distinguish direct script dispatch, ProcessEvent, CDO, instance, old/new type, retained/replaced state, and cleanup.

#### Scenario: NewObject is observed

- **WHEN** NewObject is tested
- **THEN** each argument/default/null-outer/error boundary is an independent callable/vector
- **AND** the returned object remains available for exact identity, outer, class, name, flags, and later lifetime checks
- **AND** comments state that Outer is containment rather than an automatic GC keepalive

#### Scenario: Blueprint CDO and instance are observed

- **WHEN** defaults, inheritance, recreate, or child override behavior is tested
- **THEN** CDO and runtime instance use a stable callable surface and remain distinguishable by identity/class/flags/state
- **AND** instance mutation does not silently stand in for CDO or sibling behavior

#### Scenario: ProcessEvent behavior is tested

- **WHEN** the case claims reflected ProcessEvent dispatch
- **THEN** the source preserves the exact UFUNCTION signature and typed inputs/writebacks
- **AND** direct AS calls are named and tracked as separate direct-dispatch subcases

#### Scenario: HotReload version pair is observed

- **WHEN** a Before/After or version chain is migrated
- **THEN** every version has its own CaseId and exact surface contract
- **AND** allowed signature/layout/body differences are enumerated
- **AND** retained/replaced UClass, CDO, instance, property, function, delegate and runtime state are explicit

### Requirement: TestFramework and Debugger retain protocol-owned names and external oracles

Framework and debugger sources SHALL preserve names/markers required for discovery or protocol behavior while still meeting per-callable contract and comment rules.

#### Scenario: Framework hook has a fixed name

- **WHEN** discovery, setup/teardown, latent command, assertion, lifecycle, reload, or self-hosted protocol requires an exact method name
- **THEN** the method keeps that name with a required-name reason
- **AND** its phase, expected counts/order/diagnostics, ownership, and cleanup are documented

#### Scenario: Framework cannot prove itself circularly

- **WHEN** a self-hosted or expected-failure framework case is represented
- **THEN** its contract requires an independent external oracle for discovered/pass/fail counts, diagnostics, source locations, order, and cleanup
- **AND** source-level assertions alone do not upgrade runtime acceptance

#### Scenario: Debugger marker remains stable

- **WHEN** a debugger source contains breakpoint, frame, scope, line, or event markers
- **THEN** marker location and expected sequence are explicit and stable
- **AND** semantic renaming does not silently change line-sensitive behavior

### Requirement: Full-theme completion is mechanically and semantically audited

All themes SHALL pass strict source validation and an independent review before the change is considered source-complete.

#### Scenario: Full source audit passes

- **WHEN** all theme waves finish
- **THEN** every source and callable has one reviewed contract and attached comment
- **AND** old source naming patterns have zero declaration matches
- **AND** no out/inout lacks writeback vectors
- **AND** no high-risk lifecycle pattern remains without fixture/phase/cleanup

#### Scenario: Runtime status remains truthful

- **WHEN** full TestSource strict validation passes without a plugin runner change
- **THEN** the record reports SourceStrict completion
- **AND** compile, runtime, Automation, and external-oracle verification remain pending until their own fresh evidence exists
