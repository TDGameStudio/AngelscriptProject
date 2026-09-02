## ADDED Requirements

### Requirement: Every authored case has one exact v2 contract

The system SHALL maintain one authoritative v2 contract for every authored `TestSource/**/*.as` source and SHALL identify every callable declaration in that source.

#### Scenario: Source and callable coverage is complete

- **WHEN** strict validation runs for a migrated domain
- **THEN** every source path in that domain maps to exactly one contract
- **AND** every callable declaration maps to exactly one function contract by qualified owner plus exact declaration
- **AND** equal declarations in different namespaces or types remain distinct valid callables
- **AND** stale paths, duplicate CaseIds, true same-owner duplicate declarations, and uncontracted callables fail validation

#### Scenario: Contract records an exact callable

- **WHEN** a function contract is reviewed
- **THEN** it records CaseId/subcase, qualified owner, semantic name, exact AS declaration, role, parameters/defaults, return, writebacks, vectors, comment facts, fixture, phase, cleanup owner, coverage evidence, and review state
- **AND** the declaration matches the source exactly
- **AND** strict parity also matches owner, callable kind, return type, parameter direction/defaults, and annotations

#### Scenario: Current callable syntax is inventoried

- **WHEN** a domain contains constructors, destructors, operators, delegates, events, imports, free mixins, annotated methods, or anonymous `function()` / `[](){}` bodies
- **THEN** every callable receives a stable owner-qualified inventory identity
- **AND** comments or strings containing declaration-like text do not create inventory rows
- **AND** a trailing comment on an earlier statement does not attach to the next callable

### Requirement: Semantic names replace generated observation names

Migrated source SHALL use semantic callable names and SHALL NOT retain `Observe_*`, `SurfaceNNN`, or `_Nominal` source aliases.

#### Scenario: Legacy name is migrated

- **WHEN** a callable previously used a legacy observation name
- **THEN** its old declaration is preserved only in contract history
- **AND** its source declaration uses the reviewed semantic name
- **AND** no forwarding alias with the legacy name remains in the source

#### Scenario: Framework name is required

- **WHEN** UE, Blueprint, delegate, or TestFramework discovery requires an exact callback or hook name
- **THEN** the exact required name remains unchanged
- **AND** its contract records a non-empty required-name reason

### Requirement: Typed input, result, and writeback vectors are externally readable

Every entry callable SHALL expose the tested input and actual result through its exact signature or identified host-visible state; expected results SHALL be stored in typed vectors.

#### Scenario: Raw return value is available

- **WHEN** the tested API returns a scalar, struct, container, enum, class, object, package, world, CDO, or delegate value
- **THEN** the entry publishes the raw result or identified state
- **AND** it does not hide that result behind a comparison with an Expected parameter

#### Scenario: Comparison payload is complete

- **WHEN** a vector selects exact, near, identity, element, relation, exception, or compile-diagnostic comparison
- **THEN** it supplies the typed payload required by that comparison
- **AND** contradictory return, exception, and compile-diagnostic oracles fail validation

#### Scenario: Multiple results or mutation are observed

- **WHEN** behavior produces several values or mutates an input
- **THEN** the declaration uses explicit out writebacks, inout mutation, or identified reflected state
- **AND** every out/inout has a before/after vector
- **AND** a compound Boolean is not the only observation channel

#### Scenario: Zero-argument entry is legitimate

- **WHEN** an entry has no parameters
- **THEN** its contract records a zero-argument reason tied to default construction or a fixed framework callback
- **AND** unexplained zero-argument entries fail strict validation

### Requirement: Every callable has an attached knowledge comment

Every callable declaration SHALL have a directly attached English knowledge comment; file-level comments SHALL NOT substitute for function-level documentation.

#### Scenario: Annotated callable comment attaches correctly

- **WHEN** a callable has UFUNCTION or another callable annotation
- **THEN** the comment appears directly above the annotation
- **AND** it states CaseId, purpose/role, inputs or fixture/phase, outputs/side effects, and cleanup/boundary as applicable

#### Scenario: Helper or required callback is documented

- **WHEN** a callable is a helper, constructor, operator, delegate, lifecycle callback, Blueprint override, negative trigger, or framework hook
- **THEN** it has its own concise knowledge comment
- **AND** required fixed naming or non-obvious ownership is explained

### Requirement: Contract projections and validation are deterministic

Contracts SHALL deterministically generate the global index and per-domain task projections, and strict validation SHALL reject source/contract drift.

#### Scenario: Task projection is generated

- **WHEN** contracts are generated for a domain
- **THEN** its task projection shows old declaration, new name, exact declaration, typed vectors, comment summary, fixture/cleanup, and verification command for every callable
- **AND** regenerating without input changes is byte-identical

#### Scenario: Projection fails closed

- **WHEN** a contract is draft, legacy-only, stale, duplicate, or no longer matches current source
- **THEN** it is not emitted into reviewed index/task projections
- **AND** a dirty audit prevents projection files from being written

#### Scenario: Legacy authored export cannot infer an entry

- **WHEN** only a v1 authored rule or semicolon-packed `plannedSymbols` exists
- **THEN** the adapter exposes audit-only migration evidence
- **AND** active authored export fails until a reviewed source-parity-clean v2 contract exists
- **AND** it does not guess declaration, entry point, typed vectors, or compile status

#### Scenario: Audit and strict modes remain truthful

- **WHEN** audit mode scans a non-migrated domain
- **THEN** it reports incomplete contracts and legacy patterns without crashing
- **AND** it does not label the domain strict or accepted
- **WHEN** strict mode scans a selected migrated domain
- **THEN** unrelated non-migrated domains do not affect that result

### Requirement: Acceptance state distinguishes source from runtime execution

The system SHALL distinguish materialization, reviewed contract, strict source, compile, runtime, and external-oracle states.

#### Scenario: Source-only phase completes

- **WHEN** a case has a reviewed contract, matching source, attached comments, and strict validation
- **THEN** it may be marked `SourceStrict`
- **AND** it is not marked compile-, runtime-, or external-oracle-verified without fresh evidence from the later runner
