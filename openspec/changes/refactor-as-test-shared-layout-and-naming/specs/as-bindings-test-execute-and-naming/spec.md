## ADDED Requirements

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

### Requirement: `FBindingsCoverageProfile` carries full-word field aliases in parallel with legacy abbreviations

`Shared/AngelscriptBindingsCoverage.h` SHALL add full-word fields alongside the existing abbreviated fields of `FBindingsCoverageProfile`. Construction / initialization sites SHALL keep both fields in sync. Specifically, the following abbreviations SHALL each gain a full-word sibling that holds the identical value:

| Abbreviated field (kept for alias) | New full-word field |
|------------------------------------|---------------------|
| `BodyInst` | `BodyInstance` |
| `MsgDlg` | `MessageDialog` |
| `MathOrient` | `MathOrientation` |
| `CollisionVal` | `CollisionValidation` |
| `MathPlat` | `MathPlatform` |
| `JsonConv` | `JsonConversion` |

Both abbreviated and full-word forms MUST be readable. The full-word fields SHALL be the recommended name for new Profile definitions. Deletion of the abbreviated fields and the rename of any `G<...>Profile` global Profile variables is deferred to a follow-up change.

#### Scenario: Full-word fields are populated by every Profile

- **WHEN** any `FBindingsCoverageProfile` literal is constructed in the test module
- **THEN** the construction site MUST assign the full-word field (e.g., `BodyInstance`) with the same value as the abbreviated alias (e.g., `BodyInst`), so that readers of either name observe the same value

#### Scenario: New Profiles prefer full-word fields

- **WHEN** a new Profile is added to the test module
- **THEN** the new Profile MUST set the full-word fields; the abbreviated aliases MAY be left at their default initialization unless legacy callsites of the new Profile require them

### Requirement: `ModulePrefix` uses `AS<Subject>` form without `Bindings` suffix

For every existing and new Profile, `ModulePrefix` SHALL follow the form `AS<Subject>` (for example `ASMath`, `ASBodyInstance`) and MUST NOT carry a `Bindings` suffix. Existing Profiles that already use the suffix-free form (the majority) are unchanged; the historical exception `ASMathBindings` is rewritten to `ASMath`. Since `FCoverageModuleScope` derives the AS module name by concatenating `ModulePrefix + SectionName`, all `AddExpectedError` strings that reference the old module name MUST be updated in lockstep.

#### Scenario: Every Profile follows AS<Subject> form

- **WHEN** the test module is grep'd for `FBindingsCoverageProfile` literals with `ModulePrefix`
- **THEN** every literal's `ModulePrefix` MUST match the pattern `AS<Subject>` and MUST NOT end in `Bindings`

#### Scenario: AddExpectedError strings track the rename

- **WHEN** `ASMathBindings` (or any other renamed prefix) is replaced
- **THEN** every `AddExpectedError(TEXT("...ASMathBindings..."))` call site MUST be updated to the new prefix in the same change

## Testing Requirements

- Target test layer: Bindings CQTest (`Angelscript.TestModule.Bindings.*`); existing CppTests and AngelScriptSDK suites continue to verify no regression to executor and assertion semantics.
- Expected Automation prefix unchanged: `Angelscript.TestModule.Bindings.*`.
- Recommended helpers/harnesses: `FAngelscriptTestExecutor` (canonical); `ExecuteAndExpect*` / `ExecuteAndExpectNear*` / `ExecuteAndExpectIntAtLeast` / `ExecuteBatchAndExpectInt` / `ExecuteAndValidate<T>` / `ExecuteAndExpectException` / `CompileAndExpectFailure`; `FBindingsCoverageProfile` (with new full-word fields); `FCoverageModuleScope`.
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-bindings-test-execute-and-naming -TimeoutMs 1800000 -NoXGE`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label as-bindings-test-execute-and-naming -TimeoutMs 1800000`
