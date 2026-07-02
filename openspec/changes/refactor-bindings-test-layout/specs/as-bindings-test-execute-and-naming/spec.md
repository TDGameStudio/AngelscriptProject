## ADDED Requirements

### Requirement: Refactored Bindings test registrations are unit-test gated

Bindings tests under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` SHALL keep test-only registration code, section bind objects, and helper bodies behind `WITH_ANGELSCRIPT_UNITTESTS` when the code participates only in automation coverage. The production Angelscript runtime, editor, and generated binding contracts MUST NOT gain new dependencies on these test fixtures.

#### Scenario: Modified Bindings fixture is compiled only for unit tests

- **WHEN** a Bindings test file declares `TEST_CLASS_WITH_FLAGS`, scenario `TEST_METHOD`s, or test-only file-scope bind registration objects
- **THEN** those declarations MUST be protected by the unit-test gate used by `AngelscriptTest`

#### Scenario: Runtime binding behavior is unchanged

- **WHEN** the refactor is reviewed outside `Plugins/Angelscript/Source/AngelscriptTest/Bindings`
- **THEN** no runtime module, editor module, public plugin API, or generated binding table contract MUST be changed solely to support this test layout refactor

### Requirement: Refactored Bindings tests use scenario-oriented CQTest methods

Bindings tests under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` SHALL place executable test flow inside `TEST_CLASS_WITH_FLAGS` classes and narrow `TEST_METHOD` bodies whose names describe the covered binding scenario. Broad file-level `RunXxxSection()` dispatch wrappers MUST NOT remain as the primary control flow for scenarios touched by this refactor unless a shared native bind initialization path requires a small file-scope helper.

#### Scenario: Scenario method owns the test flow

- **WHEN** a Bindings test compiles AS source and asserts binding behavior in code touched by this refactor
- **THEN** the compile, execution, and assertion flow MUST be visible from a scenario-specific `TEST_METHOD`

#### Scenario: Module names track the scenario

- **WHEN** a scenario touched by this refactor creates a temporary AS module through `FCoverageModuleScope` or equivalent helpers
- **THEN** the module name MUST use full words that identify the scenario rather than broad legacy section names or abbreviations

### Requirement: Refactored Bindings helpers consume assertion results

Bindings tests under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` SHALL consume helper return values through matcher assertions or equivalent CQTest failure reporting. Calls to helper APIs such as `ExpectGlobalInt`, `ExpectGlobalInts`, AS execution helpers, and script compile helpers MUST NOT silently ignore a boolean success or failure result in test flows touched by this refactor.

#### Scenario: Helper result reports through the active test

- **WHEN** a Bindings test touched by this refactor calls a helper that returns success or failure
- **THEN** the result MUST be checked through the active `Test` object, matcher assertion, or a helper that reports failures directly

#### Scenario: Repeated helper logic remains local and readable

- **WHEN** a Bindings class touched by this refactor needs repeated lookup, execution, or expectation glue
- **THEN** that glue MUST live as a class-private helper near the scenario methods rather than as a broad file-level wrapper that hides the test flow

### Requirement: Refactored Bindings fixtures use normalized inline AS layout

Bindings tests under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` SHALL route inline AngelScript source through `ASTEST_AS(...)` or `ASTEST_AS_ANSI(...)` and SHALL keep the embedded AS visually formatted according to `Documents/Rules/ASInlineFormattingRule.md`. The audit scope MUST include all `.cpp` and `.h` files in the Bindings test directory and legacy raw string spellings such as `TEXT(R"(`, `TEXT(R"AS(`, `FString::Printf(TEXT(R"(`, and direct `R"(` fragments, not only already-normalized `R"AS(...)AS"` fixtures. Refactored fixtures MUST NOT leave AS content or closing raw-string delimiters at column 0, MUST use Allman braces for AS functions and control blocks, MUST keep one blank line between functions/classes, and MUST keep one blank line after each `UPROPERTY()` declaration pair when another member follows.

#### Scenario: Refactored fixture passes inline formatting audit

- **WHEN** `Plugins/Angelscript/Source/AngelscriptTest/Bindings` files are audited for inline AS raw strings in any spelling
- **THEN** every modified fixture MUST use the normalized test wrapper and MUST satisfy the AS brace, blank-line, and indentation rules

#### Scenario: Full Bindings directory is checked before completion

- **WHEN** this change is considered complete
- **THEN** repeatable audits MUST report zero raw-string wrapper, inline AS style, helper-result, and C++ test-class column-zero issues across all Bindings `.cpp` and `.h` files

### Requirement: Bindings tests focus on AS-visible binding contracts

Bindings tests under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` SHALL focus on the AS-visible binding surface: whether manually/default-bound classes, functions, methods, properties, operators, namespace functions, reflective fallback paths, and similar entrypoints are exposed under the expected declaration and can be invoked through the intended native path. They MUST NOT become the authoritative broad behavior coverage matrix for AS type semantics or feature combinations; that role belongs to `Plugins/Angelscript/Source/AngelscriptTest/Coverage` and OpenSpec `test-coverage`.

#### Scenario: Bindings test proves entrypoint reachability

- **WHEN** a Bindings test covers a native class, function, method, operator, namespace function, or fallback-dispatched entrypoint
- **THEN** the test SHOULD prove representative AS compilation, declaration resolution, invocation, and minimal native parity or failure reporting for that exposed entrypoint

#### Scenario: Deeper behavior coverage routes to Coverage

- **WHEN** a scenario primarily expands edge cases, language positions, parameter combinations, lifecycle/world states, cross-feature interactions, or coverage-gap rows after the binding entrypoint is already proven
- **THEN** the scenario SHOULD be implemented or tracked under `AngelscriptTest/Coverage` rather than growing the Bindings test as a large matrix

#### Scenario: Mixed concern keeps a narrow Bindings smoke

- **WHEN** a scenario contains both binding existence and broad semantic behavior concerns
- **THEN** Bindings SHOULD retain only the small exposed-entrypoint smoke/contract assertion, while the semantic expansion SHOULD live in Coverage
