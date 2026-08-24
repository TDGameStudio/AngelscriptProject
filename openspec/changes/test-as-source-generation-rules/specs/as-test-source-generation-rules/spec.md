## ADDED Requirements

### Requirement: Shared language-neutral generation contract

The system SHALL define versioned, language-neutral request, result, recipe, comment-fact, and typed-oracle schemas under `TestSource/Generation`. The schemas SHALL contain every value needed to reproduce, inspect, export, and later execute a case without relying on Python objects, Unreal types, absolute paths, or hidden global state.

#### Scenario: Complete generated result

- **WHEN** a valid request is generated for a CaseKey, explicit axis cell, and seed
- **THEN** the result includes canonical source bundle entries, canonical manifest, selected axes, seed, typed oracle, comment facts, references, harness requirements, and negative/recovery metadata when applicable

#### Scenario: Unknown required schema version

- **WHEN** either implementation reads a request, rule, result, or oracle with an unsupported required version
- **THEN** it rejects the input with the same stable error classification and emits no partial source

### Requirement: Exhaustive explicit axes precede variation

Every recipe SHALL enumerate its complete constrained explicit product in canonical order before applying random choices. The selected seed SHALL NOT add, remove, sample, or reorder required cells unless order is itself an explicit tested axis.

#### Scenario: Seed does not change matrix membership

- **WHEN** the same product is generated with two different seeds
- **THEN** both results contain the same CaseKeys and explicit cells in the same canonical order
- **AND** only declared legal random slots may differ

#### Scenario: SDK cardinality is preserved

- **WHEN** all 271 planned Native SDK products are enumerated
- **THEN** each product produces its catalogued expanded cardinality
- **AND** the combined product contains exactly 45,760 mandatory cells for every seed

### Requirement: Controlled portable randomness

Observable generation SHALL use the specified `SplitMix64-v1` state transition, UTF-8 FNV-1a CaseKey identity input, unsigned 64-bit arithmetic, rejection sampling for bounded choices, deterministic Fisher-Yates for permutations, and named per-slot substreams. Python `random.Random`, C++ standard random engines/distributions, Unreal `FRandomStream`, time-derived seeds, process hashes, and process-global RNG state SHALL NOT influence observable output.

#### Scenario: Cross-language random vector

- **WHEN** Python and portable C++ consume the same golden seed/CaseKey/cell/slot vector
- **THEN** every state, bounded choice, and permutation byte-for-byte matches the versioned golden vector

#### Scenario: New slot does not perturb an existing slot

- **WHEN** a recipe version adds a new independently named random slot without changing an existing slot definition
- **THEN** the existing slot retains its prior sequence for the same CaseKey, cell, and seed

### Requirement: Independent Python and portable C++ implementations

Python and standard C++ SHALL implement the same schemas, algorithms, constraints, recipes, emitters, and errors independently. Neither implementation SHALL invoke, embed, bind to, or delegate generation to the other. The portable C++ implementation SHALL build without Unreal Engine.

#### Scenario: Representative parity

- **WHEN** both implementations generate every recipe family across boundary seeds, ordinary seeds, positive cells, negative cells, and recovery bundles
- **THEN** source bytes, manifest bytes, identities, cell ordering, typed oracles, comments, and stable errors are identical

#### Scenario: Repeated process determinism

- **WHEN** the same request is run in fresh processes and different output directories
- **THEN** both runs produce identical bytes and identities

### Requirement: Deep AngelScript generation surface

The initial recipe system SHALL support complete declarations, functions, parameter/return forms, expressions, statements, UE annotated definitions, reflected properties/functions, containers, frontend/compiler/runtime/module/type-system/embedding/debug/serialization/ownership cases, and structural negative/recovery bundles as described by `catalogs/recipe-family-registry.csv`. It SHALL NOT treat a fixed UE profile fragment as sufficient implementation of a declared product rule.

#### Scenario: Reflected definition case

- **WHEN** a UE definition recipe selects a class/struct/enum/interface kind, specifiers, members, defaults, publication order, and callable/property shapes
- **THEN** the generated source is a complete legal or intentionally single-invalid source unit
- **AND** the oracle describes exact reflected metadata, defaults, invocation/writeback, diagnostics, and cleanup observations required by that cell

#### Scenario: Function return and writeback case

- **WHEN** a function recipe selects return type, parameter type, direction, position, arity, and call form
- **THEN** generated inputs use distinct typed sentinels
- **AND** the oracle consumes the return value and records exact transfer/writeback/lifecycle observations rather than only compile status

### Requirement: Complete typed observations

Every generated case SHALL carry a tagged, lossless oracle appropriate to the tested behavior, including width-aware scalar values, floating comparison rules, text/name/string values, aggregates, object identity/nullability, receiver/container state, out/inout writeback, metadata/type/layout, bytecode/trace/position, exception, lifecycle/cleanup/isolation, module/save-load, diagnostic, and recovery observations as applicable.

#### Scenario: Non-integer return

- **WHEN** the source returns a boolean, unsigned width, float/double, string/name/text, enum, math struct, object/reference, or aggregate
- **THEN** the oracle preserves that type and comparison semantics without coercing it to `int`

#### Scenario: Void operation

- **WHEN** a generated entry point returns void
- **THEN** the case records an exact observable post-state, callback/trace, metadata, diagnostic, lifecycle, cleanup, or isolation expectation
- **AND** compile success alone is not accepted when the reference test observes more

### Requirement: Valid-baseline negative generation

Every negative generated cell SHALL begin from a valid source for the same recipe, apply exactly one named invalid mutation, freeze its diagnostic anchor, and retain unrelated baseline facts. A corrected recovery source SHALL be included whenever the reference behavior observes atomic failure, cleanup, isolation, reset, rebuild, or same-name recovery.

#### Scenario: Single invalid mutation

- **WHEN** a negative cell is generated across multiple seeds
- **THEN** each output contains exactly the selected named mutation
- **AND** random variation remains confined to legal baseline slots

#### Scenario: Recovery bundle

- **WHEN** the product requires recovery evidence
- **THEN** the result contains a separately identified corrected source and its expected clean build/runtime state

### Requirement: Knowledge-like AS comments

Generated source and authored-export metadata SHALL provide sufficient feature, input, expected-observation, boundary/ownership/recovery, and reference knowledge. Comment validation SHALL check semantic facts and correct attachment without imposing one universal sentence template or exact prose snapshot.

#### Scenario: Recipe-specific comment organization

- **WHEN** an expression case and a lifecycle/recovery case render their comments
- **THEN** both explain their concrete feature, inputs, and expected observations
- **AND** each may use an organization appropriate to its complexity

### Requirement: Canonical in-memory output by default

Generation SHALL return source/results in memory by default. AS source SHALL be UTF-8 without BOM, LF-normalized, and end in exactly one newline; canonical manifests SHALL follow their fixed ordering and escaping contract. Writes SHALL require an explicit Saved/temp, reviewed-golden, or release mode, and path guards SHALL prevent accidental bulk output into the plugin or TestSource authored tree.

#### Scenario: Default request

- **WHEN** a caller omits an output mode
- **THEN** the complete generated case is returned in memory
- **AND** no source, catalog, corpus, or history file is created

#### Scenario: Explicit golden write

- **WHEN** a caller selects reviewed-golden mode for an approved representative case
- **THEN** only the declared golden path is written
- **AND** its bytes equal the in-memory canonical bytes

### Requirement: Authored source export uses the same result contract

Reviewed TestSource `.as` files SHALL be exportable through the same CaseKey/result/static-release model without regenerating or silently altering their semantics. An authored callable SHALL be eligible only when a reviewed `authored-case-contract-v2` row exactly matches the current source declaration and supplies CaseId/subcase, semantic entry point, typed arguments, raw return oracle, explicit writebacks, exception oracle, adjacent knowledge-comment facts, fixture/cleanup/isolation metadata, and truthful runner status. Legacy authored rules and `plannedSymbols` SHALL be migration evidence only and SHALL NOT be used to infer declarations, entry points, vectors, or pass status. Seed SHALL be ignored for authored bytes unless a later rule explicitly promotes part of the source to generation.

#### Scenario: Authored fixture export

- **WHEN** an authored CaseKey is requested
- **THEN** its canonical source and reviewed V2 callable contracts, exact declarations, typed invocations, raw results/writebacks/exceptions, comments, harness, dependencies, status, and references are present in the result
- **AND** its AS test intent remains owned by the reviewed `.as` file

#### Scenario: Legacy-only authored metadata is rejected

- **WHEN** an authored source has only a v1 rule or a semicolon-packed `plannedSymbols` field
- **THEN** authored export fails with a stable missing-reviewed-contract error
- **AND** neither implementation guesses a declaration, entry point, argument vector, writeback, oracle, or pass status

#### Scenario: Contract and source declaration drift is rejected

- **WHEN** a reviewed V2 row no longer exactly matches its callable in the current authored source
- **THEN** authored export fails before producing a release case
- **AND** the error identifies the CaseId/subcase and mismatched declaration
