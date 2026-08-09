## ADDED Requirements

### Requirement: Runtime FunctionLibrary tests use one flat theme

Tests whose primary subject is `AngelscriptRuntime/FunctionLibraries` SHALL live directly in `Plugins/Angelscript/Source/AngelscriptTest/FunctionLibraries/` and SHALL use automation IDs rooted at `Angelscript.TestModule.FunctionLibraries`. Runtime is the implicit domain; the theme SHALL NOT add Runtime, Contract, Math, Curve, or other child directories.

#### Scenario: Contract and behavior are distinguished by names

- **WHEN** FunctionLibrary contract, math, curve, input, world, or helper tests are registered
- **THEN** their file names and automation suffixes SHALL identify the concern, such as `AngelscriptFunctionLibraryContractTests.cpp` with `Angelscript.TestModule.FunctionLibraries.Contract.*`
- **AND** every file SHALL remain directly under the FunctionLibraries directory

#### Scenario: Editor tests are not fabricated

- **WHEN** no Editor-owned FunctionLibrary binding lifecycle exists
- **THEN** no FunctionLibraries Editor test directory or `Angelscript.TestModule.FunctionLibraries.Editor` prefix SHALL be registered

### Requirement: FunctionLibrary test migration preserves coverage and suite routing

Primarily FunctionLibrary tests moved from Core or Bindings SHALL adopt the FunctionLibraries prefix without retaining duplicate legacy registrations. Mixed-concern files SHALL move only their FunctionLibrary scenarios, while broader Coverage and Functional scenarios SHALL remain in their authoritative layer.

#### Scenario: New prefix is included in suites

- **WHEN** the test suite and shard definitions are evaluated after migration
- **THEN** `Angelscript.TestModule.FunctionLibraries` SHALL be an explicit routed prefix and every moved test SHALL remain discoverable exactly once

#### Scenario: Bindings loses no uncovered matrix

- **WHEN** broad behavior is removed from a Bindings file during migration
- **THEN** the same behavior SHALL already exist in FunctionLibraries, Coverage, or the corresponding Functional layer before the old registration is deleted

#### Scenario: Mixed test file is split by primary concern

- **WHEN** a Core, Bindings, Coverage, or Functional file combines FunctionLibrary contract with unrelated engine behavior
- **THEN** only the FunctionLibrary-specific methods SHALL move and the unrelated tests SHALL keep their existing path and prefix

### Requirement: FunctionLibrary CQTests follow the current unit-test authority

Every new or refactored FunctionLibraries test SHALL conform to `Documents/UnitTest/UnitTest.md`, including the unit-test registration gate, CQTest class shape, engine lifecycle, inline AS formatting, assertion handling, helper visibility, and state cleanup requirements.

#### Scenario: Test registration is gated and scenario-oriented

- **WHEN** a FunctionLibraries test source is compiled with `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** it SHALL register no CQTest or test-only bind object
- **AND** when enabled, its flow SHALL be visible in scenario-specific `TEST_METHOD` bodies inside `TEST_CLASS_WITH_FLAGS`

#### Scenario: Shared engine and method state are cleaned correctly

- **WHEN** a FunctionLibraries CQTest class executes multiple methods
- **THEN** engine creation/reset SHALL occur through class-level `BEFORE_ALL` and `AFTER_ALL`
- **AND** each method SHALL clean its own modules, delegates, transient objects, and global mutations

#### Scenario: Inline script and assertions use canonical forms

- **WHEN** a FunctionLibraries test compiles inline AngelScript or consumes a helper result
- **THEN** the source SHALL use `ASTEST_AS` with the required layout
- **AND** boolean results SHALL be consumed by matcher assertions or equivalent active-test reporting
