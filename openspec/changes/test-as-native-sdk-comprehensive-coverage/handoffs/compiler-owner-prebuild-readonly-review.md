# Compiler owner pre-build read-only review

Date: 2026-07-27

Scope:

- `Compiler/AngelscriptNativeBuilderBytecodeTests.cpp`
  - `FBuilderBytecodeTests::CallAndControlShapesPreserveBytecodeAndRuntime`
- `Compiler/AngelscriptNativeBytecodeJumpTests.cpp`
  - `FBytecodeJumpTests::JumpTopologiesResolveOrRejectWithExactOffsets`
- `Compiler/AngelscriptNativeBuilderFunctionTests.cpp`
  - `FBuilderFunctionTests::CompileFunctionUsesProvidedSectionName`
  - `FBuilderFunctionTests::CompileFunctionFailureDoesNotLeakFunction`
- `Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp`
  - `FBuilderDiagnosticTests::WarningReportsSectionRowAndDoesNotFailByDefault`
  - `FBuilderDiagnosticTests::WarningsAsErrorsFailBuildAndPreserveWarningDiagnostic`
  - `FBuilderDiagnosticTests::CompileFunctionWarningUsesLineOffset`
- `Compiler/AngelscriptNativeBuilderDependencyTests.cpp`
  - `FBuilderDependencyTests::ModuleDependenciesPreserveTargetsFlagsAndFailureIsolation`
  - `FBuilderDependencyTests::CrossSectionPublicationPreservesOwnersAndExecution`

This was intentionally a source-only review. No build or automation test was
run, and no plugin source was changed.

## Immediate blockers

### 1. Multiple-label jump cell has an impossible distinct-offset oracle

File:
`Compiler/AngelscriptNativeBytecodeJumpTests.cpp:93-120`

The multiple-label cell emits these two equivalent layouts:

1. `JZ label3`, one `PshC4`, `label3`
2. `JNZ label4`, one `PshC4`, `label4`

Both conditional jump instructions and both intervening payload instructions
have matching serialized sizes. `asCByteCode::FindLabel` computes the relative
position from instruction sizes, so both rewritten arguments are expected to
have the same positive value. The test nevertheless requires
`FirstOffset != SecondOffset`. This should fail deterministically even though
the labels are independent and target different instruction nodes.

The catalog contract says “independent labels retain distinct rewritten
targets”, not that equal-distance targets must have different numeric relative
offsets. Either make the two distances intentionally different and assert the
exact expected offsets, or resolve the destination identity/order independently.

Severity: **blocking expected test failure**.

### 2. Call/control owner violates the fork's exact declaration rule

File:
`Compiler/AngelscriptNativeBuilderBytecodeTests.cpp:222-322, 389-395`

The table requests:

- `int Factorial(int)`
- `int Score(EMode)`

through `Module->GetFunctionByDecl`. `Documents/UnitTest/UnitTest.md` explicitly
records that this fork normalizes by-value script parameters to `const` and
requires lookup strings to match `GetDeclaration()`. The same file's older
compatibility methods already use name/arity lookup for these functions,
which is additional evidence that the non-const declarations are not reliable
in this fork.

The likely published declarations are:

- `int Factorial(const int)`
- `int Score(const EMode)`

The current lookup can therefore return null in two of the six product cells.
Use verified, normalized complete declarations. Do not fix this by falling
back to name/arity because the owner and catalog expressly claim exact
declaration publication.

Severity: **high-probability blocking test failure and mandatory UnitTest rule
violation**.

### 3. Generated-source accountability is not recorded

Files:

- `Compiler/AngelscriptNativeBuilderBytecodeTests.cpp:350`
- `Compiler/AngelscriptNativeBuilderDependencyTests.cpp:21`
- `catalogs/generated-source-registry.csv`

The two source files now contain new `PrintGeneratedAsSource` call sites, but
the generated-source registry has no row for either file or any of these new
products. This OpenSpec's prior SDK-DEPTH-090/094/129 records establish that
the registry tracks file-level print-site counts and that drift is a static
validation failure, not optional commentary.

Add the appropriate product/file rows with the correct file-level
`PrintSites` values before accepting catalog validation. Re-run the catalog
validator only after the code batch is complete, per the requested
compile/validation cadence.

Severity: **blocking OpenSpec/static-accounting gap**.

## Per-file findings

### `AngelscriptNativeBuilderBytecodeTests.cpp`

Positive evidence:

- All six declared shape IDs are physically present in one owner.
- Each source uses `ASTEST_AS_ANSI(R"AS(... )AS")`, visually indented embedded
  AS, Allman braces, and appropriate blank lines.
- Every case prints its complete source through `PrintGeneratedAsSource`.
- The six runtime oracles independently evaluate to 42:
  namespace overload, break/continue, recursion, short-circuit, default
  arguments, and enum switch.
- Module cleanup is checked after each case scope.
- Opcode inspection is null-tolerant and advances through the published
  descriptor size table.

Required corrections:

- Fix the two non-normalized complete declarations described above.
- Namespace overload and default-argument metadata currently use
  `FindModuleFunctionByNameAndParamCount`. This violates the same mandatory
  UnitTest rule: “通过完整声明查找目标函数……不得为了找到一个函数退回到名称或唯一函数猜测。”
  The catalog says every shape publishes its exact declarations, but these
  assertions prove only namespace/name/arity. Replace them with exact
  normalized declarations and, where needed, explicit namespace handling.
- Register the new source print site.

Risk notes:

- The source table stores `std::string` values directly, so source lifetime is
  sound for the loop.
- Module and engine null paths are guarded before dereference.
- `HasBytecode` and opcode helpers tolerate null functions, so compilation
  failure should report assertions rather than cause an immediate null
  dereference.
- The short-circuit source contains deliberately unreachable division by zero.
  Its runtime result is meaningful evidence, but only after the focused run
  proves this fork does not reject or eagerly evaluate the shape.

Verdict: **not ready to build until exact declaration lookup and registry
accounting are corrected**.

### `AngelscriptNativeBytecodeJumpTests.cpp`

Positive evidence:

- Forward, backward, missing-label repair, and appended-sequence paths are
  represented.
- The missing-label cell checks retained size and the unreplaced label ID
  before repairing the same fixture.
- The appended-sequence cell checks ownership transfer and serialized-size
  parity.
- Fixtures are local RAII objects; no raw module/context lifecycle is involved.

Required corrections:

- Fix the impossible multiple-label `AreNotEqual` oracle.
- Despite the method name `ExactOffsets`, the success cells assert only the
  sign, not an exact offset value. The catalog also requests exact offset
  direction/payload order. Either rename the method/claims or compute and
  assert exact offsets from the deliberately chosen layouts.
- The multiple-label product must prove distinct targets, not infer target
  identity from unequal numeric distances.

Quality notes:

- Direct reinterpretation of `Jump->arg` follows the vendored implementation's
  `ARG_DW` storage convention, so no compile-time API mismatch is apparent.
- No AS source is generated in this low-level bytecode-container test, so a
  source-print registry row is not required for this file.

Verdict: **blocking deterministic oracle defect**.

### `AngelscriptNativeBuilderFunctionTests.cpp`

Positive evidence:

- The success and invalid-signature outcomes have distinct product IDs and
  catalog owners; there is no duplicate-product ownership.
- Inline AS formatting conforms to the wrapper/raw-string/Allman rules.
- The failure owner checks the returned pointer plus module function/global/type
  tables and `Builder.functions`.

Evidence gaps:

- `COMPILER-BUILDER-COMPILE-FUNCTION-SUCCESS` says the function “leaves
  executable bytecode”, but the method never calls `HasBytecode`, executes the
  function, or even requests `ENativeEvidence::Bytecode`. At minimum, assert
  bytecode presence; align the catalog evidence list if runtime execution is
  intentionally outside the product.
- Both methods claim `Diagnostic`, but the success owner does not assert
  absence of error diagnostics and the failure owner only logs diagnostics.
  It never requires a located syntax diagnostic. The failure product's
  diagnostic evidence is therefore not real.
- Both methods claim `Cleanup` and `Isolation`, but their module scopes last to
  method exit and no post-scope `GetModule(..., asGM_ONLY_IF_EXISTS) == nullptr`
  assertion exists. RAII intent is present; observed cleanup/isolation evidence
  is absent.
- `LogBuilderSectionInput` logs only section name, byte count, and line count.
  It does not print the complete AS source. If these fixtures are to participate
  in the comprehensive source-review corpus, route them through the canonical
  complete-source printer and update the registry.

Safety issues:

- After asserting `ScriptEngine` and `Module` non-null, both methods continue
  without guards.
- The success method asserts `Function` non-null and immediately dereferences
  it. CQTest assertions do not provide a C++ control-flow guarantee. A setup or
  unexpected API failure can turn a useful assertion failure into a native
  crash. Add explicit return/guard paths.

Fork/API assessment:

- The `asCBuilder::CompileFunction` signature and `asCOMP_ADD_TO_MODULE` usage
  match the vendored implementation.
- The invalid signature is plausibly rejected before function publication;
  focused execution must confirm the stronger `Builder.functions == 0`
  atomicity assertion.

Verdict: **likely compiles, but product evidence is materially overstated and
null guards are insufficient**.

### `AngelscriptNativeBuilderDiagnosticTests.cpp`

Positive evidence:

- The three methods have distinct product IDs matching the latest catalog.
- `asEP_COMPILER_WARNINGS = 2` is a real current-fork policy:
  `as_scriptengine.cpp` accepts values 0-2 and `as_builder.cpp` writes the
  warnings-as-errors diagnostic after compilation.
- The engine property is restored with `ON_SCOPE_EXIT`.
- Warning fixtures use compliant `ASTEST_AS_ANSI` formatting.
- The default policy method checks severity, section, row, warning/error
  counters, successful final compilation, published Entry metadata, and
  bytecode.

Evidence gaps and risks:

- None of the owners places the module in an inner scope followed by an
  observed module-absence assertion, despite claiming `Cleanup` and
  `Isolation`.
- `CompileFunctionWarningUsesLineOffset` does not satisfy its catalog text:
  it does not verify the returned function's script section, exact module
  publication, executable bytecode, or absence of error diagnostics. It only
  requires a warning with matching section, `Row > 20`, and text containing
  `exact`.
- The warning-offset owner says “line offset” but checks only a lower bound.
  With a fixed source and offset, it should require the exact expected row.
- The warning-promotion method proves the original warning and promotion
  error, but does not assert that no executable function leaked after the
  rejected compile stage. Its catalog does not request Bytecode, so this is
  not a formal mismatch, but publication atomicity would strengthen the
  rejection contract.
- `LogBuilderSectionInput` again logs only metadata, not complete source.
- All three owners assert non-null engine/module/builder and then dereference
  without control-flow guards, retaining avoidable crash paths.

Fork/API assessment:

- The expected promotion text uses a substring of the vendored
  `TXT_WARNINGS_TREATED_AS_ERROR`, so the message oracle is appropriately
  tolerant without accepting unrelated behavior.
- The implicit float-to-int conversion is a plausible deterministic “not
  exact” warning in this fork; execution is still needed to confirm the exact
  row after dedenting and the `CompileFunction` line offset.

Verdict: **default/promotion behavior is grounded in production code, but
warning-offset evidence and cleanup claims are incomplete**.

### `AngelscriptNativeBuilderDependencyTests.cpp`

Positive evidence:

- The module-dependency owner covers all four catalog scenarios and prints all
  eight complete sources.
- It checks exact provider module ownership, zero-node location, deduplication,
  and mutually exclusive structural/hard flags.
- Provider and dependent modules are nested in RAII scopes and their absence is
  asserted after each scenario.
- The rejection scenario requires a located error naming
  `InitializerValue` and scans all published functions for executable-bytecode
  leakage.
- The cross-section owner prints all five complete sources, intentionally adds
  sections in reverse dependency order, checks exact section names, checks
  bytecode, executes Entry, and verifies module removal between shapes.
- `GetFunctionByDecl("int AddOne(const int)")` correctly follows this fork's
  normalized by-value declaration rule.

Required corrections and claim boundaries:

- `CrossSectionPublicationPreservesOwnersAndExecution` finds
  `SharedState.Read` via `FindTypeMethodByNameAndParamCount`. Replace this with
  a complete method declaration lookup to comply with UnitTest.md.
- The `type_helper_entry` shape publishes and lays out `SharedState`, but no
  helper or Entry function refers to that type. It therefore proves three
  independently published sections plus a helper-to-entry call; it does not
  prove a cross-section *type dependency*. Keep the catalog wording limited to
  publication/layout, or make the helper/entry consume `SharedState` if type
  dependency is intended.
- The structural dependency scenario also calls the internal API directly on
  two otherwise unrelated types. That is valid direct API evidence, but must
  not be described as compiler-discovered structural dependency evidence.
- Register the file's new complete-source print site.

Fork/API and lifecycle notes:

- Calling `Module->Build()` after manually marking a dependency invokes
  `asCModule::InternalReset()` before rebuilding. Consequently, the earlier
  manually inserted dependency-table entry is not what causes the later
  unresolved `InitializerValue` rejection. The method contains two separate
  observations: direct internal dependency bookkeeping, then public rebuild
  rejection of an unavailable symbol. This is acceptable only if the product
  text does not claim that the retained manual entry drove the rejection.
- The `Builder` pointer from before `Module->Build()` is not used afterward, so
  deletion of the builder by `Build()` does not introduce a visible
  use-after-free.
- Null-dependent dereferences in the reviewed new owners are generally guarded.

Verdict: **substantively strong and lifecycle-aware, with one mandatory
declaration-lookup correction, one registry gap, and a cross-section type
dependency overclaim to resolve**.

## Recommended pre-build order

1. Correct the deterministic jump oracle.
2. Replace every name/arity or non-normalized declaration lookup in the new
   owners with verified complete declarations.
3. Make product evidence match assertions:
   executable bytecode, diagnostics, exact warning offset, cleanup, and
   isolation.
4. Add explicit null guards before dereferencing engine/module/function
   pointers.
5. Decide whether the type/helper/entry cell is publication-only or a real
   type-dependency cell, then align source and catalog language.
6. Add generated-source registry records/counts for the new print sites.
7. Run the OpenSpec static validators.
8. Only after the whole Compiler batch is coherent, build once and then run the
   narrow owner prefixes before the aggregate Compiler/SDK prefixes.

## Overall conclusion

The owners are not yet ready for the requested batched build. No deterministic
C++ compile error was found in the reviewed API calls, but there is one
deterministic jump assertion failure, two high-probability fork-normalization
lookup failures, mandatory complete-declaration violations, missing
generated-source accounting, unsafe post-assert dereferences, and several
catalog evidence claims that the method bodies do not yet prove.
