## ADDED Requirements

### Requirement: TestSource theme registry

The TestSource plan SHALL define one canonical registry for the handwritten source themes `Bindings`, `TestFramework`, `Language`, `Definitions`, `Containers`, `Feature`, `World`, `Gameplay`, `Optional`, `HotReload`, and `Debugger`; `Generation` SHALL be recorded as a separate tooling package rather than a test theme.

#### Scenario: Existing themes remain first class
- **WHEN** the registry is generated
- **THEN** `Bindings` and `TestFramework` are present as first-class themes with their existing target roots
- **AND** their 576 and 38 materialized source paths remain owned by the existing manual-bind capability

#### Scenario: Missing themes have stable leaves
- **WHEN** a new handwritten source is planned
- **THEN** it maps to exactly one registered leaf theme and one exact `TestSource/<Theme>/.../*.as` target
- **AND** empty directories are not planned solely to make the tree look complete

### Requirement: TestSource canonical ownership

The plan SHALL treat root `TestSource/` as the only canonical home for reusable handwritten AngelScript test source and SHALL treat plugin fixtures, C++ inline strings, generated C++ functions, and release copies as later consumer artifacts.

#### Scenario: Existing fixture design conflicts
- **WHEN** a sibling OpenSpec proposes handwritten source under plugin `Fixtures/`
- **THEN** the reconciliation record identifies TestSource as the source of truth
- **AND** the sibling runner is treated as a consumer that must later import, embed, or synchronize a reviewed release result

#### Scenario: Source-only planning turn
- **WHEN** this theme expansion is applied
- **THEN** only files under this OpenSpec change are modified
- **AND** no `TestSource`, plugin, `Script`, runner, generator, build, or release file is changed

### Requirement: Current test evidence disposition

Every current `TEST_METHOD`, candidate C++ raw-string block, and independent `Script/**/*.as` file in the core, GameplayTags, and GAS test scopes SHALL receive a stable ReferenceId and an explicit disposition.

#### Scenario: Test method contains reusable script
- **WHEN** a current method contains one or more candidate script blocks and is not already owned, host-only, native-only, blocked, or generation-owned
- **THEN** every block maps to an exact planned handwritten target and task
- **AND** the method record links all block ReferenceIds

#### Scenario: Test method has no reusable script
- **WHEN** a method tests C++ host machinery or has no reusable AngelScript body
- **THEN** it is recorded as `HostOnly`, `NoReusableAngelScript`, or another permitted non-source disposition with a concrete reason
- **AND** no artificial `.as` task is created

#### Scenario: Native SDK remains reference-only
- **WHEN** a test belongs to `AngelScriptSDK`
- **THEN** it is recorded as `ReferenceOnlyNativeSDK`
- **AND** no `TestSource/AngelScriptSDK` target is planned

### Requirement: Stable inline script identity

Every candidate inline script block SHALL record its repository-relative path, owning or nearest test class and method, block ordinal, start/end line, delimiter, SHA-256 content hash, declaration hints, and C++ oracle hints.

#### Scenario: Source line moves without content change
- **WHEN** a block moves to another line but its normalized content is unchanged
- **THEN** its hash continues to identify the content
- **AND** regenerated navigation lines are reported as inventory drift rather than a new semantic test

#### Scenario: Inline content changes
- **WHEN** a block body changes
- **THEN** its hash changes and `-Check` reports the stale inventory
- **AND** its planned source task remains unchecked until the reference and expected oracle are reviewed

### Requirement: Exact planned handwritten source contract

Every `PlanHandwrittenSource` row SHALL name a unique task and target path and SHALL record theme, leaf, question, source shape, exact references, planned symbols, test scope, inputs/setup, expected results/effects, boundaries, fixture and cleanup owners, execution policy, comment focus, exclusions, blocker, and acceptance state.

#### Scenario: Non-void and writeback behavior
- **WHEN** the referenced program returns values or writes out/inout state
- **THEN** the planned task requires exact value, field, count, ordering, identity, alias, or writeback observations
- **AND** successful compilation or invocation alone is not accepted

#### Scenario: Negative diagnostic source
- **WHEN** the referenced program is expected to fail
- **THEN** the task records the expected compile/runtime phase and diagnostic meaning
- **AND** a negative program is isolated from unrelated positive declarations

#### Scenario: World or lifecycle source
- **WHEN** the referenced program needs a World, UObject, Actor, Component, subsystem, timer, delegate, asset, or network fixture
- **THEN** setup and cleanup ownership are explicit
- **AND** missing required setup is a setup failure rather than a successful null observation

### Requirement: Driver folders do not become source themes mechanically

The plan SHALL classify source by tested AngelScript subject and question rather than copying the physical C++ test directory taxonomy.

#### Scenario: Syntax or Coverage source is classified
- **WHEN** a script currently lives in `Syntax`, `Compiler`, `Preprocessor`, or `Coverage`
- **THEN** it maps to the applicable Language, Definitions, Containers, Feature, Gameplay, or other semantic leaf
- **AND** the C++ directory remains a reference/driver field only

#### Scenario: Functional source uses a World
- **WHEN** a Functional test spawns an Actor to prove a delegate, timer, definition, container, or inheritance behavior
- **THEN** the source keeps the full non-World leaf and uses question `world-story`
- **AND** it maps to `World.Actor` only when Actor lifecycle itself is the oracle

#### Scenario: Host profile tests contain incidental script
- **WHEN** Cache, StaticJIT, RuntimeJIT, Core, Dump, FileSystem, Validation, UHTTool, or generator-planner code uses an incidental script body to exercise host machinery
- **THEN** it is recorded as `HostOnly` unless a distinct reusable semantic program is identified
- **AND** no folder-mirroring theme is created

### Requirement: Intentional overlap between Bindings and semantic themes

Bindings MAY reference the same API family as a semantic theme, but the two planned sources SHALL have different questions and materially different oracles.

#### Scenario: TArray bind and behavior sources coexist
- **WHEN** `Bindings/TArray` proves AS-facing entry visibility and `Containers/TArray` proves values or lifecycle
- **THEN** each source records the other as a related theme
- **AND** the semantic source does not copy a one-line bind smoke as its behavioral oracle

### Requirement: Special theme separation

Root `HotReload` and `World` sources SHALL remain distinct from the `TestFramework/HotReload` and `TestFramework/World` framework-conformance areas, and Debugger source payloads SHALL remain distinct from the DAP host protocol.

#### Scenario: Framework reload source is classified
- **WHEN** a reload case proves registry refresh, active leaf cancellation, result coalescing, or framework session reopening
- **THEN** it remains under `TestFramework/HotReload`
- **AND** it is not duplicated under root `HotReload`

#### Scenario: Ordinary script shape reload is classified
- **WHEN** a reload case changes a script class, struct, function, property, inheritance chain, component tree, or module
- **THEN** it is planned as a root `HotReload` version pair with explicit before/after observations
- **AND** the task names retained state, replaced state, failure retention, and cleanup where applicable

### Requirement: Generated and blocked source disposition

Homogeneous expression, literal, definition, permutation, combination, or randomized programs SHALL be routed to the independent generation change, and namespace-dependent FMath behavior extraction SHALL remain blocked while its canonicalization change is active.

#### Scenario: Generation candidate is found
- **WHEN** a current method is a homogeneous or combinatorial generation candidate
- **THEN** it is recorded as `GeneratedLater` with the owning generation change
- **AND** no duplicate handwritten source checkbox is emitted

#### Scenario: FMath theme source is found
- **WHEN** a new `Gameplay.FMath` behavior/profile source would depend on the public namespace spelling
- **THEN** it is recorded as `Blocked` by `improve-as-library-namespace-canonicalization`
- **AND** existing `Bindings/FMath` inventory remains unchanged

### Requirement: Theme planning data is mechanically closed

The theme registry, method inventory, script references, planned sources, non-source dispositions, summary, matrices, and generated task section SHALL form a deterministic closed set.

#### Scenario: Inventory check passes
- **WHEN** the theme inventory script runs with `-Check`
- **THEN** every generated artifact exactly matches the current source scan
- **AND** TaskId, ReferenceId, target path, and method identity uniqueness checks pass

#### Scenario: OpenSpec validates
- **WHEN** the theme planning record is ready for review
- **THEN** `openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive` succeeds
- **AND** no files outside this change are required for the record-only result
