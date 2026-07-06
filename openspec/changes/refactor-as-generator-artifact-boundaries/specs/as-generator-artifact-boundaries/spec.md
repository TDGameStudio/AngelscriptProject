## ADDED Requirements

### Requirement: Generator artifact ownership is explicit

The AS-to-Unreal Generator SHALL separate generated artifact responsibilities by ownership: `UASClass` owns generated class runtime behavior, `UASFunction` owns generated function reflection and call behavior, and `UASFunction_*` dispatch variants own dispatch strategy specialization. Refactoring these units MUST preserve generated Unreal artifact behavior.

#### Scenario: Artifact boundaries are reviewed

- **WHEN** the follow-up refactor moves code out of `ASClass.cpp/.h`
- **THEN** each moved responsibility MUST belong to exactly one artifact layer: `UASClass`, `UASFunction`, or dispatch variants

#### Scenario: Generated behavior is unchanged

- **WHEN** the artifact split is validated
- **THEN** generated `UClass`, `UStruct`, `UFunction`, property metadata, CDO/default-component state, dispatch selection, and runtime invocation behavior MUST remain equivalent to the pre-split baseline

### Requirement: UHT-facing dispatch declarations remain explicit

The Generator refactor SHALL keep all UHT-facing `UASFunction_*` `UCLASS()` declarations as explicit committed C++ declarations. Macro/table generation MUST NOT be the only source of any declaration that UHT must parse.

#### Scenario: Dispatch variants are deduplicated

- **WHEN** implementation bodies or factory tables are generated from a shared variant list
- **THEN** the `UCLASS()` declarations consumed by UHT MUST still exist as explicit committed C++ source or checked-in generated C++ reviewed before build

### Requirement: Tests pin public artifact behavior

Characterization tests for this follow-up SHALL assert public Generator outputs rather than private implementation details. Tests MUST observe generated Unreal artifacts, diagnostics, reload results, or runtime behavior.

#### Scenario: ASClass gaps are covered narrowly

- **WHEN** new `UASClass`-related tests are added
- **THEN** they MUST target known remaining gaps such as namespaced-UCLASS positive generation, default/override component wiring details, or a stable public debugger prototype seam, without duplicating already-covered constructor/defaults/tick/replication/GC behavior

#### Scenario: Internal layout is not tested

- **WHEN** the implementation is split into new translation units
- **THEN** tests MUST NOT assert file names, helper placement, private counters, or internal state transitions that are not public Generator behavior

### Requirement: ClassGenerator tests follow UnitTest conventions

Existing `ClassGenerator` tests touched by this change SHALL be normalized to `Documents/UnitTest/UnitTest.md` before they are used as regression coverage for Generator artifact movement. Refactoring tests MUST preserve the same public behavior assertions.

#### Scenario: Test lifecycle is class-level

- **WHEN** a `ClassGenerator` CQTest file is refactored in this change
- **THEN** the test class MUST create/reset its Angelscript test engine through class-level lifecycle hooks instead of creating and resetting the engine inside each `TEST_METHOD`

#### Scenario: Inline AS fixtures are normalized

- **WHEN** a refactored test compiles inline AngelScript source
- **THEN** the source MUST use `ASTEST_AS(R"AS(... )AS")` unless the test is explicitly exercising an ANSI/raw SDK path

#### Scenario: Test behavior is preserved

- **WHEN** a test file is normalized for style
- **THEN** it MUST keep asserting the same public diagnostics, generated artifacts, reload results, or runtime behavior as before the style refactor

### Requirement: Naming cleanup is deferred

The follow-up SHALL NOT rename the `ClassGenerator` source/test directories or broad automation prefixes as part of the artifact split. Any migration from `ClassGenerator` naming to `Generator` naming MUST be planned as a separate rename-focused change.

#### Scenario: Artifact split lands first

- **WHEN** this change is implemented
- **THEN** path and test-prefix churn MUST be limited to files required for `UASClass`, `UASFunction`, and dispatch-variant ownership separation