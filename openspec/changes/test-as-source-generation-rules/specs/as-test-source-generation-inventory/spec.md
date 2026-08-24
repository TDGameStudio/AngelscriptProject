## ADDED Requirements

### Requirement: Exact authored TestSource inventory

The planning inventory SHALL contain exactly one generation/export row for every `TargetPath` in `test-as-manual-bind-source-coverage/inventory/planned-test-sources.csv`. Each row SHALL retain the manual task ID, bind/surface/reference IDs, source shape, planned symbols, AS test scope, inputs, expected observations, expected comment focus, harness, dependencies, stable CaseKey, generated C++ symbol, and current source availability.

#### Scenario: Manual-bind catalog join

- **WHEN** the generation catalogs are rebuilt
- **THEN** authored paths and manual task IDs match the manual-bind inventory as exact sets
- **AND** the baseline contains exactly 614 unique rows

### Requirement: Exact Native SDK generated-product inventory

The planning inventory SHALL contain exactly one rule row for each entry in the Native SDK `generated-source-registry.csv` and SHALL join its exact product cardinality. Each row SHALL record the legacy file/class/method/generator, theme, axes, expanded cells, classification, evidence, recipe, AS scope, oracle scope, fixed inputs, random slots, constraints, negative/recovery policy, comment knowledge, references, generated symbol, and no-replacement status.

#### Scenario: SDK product join

- **WHEN** the SDK generation catalog is rebuilt
- **THEN** all 271 ProductIds match the authoritative registry and cardinality sets
- **AND** their expanded cells sum to exactly 45,760

### Requirement: Exact Coverage method inventory

The inventory script SHALL scan the current `AngelscriptTest/Coverage` tree, record all `.cpp` files in a file-level registry, and record every `TEST_METHOD` in a method-level disposition catalog with file, class, method, line, domain, source shape, existing oracle, disposition, candidate recipe, product axes, generated AS scope, host requirements, rationale, references, and future CaseKey. A support-only file with no `TEST_METHOD` SHALL remain explicitly visible in the file registry.

#### Scenario: Current Coverage baseline

- **WHEN** the inventory is generated against the recorded main baseline
- **THEN** its file registry contains exactly 90 `.cpp` rows
- **AND** its method catalog contains 1,022 unique `TEST_METHOD` rows whose file-level counts sum to the same total
- **AND** `AngelscriptCoverageGCTestHelpers.cpp` is recorded as the one support-only file

#### Scenario: Coverage baseline drift

- **WHEN** current Coverage source no longer matches the recorded baseline
- **THEN** the script fails with the observed file/method counts instead of silently emitting a stale-success result

### Requirement: Complete current inline AS inventory

The inventory script SHALL record every `ASTEST_AS*` invocation and every likely direct AS raw literal in current `AngelscriptTest` C++/header source. Each row SHALL include file, owner class/method, line, extraction form, source-unit count, approximate shape, execution kind, oracle, return types, disposition, recipe, future identity/symbol, generated AS scope, references, and rationale.

#### Scenario: Macro completeness

- **WHEN** the current source contains 2,374 `ASTEST_AS*` invocations
- **THEN** the catalog contains exactly 2,374 corresponding macro rows

#### Scenario: Direct raw source

- **WHEN** an AS source-like raw literal is not wrapped in `ASTEST_AS*`
- **THEN** it is recorded separately with its raw-string extraction form and owning source context

### Requirement: Explicit disposition before promotion

Every Coverage method and inline source unit SHALL be classified as `AuthoredExport`, `GeneratedRecipe`, or `SpecializedScenario`. Script heuristics SHALL be treated as candidates, and every owning inline file SHALL have a concrete review task before a generated rule can be implemented.

#### Scenario: Generated candidate review

- **WHEN** a row is classified as `GeneratedRecipe`
- **THEN** its owning-file review confirms a finite explicit product, complete oracle, legal random slots, frozen semantics, host boundary, and references before implementation

#### Scenario: Specialized UE story

- **WHEN** a case depends on world, actor, component, network, timer, input, physics, asset, hot-reload, debugger, subsystem, or other scenario-specific host state
- **THEN** it remains `SpecializedScenario` unless review proves that only a finite source product is being extracted and the existing host fixture remains authoritative

### Requirement: Static registry covers reviewed origins

The static-function registry SHALL include every authored fixture and SDK product plus every currently planned generated Coverage/non-Coverage inline candidate, with unique CaseKey and C++ symbol, recipe, source/product identity, request axes, default seed, return type, release shard, and references.

#### Scenario: Minimum registry baseline

- **WHEN** the registry is built from the 614 authored fixtures and 271 SDK products
- **THEN** it contains at least 885 unique static entries before optional reviewed candidates

#### Scenario: Product not cell granularity

- **WHEN** registry rows are compared with SDK expanded cells
- **THEN** there is one SDK registry row per ProductId rather than 45,760 per-cell C++ entries

### Requirement: Execution-ready per-entry tasks

Every future implementation checkbox SHALL state files, current reference points, generated AS scope, explicit axes, oracle, random/frozen boundary, impact, tests, verification command, governing requirement, and dependencies. Authored fixtures and SDK products SHALL each have a failing-test task followed by an implementation task.

#### Scenario: Task body audit

- **WHEN** `tasks.md` is validated
- **THEN** every checkbox contains all required task-body fields
- **AND** no placeholder such as `TODO`, `TBD`, or an unspecified reference remains

### Requirement: No adoption or replacement in this change

Inventories, rules, static release outputs, and tasks SHALL be additive. They SHALL NOT delete, replace, relocate, or retarget current builders, inline source, manual TestSource files, automation names, or runners.

#### Scenario: Planning pass scope

- **WHEN** this plan-only OpenSpec creation pass completes
- **THEN** all changed paths are beneath `openspec/changes/test-as-source-generation-rules`
- **AND** `TestSource`, `Tools`, plugin/submodule source, other changes, and the old `script-corpus` worktree are untouched
