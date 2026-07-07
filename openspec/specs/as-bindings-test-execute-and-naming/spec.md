# as-bindings-test-execute-and-naming Specification

## Purpose
TBD - created by archiving change refactor-as-test-shared-layout-and-naming. Update Purpose after archive.
## Requirements
### Requirement: Single canonical AS test executor class

The `AngelscriptTest` module SHALL expose exactly one canonical executor class for AS global function invocation, named `FAngelscriptTestExecutor`, defined in `Shared/AngelscriptTestExecute.h`. New test code MUST use this class rather than any alias. Test `.cpp` files MUST NOT hand-write `asIScriptContext::Prepare` / `Execute` / `SetArg*` / `GetReturn*` sequences.

#### Scenario: Canonical executor class exists

- **WHEN** `Shared/AngelscriptTestExecute.h` is parsed
- **THEN** it MUST declare or define the class `FAngelscriptTestExecutor` with at minimum the members `IsValid()`, `AddArg(...)` overloads, `AddArgObject(void*)`, `AddArgAddress(void*)`, `AddArgRef<T>(T&)`, `AddArgStruct<T>(T&)`, `Execute()`, `ExecuteAndGet<T>(Fallback)`, and `ExecuteAndExtractStruct<T>(T& Out)`

#### Scenario: Legacy executor name is a permanent alias

- **WHEN** existing test code references `FASGlobalFunctionInvoker`
- **THEN** the symbol MUST resolve via a `using FASGlobalFunctionInvoker = FAngelscriptTestExecutor;` (or equivalent alias) declared inside `AngelscriptTestExecute.h`, so legacy callsites continue to compile

#### Scenario: Legacy member methods are permanent inline aliases

- **WHEN** existing test code calls `.Call()` / `.CallAndReturn<T>(Fallback)` / `.ReadReturnStruct<T>(Out)` on the executor
- **THEN** these names MUST be present as inline forwarding methods on `FAngelscriptTestExecutor` that delegate to the canonical `.Execute()` / `.ExecuteAndGet<T>` / `.ExecuteAndExtractStruct<T>` respectively

#### Scenario: Test files do not bypass the executor

- **WHEN** the test module is grep'd for direct usage of `asIScriptContext::Prepare`, `asIScriptContext::Execute`, or `SetArgDWord` / `SetArgObject` / `SetArgAddress` inside any `Bindings/*.cpp` or `Shared/` file other than `AngelscriptTestExecute.h`
- **THEN** no such direct usage MUST appear; all AS execution MUST go through `FAngelscriptTestExecutor`

### Requirement: `Execute*` naming family is the canonical invocation API

The free-function API for invoking AS global functions and asserting results SHALL form a single naming family rooted at `Execute`, following the word-position grammar `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect|(empty)][Near|AtLeast|(empty)][<Type>|<T>]`. The following canonical members MUST exist in `Shared/AngelscriptTestExecute.h`:

- `ExecuteAndExpectInt`, `ExecuteAndExpectBool`, `ExecuteAndExpectDouble` (exact-equality assertions)
- `ExecuteAndExpectNearFloat`, `ExecuteAndExpectNearDouble` (tolerance-based assertions)
- `ExecuteAndExpectIntAtLeast` (lower-bound assertion)
- `ExecuteBatchAndExpectInt` (batched invocation across multiple cases of the same function family)
- `ExecuteAndValidate<T>` (custom validator with a caller-supplied predicate)
- `ExecuteAndExpectException` (negative-path script exception assertion)

#### Scenario: Canonical free functions are declared

- **WHEN** `Shared/AngelscriptTestExecute.h` is parsed
- **THEN** all of the canonical members listed above MUST be declared as free functions or function templates in the file's primary namespace

#### Scenario: Word positions follow the locked grammar

- **WHEN** a new helper is added to the family
- **THEN** the new name MUST follow `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect|(empty)][Near|AtLeast|(empty)][<Type>|<T>]`, with `Near`/`AtLeast` attached to `Expect` and `Batch` attached to `Execute`

#### Scenario: Validator branch uses a distinct verb

- **WHEN** a caller needs to drive a custom predicate against the return value
- **THEN** the API MUST be `ExecuteAndValidate<T>(..., Validator)` and MUST NOT be expressed as an overload of `ExecuteAndExpect<T>` (to avoid lambda overload ambiguity)

### Requirement: Compile-side failure assertion is a sibling `Compile*` family

Assertions that fire during AS module compilation (rather than execution) SHALL live in a sibling `Compile*` naming family with exactly one member, `CompileAndExpectFailure`, defined in `Shared/AngelscriptTestExecute.h`. This MUST NOT be folded into the `Execute*` family. No other `Compile*`-family members are permitted without a follow-up change that extends this requirement.

#### Scenario: Compile family contains exactly one member

- **WHEN** `Shared/AngelscriptTestExecute.h` is parsed for free-function names starting with `Compile`
- **THEN** exactly one canonical name MUST exist: `CompileAndExpectFailure`

#### Scenario: Legacy `ExpectBindingCompileFailure` is a permanent alias

- **WHEN** existing test code calls `ExpectBindingCompileFailure(...)`
- **THEN** the symbol MUST be declared as an inline forwarding wrapper in `AngelscriptTestExecute.h` that delegates to `CompileAndExpectFailure`

### Requirement: Legacy `Expect*` and `Execute*Function*` names are permanent inline aliases

Every legacy free-function helper that participated in invoking AS global functions or asserting their results SHALL be preserved as an inline forwarding wrapper inside `Shared/AngelscriptTestExecute.h`, so that all existing callsites in `Bindings/*.cpp` and the `AngelscriptTestUtilities.h` umbrella consumers compile without change. The set MUST include at minimum:

- `ExpectGlobalInt`, `ExpectGlobalBool`, `ExpectGlobalDouble`
- `ExpectGlobalIntAtLeast`
- `ExpectGlobalInts`
- `ExpectGlobalReturnBool`, `ExpectGlobalReturnFloat`, `ExpectGlobalReturnCustom<T>`
- `ExecuteIntFunction`, `ExecuteIntFunctionExpectingScriptException`, `ExecuteInt64Function` (the trio originally inlined in `AngelscriptTestUtilities.h` lines 873-1015)

#### Scenario: Legacy aliases compile every existing callsite

- **WHEN** the project is built without any modification to existing `Bindings/*.cpp` callsites
- **THEN** every legacy helper listed above MUST resolve through an inline wrapper in `AngelscriptTestExecute.h` and the build MUST succeed

#### Scenario: New code MUST use the canonical names

- **WHEN** a new test file is authored that needs AS function invocation or assertions
- **THEN** the file MUST use the canonical `Execute*` / `Compile*` names and MUST NOT introduce new callsites of any legacy alias listed above

### Requirement: No parallel naming families are introduced

The module MUST NOT introduce new helper families with verbs other than `Execute` (for runtime) and `Compile` (for compile-side). Specifically: no new `Expect*`, `Invoke*`, `Call*`, `Run*`, or `Verify*` free-function prefixes for AS function invocation or assertion MAY be added. Existing legacy `Expect*` names exist only as inline aliases per the previous requirement and MUST NOT be extended with new members.

#### Scenario: Adding a new helper triggers naming review

- **WHEN** a contributor proposes a new AS function invocation or assertion helper
- **THEN** the name MUST start with `Execute` or `Compile` (per the previous two requirements), and MUST NOT extend any legacy prefix

### Requirement: Scattered private `Execute*Function*` helpers in Bindings cpp files are marked for migration

Each `Bindings/*.cpp` that defines a private file-scope `Execute*Function*` helper (for example `ExecuteValueFunction` in `AngelscriptMathBindingsTests.cpp` / `AngelscriptMathOrientationFunctionLibraryTests.cpp`, `ExecuteIntFunctionWithAddressArg` in the Curve bindings tests, `ExecuteIntFunction` / `ExecuteFunctionExpectingException` in the WorldFunc bindings tests) SHALL carry a leading file-level `// TODO(refactor-as-test-shared-layout-and-naming)` comment that points to `Shared/AngelscriptTestExecute.h` as the migration target. The helper bodies themselves are NOT modified by this change.

#### Scenario: TODO marker exists and is consistent

- **WHEN** a `Bindings/*.cpp` containing such a private helper is opened
- **THEN** the file MUST contain a top-of-file comment matching the pattern `// TODO(refactor-as-test-shared-layout-and-naming): migrate <helper-list> to Shared/AngelscriptTestExecute.h` listing the helper(s) defined locally

#### Scenario: Private helpers remain functional in this change

- **WHEN** the project is built after the TODO markers are added
- **THEN** the private helpers MUST continue to compile and operate exactly as before; no in-place rewrite or deletion is performed by this change

### Requirement: Bindings profile context is removed from canonical execution APIs

`FBindingsCoverageProfile` SHALL NOT be part of the canonical AS execution or assertion API. `Shared/AngelscriptTestExecute.h` MUST NOT include `AngelscriptBindingsCoverage.h`, MUST NOT declare `FBindingsCoverageProfile`, and MUST NOT require callers to pass a Bindings-specific profile/context object to `Execute*` or `Compile*` helpers.

#### Scenario: Canonical helpers accept plain labels

- **WHEN** `Shared/AngelscriptTestExecute.h` is parsed
- **THEN** canonical `ExecuteAndExpect*`, `ExecuteBatchAndExpectInt`, `ExecuteAndValidate<T>`, `ExecuteAndExpectException`, and `CompileAndExpectFailure` helpers MUST accept a plain `const TCHAR* CaseLabel` (or equivalent string label) rather than a Bindings profile/context parameter

#### Scenario: Execute layer has no Bindings coverage dependency

- **WHEN** the Shared headers are grep'd for `AngelscriptBindingsCoverage.h` includes
- **THEN** `Shared/AngelscriptTestExecute.h` MUST NOT include it

### Requirement: Bindings module lifetime scope uses explicit module names

Bindings CQTest helpers that compile temporary AS source SHALL use an explicit module name rather than a `FBindingsCoverageProfile`. The module lifecycle helper (`FCoverageModuleScope` or its replacement) SHALL accept `ModuleName` and `Source`, compile the module under that name, and discard the same name on destruction.

#### Scenario: Module scope does not require a profile

- **WHEN** a Bindings test creates a temporary AS module
- **THEN** it MUST be able to construct the module scope with `FAutomationTestBase&`, `FAngelscriptEngine&`, `const TCHAR* ModuleName`, and `Source`, with no Profile argument

#### Scenario: Module names use full words

- **WHEN** Bindings tests hard-code or locally compose AS module names
- **THEN** those names MUST use full words (for example `ASBodyInstance_Latent`, `ASMath_Orientation_FactoriesAndMutators`) and MUST NOT use project-local abbreviations such as `BodyInst`, `MsgDlg`, `MathOrient`, `MathPlat`, `JsonConv`, or the historical `ASMathBindings`

#### Scenario: AddExpectedError strings track module renames

- **WHEN** a module name is renamed away from an abbreviated or suffixed form
- **THEN** every `AddExpectedError(TEXT("...<old module name>..."))` call site MUST be updated to the new module name in the same change

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

### Requirement: Project docs describe Bindings as a binding-surface contract layer

Project test guidance SHALL describe `AngelscriptTest/Bindings` as a binding-surface contract/smoke layer, not a per-type coverage matrix. `Documents/UnitTest/UnitTest.md` and `Documents/Guides/TestConventions.md` MUST NOT recommend organizing Bindings around exhaustive "type matrix", "API entry-point coverage", or broad boundary/exception matrices; that guidance MUST point to `AngelscriptTest/Coverage` and OpenSpec `test-coverage`.

#### Scenario: Docs route matrix guidance to Coverage

- **WHEN** the Bindings responsibility is described in `UnitTest.md` or `TestConventions.md`
- **THEN** the docs MUST frame Bindings as proving that an AS-visible bind exists and reaches its native path, and MUST route large semantic/type/boundary matrices to `Coverage/`

### Requirement: Matrix content migrates to Coverage before Bindings trimming

When broad semantic matrix content is removed from a Bindings test as part of the responsibility narrowing, an equivalent matrix row and `TEST_METHOD` SHALL already exist (or be added first) in `AngelscriptTest/Coverage`. A per-file disposition and a `Bind_*.cpp`-to-contract-smoke inventory SHALL be recorded before large matrix content is trimmed or moved, so that the consolidation does not lose coverage and the remaining Bindings surface is knowable.

#### Scenario: No net coverage loss during consolidation

- **WHEN** a Bindings test loses semantic matrix content during the narrowing
- **THEN** the equivalent coverage MUST exist in `Coverage/` first, and the Bindings file MUST retain a minimal exposed-entrypoint smoke

#### Scenario: Binding surface is inventoried before trimming

- **WHEN** the responsibility narrowing trims or moves matrix content across the Bindings directory
- **THEN** a per-file disposition (`Keep as contract` / `Trim to smoke` / `Move-Delete duplicate` / `Needs missing contract`) and a `Bind_*.cpp`-to-contract-smoke inventory MUST be recorded first

