# Canonical Typed AST compiler final-completion issue log

Worktree: `D:\as-cta`

This attachment records the problems, root causes, RED/GREEN evidence, and
remaining boundaries encountered while executing
`final-completion-execution-plan-2026-08-27.md`. It is intentionally separate
from `tasks.md`: task checkboxes change only when their complete wording is
true.

## CTA-P0-01 — premature global CANONICAL default breaks the truthful migration baseline

### Scope

- OpenSpec: `10.2`, `10.9`, `12.3`, `14.2`, `14.6`.
- Source:
  `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`.
- Permanent front assertion:
  `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp`.

### Expected contract

Until Tasks 1–9 and the complete AST-first matrix are green, a newly created
Engine defaults to `asCOMPILER_PIPELINE_LEGACY`. Canonical development tests
must explicitly call `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)`.
Task 10.2 flips the product default only after the full compiler surface and
all real entry points are proven; a Canonical gap must then fail closed rather
than silently fall back.

### RED baseline — 2026-08-27

Command:

```powershell
Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix cta-final-baseline -TimeoutMs 600000
```

Result: **8/21 PASS, 13/21 FAIL**, suite exit 1 / raw CTest exit 8.

Primary local evidence:

- `Plugins/Angelscript/Standalone/out/build/win64-msvc/Testing/Temporary/LastTest.log`
  (2026-08-27 04:54:30, 97,335 bytes).
- Build completed; the failures are runtime/contract failures, not a compile
  or link failure.

Failed CTests:

1. `AngelscriptStandalone.TypedSemanticIR`
2. `AngelscriptStandalone.SemanticObserver`
3. `AngelscriptStandalone.Addons`
4. `AngelscriptStandalone.Cli`
5. `AngelscriptStandalone.CliEndToEnd`
6. `AngelscriptStandalone.Runtime`
7. `AngelscriptStandalone.UEAnalysis`
8. `AngelscriptStandalone.Adapters`
9. `AngelscriptStandalone.CanonicalAST`
10. `AngelscriptStandalone.Package`
11. `AngelscriptStandalone.Corpus`
12. `AngelscriptStandalone.Soak`
13. `AngelscriptStandalone.Benchmarks`

The dedicated CanonicalAST test failed its two first-layer assertions:

```text
standalone engines must default to LEGACY until sealed-AST CodeGen publishes production Bytecode
a LEGACY-default standalone Engine must not advertise canonical CodeGen readiness
```

The ordinary Standalone hosts/tests create an Engine and do not explicitly
select CANONICAL. Because `asCScriptEngine` currently initializes
`ep.canonicalCompilerPipeline = true`, they are all routed through the partial
Canonical compiler. The remaining diagnostics are therefore correlated
downstream symptoms:

- HIR observer/oracle fixtures publish no HIR on the Canonical path;
- `array<T>` / dictionary methods such as `length`, `insertLast`, `join`, and
  constructors fail Canonical resolution;
- inherited host member lookup, adapter iterator routes, detached function
  signatures, cleanup/allocator checks, and a soft-path Construct declaration
  fail at later Canonical layers.

These are real Canonical coverage gaps to close in Batches 2–4. They are not
thirteen independent regressions in the normal Standalone product path, and
restoring the transitional default must not be recorded as fixing those
Canonical gaps.

### Root cause

`as_scriptengine.cpp` initializes the product-wide Engine default to
CANONICAL before Task 10.2's prerequisite gates. This conflicts with:

- the task/spec ordering;
- the permanent Standalone default assertion; and
- the explicit pipeline selection already used by Canonical AST/Sema/CodeGen
  tests.

### Repair and GREEN evidence

The one-line constructor default was restored to LEGACY. Explicit
`SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` behavior was not changed.

Standalone command:

```powershell
Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix cta-transitional-default-green -TimeoutMs 600000
```

Result: **21/21 PASS**, zero failures, suite exit 0. Local CTest evidence:
`Plugins/Angelscript/Standalone/out/build/win64-msvc/Testing/Temporary/LastTest.log`.

Explicit Canonical command:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label cta-explicit-canonical-after-default-repair -TimeoutMs 600000
```

Result: **12/12 PASS**, including canonical publisher/digest/zero-legacy,
CompileFunction snapshot/rollback, dual rejection and explicit LEGACY opt-out.
Evidence:
`Saved/Tests/cta-explicit-canonical-after-default-repair/20260827_045636_575_6e830ece/Report/index.json`.

Runtime type-binding acceptance was also refreshed after the default repair:
**10/10 PASS** at
`Saved/Tests/cta-runtime-type-binding-after-standalone-repair/20260827_045712_422_fc785665/Report/index.json`.

This closes CTA-P0-01 and the remaining Task 14.2 Standalone gate.

### Remaining boundary

Tasks `10.2` and `10.9` remain open. Task `14.6` was closed later by the
complete type-identity boundary matrix. The
array/container/member/HIR/metadata/lifetime diagnostics above
are an inventory for the explicit Canonical implementation path, not work that
may be hidden forever behind LEGACY.

## CTA-P0-02 — SemaAuthority dump helper destroyed the just-built snapshot

Status: repaired and verified.

### Symptom and RED evidence

After restoring the transitional Engine default and synchronizing the UE
binary with:

```powershell
Tools\RunBuild.ps1 -Label cta-sema-source-sync -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-sema-authority-after-source-sync -TimeoutMs 900000
```

the build passed, while SemaAuthority reported **283/301 PASS, 18/301 FAIL**.
Every failure was a `CompileSeal...` or combined production-build fixture that
first asserted `Module->Build() == 0`, then failed because no sealed AST was
available to dump. Evidence:
`Saved/Tests/cta-sema-authority-after-source-sync/20260827_050352_388_e675a071/Report/index.json`.

### Root cause

`DumpSealedCanonicalAst()` unconditionally called `Module->Build()` before
reading `GetCanonicalASTContext()`. The 18 failing tests had already performed
and asserted the Canonical Build. Its builder had been consumed, so the helper
issued a second, empty module lifecycle operation before querying the retained
snapshot. Tests that delegated their only Build to the helper remained green,
which explains the sharp 283/18 split.

This was a test-observer defect, not evidence that the 18 Sema rules were
missing and not a reason to restore the premature product-wide Canonical
default.

### Repair

The helper now builds only when the internal module still owns a pending
builder. If the test already built the module, it reads the existing sealed
context without mutating module lifecycle state. A negative first Build is
also propagated as a failed dump rather than ignored.

Source:
`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.

### GREEN evidence

```powershell
Tools\RunBuild.ps1 -Label cta-sema-dump-helper-green -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.CompileSealAssignConversionDumpsNamedSrcAndDestTypes" -Label cta-sema-dump-helper-focused-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-sema-authority-dump-helper-green -TimeoutMs 900000
```

Results:

- Runtime/Editor build: PASS.
- Representative compile→seal method: **1/1 PASS**.
- Complete SemaAuthority group: **301/301 PASS**, zero failures/skips.

Evidence:

- `Saved/Build/cta-sema-dump-helper-green/20260827_050601_646_2076a82a/RunMetadata.json`
- `Saved/Tests/cta-sema-dump-helper-focused-green/20260827_050618_274_f389dd7e/Report/index.json`
- `Saved/Tests/cta-sema-authority-dump-helper-green/20260827_050649_449_246fd41c/Report/index.json`

## CTA-P0-03 — Hand-built CodeGen fixtures violated the authored SourceManager contract

Status: repaired and verified.

### Symptom and RED evidence

The refreshed Frontend CanonicalAST group reported **130/139 PASS**. Eight of
the nine failures were hand-built CodeGen success/serialization tests:

- `CodeGenEmitsIntegerLiteralReturn`
- `CodeGenEmitsParameterReadsAndScalarOps`
- `CodeGenEmitsLocalAssignmentAndUnaryMinus`
- `CodeGenEmitsIfAndComparison`
- `CodeGenEmitsWhileLoop`
- `CodeGenEmitsCallInReverseFormalOrder`
- `CodeGenSaveLoadByteCodeRoundTripHasNoAstBytes`
- `CodeGenLoadByteCodeRejectsUnsupportedVersion`

Group evidence:
`Saved/Tests/cta-frontend-canonical-rebaseline/20260827_050823_797_a96bccd8/Report/index.json`.

The first method was instrumented to preserve the CodeGen diagnostic and then
run in isolation:

```text
result=-10 detail=failed to materialize detached function metadata/signature:
key=F() returnType=1:0 error=-10
```

Evidence:
`Saved/Tests/cta-frontend-codegen-detail/20260827_051117_586_6284567c/Report/index.json`.

### Root cause

`-10` is `asINVALID_DECLARATION`. The failure occurs in
`FillFunctionSourceMetadata()`, before runtime type resolution. Canonical
CodeGen intentionally refuses to publish an authored declaration that has a
body but no valid source identity: otherwise debug coordinates, cache capture,
and StaticJIT source attribution become silently incomplete.

These eight older tests build executable function declarations with empty
`asCSourceRange()` values. That was accepted before the SourceManager contract
was tightened, but no longer represents a publishable authored AST. The
`returnType=1:0` detail is a valid internal context-local `int` type reference;
it is diagnostic context, not the cause of this failure.

### Repair contract

- Keep production CodeGen fail-closed for authored bodies without source
  identity.
- Give each hand-built success fixture a synthetic authored source section and
  a SourceManager-issued function range.
- Preserve the detailed CodeGen assertion so future failures identify the
  publication stage instead of presenting only a generic expectation.
- Verify the exact integer-return method, all CodeGen methods, and the complete
  Frontend CanonicalAST group. Re-run SemaAuthority after the Frontend group is
  green.

### Repair and GREEN evidence

`AngelscriptNativeCanonicalASTCodeGenTests.cpp` now provides a synthetic
authored source section through `asCASTContext::AddSourceSection()` and uses
the SourceManager-issued range on every hand-built function that is expected
to publish executable Bytecode. Production CodeGen remains unchanged and
continues to reject authored bodies with no source identity.

The independent Verifier failure in the same 130/139 run was also a stale
fixture contract: its positive control gave a call a resolved declaration but
left the now-required dispatch kind at `NONE`. The fixture now marks that call
as `asAST_CALL_DISPATCH_DIRECT`; the negative half still removes only the
resolved declaration it is intended to test.

```powershell
Tools\RunBuild.ps1 -Label cta-codegen-source-range-green -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.FCanonicalASTCodeGenTests.CodeGenEmitsIntegerLiteralReturn" -Label cta-codegen-source-range-focused-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier.FCanonicalASTVerifierTests.RejectsSealedPublicationCallWithoutResolvedDecl" -Label cta-verifier-call-dispatch-focused-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label cta-codegen-source-range-group-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label cta-frontend-canonical-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-sema-authority-after-frontend-green -TimeoutMs 900000
```

Results:

- Runtime/Editor build: PASS.
- Focused integer-return CodeGen: **1/1 PASS**.
- Focused Verifier call contract: **1/1 PASS**.
- Complete CodeGen group: **45/45 PASS**.
- Complete Frontend CanonicalAST group: **139/139 PASS**.
- Complete SemaAuthority group after the repair: **301/301 PASS**.

Evidence:

- `Saved/Build/cta-codegen-source-range-green/20260827_051515_094_31999dbf/RunMetadata.json`
- `Saved/Tests/cta-codegen-source-range-focused-green/20260827_051532_133_60e9630e/Report/index.json`
- `Saved/Tests/cta-verifier-call-dispatch-focused-green/20260827_051603_001_46539c31/Report/index.json`
- `Saved/Tests/cta-codegen-source-range-group-green/20260827_051635_350_189d33f6/Report/index.json`
- `Saved/Tests/cta-frontend-canonical-green/20260827_051706_727_7ccb2b8b/Report/index.json`
- `Saved/Tests/cta-sema-authority-after-frontend-green/20260827_051751_025_7623d343/Report/index.json`

## CTA-P0-04 — ProductionCodeGen fixtures coupled explicit Canonical coverage to the premature default

Status: repaired and verified.

### Symptom and RED evidence

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label cta-production-codegen-rebaseline -TimeoutMs 1200000
```

Result: **96/111 PASS, 15/111 FAIL**, zero skips. Evidence:
`Saved/Tests/cta-production-codegen-rebaseline/20260827_051931_061_3a81edc9/Report/index.json`.

Every failure stopped at the same first assertion:

```text
production engines must default to the Canonical compiler
```

The affected methods cover modules/functions, namespaces, overload selection,
classes/value objects, enums, lambdas, imports, generated accessors/destructors,
list factories, and const globals.

### Root cause

All fifteen methods already call
`SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` immediately after the
failed assertion. Their CodeGen/provenance/lifecycle bodies are therefore
valid explicit-Canonical gates, but an older Task 10.2 expectation was copied
into each fixture while the Engine default was prematurely CANONICAL.

After CTA-P0-01 restored the required migration-phase LEGACY default, these
duplicated default assertions prevent the tests from reaching the exact
Canonical behavior they are intended to validate. The final default belongs
to the dedicated Cutover/default gate after Tasks 1-9, not to each focused
ProductionCodeGen method.

### Repair contract

- Remove only the duplicated default-CANONICAL assertions.
- Preserve every explicit `SetCompilerPipeline(CANONICAL)` call and every
  publisher/digest/zero-legacy assertion.
- Do not change the Engine default or weaken a Canonical execution/lifecycle
  expectation.
- Re-run the complete ProductionCodeGen group; any failure after explicit
  selection is a real Canonical gap and must receive its own AST-first card.

### Repair and GREEN evidence

The fifteen duplicated default assertions were removed. Their explicit
`SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` selections and all
subsequent Canonical publisher, sealed-digest, zero-legacy, execution,
namespace, ownership and lifecycle assertions remain unchanged.

```powershell
Tools\RunBuild.ps1 -Label cta-production-codegen-default-fixture-green -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label cta-production-codegen-default-fixture-green -TimeoutMs 1200000
```

Results:

- Runtime/Editor build: PASS.
- Complete ProductionCodeGen group: **111/111 PASS**, zero failures/skips.

Evidence:

- `Saved/Build/cta-production-codegen-default-fixture-green/20260827_052208_543_da99afaa/RunMetadata.json`
- `Saved/Tests/cta-production-codegen-default-fixture-green/20260827_052223_184_c4e82c9e/Report/index.json`

This repairs test routing only. It does not close Tasks `9.5`, `9.6`, `9.7`,
`10.2`, or `13.6`: those tasks still require the full active language,
metadata, differential and post-cutover matrices named in their wording.

## CTA-P0-05 — Compiler CanonicalAST contained hidden LEGACY-routed Canonical fixtures

Status: repaired; final-default RED intentionally remains open.

### Symptom and RED evidence

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label cta-compiler-canonical-rebaseline -TimeoutMs 1800000
```

Result: **452/458 PASS, 6/458 FAIL**, zero skips. Evidence:
`Saved/Tests/cta-compiler-canonical-rebaseline/20260827_052312_175_1bd4d7a5/Report/index.json`.

One failure is the intentional final Task 10.2 RED gate:

- `DefaultPipelineIsCanonicalReadyRejectsDualAndRetainsLegacyOptOut`

It must remain red while the migration-phase default is LEGACY.

The other failures were tests named and asserted as Canonical but did not
select the Canonical pipeline before source Build/CompileFunction:

- `CanonicalCompileFunctionDetachedKeepsCompleteSnapshotCurrent`
- `CanonicalCompileFunctionOwnsNestedLambdaClosureWithoutExposingIt`
- `CanonicalCompileFunctionBindsCurrentModuleFunctionsAndGlobals`
- `CanonicalSelectionPublishesValueObjectsFromCodeGen` (duplicated default
  assertion before an existing explicit selection)
- `CleanupDestructionExceptionsImportsAndGlobals`

A source audit found additional false-green routing in the same files:

- `CanonicalCompileFunctionFailureLeavesPublishedGenerationUntouched`
- `EvaluationOrderAndReverseFormalArguments`
- `PropertyRewriteAndMutationSingleEvaluation`
- `LoopsSwitchTransfersAndSafePoints`

These methods passed only because LEGACY happened to satisfy their behavioral
assertions; without explicit publisher/provenance selection, they were not
valid Canonical evidence.

### Repair contract

- Explicitly select CANONICAL at the start of every Canonical-only
  CompileFunction and VM-matrix fixture.
- Remove only the duplicated value-object default assertion; retain its
  explicit selection and CodeGen provenance assertions.
- Keep the dedicated final-default method unchanged and red until Task 10.2.
- Re-run the corrected methods/groups. Any failure after explicit selection is
  a real Canonical implementation gap, not a fixture-routing issue.

### Repair and verification evidence

The four Canonical CompileFunction fixtures and four Canonical VM-matrix
fixtures now explicitly select `asCOMPILER_PIPELINE_CANONICAL`. The duplicated
value-object default assertion was removed; its explicit Canonical selection
and publisher/readiness checks remain.

```powershell
Tools\RunBuild.ps1 -Label cta-compiler-canonical-explicit-routing -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover.FCanonicalASTCutoverTests.CanonicalCompileFunction" -Label cta-cutover-compilefunction-explicit-canonical -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests" -Label cta-vm-matrix-explicit-canonical -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover.FCanonicalASTCutoverTests.CanonicalSelectionPublishesValueObjectsFromCodeGen" -Label cta-cutover-value-object-explicit-canonical -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label cta-compiler-canonical-explicit-routing -TimeoutMs 1800000
```

Results:

- Runtime/Editor build: PASS.
- Canonical CompileFunction group: **4/4 PASS**.
- Canonical VM matrix: **12/12 PASS**.
- Value-object focused method: **1/1 PASS**.
- Complete Compiler CanonicalAST group: **457/458 PASS**, zero skips; the
  sole failure is the intentionally retained final-default Task 10.2 RED.

Evidence:

- `Saved/Build/cta-compiler-canonical-explicit-routing/20260827_052538_327_dfe4ddd4/RunMetadata.json`
- `Saved/Tests/cta-cutover-compilefunction-explicit-canonical/20260827_052558_285_35362d63/Report/index.json`
- `Saved/Tests/cta-vm-matrix-explicit-canonical/20260827_052629_669_ee9cd576/Report/index.json`
- `Saved/Tests/cta-cutover-value-object-explicit-canonical/20260827_052701_822_504e81c1/Report/index.json`
- `Saved/Tests/cta-compiler-canonical-explicit-routing/20260827_052733_668_da81fbf0/Report/index.json`

The intentional default failure is not a product regression. It remains the
visible transition gate and must not be made green until the remaining Sema,
TypedASTJIT, source/snapshot and entry-point work is complete.

## CTA-SRC-01 — SourceManager architecture closure lacked one end-to-end evidence chain

Status: verified; no production defect found.

### Existing baseline

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.SourceManager" -Label cta-source-manager-baseline -TimeoutMs 600000
```

Result: **8/8 PASS**, zero failures/skips. Evidence:
`Saved/Tests/cta-source-manager-baseline/20260827_053038_245_8413603d/Report/index.json`.

Static inspection also confirms that:

- `asCSourceManager::RemapLogical()` reuses a logical source only when origin,
  line offset, byte length and byte content all match; an alias with changed
  content fails closed without mutating the existing record;
- `asCSema` stores diagnostic text and `asCSourceRange` in parallel immutable
  facts, including parser-driven unresolved-identifier diagnostics;
- `asCBytecodeCodeGen` consumes parser/Sema-owned ranges to publish executable
  line metadata, with an existing Canonical-vs-LEGACY parity test;
- the public V1 snapshot exposes source origin, stable logical key and mapped
  line/column coordinates;
- the AST body sidecar encodes logical key, origin, line offset and complete
  source bytes before rebuilding a sealed context during decode.

### Missing proof, not yet a production defect

The existing tests cover each subsystem separately, but do not yet assert the
complete Task 13.10 contract:

1. a diagnostic created by Canonical Sema through the parser must retain a
   valid range which maps through the same owned SourceManager session; and
2. cache/sidecar round-trip must preserve every source-origin class together
   with logical key, line offset, byte length and exact bytes, rather than only
   checking one authored key and line offset.

### AST-first completion contract

- Add a parser-to-Sema diagnostic-range test using a non-zero line offset and
  assert logical key, row and column through `asCSourceManager`.
- Add a sealed sidecar source-model round-trip test for AUTHORED, PROCESSED and
  GENERATED sources, including exact bytes.
- Do not change production code unless either test exposes a concrete defect.
- Re-run the SourceManager group, cache sidecar group, focused backend source
  line test, public snapshot traversal test and complete Frontend CanonicalAST
  group before considering Task 13.10 complete.

### Evidence completion

The two missing facts were added as test-only coverage. No production source
change was necessary:

- `CanonicalSemaDiagnosticRangeMapsThroughOwnedSourceSession` parses a source
  with a non-zero line offset, observes Canonical Sema's unresolved-identifier
  diagnostic, and maps its owned range back to the expected logical key, row
  and column;
- `SidecarRoundTripPreservesCompleteSourceModel` seals and restores AUTHORED,
  PROCESSED and GENERATED records, checking logical key, origin, line offset,
  byte length and exact bytes for every record.

```powershell
Tools\RunBuild.ps1 -Label cta-source-manager-evidence-build -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.SourceManager.FCanonicalSourceManagerTests.CanonicalSemaDiagnosticRangeMapsThroughOwnedSourceSession" -Label cta-source-manager-sema-range -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar.FAngelscriptCacheASTBodySidecarTests.SidecarRoundTripPreservesCompleteSourceModel" -Label cta-source-sidecar-model -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.SourceManager" -Label cta-source-manager-complete -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar" -Label cta-source-sidecar-complete -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.FCanonicalASTCodeGenTests.CodeGenParserSourceEmitsDebugLinesAndMatchesLegacy" -Label cta-source-backend-debug-lines -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot.FCanonicalASTSnapshotAPITests.RetainedV1SnapshotTraversesSourceAndResolvedSemanticEdges" -Label cta-source-public-snapshot -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label cta-source-frontend-regression -TimeoutMs 900000
```

Results:

- Runtime/Editor build: PASS.
- Focused Canonical Sema source range: **1/1 PASS**.
- Focused complete sidecar source model: **1/1 PASS**.
- Complete SourceManager group: **9/9 PASS**.
- Complete AST body sidecar group: **17/17 PASS**.
- Focused backend debug-line parity: **1/1 PASS**.
- Focused public snapshot source traversal: **1/1 PASS**.
- Complete Frontend CanonicalAST group: **140/140 PASS**.

Evidence:

- `Saved/Build/cta-source-manager-evidence-build/20260827_053507_492_51857eed/RunMetadata.json`
- `Saved/Tests/cta-source-manager-sema-range/20260827_053527_321_7ad3ec78/Report/index.json`
- `Saved/Tests/cta-source-sidecar-model/20260827_053559_583_b0cca1f3/Report/index.json`
- `Saved/Tests/cta-source-manager-complete/20260827_053644_314_fa6eba33/Report/index.json`
- `Saved/Tests/cta-source-sidecar-complete/20260827_053714_820_d3ba7c57/Report/index.json`
- `Saved/Tests/cta-source-backend-debug-lines/20260827_053746_298_d8fb741d/Report/index.json`
- `Saved/Tests/cta-source-public-snapshot/20260827_053818_767_7647fe93/Report/index.json`
- `Saved/Tests/cta-source-frontend-regression/20260827_053850_130_384e8357/Report/index.json`

This closes only Task 13.10. It does not claim that Sema has stopped walking
legacy parse nodes, that public snapshot generation ownership is complete, or
that TypedASTJIT has stopped consuming HIR.

## CTA-SNAP-01 — Snapshot and Runtime-binding generation aggregate closure

Status: Core snapshot/runtime-binding aggregate verified; the broader
multi-entry publication audit remains open under Tasks 3.4 and 13.8.

### Owning tests and fixtures

- `AngelscriptNativeASTSnapshotAPITests.cpp`
  - `RetainPolicyPublishesImmutableV1Snapshot`
  - `FailedRebuildKeepsCurrentSnapshotStableForConcurrentAcquires`
  - `CompileFunctionAddToModuleInvalidatesRetainedSnapshot`
  - `AcquireDuringRebuildOnlyReturnsStableLeases`
- `AngelscriptCanonicalASTSnapshotReloadTests.cpp`
  - successful A→B publication, failed reload preservation, reader-thread
    sealed-view safety and old TypedASTJIT lease behavior
- `AngelscriptCanonicalRuntimeTypeGenerationTests.cpp`
  - `SameModuleReplacementRetiresGenerationBehindSnapshotLease`
  - `FailedResolutionOrSnapshotPreparationKeepsGenerationACurrent`
  - `PreparedExecutionKeepsRetiredGenerationAliveAfterSnapshotRelease`
  - `ConcurrentAcquireNeverSeesRetiredGenerationAdvertisedAsCurrent`
- `AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp` and
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  - failure-before-commit and failed canonical rebuild mutation boundaries
- Canonical Type/TypeIdentity and RuntimeTypeBinding groups
  - same-index foreign IDs, cross-Engine numeric projection, complete-key and
    non-authoritative-hash rejection

### Sealed/public facts required before execution evidence

1. a retain-policy source build publishes only a sealed/verified immutable
   public snapshot; discard policy publishes none and VM execution remains
   independent of AST storage;
2. current snapshot acquisition and A→B current-marker exchange share one
   lock/retain protocol, while a held A lease remains traversable;
3. `CompileFunction(..., asCOMP_ADD_TO_MODULE)` invalidates the prior complete
   snapshot rather than advertising an AST which omits the new function;
4. a snapshot lease and a prepared function execution lease both own the same
   immutable Runtime generation (type objects, binding table and numeric-ID
   map dependencies);
5. failed Runtime resolution or snapshot preparation keeps the exact A
   snapshot, executable, generation key, TypeInfo/public-ID mapping and frozen
   binding row current.

### Historical RED evidence

This slice already has retained AST-first RED→GREEN evidence rather than a new
production failure discovered during this final audit:

- prepared execution failed to keep retired generation A alive:
  `Saved/Tests/canonical-runtime-type-execution-lease-red/20260827_034255_512_63c2abcd/Report/index.json`
  (**0/1**), later fixed without weakening the snapshot fact;
- concurrent publication exposed a mixed snapshot/executable current state:
  `Saved/Tests/canonical-runtime-generation-atomic-publication-red/20260827_035248_839_6c8d92a2/Report/index.json`
  (**0/1**), later fixed by the single-lock aggregate exchange;
- Cache sidecar capture previously borrowed a raw AST context rather than a
  retained public lease; Standalone Architecture failed **1/21** until the
  consumer acquired and held `asIASTSnapshot` during encoding. Full details
  are retained in `attachments/snapshot-publication-protocol-audit-2026-08-23.md`
  and `reviews/canonical-runtime-type-generation-lifecycle-2026-08-27.md`.

### Final-audit delta

The existing failed-generation test proves snapshot identity, TypeId mapping
and executable preservation, but its assertion text does not explicitly pin
the frozen Runtime binding row. Extend that test to capture A's binding count
and row before both failure modes, then require the exact row/table view to be
unchanged after each failed B. This is a test-only completion unless it exposes
a concrete production defect.

### Final-audit result

`FailedResolutionOrSnapshotPreparationKeepsGenerationACurrent` now captures
generation A's binding count and exact immutable binding row before each
failure injection. Both Runtime-resolution failure and snapshot-preparation
failure must preserve the same row, table size, executable, snapshot,
generation key and TypeInfo/public-ID projection. No production change was
needed for this delta.

The fresh combined core audit is green:

- Runtime/Editor build: PASS;
- Module Snapshot: **9/9 PASS**;
- HotReload CanonicalAST: **12/12 PASS**;
- Canonical CodeGen Transaction: **20/20 PASS**;
- RuntimeTypeBinding: **10/10 PASS**;
- complete Frontend CanonicalAST, which includes Type and TypeIdentity:
  **140/140 PASS** (from the immediately preceding SourceManager gate).

Evidence:

- `Saved/Build/cta-snapshot-binding-preservation-build/20260827_054253_978_103750c8/RunMetadata.json`
- `Saved/Tests/cta-snapshot-binding-preservation/20260827_054312_676_20ad50cd/Report/index.json`
- `Saved/Build/cta-snapshot-module-routing-build/20260827_054614_596_96daec09/RunMetadata.json`
- `Saved/Tests/cta-snapshot-module-routing-green/20260827_054824_210_068c7687/Report/index.json`
- `Saved/Tests/cta-snapshot-hotreload-complete/20260827_054905_217_69d2bf93/Report/index.json`
- `Saved/Tests/cta-snapshot-codegen-transaction/20260827_054942_145_87cae2bf/Report/index.json`
- `Saved/Tests/cta-snapshot-runtime-type-binding/20260827_055019_375_81ca0cd2/Report/index.json`
- `Saved/Tests/cta-source-frontend-regression/20260827_053850_130_384e8357/Report/index.json`

This closes the complete adversarial matrix in Task 13.11: foreign IDs,
undersized views, Acquire/publish races, last-good executable/snapshot/binding
preservation, mutation-free CodeGen failure, cross-Engine numeric TypeId
projection, same-name HotReload ABI revisions and alias/hash fail-closed
behavior. It does **not** close Tasks 3.4 or 13.8: their broader wording still
requires the final universal source-build/default route and the remaining
StaticJIT, commandlet, Standalone and explicit-restore publisher rows.

## CTA-SNAP-02 — Snapshot replacement fixtures silently depended on the premature Canonical default

Status: Repaired and verified.

### Symptom and RED evidence

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot" -Label cta-snapshot-module-complete -TimeoutMs 900000
```

Result: **6/9 PASS, 3/9 FAIL**, zero skips. Evidence:
`Saved/Tests/cta-snapshot-module-complete/20260827_054355_507_a39d4cc6/Report/index.json`.

Failures:

- `RetainRebuildKeepsOldSnapshotLease`
- `FailedRebuildKeepsCurrentSnapshotStableForConcurrentAcquires`
- `AcquireDuringRebuildOnlyReturnsStableLeases`

The first two lose the last-good/current snapshot after a deliberately failed
replacement. The concurrent success loop can observe a missing/retired lease.

### Root cause

These methods test candidate-first Canonical replacement and atomic snapshot
publication, but did not explicitly select
`asCOMPILER_PIPELINE_CANONICAL`. They previously passed only while the Engine
default was prematurely CANONICAL. After CTA-P0-01 correctly restored the
migration-phase LEGACY default, the fixtures execute LEGACY Build's existing
destructive replacement contract; their Canonical assertions are therefore
misrouted rather than evidence of a Canonical publication regression.

### Repair contract

- Explicitly select CANONICAL in only the three candidate-publication methods.
- Preserve the LEGACY default and its destructive replacement behavior.
- Do not weaken the failed-rebuild, concurrent-reader or old-lease assertions.
- Re-run the three focused methods and the complete Module Snapshot group,
  then continue the HotReload and CodeGen transaction gates.

### GREEN evidence

Only the three affected fixtures were changed, and each now calls
`SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` before constructing its
module. The LEGACY default was not changed and no assertion was weakened.

Results:

- Runtime/Editor build: PASS;
- each previously failing focused method: **1/1 PASS**;
- complete Module Snapshot group: **9/9 PASS**;
- downstream HotReload CanonicalAST: **12/12 PASS**;
- downstream Canonical CodeGen Transaction: **20/20 PASS**.

Evidence:

- `Saved/Build/cta-snapshot-module-routing-build/20260827_054614_596_96daec09/RunMetadata.json`
- `Saved/Tests/cta-snapshot-retain-rebuild-green/20260827_054637_088_25a58488/Report/index.json`
- `Saved/Tests/cta-snapshot-failed-rebuild-green/20260827_054723_124_3c86a9b2/Report/index.json`
- `Saved/Tests/cta-snapshot-acquire-rebuild-green/20260827_054750_424_3827f184/Report/index.json`
- `Saved/Tests/cta-snapshot-module-routing-green/20260827_054824_210_068c7687/Report/index.json`
- `Saved/Tests/cta-snapshot-hotreload-complete/20260827_054905_217_69d2bf93/Report/index.json`
- `Saved/Tests/cta-snapshot-codegen-transaction/20260827_054942_145_87cae2bf/Report/index.json`

## CTA-T-02 — TypedASTJIT dependency aggregate crashes on a missing Provider entry

Status: repaired and verified.

### Symptom and Gate 0 evidence

The Task 14.6 StaticJIT boundary run did not produce an ordinary assertion
failure. It terminated the Editor process in
`ChangedFunctionContentIsSemanticDependencyMismatch`:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.TypedASTJIT" -Label cta-type-boundary-typedastjit -TimeoutMs 1800000
```

Failure:

- `FDependencyProvider::SetEntryDependencies` cannot find the requested root
  function in its filtered provider-entry array;
- the test helper calls `check(EntryIndex != INDEX_NONE)` and aborts the
  process instead of reporting a bounded test failure;
- crash site:
  `AngelscriptTypedASTJITProviderDependencyTestSupport.h:331`;
- triggering test site:
  `AngelscriptTypedASTJITProviderDependencyMatchTests.cpp:185`.

Evidence:
`Saved/Tests/cta-type-boundary-typedastjit/20260827_055250_392_0bbfa27a/RunMetadata.json`.

### Repair constraints

- Reproduce the exact method independently and determine whether the missing
  entry is caused by pipeline/provenance routing or cross-test global state.
- Preserve exact provider matching; do not synthesize an entry for an
  unverified function and do not weaken semantic-dependency mismatch checks.
- Replace fatal helper behavior with an assertion-friendly contract only if
  the helper itself is defective; the owning test must still assert that its
  requested provider entry exists before mutation.
- Re-run the focused method, ProviderMatch group and complete TypedASTJIT
  prefix before counting this TypeId boundary gate.

### Root cause and repair

The Provider dependency fixture had implicitly depended on the premature
global CANONICAL/Cache defaults. After the migration baseline correctly
restored LEGACY and Cache V2 default-off behavior, the helper's private Engine
did not create the canonical capture route required by the test.

The repair makes the fixture's preconditions explicit:

- `CreateEngine` selects `asCOMPILER_PIPELINE_CANONICAL`;
- the Engine config explicitly overrides and enables Cache V2 for this
  contained fixture;
- `SetEntryDependencies` returns `bool` instead of issuing a fatal `check`;
- owning tests assert success and return on a missing entry;
- exact dependency matching and mismatch behavior remain unchanged.

### GREEN evidence

- Runtime/Editor build: PASS at
  `Saved/Build/cta-type-provider-explicit-capture-build/20260827_055929_550_b9fc3d75/RunMetadata.json`;
- focused method: **1/1 PASS** at
  `Saved/Tests/cta-type-provider-match-explicit-capture-green/20260827_055948_604_19b66944/Report/index.json`;
- ProviderMatch group: **8/8 PASS** at
  `Saved/Tests/cta-type-provider-match-group-green/20260827_060025_962_d1571945/Report/index.json`;
- ProviderReload group: **5/5 PASS** at
  `Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT.Dependencies.ProviderReload/20260827_061848_934_9c1fbad5/Report/index.json`;
- complete TypedASTJIT: **70/70 PASS** at
  `Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT/20260827_061944_194_7f4e9a9c/Report/index.json`.

This closes CTA-T-02 without changing the product compiler or Cache defaults.

## CTA-T-03 — Cache maintenance ignored the target Engine's enablement policy

Status: repaired and verified.

### Symptom and root cause

The Cache ForceClean boundary failed when Cache V2 was explicitly enabled for
one Engine while the product default remained disabled. The maintenance path
read mutable global settings directly rather than the Engine's resolved
configuration, so a valid per-Engine override was ignored.

### Repair

`AngelscriptCacheDiagnostics.cpp` now uses
`Engine->IsCacheV2Enabled()`. The product default remains disabled, and an
explicit contained Engine is treated consistently by compile and maintenance
paths.

### RED/GREEN evidence

- RED: **0/1 PASS** at
  `Saved/Tests/cta-cache-engine-override-red/20260827_060553_375_b8327cc6/Report/index.json`;
- build: PASS at
  `Saved/Build/cta-cache-boundary-fix-build/20260827_060703_182_8d970ff5/RunMetadata.json`;
- GREEN: **1/1 PASS** at
  `Saved/Tests/cta-cache-engine-override-green/20260827_060724_195_cf2b03be/Report/index.json`;
- final SettingsAndShutdown boundary: **7/7 PASS** at
  `Saved/Tests/Angelscript.TestModule.Cache.SettingsAndShutdown/20260827_063122_516_91817d34/Report/index.json`.

## CTA-T-04 — default-array nominal alias failed target-generation late binding

Status: repaired and verified.

### Symptom and root cause

Canonical source identity uses the nominal spelling `TArray<int>`, while the
AngelScript Engine may expose its registered default-array type as `int[]`.
The Runtime binding resolver compared only the latter spelling and rejected an
otherwise exact target type.

### Repair

`as_runtime_type_binding.cpp` now reconstructs the registered template nominal
key locally from the candidate Engine's `asCDataType` and accepts it as an
additional exact candidate form. The stable key remains `TArray<int>`; the
alias is not persisted. Each Engine still supplies its own TypeInfo, layout and
current numeric TypeId.

The permanent two-Engine regression perturbs Engine B's registration order,
proves the public numeric IDs differ and proves the same stable key resolves
to independent Engine-local TypeInfo objects.

### RED/GREEN evidence

- RED: **0/1 PASS** at
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type.FCanonicalASTTypeTests.RuntimeBridgeResolvesDefaultArrayAliasPerEngineGeneration/20260827_061556_452_de54bb4b/Report/index.json`;
- build: PASS at
  `Saved/Build/cta-type-alias-green-build/20260827_061714_236_12b90f9f/RunMetadata.json`;
- GREEN: **1/1 PASS** at
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type.FCanonicalASTTypeTests.RuntimeBridgeResolvesDefaultArrayAliasPerEngineGeneration/20260827_061727_857_03a4cb74/Report/index.json`;
- final Frontend Type group: **20/20 PASS** at
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type/20260827_062158_158_0b19ea9b/Report/index.json`.

## CTA-B-02 — local `TArray<int>` default construction is not Canonical-CodeGen complete

Status: repaired and verified for the bounded real-UE local construction
family.

An attempted TypedASTJIT script-corpus fixture containing
`TArray<int> LocalIntArray;` reached Canonical CodeGen with
`DANGLING_ID construct-decl`. This is a genuine container/default-construction
Sema/lifetime/lowering gap, not a durable type-identity or late-binding error.

The failing discovery is retained at
`Saved/Tests/cta-typedastjit-script-fallback-green/20260827_060804_555_6dbf659d/Report/index.json`.
The corpus test was refocused on an array parameter signature and its safe
`UnsupportedSignature` TypedASTJIT fallback; that method is **1/1 PASS** at
`Saved/Tests/Angelscript.TestModule.StaticJIT.TypedASTJIT.ScriptCorpus.FAngelscriptTypedASTJITScriptFunctionCorpusTests.AdaptedScriptClassAndArrayFixturesFallbackFromTypedBackend/20260827_061810_989_783c7ace/Report/index.json`.

No assertion was weakened to call default construction supported. Closure
belongs to Tasks `5.2`, `5.5`, `5.7`, `5.8`, `9.5` and their compiler-cutover
umbrellas.

### 2026-08-27 focused reproduction and root cause

A dedicated real-UE fixture now isolates:

```angelscript
TArray<int> LocalIntArray;
return 2;
```

It fails **0/1 PASS** with the same `DANGLING_ID construct-decl` at
`Saved/Tests/cta-tarray-local-current-green/20260827_070509_629_816a476d/Report/index.json`.
This disproves the hypothesis that the nominal default-array type-alias repair
alone closed construction.

The exact cause is the native-behaviour import filter. AngelScript reuses a
template-base behaviour function when its signature does not depend on the
template subtype. The instantiated `TArray<int>` behaviour list therefore
correctly references the zero-argument `TArray<T>::void f()` whose function
owner remains the template base. `InternNativeBehaviourList` rejected that
owner unconditionally, imported no constructor and left
`Construct.resolvedDecl` invalid.

Importing that generic base directly proved the first diagnosis by moving the
failure past AST verification, but detached relocation capture then correctly
rejected its bare template owner: **0/1 PASS** at
`Saved/Tests/cta-tarray-local-green/20260827_070851_400_e9df8c8f/Report/index.json`.
The complete repair therefore materializes the instance-local template
function shell with `GenerateTemplateFunction` before importing the behaviour.
This preserves the concrete `TArray<int>` owner for both Sema and relocation
identity while retaining parameter substitution for signatures that depend on
`T`. It deliberately does not teach the reverse type mapper to reinterpret a
bare template owner as an arbitrary concrete instance.

Final evidence:

- Runtime/Editor build: PASS at
  `Saved/Build/cta-tarray-instantiated-behaviour-build/20260827_071046_007_92fa937f/RunMetadata.json`;
- focused real-UE source/AST/CodeGen/VM gate: **1/1 PASS** at
  `Saved/Tests/cta-tarray-local-instantiated-green/20260827_071058_450_f9fbe3e2/Report/index.json`;
- owning ScriptCorpus: **5/5 PASS** at
  `Saved/Tests/cta-tarray-script-corpus-green/20260827_071252_550_ce6ec6be/Report/index.json`;
- Frontend Type: **20/20 PASS** at
  `Saved/Tests/cta-tarray-frontend-type-green/20260827_071349_941_486c42f7/Report/index.json`;
- SemaAuthority: **301/301 PASS** at
  `Saved/Tests/cta-tarray-sema-authority-green/20260827_071425_792_0032fb2f/Report/index.json`;
- ProductionCodeGen: **111/111 PASS** at
  `Saved/Tests/cta-tarray-production-codegen-green/20260827_071505_738_6f86c4cb/Report/index.json`;
- complete TypedASTJIT: **71/71 PASS** at
  `Saved/Tests/cta-tarray-typedastjit-green/20260827_071539_837_7538782a/Report/index.json`.

The detailed RED-to-GREEN chain is retained in
`attachments/tarray-local-default-construction-gate-2026-08-27.md`. The issue
is closed, but the broad Task `5.2`/`5.5`/`5.7`/`5.8`/`5.9`/`9.5` language and
lifetime matrices remain open; no umbrella checkbox is implied.

## CTA-T-05 — Task 14.6 type-identity boundary gate

Status: verified.

The complete Runtime/Editor, Frontend Type, SemaAuthority, ProductionCodeGen,
transaction, Module Snapshot, HotReload, StaticJIT TypedASTJIT/identity,
Cache-default-disabled, Standalone, deterministic-output and durable-source
scan matrix is green. OpenSpec strict validation and parent/plugin
`git diff --check` also pass. Public AST, diagnostics, optional DTOs, Provider
identity and detached relocations contain no Engine pointer, numeric TypeId or
snapshot-local type ref as durable identity.

Exact counts, report paths, scan classifications and non-claims are recorded
in `attachments/type-identity-boundary-gate-2026-08-27.md`.

This closes Task 14.6 only. Section 10 default cutover and section 12 final
focused/Standalone Release/All gates remain open.

## CTA-S-05 — explicit qualified names were not exact or fail-closed

Status: repaired and verified for the bounded call/`DeclRef` scope family.

Canonical Sema originally allowed four related violations:

1. an unresolved qualifier such as `Missing::Target()` or `Missing::Value`
   could be discarded and retried as an unqualified/global name;
2. a resolved qualifier with a missing member, such as
   `Present::Target()` for an empty namespace, could climb to the translation
   unit and bind a global `Target`;
3. an unresolved recovery call could retain `direct` dispatch even though it
   had no valid `resolvedDecl`;
4. a qualifier segment could resolve through a same-name callable or
   constructor rather than a declaration that can own a scope.

The repair carries exact-scope intent through call and DeclRef deferred state,
uses scope-local candidate collection for qualified final components, filters
qualifier traversal to TU/namespace/class/interface/enum declarations and
publishes direct dispatch only after successful resolution. Missing qualified
names remain ERROR-typed and unbound with deterministic diagnostics; later
qualified declarations reconcile to their exact child. Invalid production
replacements fail before publication and preserve the complete prior
generation.

The full RED/GREEN chain, including the stale-dispatch second RED and the
qualifier-kind regression caught by the complete group, is recorded in:

- `attachments/canonical-explicit-scope-resolution-gate-2026-08-27.md`;
- `attachments/canonical-explicit-scope-declref-gate-2026-08-27.md`.

Final bounded evidence is SemaAuthority **306/306 PASS** at
`Saved/Tests/cta-explicit-scope-qualifier-kind-final-green/20260827_075437_411_058b9e43/Report/index.json`
and ProductionCodeGen **113/113 PASS** at
`Saved/Tests/cta-explicit-scope-qualifier-kind-production-final-green/20260827_075622_157_7850f302/Report/index.json`.

This closes CTA-S-05 only. It does not prove action-only Parser/Sema ownership,
the complete overload/candidate matrix, deferred parent-expression
reconciliation, or Tasks `4.3`, `5.3`, and `13.2`.

## CTA-S-06 — deferred names left stale primitive parent semantics

Status: repaired and verified for the bounded primitive-binary parent family.

Both later-qualified calls and globals correctly reconciled their own
declaration and `double` type, but a surrounding `+` expression retained the
provisional `int` selected while that child was ERROR-typed. The reachable
return path also retained a now-false `int -> double` conversion. The combined
AST gate was **2/4 PASS** and printed the exact stale chain for both paths.

`ResolveDeferredCalls` is now accurately named `ResolveDeferredNames`. Its
final AST-only pass recomputes built-in primitive binary parents to a fixed
point, materializes required integer/float promotions, updates comparison or
arithmetic result types and disconnects exact no-op conversion wrappers from
reachable uses. No Parser node is revisited or stored as semantic truth.

The initial repair build exposed one compile-order error because the new helper
used existing primitive classification functions before their definitions.
Local forward declarations corrected that build-only defect; it is retained in
the evidence chain.

The permanent fixtures use `double deferred-name + int literal` and prove both
operands plus the parent are `double`; production Canonical CodeGen executes
the call and global paths as `42.0` with zero legacy compiler invocations.
Final evidence is SemaAuthority **308/308 PASS** and ProductionCodeGen
**114/114 PASS**. Exact RED, failed/corrected builds and focused reports are in
`attachments/canonical-deferred-expression-reconciliation-gate-2026-08-27.md`.

This closes CTA-S-06 only. Object operators, assignment, conditional, cast,
member-access, lifetime-plan parents, Parser action-only ownership and Tasks
`4.3`, `5.3`, `5.4`, `5.6`, and `13.2` remain open.

## CTA-S-07 — namespace semantics crossed a generic Parser-node replay boundary

Status: repaired and verified for the bounded namespace declaration family.

Static authority inventory showed that `ParseNamespace()` called
`NotifySema(node)` and `WalkOne` decoded `case snNamespace`. The first RED was
the new source-architecture assertion: the valid SemaAuthority run was
**308/309 PASS** at
`Saved/Tests/cta-namespace-typed-action-sema-red/20260827_081945_553_6c1c43c3/Report/index.json`.
The earlier `cta-namespace-typed-action-red` exact-prefix invocation selected
zero tests and is retained only as invalid/no-evidence runner history.

The first repair replaced the namespace-specific boundary with a plain segment
DTO `{name, beginOffset, endOffset}`, remapped through SourceManager inside
Sema, and removed `snNamespace` from `WalkOne`. It passed the focused
architecture test and then-current SemaAuthority group. The mandatory backend
gate exposed a second defect: ProductionCodeGen was **109/114 PASS** at
`Saved/Tests/cta-namespace-typed-action-production-final-green/20260827_082331_889_90b68e4c/Report/index.json`.
All failures were namespace-owned functions/globals/value methods.

Root cause: generic namespace replay had also been the only post-body
finalization route for declarations parsed by `ParseScript(true)`. Early typed
actions deliberately intern function/class facts before the body exists, but
their completed authored bodies/traits were never attached after removing the
recursive namespace walk. A strengthened AST fixture proved this directly:
`Game::F(int)` existed but had no canonical body, **0/1** at
`Saved/Tests/cta-namespace-child-body-sema-red/20260827_082602_269_298bedad/Report/index.json`.

The final repair does not restore namespace replay. `ParseScript(true)` sends a
completed-child callback for each successful non-namespace child, matching the
root declaration transition, while namespace path creation remains typed and
action-only. This child callback is explicitly transitional debt to be removed
family by family through typed finish actions.

Final evidence:

- build PASS:
  `Saved/Build/cta-namespace-child-finish-fix-build/20260827_082808_157_d18e9806/RunMetadata.json`;
- authored-body AST **1/1 PASS**:
  `Saved/Tests/cta-namespace-child-body-sema-green/20260827_082829_020_6a245fdf/Report/index.json`;
- namespace architecture **1/1 PASS**:
  `Saved/Tests/cta-namespace-typed-action-architecture-regreen/20260827_082904_108_3b72e0ea/Report/index.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-namespace-child-finish-production-regreen/20260827_082935_642_82e4c9d1/Report/index.json`;
- SemaAuthority **309/309 PASS**:
  `Saved/Tests/cta-namespace-child-finish-sema-final-green/20260827_083009_371_1df2c6ed/Report/index.json`.

This closes CTA-S-07 only. Function/class/enum/typedef/funcdef/interface/
variable/import/parameter completed-child node callbacks, expression and
statement node decoding, full action-only scope/type/call/lifetime authority
and Tasks `4.2`/`13.2` remain open. Compiler and Cache defaults are unchanged.

## CTA-S-08 — enum and enumerator names crossed Parser-node declaration replay

Status: repaired and verified for the bounded enum/enumerator declaration-name
family.

`ParseEnumeration()` previously created the canonical enum through the generic
`NotifySema(snEnum)` boundary, created each enumerator from an identifier node,
and left `WalkOne` responsible for `case snEnum`. That made a completed Parser
tree, rather than typed Parser recognition results, authoritative for enum
declaration identity. The permanent architecture fixture failed **0/1** before
production edits at
`Saved/Tests/cta-enum-typed-action-red/20260827_083633_177_38131c5c/Report/index.json`;
its test build passed at
`Saved/Build/cta-enum-typed-action-red-test-build/20260827_083616_365_81c4a00c/RunMetadata.json`.

The repair introduces a short-lived recognized-name payload containing only
the name and half-open byte range. `ActOnEnumName` and
`ActOnEnumeratorName` remap that range through SourceManager, validate it, and
construct declarations under the exact current context. The Parser pushes the
new enum context before parsing enumerators. `WalkOne` no longer has an
`snEnum` case and the generic completed-child callback excludes enum, so there
is no whole-enum semantic replay.

Enumerator initializer syntax remains expression migration debt. The adapter
is now explicitly named `ActOnEnumeratorInitializerFromNode`, receives the
already-created enumerator declaration ID, and cannot rediscover declaration
identity. Direct `asCScriptNode` occurrences in `as_sema_decl.cpp` measure 119
after the change versus the earlier inventory's 117 because this transitional
boundary is now explicit; the removed `snEnum` replay is the meaningful
architecture result, not a lower raw token count.

Final evidence:

- Runtime/Editor build PASS:
  `Saved/Build/cta-enum-typed-action-fix-build/20260827_083825_410_54f9a951/RunMetadata.json`;
- focused architecture **1/1 PASS**:
  `Saved/Tests/cta-enum-typed-action-focused-green/20260827_083850_221_28b76a35/Report/index.json`;
- complete SemaAuthority **310/310 PASS**:
  `Saved/Tests/cta-enum-typed-action-sema-full/20260827_083927_544_324b6a6e/Report/index.json`;
- complete ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-enum-typed-action-production-full/20260827_084006_885_daa7d173/Report/index.json`;
- strict OpenSpec validation and separate parent/plugin `git diff --check`
  PASS; diff checks emitted existing LF/CRLF notices only.

This closes CTA-S-08 only. Enum initializer expressions, class/interface/
mixin/function/variable/import/type/expression/statement actions and the
remaining completed-child callbacks keep Tasks `4.2` and `13.2` unchecked.
Compiler default remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-16 — retained Parser funcdef crossed typed signature action

Status: repaired and verified for the retained internal Parser family while
preserving the fork's authored-script rejection and host Runtime ABI.

Before the repair, `ParseFuncDef()` built a complete `snFuncDef`; top-level and
class-member completion could notify that shell, and
`WalkOne(case snFuncDef)` reconstructed its name, return type and parameters.
That was a dormant but real violation of the Parser-to-Sema action boundary.
The dialect boundary is intentional: `as_tokendef.h` keeps the `funcdef`
keyword entry commented out, so authored script declarations remain rejected;
host `RegisterFuncdef` uses a separate dynamic Runtime registration path.

Two permanent tests were added first. The valid RED was a test-only compile
failure because `asSFuncDefSignatureAction` and
`ActOnFuncDefSignatureAction` did not exist:

`Saved/Build/cta-funcdef-typed-action-red-test-build/20260827_123726_803_20efe23b/RunMetadata.json`

Production added a pointer-free name/return-type/range payload and typed
start/action APIs. `ParseFuncDef()` now publishes the callable declaration
before `ParseParameterList()`, binds the retained Parser shell only to that
identity, enters the exact FuncDef DeclContext for existing parameter actions,
and never notifies the completed shell. The old `case snFuncDef:` decoder and
class callback are deleted. The first repair build passed at:

`Saved/Build/cta-funcdef-typed-action-first-fix-build/20260827_123856_518_dbd7fbdf/RunMetadata.json`

Two first focused test invocations were invalid runner calls, not product
failures. Their prefixes omitted the CQTest class segment and matched zero
tests:

- `Saved/Tests/cta-funcdef-typed-action-semantic-green/20260827_123932_150_bf5011e2/RunMetadata.json`;
- `Saved/Tests/cta-funcdef-typed-action-architecture-green/20260827_124000_900_612fffb0/RunMetadata.json`.

The complete suite proved the tests were registered, after which corrected
focused prefixes passed. Final evidence is:

- SemaAuthority **326/326 PASS**:
  `Saved/Tests/cta-funcdef-typed-action-sema-authority-first-green/20260827_124057_950_c982e472/Report/index.json`;
- direct semantic fixture **1/1 PASS**:
  `Saved/Tests/cta-funcdef-typed-action-semantic-focused-green/20260827_124146_765_c7d51f9f/Report/index.json`;
- architecture fixture **1/1 PASS**:
  `Saved/Tests/cta-funcdef-typed-action-architecture-focused-green/20260827_124215_052_f9ff04c3/Report/index.json`;
- Parser and language authored-script rejection **1/1 + 1/1 PASS**:
  `Saved/Tests/cta-funcdef-script-parser-rejection-green/20260827_124300_141_33f74657/Report/index.json` and
  `Saved/Tests/cta-funcdef-script-language-boundary-green/20260827_124328_547_56714320/Report/index.json`;
- host registration/call/rebuild **1/1 PASS**:
  `Saved/Tests/cta-funcdef-host-registration-green/20260827_124357_078_a0104cd3/Report/index.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-funcdef-typed-action-production-codegen-green/20260827_124444_513_6580b8bf/Report/index.json`.

The final source scan finds zero `case snFuncDef:` and zero class-member
`NotifySema(node->lastChild)`. Direct line-bearing `asCScriptNode` sites are
declaration **83**, expression **42**, statement **20**, and core Sema **3**.
Strict OpenSpec validation plus parent/plugin `git diff --check` all exit **0**;
only existing LF/CRLF notices remain.

This closes CTA-S-16 only. It does not enable script funcdef, change host
funcdef registration, replace dynamic numeric TypeId projection, or prove
detached funcdef publication. General type/parameter/default/property/access-
group/lambda/body/expression/statement/lifetime actions, complete detached
CodeGen, TypedASTJIT HIR retirement and final CANONICAL-default cutover remain
open. Compiler default remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-17 — custom access declaration crossed typed actions and exact member edges

Status: repaired and verified for the fork's custom
`access NAME = ...;` metadata, ordered permission facts and exact record-local
field/method binding. Final Canonical Runtime installation remains a separate
cutover boundary.

Before this slice, `ParseAccessDecl()` retained `snAccessDeclaration` syntax
and Builder/Runtime registration, but the sealed Canonical graph had no
access-specifier declaration, permission representation or member edge.
Consequently a later `access:NAME` prefix could not be proved from immutable
AST facts, sidecar/public snapshots could not carry it, and a future detached
consumer would have been forced to repeat name lookup or depend on a Runtime
pointer.

Permanent Sema/Parser, traversal/verifier, Sidecar and public-snapshot tests
were added first. The intended test-only compile RED is:

`Saved/Build/cta-access-specifier-red-test-build/20260827_131137_537_f1456a76/RunMetadata.json`

It failed for the missing declaration kinds, permission traits, action
payloads, explicit edge, public field and sidecar setter. During that RED the
direct test fixture was also corrected to call the pre-existing
`ActOnStartMethodDecl` with its canonical `IntType`; that was a test API error,
not a production defect.

Production now has append-only `ACCESS_SPECIFIER` and `ACCESS_PERMISSION`
declaration kinds, PRIVATE/PROTECTED base visibility plus wildcard/readonly/
editdefaults/inherited permission traits, and an explicit `accessSpecifier`
DeclId edge on members. Parser publishes one pointer-free action only after
the complete terminating `;`; variable/function headers carry only the
authored group name. Sema resolves only an exact same-record specifier and
fails closed for missing/ambiguous names. Verifier, traversal, deterministic
dump/shadow comparison, capacity-aware public views, metadata-only CodeGen and
Sidecar schema **V5** all understand the new declarations/edge. The first
production build passed at
`Saved/Build/cta-access-specifier-first-fix-build/20260827_133435_740_8ebc274d/RunMetadata.json`.

Three GREEN-stage failures were test-contract issues and were fixed without
weakening production:

1. traversal was **5/6** because its hand-built specifier omitted mandatory
   PRIVATE/PROTECTED; adding PRIVATE made it **6/6**;
2. snapshot was **9/10** because it demanded Runtime access registration from
   the current detached CANONICAL Build, contradicting the locked non-claim;
   the permanent test now proves Runtime registration in a separate LEGACY
   module and immutable facts in the CANONICAL snapshot;
3. snapshot remained **9/10** because the fixture searched a class method as
   `FUNCTION`; correcting the oracle to `METHOD` made it **10/10**.

The failing/rebuild/final paths are preserved in
`attachments/canonical-access-specifier-typed-action-gate-2026-08-27.md`.
They are test-fixture corrections, not product failures and not evidence that
Canonical Runtime access installation is complete.

Final evidence:

- SemaAuthority **329/329 PASS**:
  `Saved/Tests/cta-access-specifier-sema-authority-first-green/20260827_133752_645_73f70bcc/RunMetadata.json`;
- traversal/verifier **6/6 PASS**:
  `Saved/Tests/cta-access-specifier-traversal-second-green/20260827_134815_198_011a6ded/RunMetadata.json`;
- ASTBodySidecar V5 **18/18 PASS**:
  `Saved/Tests/cta-access-specifier-sidecar-green/20260827_134953_130_02805a42/RunMetadata.json`;
- public Module Snapshot **10/10 PASS**:
  `Saved/Tests/cta-access-specifier-snapshot-third-green/20260827_135753_785_3d252b3f/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-access-specifier-production-codegen-green/20260827_135836_707_f0720c25/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-access-specifier-parser-declarations-green/20260827_140000_944_d201f485/RunMetadata.json`.

The exact `ParseAccessDecl` slice has one typed action publication and zero
`NotifySema` calls; Sema has zero `case snAccessDeclaration:`. Direct
line-bearing `asCScriptNode` sites remain declaration **83**, expression
**42**, statement **20**, and core Sema **3** because general type/parameter/
property/lambda/body adapters remain. Strict OpenSpec validation and separate
parent/plugin `git diff --check HEAD` pass with existing LF/CRLF notices only.

This closes CTA-S-17 only. Builder `RegisterAccessSpecifier` and Runtime
`asSAccessSpecifier` remain the legacy/shadow registration path; final
Canonical Runtime access installation, property/general action authority,
complete detached CodeGen, TypedASTJIT HIR retirement and default cutover stay
open. Compiler default remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-15 — class `default` statement crossed generated-method replay

Status: repaired and verified for class `default <statement>` ownership,
single generated `__InitDefaults` reuse, exact statement routing, recovery and
multiple-statement ordering.

Before the repair, Parser recognized and completed an
`snClassDefaultStatement` under the class, then `ParseClass()` called the
generic whole-node callback. Declaration Sema reconstructed
`void __InitDefaults()` afterward and replayed/reparented the child statement.
The generated method therefore did not own the statement while it was being
parsed, and early recovery could observe a class-owned semantic statement.

Two permanent tests were added before production edits. The test-only build
passed at
`Saved/Build/cta-class-default-typed-action-red-test-build/20260827_120856_013_da8009b9/RunMetadata.json`.
The first valid focused run was the intended **0/2 RED** at
`Saved/Tests/cta-class-default-typed-action-red/20260827_120918_710_136a5017/Report/index.json`:
the recovery AST contained the field, generated method, wrapper body and
assignment, but the body/statement owner was the class; the architecture test
also found no typed start/finish action and found the old replay case.

Parser now calls `ActOnClassDefaultStartAction` immediately after `default`,
pushes the returned generated method as the exact DeclContext, parses the
complete statement there, and calls `ActOnClassDefaultStatementAction` with
only the exact source range. Sema creates/reuses one generated
`void __InitDefaults()` with origin `canonical-init-defaults`, requires one
statement matching both exact method owner and exact range, and fails closed
with `class-default-statement-action-missing` if the typed statement is absent.
The generated wrapper body owns later statements exactly once in source order.
`ParseClass()` no longer notifies the completed class-default shell, and
declaration Sema no longer contains `case snClassDefaultStatement:`.

The first repair build and focused GREEN passed at:

- `Saved/Build/cta-class-default-typed-action-first-fix-build/20260827_121449_636_7fd165be/RunMetadata.json`;
- `Saved/Tests/cta-class-default-typed-action-first-green/20260827_121515_121_dc7a5bce/Report/index.json` — **2/2 PASS**.

Existing class-default compile/execute remained **1/1 PASS**, complete
ProductionCodeGen remained **114/114 PASS**, and the TypedSemanticIR
synthesized-default execution/disposition boundary remained **1/1 PASS**. A
new multiple-default regression then proved exactly one generated method, two
method-owned body children and strict source order. Its build/focused evidence
is:

- `Saved/Build/cta-class-default-multiple-order-build/20260827_122141_707_a8355a33/RunMetadata.json`;
- `Saved/Tests/cta-class-default-multiple-order-green/20260827_122207_821_62040798/Report/index.json` — **1/1 PASS**.

Final complete SemaAuthority is **324/324 PASS** at
`Saved/Tests/cta-class-default-sema-authority-final-green/20260827_122244_926_55762a97/Report/index.json`.

Tooling issues were non-product and changed no repository state: several
read-only searches initially guessed an obsolete maintained-fork path or used
Windows-incompatible wildcard arguments; the first TypedSemanticIR prefix
omitted the CQTest class segment and found zero tests; the first post-test
build used unsupported `-LabelPrefix`, which PowerShell rebound as a
nonexistent UBT target before compilation. Exact invalid metadata paths and
the `asCSourceRange` equality precheck are recorded in
`attachments/canonical-class-default-typed-action-gate-2026-08-27.md`.
The final combined validation/location-report helper also had an invalid
PowerShell `"$d:..."` interpolation and stopped at parse time before running
any nested command; the validation was then split and rerun.

Final scans show zero `case snClassDefaultStatement:` and zero semantic
`case snDeclaration:`. Direct line-bearing `asCScriptNode` references remain
declaration **84**, expression **42**, statement **20**, and core Sema **3**.
General type/parameter/property/access-group/funcdef/lambda/body/expression/
statement/lifetime adapters still keep Tasks `4.2`–`4.5` and `13.2` open.
Compiler default remains LEGACY and Cache V2 remains default-disabled.

Strict OpenSpec validation and separate parent/plugin `git diff --check`
commands all exit **0** after the final CTA-S-15 records are written; only the
existing LF/CRLF conversion notices are emitted.

## CTA-S-14 — local/`for`/`foreach` declarations crossed exact typed actions

Status: repaired and verified for ordinary local declarations, `for`
initializer declarations, and `foreach` variable declaration identity.

The remaining `snDeclaration` semantic replay handled locals by recursively
extracting only the first name, type and initializer. Parser also notified a
completed declaration shell from both ordinary statement blocks and `for`
initializers. This made comma-declarator identity/initializer ownership an
implicit traversal result and left `foreach` variable construction separate
from the typed declaration boundary.

Two permanent tests were added before production changes. The test-only build
passed at
`Saved/Build/cta-local-loop-variable-red-test-build/20260827_113735_171_532e7e4c/RunMetadata.json`.
The valid full discovery run produced the intended **319/321 PASS, 2 FAIL** at
`Saved/Tests/cta-local-loop-variable-red/20260827_113803_635_66c1e0d8/Report/index.json`;
only the new semantic and architecture tests failed.

Parser now publishes an exact typed header for every local/`for` declarator,
binds the bounded optional initializer to that returned DeclId, and finishes
one exact-range statement sequence after `;`. Normal blocks flatten the
sequence so lexical visibility is unchanged; the `for` sequence stays the
initializer carrier and is flattened into the loop scope by the existing
resolver. `foreach` publishes its exact typed DeclStmt without inventing
default construction. Sema statement assembly routes a declaration shell only
by exact owner/range identity and diagnoses `local-declaration-action-missing`
when the action is absent. All semantic `case snDeclaration:` decoders are
physically absent from maintained-fork Sema sources.

The first implementation build passed at
`Saved/Build/cta-local-loop-variable-first-fix-build/20260827_114822_865_5e0fe235/RunMetadata.json`,
but the full SemaAuthority run was a real product regression: **248/321 PASS,
73 FAIL** at
`Saved/Tests/cta-local-loop-variable-first-green/20260827_114848_097_6315e5fe/Report/index.json`.
The common verifier detail was `stmt-multi-owner`. Ordinary compound assembly
copied the synthetic declaration sequence's children into the surrounding
block but left the carrier edges intact. Clearing those carrier children only
after normal-block flattening restored single structural ownership; the `for`
initializer carrier intentionally keeps its children. The repair build passed
at
`Saved/Build/cta-local-loop-variable-sequence-owner-fix-build/20260827_115014_344_6ecf72de/RunMetadata.json`.

That repair produced focused **2/2 PASS** at
`Saved/Tests/cta-local-loop-variable-focused-green/20260827_115032_450_1fdc081f/Report/index.json`
and full **320/321 PASS** at
`Saved/Tests/cta-local-loop-variable-sema-authority-green/20260827_115111_186_76ff738d/Report/index.json`.
The sole remaining failure, `ParserActOnListPatternBeforeBlockCloseFails`, was
another real migration regression: removing the old early whole-declaration
callback caused malformed `{1,2` initializer parsing to return before the
exact local action retained its partial expression. Publishing the bounded
initializer action before returning the parse error restored recovery without
restoring replay. The repair build and focused GREEN are
`Saved/Build/cta-local-loop-variable-recovery-fix-build/20260827_115259_898_7127620e/RunMetadata.json`
and
`Saved/Tests/cta-local-loop-variable-list-recovery-green/20260827_115313_772_e1952ec0/Report/index.json`
(**1/1 PASS**).

The final semantic test was strengthened to compile and execute the valid
comma-declarator/loop shape through Canonical CodeGen and require `Entry() ==
34`. Final evidence:

- build PASS:
  `Saved/Build/cta-local-loop-variable-execution-assert-build/20260827_115717_073_f76010b3/RunMetadata.json`;
- exact semantic/architecture **2/2 PASS**:
  `Saved/Tests/cta-local-loop-variable-execution-focused-green/20260827_115738_409_6b24e5db/Report/index.json`;
- SemaAuthority **321/321 PASS**:
  `Saved/Tests/cta-local-loop-variable-sema-authority-final-green/20260827_115815_734_72290e1d/Report/index.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-local-loop-variable-production-codegen-final-green/20260827_115907_186_7c6a8d5e/Report/index.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-local-loop-variable-parser-declarations-final-green/20260827_115947_756_696dcbf0/Report/index.json`;
- strict OpenSpec validation and separate parent/plugin `git diff --check`
  PASS, with existing LF/CRLF conversion notices only.

Invalid/non-product tooling events were kept out of the product failure count:

1. `RunTests.ps1 -Target ...` was rejected before Unreal launch because the
   wrapper requires `-TestPrefix`.
2. The initial skill lookup guessed a project-local superpowers path; the
   available skill is under `C:/Users/scottmei/.agents/skills`. The complete
   instruction file was then read from the advertised path before task work.
3. A final build command used unsupported `-RunId`; UBT rejected the forwarded
   nonexistent target before compilation. Metadata:
   `Saved/Build/build/20260827_115701_240_0acf91a5/RunMetadata.json`.
4. One read-only `rg` command had malformed PowerShell quoting and was
   immediately reissued correctly. It performed no write and supplied no
   evidence.

This closes CTA-S-14 only. General type/property/default/funcdef/lambda/body/
expression/statement/lifetime actions and final Builder/LEGACY authority
retirement keep Tasks `4.2`, `4.3`, `4.4`, `4.5`, and `13.2` unchecked.
Compiler default remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-09 — primitive typedef semantics crossed Parser-node declaration replay

Status: repaired and verified for the maintained fork's bounded non-void
primitive typedef grammar.

`ParseTypedef()` previously sent a completed `snTypedef` through generic
`NotifySema`, and `WalkOne(case snTypedef)` rediscovered the alias and decoded
its primitive type from Parser children. The permanent architecture test was
added first; its build passed at
`Saved/Build/cta-typedef-typed-action-red-test-build/20260827_084519_331_88ea522d/RunMetadata.json`
and it produced the intended **0/1 RED** at
`Saved/Tests/cta-typedef-typed-action-red/20260827_084539_629_c76cf1bc/Report/index.json`.

The repair introduces the pointer-free short-lived payload
`{alias name, Parser-resolved primitive token, begin offset, end offset}`.
`ActOnTypedefAction` validates the non-void primitive and SourceManager range,
then creates/reuses the exact-context declaration with its canonical primitive
QualType. The action fires after type and identifier recognition but before
the semicolon, preserving early recovery facts. Parser still builds
`snTypedef` for LEGACY syntax/recovery, but `WalkOne` has no `snTypedef` case
and the generic completed-declaration callback excludes typedef.

One strengthened behavior run was invalid rather than a product RED:
`Saved/Tests/cta-typedef-behavior-green/20260827_084905_428_49945bea/Report/index.json`
reported **0/2** because the new assertion assumed `name` and `type` dump
fields were adjacent. The dump already showed one `Typedef Count` with
`type=int`. The test was corrected to require both fields on the same
declaration line; no production repair was made for this invalid run. Its
test build passed at
`Saved/Build/cta-typedef-type-fact-assertion-fix-build/20260827_085003_763_e49b8f2b/RunMetadata.json`.

Final evidence:

- Runtime/Editor build PASS:
  `Saved/Build/cta-typedef-typed-action-fix-build/20260827_084730_791_1106805b/RunMetadata.json`;
- focused architecture **1/1 PASS**:
  `Saved/Tests/cta-typedef-typed-action-focused-green/20260827_084758_328_2f4e1e4b/Report/index.json`;
- incomplete/complete/unique/type-fact behavior **2/2 PASS**:
  `Saved/Tests/cta-typedef-behavior-final-green/20260827_085025_680_43265705/Report/index.json`;
- complete SemaAuthority **311/311 PASS**:
  `Saved/Tests/cta-typedef-sema-full/20260827_085100_053_944da7da/Report/index.json`;
- complete ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-typedef-production-full/20260827_085139_160_8ba25e55/Report/index.json`;
- source scans, strict OpenSpec validation, and separate parent/plugin
  `git diff --check` PASS; diff checks emitted existing LF/CRLF notices only.

Direct `asCScriptNode` occurrences now measure `as_sema_decl.cpp=117`,
`as_sema_expr.cpp=42`, `as_sema_stmt.cpp=27`, and `as_sema.cpp=2`. The
meaningful result is removal of `snTypedef` semantic replay, not the raw count.

This closes CTA-S-09 only. General type grammar and class/interface/mixin/
function/variable/import/expression/statement typed actions remain open, so
Tasks `4.2`, `4.3`, and `13.2` stay unchecked. Compiler default remains LEGACY
and Cache V2 remains default-disabled.

## CTA-S-10 — import signature and origin crossed whole-node declaration replay

Status: repaired and verified for the bounded import declaration start/origin
family.

`ParseImport()` previously notified the same growing `snImport` shell around
signature and origin parsing, while `WalkOne(case snImport)` reconstructed the
name, return type, parameters and origin. The permanent architecture test was
added first. Its build passed at
`Saved/Build/cta-import-typed-action-red-test-build/20260827_085912_047_df9ac09b/RunMetadata.json`
and it produced the intended **0/1 RED** at
`Saved/Tests/cta-import-typed-action-red/20260827_085930_436_2640d507/Report/index.json`.

The repair publishes a pointer-free signature payload before the parameter
list, pushes the exact import DeclContext for incremental parameter actions,
and publishes a pointer-free origin payload after the module string but before
`;`. `WalkOne` has no `snImport` case, `ParseImport()` no longer calls
`NotifySema(node)`, and the generic completed callback excludes import.
Multi-parameter attachment also now falls back to the current declaration
context when `lastActedDecl` names the preceding parameter.

One behavior run was invalid rather than a product RED: **2/3 PASS** at
`Saved/Tests/cta-import-typed-action-behavior-green/20260827_090344_514_cf0a1f8d/Report/index.json`.
The dump correctly contained `SharedValue(int,double)` and both parameters;
the test expected source `float` instead of the configured canonical
`double`. The assertion was corrected without a production change.

The first full ProductionCodeGen run was a valid product RED, **113/114 PASS**
at
`Saved/Tests/cta-import-typed-action-production-full/20260827_090617_602_128e9cb9/Report/index.json`.
The prepared Runtime import shell lacked its producer-carried stable key.
Removing whole-node replay had also removed the old implicit
pointer-to-Decl association used by the transitional Builder shell. The repair
adds `BindParsedDeclarationIdentity(node, decl)` as an explicit identity-only
bridge after the canonical import declaration already exists. It reads no
semantic field from the Parser node and must disappear with the remaining
Builder/Parser mapping; it is not Canonical Sema authority.

Final evidence is behavior **3/3 PASS**, SemaAuthority **313/313 PASS**,
focused prepared-import execution **1/1 PASS**, and ProductionCodeGen
**114/114 PASS** at the exact report paths recorded in
`attachments/canonical-import-typed-action-gate-2026-08-27.md`. Source scans
show no `case snImport` or `ParseImport()` whole-node notification. Direct
`asCScriptNode` counts are now declaration **111**, expression **42**,
statement **27**, and core Sema **3**, with the core increment classified as
the named non-semantic identity bridge.

This closes CTA-S-10 only. The import return type still crosses the general
`ActOnQualTypeFromNode` adapter, parameters still cross `ActOnParsedParam`, and
function/class/interface/mixin/variable/expression/statement families remain
open. Tasks `4.2`, `4.3`, `4.4`, and `13.2` stay unchecked. Compiler default
remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-11 — ordinary function-family identity and traits crossed whole-node replay

Status: repaired and verified for ordinary global functions, methods,
constructors/destructors, mixins, local functions and interface methods.

The old boundary built a complete `snFunction` and let
`ActOnFunctionLike` rediscover name, kind, return type, parameters, traits and
body. That meant trailing method traits were unavailable if body recovery
failed, and the same syntax shell was both the semantic input and the
transitional Builder identity.

The permanent early-traits and architecture tests were added first. Their
test-only build passed at
`Saved/Build/cta-function-typed-action-red-test-build/20260827_093250_370_4bb52018/RunMetadata.json`.
Three initial focused commands found zero tests because their prefixes omitted
the CQTest class segment; their metadata paths are recorded in
`attachments/canonical-function-typed-action-gate-2026-08-27.md` and they are
invalid runner evidence, not product failures. A valid full discovery run then
produced the intended **313/315 PASS, 2 FAIL** at
`Saved/Tests/cta-function-typed-action-sema-red-discovery/20260827_093733_885_1291771c/Report/index.json`.

The repair introduces a pointer-free signature payload, a bounded typed
function-kind hint, an exact function DeclContext during parameter parsing, a
typed trait-mask action before `;`/body, and an explicit body-only statement
adapter. `ParseFunction()` and `ParseInterfaceMethod()` no longer notify a
completed ordinary function node; the generic completion callback excludes
ordinary `snFunction`; `WalkOne(case snFunction)` retains only the separate
lambda path. Constructor identity is derived from exact owner/name, and local
functions enter the same typed function path.

The first repair build and full Sema/Production regressions were green, but a
strengthened architecture test correctly found that the obsolete
`ActOnFunctionLike` decoder remained as unreachable source. Its build passed
at
`Saved/Build/cta-function-decoder-removal-red-test-build/20260827_095035_684_d709264f/RunMetadata.json`
and the focused test produced **0/1 RED** at
`Saved/Tests/cta-function-decoder-removal-red/20260827_095054_021_217a9da5/Report/index.json`.
The decoder was physically deleted; the final build passed at
`Saved/Build/cta-function-decoder-removal-fix-build/20260827_095153_486_abb703d6/RunMetadata.json`.

Final evidence:

- strengthened architecture **1/1 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.ParserFunctionFamilyUsesTypedActionsWithoutOrdinaryFunctionReplay/20260827_095332_595_acba8304/Report/index.json`;
- SemaAuthority **315/315 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_095410_756_d26fc2b1/Report/index.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen/20260827_095453_925_a4db9176/Report/index.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.Parser.Declarations/20260827_095707_103_82667e93/Report/index.json`.

Final scans show zero obsolete `ActOnFunctionLike` sites. Direct
`asCScriptNode` references are now declaration **100**, expression **42**,
statement **27**, core Sema **3**. Strict OpenSpec validation and parent/plugin
`git diff --check` pass; only existing LF/CRLF notices are emitted.

This closes CTA-S-11 only. General return-type/parameter/default payloads,
lambda Sema, class/interface body actions and statement/expression/lifetime
actions remain transitional, so Tasks `4.2`, `4.3`, `4.4` and `13.2` stay
unchecked. Compiler default remains LEGACY and Cache V2 remains
default-disabled.

## CTA-S-12 — class/struct/interface header, bases and completion crossed record replay

Status: repaired and verified for record header identity/kind, exact ordered
base edges and real-body completion.

Before the repair, `ParseClass()`/`ParseInterface()` notified a growing record
shell after the name and generic completion could replay the finished shell.
`WalkOne(case snClass/snInterface)` then reconstructed record facts and
synthesized lifecycle/accessors. The base decoder recursively selected the
first identifier, which made a qualified `Right::Base` vulnerable to
truncation or first-name binding.

Two permanent tests were added first. Their test-only build passed at
`Saved/Build/cta-record-typed-action-red-test-build/20260827_101850_939_05dd38df/RunMetadata.json`.
The valid full SemaAuthority run produced the intended **315/317 PASS, 2
FAIL** at
`Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_101913_603_402b0d53/Report/index.json`:
the early-recovery fixture could not observe the exact qualified base, and the
architecture scan found the old replay boundary. No runner attempt was
invalid in this slice.

Parser now publishes three bounded phases: a pointer-free record
name/kind/range header, an ordered array of complete qualified base spellings,
and a finish action only after a real closing brace. Sema creates/reuses the
exact record, owns VALUE vs REFERENCE_OBJECT kind/traits, resolves bases by
complete stable key with fail-closed ambiguity handling, records stable
dependencies, applies the native `PreClassData` base only when no authored
base exists, and owns generated lifecycle/accessors at class finish.
`WalkOne` no longer handles class/interface records and the old base decoder
is physically deleted. The transitional Parser shell association is explicitly
identity-only and does not carry semantic syntax.

The first production build passed at
`Saved/Build/cta-record-typed-action-first-fix-build/20260827_103214_490_1144454a/RunMetadata.json`.
Final results are focused qualified base **1/1**, focused architecture **1/1**,
SemaAuthority **317/317**, ProductionCodeGen **114/114**, and Parser
declarations **18/18** at the exact paths in
`attachments/canonical-record-typed-action-gate-2026-08-27.md`.
Strict OpenSpec validation passes, and parent/plugin
`git diff --check HEAD` both exit **0** with existing LF/CRLF conversion
notices only.

The final static scan finds zero `ActOnParsedBaseSpecifiers`,
`RecordClassBases`, `case snClass:` or `case snInterface:`. Remaining direct
`asCScriptNode` line-bearing sites are declaration **94**, expression **42**,
statement **27**, and core Sema **3**. A nearby audit found and repaired a
stale comment claiming CANONICAL was already default; executable state remains
`ep.canonicalCompilerPipeline = false`. Cache V2 also remains default-disabled.

This closes CTA-S-12 only. Record member fields/properties/defaults/funcdefs,
general type/parameter/body actions, lambdas and expression/statement/lifetime
replay keep Tasks `4.2`, `4.3`, `4.4`, and `13.2` unchecked.

## CTA-S-13 — global/field multi-declarators crossed typed per-declarator actions

Status: repaired and verified for top-level/namespace globals and class/struct
fields, including exact multi-declarator identity, access traits, initializer
ownership and early-recovery durability.

The old boundary notified one complete `snDeclaration`, and
`WalkOne(case snDeclaration)` selected the first identifier/type/initializer.
That could silently drop later comma-separated declarations and made class
access an inferred replay side effect. The permanent semantic and architecture
tests were added first. Their test-only build passed at
`Saved/Build/cta-global-field-variable-red-test-build/20260827_105912_773_f0903c02/RunMetadata.json`.
The valid full SemaAuthority run produced the intended **317/319 PASS, 2
FAIL** at
`Saved/Tests/cta-global-field-variable-red/20260827_110132_423_71fbb6a6/Report/index.json`.
No test-runner attempt was invalid in this slice.

Parser now publishes a typed header immediately for each global/field
identifier and binds only that declarator's optional initializer to the exact
returned DeclId. Sema validates owner/type/range/trait payloads, records the
named type dependency, folds global constants through the global initializer
authority, and retains field InitPlans. Generic top-level completion excludes
`snDeclaration`; the class field branch performs no whole-node callback; the
residual walker fails closed for translation-unit/namespace/class owners and
remains local-statement-only.

The first focused semantic run was not a product failure: **0/1** at
`Saved/Tests/cta-global-field-variable-semantics-focused-green/20260827_110729_407_1bb72dfb/Report/index.json`.
The dump had correct global constants `11`/`22` and field InitPlans `31`/`47`,
but the test expected all four values in `Decl::inits`. The oracle was corrected
to assert the sealed representation contract—global
`hasConstantValue/constantValue`, field InitPlan expressions—without a
production change. The corrected build passed at
`Saved/Build/cta-global-field-variable-test-oracle-fix-build/20260827_110842_018_08cfa2a3/RunMetadata.json`
and both focused tests became **2/2 PASS** at
`Saved/Tests/cta-global-field-variable-focused-green/20260827_110907_732_10bc4e70/Report/index.json`.

The first full ProductionCodeGen run exposed a real product regression,
**113/114 PASS** at
`Saved/Tests/cta-global-field-variable-production-codegen-green/20260827_111033_877_9397f6b7/Report/index.json`.
`40 + 1` had a correct folded constant `41` but a stale default string `40`.
`ActOnGlobalVarInit` normalized the default to `41`, after which a generic
source-literal extractor overwrote it with the first source integer. The
repair makes global/namespace normalized default text exclusively owned by
`ActOnGlobalVarInit`; the literal extractor is class-field-only. Repair build
and exact focused execution passed at
`Saved/Build/cta-global-field-variable-normalized-default-fix-build/20260827_111143_721_a99f9044/RunMetadata.json`
and
`Saved/Tests/cta-global-field-variable-normalized-default-focused-green/20260827_111155_506_fb5f5d04/Report/index.json`.

Final evidence is SemaAuthority **319/319**, ProductionCodeGen **114/114**,
and Parser declarations **18/18** at the exact report paths recorded in
`attachments/canonical-global-field-variable-typed-action-gate-2026-08-27.md`.
Strict OpenSpec validation and separate parent/plugin `git diff --check HEAD`
pass; only existing LF/CRLF conversion notices are emitted.

One initial read-only source scan used a stale guessed private path and found
no files. It was not treated as evidence. The corrected maintained-fork scan
shows direct line-bearing `asCScriptNode` sites of declaration **96**,
expression **42**, statement **27**, and core Sema **3**; the declaration
increase from CTA-S-12 is the explicitly named initializer adapter signature,
not a new whole-declaration walker.

This closes CTA-S-13 only. Local declarations, general type/parameter/default/
property/access-group/funcdef/lambda actions, and expression/statement/lifetime
node adapters keep Tasks `4.2`, `4.3`, `4.4`, `4.5`, and `13.2` unchecked.
Compiler default remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-18 — callable parameters waited for completed defaults and recovered owners from Parser state

Status: repaired and verified for ordinary/import/interface/funcdef parameter
headers. Default-expression decoding and lambda parameters remain explicit
later migration boundaries.

Before this slice, `ParseParameterList` accumulated type, modifier, name and
optional default Parser nodes, then called
`ActOnParsedParam(typeNode, typeMod, nameNode, defaultNode, script)`. Sema could
recover the owner through `lastActedDecl`. This meant a complete header could
vanish when its later default was malformed, and detached semantics depended
on a Parser-node tuple plus mutable callback history.

The behavior and source-architecture tests were added first. Their test-only
build passed at
`Saved/Build/cta-parameter-typed-action-red-test-build/20260827_142027_896_3c176d98/RunMetadata.json`.
The valid RED was **329/331 PASS, 2 FAIL** at
`Saved/Tests/cta-parameter-typed-action-red/20260827_142049_419_75f5ca58/RunMetadata.json`:
`int F(const int &in A = 40 + )` lost `A`, and the source scan found the old
tuple instead of a typed action.

Parser now publishes `asSParameterDeclAction` immediately after the complete
header with exact callable DeclId, canonical `asCQualType`, authored name and
half-open range. Sema validates callable kind/type/range, constructs the exact
ParamDecl and records the named-type dependency. A successfully parsed default
attaches later through the separately named
`ActOnParameterDefaultFromNode(parameterDecl, ...)`; failure creates no fake
init. Import, funcdef, ordinary-function and interface-method call sites pass
their exact declarations. `ActOnParsedParam` and the owner-history fallback are
deleted. Authored virtual-property syntax remains removed rather than being
resurrected to satisfy stale Task 4.4 wording.

The production build and first focused GREEN passed at
`Saved/Build/cta-parameter-typed-action-first-fix-build/20260827_142519_725_119d8014/RunMetadata.json`
and
`Saved/Tests/cta-parameter-typed-action-focused-first-green/20260827_142609_776_934a4b23/RunMetadata.json`.
The first complete Sema regression was **330/331 PASS** at
`Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_142744_257_3606f338/RunMetadata.json`.
Its only failure was a stale static oracle that searched for
`ParseParameterList()` in the funcdef slice. The protected phase order was
unchanged and the route was now stronger, so the oracle was corrected to
require `ParseParameterList(canonicalFuncDef)`. The test-fix build passed at
`Saved/Build/cta-parameter-typed-action-regression-test-fix-build/20260827_142859_406_3c76fefe/RunMetadata.json`.

Two invalid build invocations are explicitly excluded from evidence. The first
lost the slash in `Tools/RunBuild.ps1` through outer command-string escaping
and never started a runner. The second used unsupported
`-ReportOutputPath`; UBT treated its value as a target and failed before
compilation with `RulesError` at
`Saved/Build/build/20260827_142846_643_6e51c19f/RunMetadata.json`. The corrected
runner parameter is `-Label`.

Final evidence is:

- SemaAuthority **331/331 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_142918_046_591fd064/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-parameter-typed-action-production-codegen-green/20260827_143021_524_803323d9/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-parameter-typed-action-parser-declarations-green/20260827_143058_819_19718c0f/RunMetadata.json`.

The final scan finds zero `ActOnParsedParam`, exact DeclId routing at every
Canonical `ParseParameterList` call site, and unchanged direct line-bearing
Parser-node sites of declaration **83**, expression **42**, statement **20**
and core **3**. `ParseVirtualPropertyDecl` still emits the removal diagnostic,
Sema has no virtual-property case and `ActOnPropertyDecl` has no production
caller. Strict OpenSpec validation and parent/plugin `git diff --check` pass;
only existing line-ending conversion warnings remain.

This closes CTA-S-18 only. General qualified/template type production,
default/named-argument semantic decoding, property/accessor behavior, lambda/
list-pattern/body actions, expression/statement/lifetime adapters and final
Builder/LEGACY retirement keep Tasks `4.2`, `4.3`, `4.4`, `4.5`, and `13.2`
unchecked. Compiler default remains LEGACY and Cache V2 remains
default-disabled.

## CTA-S-19 — declaration types crossed Parser nodes into Sema

Status: repaired and verified for every declaration-site return, parameter and
variable type. Residual lambda/property/expression type recovery remains an
explicit later migration boundary.

Before this slice, import, funcdef, ordinary/interface function, parameter,
global/field/local/`for`, and `foreach` routes all called
`ActOnQualTypeFromNode(typeNode, typeMod, script)`. Parser recognized the type
syntax, but Sema then recursively decoded the Parser nodes to rediscover the
spelling, scope, template arguments and qualifiers. This leaked syntax-tree
ownership across the intended Clang-shaped action boundary.

The semantic and source-architecture tests were added before production edits.
The intended valid RED was the test-only compile failure at
`Saved/Build/cta-declaration-qualtype-action-red-test-build/20260827_144035_331_ea2671f1/RunMetadata.json`:
`asSQualTypeSyntaxAction` and `ActOnQualTypeAction` did not exist. No unrelated
production or runner failure was involved.

Parser now copies a short-lived `asSQualTypeSyntaxAction` containing the
complete spelling, root primitive token, qualifier mask and half-open source
offsets. It may inspect transient syntax nodes while building the action, but
Sema alone validates the action and resolves its local `asCQualType` through
the existing exact lexical/qualified/Runtime type contract. The action embeds
no Parser/Runtime pointer, numeric TypeId or foreign snapshot-local TypeRef.
All seven declaration route families call `ActOnQualTypeAction`; Parser has
zero `ActOnQualTypeFromNode` calls.

The production build and all gates passed:

- build:
  `Saved/Build/cta-declaration-qualtype-action-first-fix-build/20260827_144619_355_c3e76329/RunMetadata.json`;
- focused tests **2/2**:
  `Saved/Tests/cta-declaration-qualtype-action-focused-first-green/20260827_144720_697_8f5e2de3/RunMetadata.json`;
- SemaAuthority **333/333**:
  `Saved/Tests/cta-declaration-qualtype-action-sema-green/20260827_144808_676_95784871/RunMetadata.json`;
- ProductionCodeGen **114/114**:
  `Saved/Tests/cta-declaration-qualtype-action-production-codegen-green/20260827_144856_587_4974dfa3/RunMetadata.json`;
- Parser declarations **18/18**:
  `Saved/Tests/cta-declaration-qualtype-action-parser-declarations-green/20260827_145041_742_1434b1c0/RunMetadata.json`;
- Frontend CanonicalAST Type prefix **20/20**:
  `Saved/Tests/cta-declaration-qualtype-action-frontend-type-green/20260827_145116_223_12ac1673/RunMetadata.json`.

The maintained-fork scan finds exactly seven Parser action calls and zero
Parser node-adapter calls. Direct line-bearing `asCScriptNode` sites remain
declaration **83**, expression **42**, statement **20**, and core Sema **3**.
Eight `ActOnQualTypeFromNode` textual sites remain in the Sema/header surface
for the adapter definition/declaration and lambda/property/expression/cast/
construct recovery. This is an explicit non-closure, not hidden completion.
The type action's range is validated at the boundary but is not stored on the
interned type object because the type graph has no source-range field.

One initial read-only scan used the stale guessed
`Private/AngelscriptCode/angelscript/source` path and returned no files. It is
not evidence. The corrected scan uses
`AngelscriptRuntime/ThirdParty/angelscript/source`. No build/test runner issue
occurred. Strict OpenSpec validation and separate parent/plugin
`git diff --check` pass with only existing line-ending conversion notices.

This closes CTA-S-19 only. Default/named-argument semantics, property/accessor,
lambda/list-pattern/body, expression/statement/lifetime actions, residual
type-node recovery, Builder/Runtime installation, TypedASTJIT HIR retirement
and default cutover keep Tasks `4.2`, `4.3`, `4.4`, and `13.2` unchecked.
Compiler default remains LEGACY and Cache V2 remains default-disabled.

## CTA-S-20 — cast/construct target types were re-decoded from Parser nodes

Status: repaired and verified for primitive functional casts and object
construction target types. General expression-tree lowering, lambda types,
defaults, properties, statements and lifetime plans remain later boundaries.

Before this slice, Parser recognized the target type in both `ParseCast` and
`ParseConstructCall`, but Sema expression lowering subsequently called
`ActOnQualTypeFromNode` on the retained `snDataType`. The incremental cast path
had a second copy of the same recovery. This meant expression semantics still
depended on Parser type nodes after CTA-S-19 had removed them from every
declaration route.

Two permanent tests were added first. Their test-only build passed at
`Saved/Build/cta-expression-target-type-red-test-build/20260827_150238_096_3c4c8ce4/RunMetadata.json`.
The valid initial SemaAuthority RED was **333/335 PASS, 2 FAIL** at
`Saved/Tests/cta-expression-target-type-red/20260827_150256_294_a8aed27a/RunMetadata.json`.
The architecture assertion failed as intended. The semantic fixture also used
`cast<double>(40)`, but this maintained fork reserves `cast<T>` for reference
casts; the fixture was corrected to the supported primitive functional cast
`double(40)` beside `C()`. That dialect correction changed no production code
and did not remove the architecture RED.

Parser now resolves the target from the same pointer-free
`asSQualTypeSyntaxAction` used by declaration types and publishes the local
QualType through exactly two `BindParsedExpressionType` calls. The explicitly
transitional binding holds only node identity, exact source section/offset and
local `asCQualType`; exact-node lookup is preferred and coordinate fallback
must be unambiguous. `as_sema_expr.cpp` uses only
`FindParsedExpressionType` for cast/construct destinations and fails closed
with `expression-target-type-unbound`. The incremental cast route now shares
that expression action rather than decoding the node a second time.

The corrected-fixture build and first production build compiled/linked the
Runtime but the test module failed in the independent clean file
`AngelscriptNativeContextReturnValueTests.cpp`, which uses `ASTEST_AS_ANSI`
without including `AngelscriptTestMacros.h`. The records are:

- `Saved/Build/cta-expression-target-type-red-fixture-correction-build/20260827_150554_992_0dd064aa/RunMetadata.json`;
- `Saved/Build/cta-expression-target-type-first-fix-build/20260827_151005_493_21b7ba9b/RunMetadata.json`.

A validation-only include was applied to that file, the supported build runner
was executed, and the include was immediately removed. The successful full
build is
`Saved/Build/cta-expression-target-type-first-fix-test-module-build/20260827_151048_461_a9e83c24/RunMetadata.json`.
The workaround is not implementation, is absent from the final logical diff,
and does not justify a claim that the independent aggregate clean-build
blocker has been fixed.

Final evidence is:

- SemaAuthority **335/335 PASS**:
  `Saved/Tests/cta-expression-target-type-sema-green/20260827_151114_175_0b6031eb/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-expression-target-type-production-codegen-green/20260827_151224_854_556ceeca/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-expression-target-type-parser-declarations-green/20260827_151305_977_e46c5ea4/RunMetadata.json`;
- Frontend Type **20/20 PASS**:
  `Saved/Tests/cta-expression-target-type-frontend-type-green/20260827_151450_953_7e06f64d/RunMetadata.json`;
- Language Conversions **17/17 PASS**:
  `Saved/Tests/cta-expression-target-type-language-conversions-green/20260827_151527_750_95ebaf72/RunMetadata.json`;
- Expression Chain **1/1 PASS**:
  `Saved/Tests/cta-expression-target-type-expression-chain-green/20260827_151620_271_b1c9dc7a/RunMetadata.json`.

The final scan finds exactly two Parser publications and zero
`ActOnQualTypeFromNode` calls in Parser, expression Sema or the incremental
cast slice. The only production call sites now are three residual
lambda/declaration-related adapters in `as_sema_decl.cpp`. Direct line-bearing
Parser-node sites are declaration **80**, expression **41**, statement **20**
and core **5**; the core count increase names the transient binding boundary,
not a new decoder.

Final record checks pass: strict OpenSpec validation reports the change valid,
and parent/plugin diff checks both exit zero with only existing LF→CRLF
conversion notices.

This closes CTA-S-20 only. Tasks `4.2`, `4.3`, `4.4`, `5.2`–`5.9` and `13.2`
remain unchecked. Compiler default remains LEGACY and Cache V2 remains
default-disabled.

## CTA-S-21 — lambda headers and explicit parameter types still crossed Parser nodes

Status: repaired and verified as a bounded slice.

After CTA-S-20, all three remaining production calls to
`ActOnQualTypeFromNode` were confined to lambda/declaration recovery:
`WalkParameterSequence` reconstructed explicit lambda parameters,
`FindExistingFunctionLike` reconstructed them again to match an existing
lambda, and `ActOnLambdaFromNode` treated the first `snDataType` as the
migration-phase recovery return type. `ParseLambda` published the entire
completed header with `NotifySema(node)` and entered the body through
`lastActedDecl`, leaving syntax ownership and declaration authority mixed.

The CTA-S-21 gate and two permanent tests were written first. The supported
build failed at
`Saved/Build/cta-lambda-header-red-test-build/20260827_154559_687_cecce7e7/RunMetadata.json`.
The intended errors are that `asSLambdaHeaderAction` is undeclared and
`asCSema::ActOnLambdaHeaderAction` does not exist. This is a valid compile-time
RED for the missing pointer-free contract.

The same adaptive non-unity invocation also reproduced the already-recorded,
out-of-slice clean-build failure in
`AngelscriptNativeContextReturnValueTests.cpp`: four `ASTEST_AS_ANSI` uses are
compiled without `AngelscriptTestMacros.h`. The compiler errors are independent
translation-unit failures, so the macro include problem neither invalidates
the intended CTA-S-21 RED nor authorizes an unrelated production/test cleanup.

The bounded repair now publishes one exact pointer-free lambda header action,
reuses the existing parameter action for explicitly typed lambda parameters,
pushes the returned DeclId directly and binds that exact identity to the
retained recovery shell. `ParseLambda` no longer calls `NotifySema(node)` for
the header or chooses the body owner through `lastActedDecl`.

`ActOnLambdaFromNode` is now body-only: it retrieves the exact bound lambda,
validates the lambda trait and fails closed with `lambda-header-action-missing`
if the typed header did not run. `ActOnQualTypeFromNode`,
`WalkParameterSequence`, `WalkParameterList`, `FindExistingFunctionLike` and
their private signature/type decoder helpers were physically deleted. A final
source scan reports zero matches.

The first production build at
`Saved/Build/cta-lambda-header-green-build/20260827_155518_820_e025dd40/RunMetadata.json`
found two issues. The in-slice Canonical TypeSema test helper still called the
deleted node API; it was migrated to
`BuildQualTypeSyntaxAction -> ActOnQualTypeAction` rather than restoring the
compatibility decoder. The already-known out-of-slice
`AngelscriptNativeContextReturnValueTests.cpp` macro-include blocker also
recurred. A validation-only include allowed the complete build to pass at
`Saved/Build/cta-lambda-header-green-build-workaround/20260827_155700_053_4034ffea/RunMetadata.json`
and was immediately removed. `git diff --quiet HEAD --` for that file is true;
the workaround is absent and the unrelated clean-build blocker is not claimed
fixed.

Final GREEN evidence is:

- SemaAuthority **337/337 PASS**:
  `Saved/Tests/cta-lambda-header-sema-green/20260827_155733_206_0edcdf13/RunMetadata.json`;
- Canonical TypeSema **1/1 PASS**:
  `Saved/Tests/cta-lambda-header-type-sema-green/20260827_155825_582_d8c0f5b0/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-lambda-header-parser-declarations-green/20260827_155919_446_58eb69e2/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-lambda-header-production-codegen-green/20260827_160000_979_728abf3e/RunMetadata.json`;
- Frontend Type **20/20 PASS**:
  `Saved/Tests/cta-lambda-header-frontend-type-green/20260827_160044_351_9b26546b/RunMetadata.json`.

One initial read-only source scan used a stale guessed
`Private/AngelscriptCode/...` path. It produced no evidence and was replaced by
the maintained-fork path under
`AngelscriptRuntime/ThirdParty/angelscript/source`. The final direct
line-bearing Parser-node inventory is declaration **49**, expression **41**,
statement **20** and core **5**.

This slice intentionally preserves the migration-phase recovery return type
(first explicit parameter type, otherwise `int`). It does not claim contextual
funcdef signature binding, untyped non-zero parameter inference, return
inference, body action completion, Task 4.4 closure, default CANONICAL
selection or Cache V2 enablement.

## CTA-I-01 — native SDK macro users relied on unity include leakage

Status: repaired as test infrastructure; no Canonical semantic credit.

The first CTA-S-22 test-only build failed in
`AngelscriptNativeContextReturnValueTests.cpp` because four
`ASTEST_AS_ANSI` uses had no direct declaration. This was the third consecutive
Canonical slice in which the same adaptive non-unity failure interrupted the
supported build. A scan of all 450 `.cpp` macro users found three real missing
direct includes: ReturnValue, PublicApiDepth and Invocation context tests.
`StaticJIT/AngelscriptJITExecutionContextTests.cpp` was a scan false positive
because it already includes `Shared/AngelscriptTestMacros.h`.

All three real files had no logical diff against `HEAD` before the repair.
Each now directly includes `AngelscriptTestMacros.h`. The failing build is
`Saved/Build/cta-declaration-replay-red-test-build/20260827_161618_560_f16f8b65/RunMetadata.json`;
the repaired test-only build is
`Saved/Build/cta-declaration-replay-red-test-build-fix1/20260827_161748_865_35cfc34c/RunMetadata.json`.
This resolves the recurring include dependency rather than hiding it with a
third temporary workaround. It does not change Runtime behavior or close an
OpenSpec compiler task.

## CTA-S-22 — inactive whole-tree declaration replay remained callable

Status: physically removed and verified as a bounded architecture slice.

After CTA-S-21, Parser still retained `NotifySema`, `semaDeclActions` and a
zero-action fallback into `ActOnParsedScript`; Sema still publicly exposed
`ActOnParsedDeclaration`/`ActOnParsedScript` and retained recursive
`WalkOne`/`WalkDecls`. Every accepted top-level declaration node kind was
already excluded from the callback and all supported declaration families
incremented the action counter, so the fallback had no valid production
producer. Keeping it nevertheless left a second declaration-semantic entry
point that could silently regain authority.

Two SFINAE API-surface tests were written first. The valid RED was **337/339
PASS**, with only the two obsolete methods observed as present:
`Saved/Tests/cta-declaration-replay-red/20260827_161809_396_b4bdbf7d/RunMetadata.json`.

Parser now has no callback, action counter, counter increments, top-level
exclusion list or zero-action script replay. Sema has no whole-tree declaration
API, replay walker or replay-only identifier/token/type/return/trait helpers.
Explicit body/default/initializer/expression/statement adapters remain named
migration boundaries and were not conflated with this deletion.

The full implementation build passed at
`Saved/Build/cta-declaration-replay-green-build/20260827_162535_044_2ed1c425/RunMetadata.json`.
The first GREEN run was **335/339** because four earlier source-structure tests
still required the now-deleted exclusion list or residual walker as proof of
non-replay. No semantic/AST/CodeGen assertion failed. Those tests now require
global absence of `NotifySema` and `WalkOne`; the repair build passed at
`Saved/Build/cta-declaration-replay-green-test-repair-build/20260827_162848_770_7cf1decf/RunMetadata.json`.

Final evidence is SemaAuthority **339/339 PASS** at
`Saved/Tests/cta-declaration-replay-green-sema-fix1/20260827_162908_093_8a7561d0/RunMetadata.json`
and the combined TypeSema/Parser-declaration/ProductionCodeGen/Frontend-Type
matrix **152/152 PASS** at
`Saved/Tests/cta-declaration-replay-green-regression-matrix/20260827_163022_003_215ff320/RunMetadata.json`.

The forbidden-symbol scan is zero. Direct line-bearing `asCScriptNode` sites
fall from **49/41/20/5** to **25/41/20/5** for declaration/expression/
statement/core Sema. This closes only the whole-tree fallback bullet in Batch
2 Task 2.1. Property/default/body/general expression/statement/control/
lifetime actions, CANONICAL independence from Builder/LEGACY facts, backend
coverage, HIR removal and
default cutover keep all umbrella tasks unchecked. Compiler default remains
LEGACY and Cache V2 remains default-disabled.

Strict OpenSpec validation reports the change valid. Parent and plugin
`git diff --check` both exit zero; existing LF-to-CRLF conversion notices are
the only warnings. The final forbidden-symbol scan is also zero.

## CTA-SCOPE-01 — native AngelScript AST and TypedSemantic HIR were conflated

Status: OpenSpec scope corrected; no production source change or completion
credit.

The current record used “legacy AST”, “legacy semantic retirement”, and “HIR
removal” as if they named one structure. They do not:

- `asCScriptNode` is AngelScript's native Parser syntax/recovery tree and feeds
  the explicit LEGACY Builder/Compiler path;
- `asCTypedSemanticFunction` is the additional function-owned TypedSemantic
  HIR sidecar introduced for typed semantic capture/TypedASTJIT.

The user explicitly requires the native AST/Builder/Compiler implementation to
remain for syntax-coverage reference, isolated differential comparison and
stability rollback. Its physical deletion therefore moves to a later dedicated
`retire-as-legacy-native-compiler-pipeline` OpenSpec, which is named but not
created here. The current change still migrates every production consumer off
TypedSemantic HIR and physically deletes HIR builders/storage/accessors/types
after the corresponding Canonical tests are green.

The corrected cutover contract is:

1. CANONICAL becomes independently complete and then default;
2. CANONICAL never semantically replays `asCScriptNode`, invokes LEGACY as an
   automatic fallback, merges facts, or accepts a `dual` pipeline value;
3. an explicitly selected LEGACY Engine may still publish through the retained
   native Parser/Builder/Compiler path;
4. TypedSemantic HIR is removed from both production and test-oracle authority.

CTA-S22 remains valid: it deleted an inactive duplicate whole-tree replay API
inside the new Canonical integration, not the native syntax node classes,
Builder, Compiler, or LEGACY Build route. The authoritative rationale, scope
matrix, unchanged HIR requirements and non-claims are recorded in
`attachments/legacy-native-ast-retention-scope-revision-2026-08-27.md`.

During the reconciliation another record defect was found: `proposal.md`
claimed source-module `Build()` already defaulted to CANONICAL, contradicting
current source and the verified LEGACY migration default. The status text is
corrected. No default, code, test, checkbox, commit, archive, or follow-up
change was altered by this documentation-only decision.

## CTA-S-23 — lambda expression replay rediscovered identity and body

Status: physically removed and verified as a bounded Canonical action slice;
native AST/LEGACY retained.

The Parser already created the exact `<lambda>` declaration through
`asSLambdaHeaderAction`, published parameters under that `DeclId`, entered the
exact declaration context and attached the completed body. Later expression
lowering nevertheless called `ActOnLambdaFromNode`, recovered the declaration
from `snFunction`, created the `DeclRef` and attached the same body again. A
second call in bare-lambda statement lowering was initially missed by the
inventory.

The gate and permanent tests were written first. The supported RED build failed
only because `asSLambdaExpressionAction` and
`ActOnLambdaExpressionAction` did not exist:

`Saved/Build/cta-lambda-expression-action-red/20260827_170515_552_cb021d38/RunMetadata.json`.

The repair adds a pointer-free action carrying the exact lambda `DeclId` and
full range, plus a transient build-only native-node-to-`ExprId` identity map.
Parser publishes and binds the expression after its one body action. Expression
and statement lowering retrieve only that exact identity; missing or ambiguous
identity fails closed with `lambda-expression-action-missing`. The old adapter
and its sole child-search helper are deleted. No native node pointer crosses a
snapshot/Provider/Cache/relocation/Runtime boundary.

The first GREEN build exposed the missed statement call as its only compile
error:

`Saved/Build/cta-lambda-expression-action-green-build/20260827_170659_069_da9e2481/RunMetadata.json`.

Migrating that branch to the same binding made the full build pass:

`Saved/Build/cta-lambda-expression-action-green-build-fix1/20260827_170800_056_12ab0643/RunMetadata.json`.

One patch attempt used stale comment context and failed safely; the exact slice
was reread before applying the correction. Two read-only inventories also used
Windows wildcard path components directly with `rg`; both produced no accepted
evidence and were rerun against directory roots with `--glob`. Existing
C5038/C4191 native-fixture warnings are unchanged baseline noise.

Final GREEN evidence is:

- SemaAuthority **341/341 PASS**:
  `Saved/Tests/cta-lambda-expression-action-final-sema/20260827_171049_642_4ce5dbcd/RunMetadata.json`;
- native ScriptNode shape **14/14 PASS**:
  `Saved/Tests/cta-lambda-native-ast-retention-green/20260827_171004_229_60d52e39/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-lambda-expression-action-parser-declarations/20260827_171140_724_0516a334/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-lambda-expression-action-production-codegen/20260827_171213_695_de9cb526/RunMetadata.json`.

The source scan finds zero production `ActOnLambdaFromNode` and
`FirstChildOfType` matches. `ParseLambda()` still returns `asCScriptNode*` and
constructs `snFunction`; the real native-shape test locks its parameter list
and statement block too. Direct Sema node-reference inventory is
**22/41/20/7** for declaration/expression/statement/core. The two extra core
lines are identity-only binding APIs, not node semantic decoding.

This advances Tasks 4.2/4.4/5.2/13.2 but closes none. Contextual lambda
signature/return inference, other body/default/property/general expression/
statement/control/lifetime adapters, TypedSemantic HIR deletion and final
CANONICAL default remain open. LEGACY remains the current default, the native
AST/Builder/Compiler remain explicitly retained, and Cache V2 remains
default-disabled.

## CTA-HIR-01 — HIR physical deletion has a wider live surface than the model files

**Status:** Open; Task 10.5 remains incomplete.

The user clarified that the added TypedSemantic HIR must be physically deleted
in this OpenSpec, while AngelScript's native `asCScriptNode`/Parser/Builder/
Compiler and explicit LEGACY path must remain. A case-insensitive audit finds
HIR names/contracts across 44 Runtime files, 6 Editor files, 93 test files and
5 Standalone files. Production still has compiler capture instrumentation,
script-function ownership/accessors, engine capture configuration, HIR
Analyzer/Emitter/Eligibility/Closure/Dependency compatibility paths, Editor
HIR dump surfaces, and active HIR test oracles.

One required non-HIR capability is currently coupled to the HIR header:
`asCScriptCode` and module source ingestion use HIR-named source-provenance
types. Those records must be extracted into neutral SourceManager/ScriptCode
ownership before `as_typed_semantic_ir.h/.cpp` can be deleted. This is a naming
and ownership migration, not permission to remove source provenance.

**Resolution rule:** migrate valuable HIR semantic oracles to Canonical
AST/Bytecode/TypedASTJIT, remove every HIR consumer and compatibility branch,
extract neutral provenance, then delete the builder/storage/accessors/model and
build wiring as a coordinated unit. Do not add AST-to-HIR or Bytecode-to-HIR
compatibility. Do not delete the native AST/Builder/Compiler. Full inventory,
sequence, forbidden-symbol scan, and the corrected Windows `rg` audit are in
`attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md`.

## CTA-HIR-02 — neutral source provenance was physically owned by HIR

**Status:** Resolved as a bounded prerequisite; HIR retirement remains open.

`asCScriptCode`, module source ingestion and the UE compile bridge depended on
source-provenance types declared in `as_typed_semantic_ir.h`. Those authored/
generated coordinates remain valid after HIR deletion, so deleting the model
would either break source mapping or force neutral code to keep including HIR.

The repair introduces `as_source_provenance.h` with neutral anchor,
generated-kind, origin, span and range types. ScriptCode, Module and Engine
ingestion now consume those names directly. The HIR header temporarily aliases
its old vocabulary to the neutral records while remaining HIR consumers are
migrated; the aliases are deleted with HIR and are not a permanent API.

The first GREEN build exposed a stale
`struct asSTypedSemanticSourceSpan` TypedASTJIT forward declaration that could
not coexist with the alias. The backend test seam now uses `asSSourceSpan`.
It also proved that a unity translation unit's HIR include-guard state cannot
test a single header's dependency: the permanent test was changed to exact
typed API/behavior assertions, and explicit source scans prove direct include
isolation. Two later scans were rejected because of PowerShell quote syntax
and Windows wildcard path components; corrected explicit-file scans returned
zero forbidden ScriptCode/module ingestion matches. A new non-ASCII comment
warning was removed by changing the comment to ASCII.

The final post-validation dependency scan repeated the PowerShell/regular-
expression quote failure and reached `rg` as an invalid unclosed group. That
command produced no accepted evidence. Its fixed-string, explicit-file rerun
returned `neutral-ingestion-forbidden-match-count=0`.

Final evidence is Runtime/Editor build PASS, provenance compatibility **7/7**,
Canonical SourceManager **9/9**, and Standalone **21/21**. Old HIR provenance
symbol matches move from **203** to **173**; remaining HIR, TypedASTJIT and old
test consumers keep Task 10.5 open. Full RED/GREEN paths, issues, scans and
non-claims are in
`attachments/hir-neutral-source-provenance-extraction-gate-2026-08-27.md`.

## CTA-HIR-03 — Editor HIR dump remained a product-facing compatibility surface

**Status:** Resolved bounded deletion slice; Task 10.5 remains open.

The Editor still exposed `AngelscriptHIRDump` command/Commandlet types, a
`DeveloperHIRDump` ProjectSourceGraph request mode, a dedicated scratch route,
and HIR-specific Automation tests even though read-only Canonical AST
diagnostics already own list/dump/query/verify/diff.

The architecture gate was written first and failed exactly because the four
Editor files plus dedicated Commandlet test still existed: Standalone was
20/21 with only Architecture red. The production types, Commandlet, dedicated
tests, one-value request-kind and HIR scratch branch are now physically
deleted. The old contained-engine and primary-snapshot behaviors were retained
as direct ProjectSourceGraph/public AST lease tests rather than wrapper tests.

The initial five-file scan missed three embedded test users. A first combined
deletion patch then failed atomically on repeated stale context and made no
partial edit. One Windows wildcard scan produced `os error 123` and no accepted
evidence. The first GREEN Automation selector omitted CQTest's class segment,
so its 2/2 result covered only existing ProjectSourceGraph tests; the exact two
migrated paths were rerun separately and passed 2/2.

One capability gap remains explicit: the removed HIR generated-source-
provenance integration test had shown literal-asset/subsystem generated-origin
chains in HIR output. Neutral ScriptCode propagation remains tested, but
Canonical SourceManager/structured diagnostics do not yet retain or show that
chain. This must be migrated before final HIR model deletion and is not claimed
as equivalently covered here.

Final evidence is Runtime/Editor build PASS, migrated behavior **2/2**,
ProjectSourceGraph **2/2**, Standalone **21/21**, five deleted paths absent and
zero live `AngelscriptHIRDump`, `DeveloperHIRDump` or ProjectSourceGraph
request-kind symbols under `Source`. Full RED/GREEN paths, problems and
non-claims are in
`attachments/hir-editor-dump-retirement-gate-2026-08-27.md`.

## CTA-HIR-04 — Canonical snapshot and V5 sidecar lost neutral provenance

**Status:** Resolved bounded prerequisite; Task 10.5 remains open.

After the HIR dump surface was deleted, neutral ScriptCode propagation still
had no complete Canonical ownership/restore route. SourceManager originally
retained logical key, source class, bytes and line mapping only; Cache sidecar
V5 restored that processed model but dropped authored/generated anchors. The
permanent restore test failed exactly at the missing authored origin.

SourceManager now copies and validates neutral ranges, exact remap includes
provenance, Parser/Sema carries ScriptCode ranges into the source session, and
span resolution exposes applicable authored/generated facts. ASTBodySidecar V6
serializes the pointer-free source records, rejects malformed flags/kinds/counts
and treats V5 as a safe miss. A separate boundary test proves provenance is
diagnostic-only and does not alter function record content identity.

The first broad GREEN build timed out at the wrapper's short 180-second budget
without compiler errors; its 600-second rerun passed. A later test-only build
failed on a nonexistent verifier enum and passed immediately after the helper
used a local failure code. Several read-only `rg` invocations named nonexistent
paths or used Windows wildcard path components; all were rejected as evidence
and rerun against correct roots/explicit files. These issues and exact paths
are recorded in the dedicated attachment.

Final evidence is Runtime/Editor build PASS, ASTBodySidecar **21/21**,
SourceManager **12/12**, neutral ownership **3/3**, Preprocessor provenance
**2/2** and Standalone **21/21**. HIR model/capture/storage/accessors and
remaining consumers still exist; the native AST/Parser/Builder/Compiler and
explicit LEGACY path remain intentionally retained. Full record:
`attachments/canonical-source-provenance-retention-gate-2026-08-27.md`.

## CTA-HIR-05 — Legacy compiler still contained the complete HIR capture implementation

**Status:** Compiler capture resolved; model/consumer deletion remains open.

Static generation had already stopped retaining production HIR, but
`asCCompiler` still contained the 2,000+ line function-local builder plus
hundreds of expression/statement/call hooks. Default-off capture therefore was
not physical retirement. Exact reverse hunks from the HIR introduction commit
removed 3,763 implementation lines and 23 header lines while retaining the
native compiler and later Canonical/LEGACY instrumentation.

One reverse include hunk correctly rejected due to a later `as_module.h`
addition; no forced overwrite was used and the corrected compiler scan is
zero. The first build then exposed one obsolete test of the removed
`asCExprContext::typedSemanticExpression` carrier. That HIR-only test was
deleted, and the full Editor build passed on rerun.

Remaining HIR model/storage/accessors, Engine flags, TypedASTJIT compatibility,
diagnostics, Standalone wiring, and test consumers keep Task 10.5 open. Exact
RED/GREEN paths, counts, preservation boundary, and non-claims are in
`attachments/typed-semantic-hir-compiler-capture-removal-gate-2026-08-27.md`.

## CTA-HIR-06 — Removing HIR ownership exposed residual AOT and mixed-test consumers

**Status:** Partial GREEN; ownership/configuration removal and the first
consumer migration gates are green, but physical HIR model/compatibility
deletion is incomplete.

The working tree now has zero exact matches for the ScriptFunction HIR
ownership accessors, Engine HIR capture setters/getters/configuration/freeze
fields, and the UE `bCaptureTypedSemanticIR` setting. This is a real physical
ownership/configuration deletion, not a default-off branch. Mixed native
Language and Cache fixtures retain their non-HIR assertions, and the native
AST/Parser/Builder/Compiler/LEGACY path remains intentionally present.

The first integration build failed with three actionable classes rather than a
Runtime ownership ABI failure: a single obsolete Power-test HIR assertion, two
non-HIR generation-isolation helper definitions removed by an overly broad
historical reverse hunk, and incomplete AOT migration from HIR diagnostics and
emission to Canonical snapshot/DeclId inputs. The missing helper definitions
must be restored from their pre-HIR-independent implementation; their call
sites must not be deleted merely to make the build pass. The AOT path must not
gain an AST-to-HIR compatibility adapter.

RED evidence:
`Saved/Build/cta-hir-delete-ownership-consumers-check/20260827_191004_450_41c70479/RunMetadata.json`.

This issue keeps Task 10.5 open. A green UE build, Standalone suite after the
CMake target deletion, focused Canonical AST/TypedASTJIT gates, removal of the
remaining HIR model/TypedASTJIT overloads/diagnostic names, and final positive
native-AST retention scan are still required.

The first three gates are now evidenced: Runtime/Editor build GREEN at
`Saved/Build/cta-hir-delete-ownership-consumers-fix2/20260827_192428_316_5f4ed604/RunMetadata.json`,
Standalone **20/20 PASS** at
`Saved/StandaloneTests/cta-hir-delete-ownership-consumers_01_Standalone/20260827_192452_896_694636cf/RunMetadata.json`,
native Power **3/3 PASS** at
`Saved/Tests/cta-hir-delete-power-native/20260827_192631_967_77452e07/RunMetadata.json`,
and ProjectGeneration.Engine **32/32 PASS** at
`Saved/Tests/cta-hir-delete-generation-engine/20260827_192711_399_07b38c33/RunMetadata.json`.
The prior repair-1 link RED is retained as evidence at
`Saved/Build/cta-hir-delete-ownership-consumers-fix1/20260827_192121_312_e77f830d/RunMetadata.json`;
it exposed four non-HIR AOT wrapper definitions accidentally removed with the
historical HIR hunk. They were restored with Canonical snapshot/DeclId emission
and Canonical AST benchmark fields, not through an AST-to-HIR adapter.

Remaining issue scope is now narrower: delete `as_typed_semantic_ir.h/.cpp`,
remove production TypedASTJIT HIR overloads/model vocabulary and HIR-named
diagnostics, run AOT GenerationVerification/Benchmarks plus
CanonicalASTMigration, and prove the native AST/Parser/Builder/Compiler/LEGACY
retention scan. Standalone **20/20** is the correct post-deletion count because
the removed twenty-first target was HIR-only.

## CTA-HIR-07 — physical HIR model deletion exposed stale AOT generation expectations

**Status:** Physical model/production compatibility deletion is GREEN at build
and Standalone level; four focused AOT generation expectations remain open.

A permanent Standalone architecture assertion was added before deletion and
failed with **19/20 PASS** because `as_typed_semantic_ir.h/.cpp` still existed:
`Saved/StandaloneTests/cta-hir-model-delete-red_01_Standalone/20260827_193915_030_9210e623/RunMetadata.json`.
The two files, production HIR analyzer/dependency/legacy-emitter paths, HIR-only
TypedASTJIT overloads/vocabulary, HIR-named diagnostics, and HIR-oracle-only UE
tests are now physically removed. Canonical-owned expression IDs, source spans,
invocation/receiver/call-target/cleanup enums and failure categories replace the
removed model; no AST-to-HIR compatibility adapter was introduced.

The final Editor build passed at
`Saved/Build/cta-hir-model-delete-green3/20260827_200012_445_37099496/RunMetadata.json`.
Standalone passed **20/20** at
`Saved/StandaloneTests/cta-hir-model-delete-green_01_Standalone/20260827_200033_113_1ec00343/RunMetadata.json`,
including the physical-absence assertion. Two intermediate build failures are
retained as evidence: the first exposed stale Canonical snapshot/test field
names, and the second exposed `LexToString(EAngelscriptTypedASTJITSemanticUseKind)`
being defined only in the deleted dependency implementation. The definition now
lives with the Canonical model.

The combined AOT GenerationVerification/Benchmarks, ProjectGeneration.Engine
and CanonicalASTMigration gate finished **44/48 PASS** at
`Saved/Tests/cta-hir-model-delete-focused/20260827_200245_771_e1d1332e/RunMetadata.json`.
The remaining failures are:

- `CrossProfileOutputHasDistinctIdentityAndVerifyReportsStale`;
- `EmitterVerificationFailureFallsBackAtomicallyAndFailsVerification`;
- `ExpectedEligibleTypedFallbackFailsVerification`;
- `RepeatedTypedGenerationIsByteDeterministicAndCurrent`.

These failures are not accepted as a waiver and keep Task 10.5/final completion
open. They are currently classified as stale generation-verification/output
expectations after removing the HIR fallback/emitter path; each must be traced
against the Canonical-only production contract before changing either tests or
implementation. This gate does not invalidate the separately completed dynamic
TypeId identity/relocation architecture; it exercises the in-progress AOT HIR
retirement seam.

Follow-up generation and baseline refresh closed the first three failures. A
fresh Canonical-only commandlet generation wrote the complete managed
EditorDevelopment set, the generated C++ compiled, and the exact
GenerationVerification class reached **3/4 PASS**. The sole remaining failure
was the stale cross-authority content-hash assertion described in CTA-HIR-09;
all repeated Canonical parses in that run completed with zero diagnostics.

## CTA-HIR-08 — qualified native calls raced Canonical namespace projection

**Status:** Resolved; focused native-configuration execution is still part of
the final layered gate.

During repeated Canonical AOT generation, calls such as `Math::...` and
`FDateTime::...` could report an unresolved scope because `InternParsedCall()`
performed explicit-scope lookup before the lazy native global/namespace
projection had populated the Canonical declaration graph. The same global
projection already existed later in `ResolveCallee`, but that was too late for
the earlier scope lookup.

A TDD fixture registers `Host::Lookup(int,int)`, parses
`Host::Lookup(3,4)`, and requires an exact resolved callee with no unresolved
scope. `InternParsedCall()` now invokes the existing idempotent
`InternNativeGlobals` projection before explicit-scope resolution; it does not
copy declarations through Builder, replay LEGACY facts, or add a fallback.

The Editor build passed at
`Saved/Build/cta-qualified-native-scope-green-build/20260827_202650_384_879051f6/RunMetadata.json`.
The post-fix determinism run kept Canonical parse diagnostics at zero through
epochs 16–49 and failed only because the checked-in generated baseline was
stale:
`Saved/Tests/cta-aot-direct-canonical-scope-green-determinism/20260827_202703_479_d2234450/RunMetadata.json`.

## CTA-HIR-09 — AOT determinism test equated content hashes across compiler authorities

**Status:** Resolved; exact method **1/1 PASS**.

After refreshing generated output and compiling it, the exact AOT
GenerationVerification class passed **3/4**. The remaining
`RepeatedTypedGenerationIsByteDeterministicAndCurrent` failure compared the
isolated Bytecode and TypedAST `ExecutionHash` values for equality. Both first
and second generations were individually stable; the mismatch was between the
LEGACY-compiled Bytecode artifact and CANONICAL-compiled TypedAST artifact.

That equality is not an OpenSpec contract. `ExecutionHash` and `DebugHash` are
exact Provider/runtime content identities. The differential requirement
explicitly compares maintained observable behavior rather than identical
instruction bytes, and the installed AOT differential test already executes
both generated artifacts through Raw, VM, and Parms entries over the same case
matrix. Stable function identity, artifact profile, and entry ABI remain common
across the two backends.

The generation verification now requires non-empty per-backend content hashes
and retains complete first-versus-second identity equality separately for each
backend. It no longer requires hashes produced by distinct compiler authorities
to be equal and does not assert permanent inequality, so a later explicit
Bytecode default cutover may legitimately converge them. No production hash,
Provider matcher, manifest, or generated artifact was weakened. RED evidence:
`Saved/Tests/cta-aot-canonical-generated-baseline-green/20260827_203654_096_b966759f/RunMetadata.json`.

The test-only source compiled successfully at
`Saved/Build/cta-aot-cross-authority-hash-green-build/20260827_205153_940_b73070a8/RunMetadata.json`.
The exact CQTest method then completed **1/1 PASS** after two full generation
passes (production plus twelve isolated TypedAST backends per pass), with zero
Canonical parse diagnostics:
`Saved/Tests/cta-aot-cross-authority-hash-green-exact/20260827_205311_123_d88ffd53/RunMetadata.json`.

One intervening command omitted the CQTest class segment from the full
Automation path and matched zero tests. It exited nonzero at
`Saved/Tests/cta-aot-cross-authority-hash-green/20260827_205229_011_fd7e1c36/RunMetadata.json`;
it is retained as a selector error and is not test evidence. The corrected path
was `Angelscript.TestModule.StaticJIT.AOT.GenerationVerification.FAngelscriptStaticJITAotGenerationVerificationTests.RepeatedTypedGenerationIsByteDeterministicAndCurrent`.

## CTA-SEMA-01 — CANONICAL Sema still replays native Parser-node body structure

**Status:** Open; this is the principal frontend-authority blocker after HIR
retirement.

The current CANONICAL backend is genuinely AST-direct: Stage 3 seals and takes
`asCASTContext`, then calls `asCBytecodeCodeGen::GeneratePreparedModule()`;
TypedASTJIT/AOT likewise consumes a sealed snapshot and stable declaration
identity. Neither route reads an AST dump, HIR, or reconstructed Bytecode
semantics.

The earlier construction boundary is still hybrid. Parser declaration headers
now publish many typed actions, but function bodies, expressions, statements,
control structures and several initializer/default/property routes still call
`ActOnFunctionBodyFromNode`, `ActOnParsedExpr`, `ActOnParsedStmt`,
`ActOnExprFromNode`, `ActOnStmtFromNode`, `InternParsedCompoundStmt` and related
named adapters. Those functions interpret `asCScriptNode::nodeType`, token
kind/text and child/sibling layout to construct Canonical Expr/Stmt facts.
Expression replay even reconstructs precedence from the Parser's flat
term/operator sequence in parallel with the native compiler convention.

The native `asCScriptNode` tree itself is intentionally retained for the
explicit LEGACY pipeline, grammar/recovery, reference, differential testing
and rollback. The violation is using it as CANONICAL semantic input. The
target is for Parser to continue producing that independent tree while also
passing pointer-free typed action payloads and Expr/Stmt/Decl IDs directly to
Sema. Builder must then project already-determined Canonical facts into
Engine-local Runtime shells instead of serving as a second declaration/type
authority.

This keeps Tasks 4.2, 4.3, 4.6, 5.2–5.9, 10.6, 10.7 and the final default
cutover open. It is independent from the resolved physical HIR deletion and
must not be waived by AOT/build/prefix greens. Full lifecycle, current call
inventory, risks and recommended AST-first migration order are recorded in
`attachments/current-compiler-lifecycle-and-parser-node-adapter-audit-2026-08-27.md`.

## CTA-S-24 — literal token semantics still came from `snConstant` replay

**Status:** Resolved and verified; CTA-SEMA-01 remains open for the other
expression/statement/body families.

Before this slice, CANONICAL Sema decoded literal token kind/text and source
position by receiving an `asCScriptNode*`. That made the retained native
`snConstant` tree a semantic authority even though sealed-AST CodeGen itself
was already direct.

The repair adds pointer-free `asSLiteralExprAction` carrying copied token kind,
spelling and half-open offsets. Parser invokes
`asCSema::ActOnLiteralExprAction`, binds the returned exact `ExprId`, and still
returns the independent native node for LEGACY/reference/recovery. The
remaining `ActOnExprFromNode(snConstant)` route is identity-only and fails
closed with `literal-expression-action-missing`; it no longer decodes the
node. `ActOnParsedStringLiteral` is deleted and scans to zero.

TDD evidence includes the missing-action compile RED at
`Saved/Build/cta-s24-literal-action-red2/20260827_214946_391_3f1be476/RunMetadata.json`
and the pre-Parser-wiring runtime RED **0/1** at
`Saved/Tests/cta-s24-parser-literal-identity-red/20260827_215558_245_71d6a44a/RunMetadata.json`.
Final gates are direct action **1/1**, Parser identity **1/1**, SemaAuthority
**344/344**, native ScriptNode **32/32**, ProductionCodeGen **114/114**, and two
successful Runtime/Editor builds. Exact report paths, the corrected CQTest
selectors, the per-worktree command-lock rejection, and non-claims are recorded
in
`attachments/canonical-literal-expression-typed-action-gate-2026-08-27.md`.

This does not close decl-ref/composite expressions, statements, control flow,
function bodies, defaults, initializers, lifetime actions, Builder Runtime-
shell narrowing, full CodeGen, or the final default cutover.

## CTA-S-25 — declaration-reference semantics still came from `snVariableAccess` replay

**Status:** Resolved and verified; CTA-SEMA-01 remains open for composite
expressions and the statement/body families.

Before this slice, CANONICAL Sema reconstructed identifier and explicit-scope
meaning from an `asCScriptNode*`. The repair adds pointer-free
`asSDeclRefExprAction`, carrying copied name/scope/root-scope/range facts plus
the current short-lived AST owner. Sema now owns lexical and exact-scope
lookup, `this`, native-enum projection, automatic-import projection, deferred
binding and diagnostics from that action. Parser binds the returned exact
`ExprId` while continuing to retain native `snVariableAccess` for
LEGACY/reference/recovery.

The old `InternParsedDeclRef` API is physically deleted and scans to zero. The
two surviving Sema `snVariableAccess` routes are identity-only and fail closed
with `decl-ref-expression-action-missing`; neither decodes name or scope.
Parser currently copies the action from the native syntax node it has just
constructed. That local grammar copy is a later cleanup opportunity, not a
remaining Sema authority leak, because no node crosses the action boundary.

TDD evidence begins with the missing-action compile RED at
`Saved/Build/cta-s25-decl-ref-action-red/20260827_221232_922_e9fe55bc/RunMetadata.json`.
Both permanent tests were added together, so compilation prevented a separate
runtime RED; none is claimed. Final gates are direct action **1/1**, Parser
identity **1/1**, SemaAuthority **346/346**, ProductionCodeGen **114/114**,
retained native ScriptNode **32/32**, and a successful Runtime/Editor build.
Exact report paths, the unqualified/relative/absolute/`this`/native-enum/
automatic-import/deferred semantic matrix, one atomically rejected patch
attempt, and non-claims are recorded in
`attachments/canonical-decl-ref-expression-typed-action-gate-2026-08-27.md`.

Parser still has 18 general `ActOnParsedExpr` calls. Call/member/index/unary/
binary/assignment/conditional expressions, statements, control flow, bodies,
defaults, initializers, lifetimes, Builder Runtime-shell narrowing, complete
CodeGen and final default cutover therefore remain open.

## CTA-S-26 — complete ternary semantics still came from `snCondition` replay

**Status:** Resolved and verified for conditional expressions; CTA-SEMA-01
remains open for the other composite and statement/body families.

Before this slice, Parser called generic expression replay after parsing a
complete conditional, and Sema rediscovered condition/then/else structure from
the native node. The repair adds pointer-free `asSConditionalExprAction` with
three exact child ExprIds and copied half-open offsets. Sema owns validation,
arm conversion, result-type selection and typed construction. Parser binds the
returned exact parent identity while retaining native `snCondition` for
LEGACY/reference/recovery. Complete ternary Sema cases are identity-only and
fail closed with `conditional-expression-action-missing`.

The missing-action compile RED is recorded at
`Saved/Build/cta-s26-conditional-action-red/20260827_222949_003_5cd11879/RunMetadata.json`.
The corrected exact-identity runtime RED is **0/1** at
`Saved/Tests/cta-s26-parser-conditional-exact-identity-red/20260827_223557_360_9d38d827/RunMetadata.json`.
Final gates are direct action **1/1**, Parser exact identity **1/1**,
SemaAuthority **348/348**, conditional differential **1/1**,
ProductionCodeGen **114/114**, native ScriptNode **32/32**, and complete
Canonical Semantics **12/12**. Parser `ActOnParsedExpr` calls fall from 18 to
14. Full evidence and non-claims:
`attachments/canonical-conditional-expression-typed-action-gate-2026-08-27.md`.

## CTA-S26-I1 — section+offset expression recovery aliased a parent to its first leaf

**Status:** Resolved and permanently covered.

The first Parser conditional test unexpectedly returned a `DeclRefExpr` for
the outer `b ? 1 : 2`. The parent and `b` shared section and begin offset, and
the broad recovery lookup had no node-kind or length discriminator. Treating
that result as exact would allow later action composition to attach the wrong
semantic identity.

The fix separates pointer-exact lookup into
`FindExactParsedExpressionIdentity`. Parser composite actions use only that
API. Structural recovery now matches section, node kind, offset and length,
and recursive transparent lookup fails if it sees multiple distinct exact
descendants. The initial false-positive failure remains at
`Saved/Tests/cta-s26-parser-conditional-identity-red/20260827_223336_872_49fcc689/RunMetadata.json`;
the exact-API compile RED and real missing-parent runtime RED are recorded in
the gate attachment.

## CTA-S26-I2 — conditional action was skipped although recovery had all exact operands

**Status:** Resolved and permanently covered.

The first full post-wiring SemaAuthority run was **347/348**, with
`ParserActOnConditionalBeforeElseCloseFails` as the sole failure. Its enclosing
call omitted a close delimiter, but condition, then and else operands had all
published exact identities. Parser initially withheld the conditional action
on this error path, leaving the parent identity absent.

Parser now attempts the action whenever all three exact child IDs exist. It
still publishes nothing for a missing then expression, missing colon or absent
operand, and never recovers semantics by walking the parent node. Focused
recovery is **1/1** and the rerun is **348/348**. The failed and repaired paths
are recorded in the gate attachment.

## CTA-LIFE-01 — CANONICAL Stage 3 bypasses the only Parser/FMemStack cleanup

**Status:** Resolved and verified.

`BuildParallelParseScripts()` allocates and retains one owning `asCParser*`
per source section. Each Parser owns the `FMemStackBase` containing that
section's complete native `asCScriptNode` tree. Before repair, only the tail of
LEGACY `BuildCompileCode()` deleted the Parser array. CANONICAL Stage 3 skips
that function, seals the AST, calls `GeneratePreparedModule()`, and then deletes
Builder. Builder's destructor did not delete `parsers`; `asCArray` only
destroys the raw pointer slots.

Therefore successful CANONICAL builds leak Parser objects and their syntax
tree pages, especially across repeated generation and Hot Reload. The repair
must move deletion to one idempotent Builder-owned routine used by both the
destructor and LEGACY early cleanup. It must not remove the native syntax tree
or conflate its transient lifetime with the retained Canonical snapshot.

The permanent Standalone architecture gate first failed **0/1** on the three
missing ownership facts. The repair adds one idempotent
`asCBuilder::ReleaseParsers()` routine, calls it from Builder destruction on
every route, and keeps LEGACY's eager post-compile release through that same
routine.

Fresh GREEN evidence after the repair:

- focused Standalone Architecture **1/1 PASS**;
- complete Standalone Debug CTest **20/20 PASS**;
- Runtime/Editor build **PASS**, 186/186 actions at
  `Saved/Build/cta-parser-lifetime-green-build/20260827_211820_226_d38fc24c/RunMetadata.json`;
- repeated real CANONICAL compilation/TypedAST generation **1/1 PASS** at
  `Saved/Tests/cta-parser-lifetime-green-repeat-generation/20260827_212202_430_097fe78e/RunMetadata.json`;
- final explicit Cutover **12/12 PASS** at
  `Saved/Tests/cta-parser-lifetime-green-cutover-final/20260827_212626_867_9428d09d/RunMetadata.json`.

Full RED, implementation, GREEN and non-claim record:
`attachments/canonical-parser-lifetime-gate-2026-08-27.md`.

## CTA-GATE-01 — Cutover test asserted the future default during transitional LEGACY phase

**Status:** Resolved and verified; final Task 10.2 default flip remains open.

After the Parser lifetime repair, the first complete Cutover run reported
**11/12 PASS**. The sole failure was
`DefaultPipelineIsCanonicalReadyRejectsDualAndRetainsLegacyOptOut`; it created
a new Engine and required the default to be CANONICAL. Current product source,
Standalone architecture tests, CTA-P0-01, and open Tasks 10.2/10.7 all require
the default to remain LEGACY until the complete action-only/full-language gate
is satisfied. All eleven explicit CANONICAL publisher, snapshot, rollback and
execution tests passed in that same run.

RED evidence:
`Saved/Tests/cta-parser-lifetime-green-cutover/20260827_212108_749_59b95c98/RunMetadata.json`
(12 total, 11 passed, 1 failed).

The test was renamed to
`TransitionalDefaultIsLegacyRejectsDualAndAllowsCanonicalOptIn` and now checks
the actual transitional contract:

1. new Engine selects LEGACY and reports Canonical readiness false;
2. unknown/dual selection is rejected without changing the active pipeline;
3. explicit CANONICAL opt-in succeeds and reports readiness true;
4. explicit LEGACY rollback remains available and reports readiness false.

This is not a permanent claim that LEGACY must always be the default. Task
10.2 must intentionally update the production default and this test together
after Tasks 1–9, 10.3–10.6 and the final cutover gates are complete.

GREEN evidence:

- incremental Runtime/test build **PASS**, 4/4 actions at
  `Saved/Build/cta-transitional-cutover-test-sync/20260827_212608_472_cd1cb8ea/RunMetadata.json`;
- complete Cutover **12/12 PASS** at
  `Saved/Tests/cta-parser-lifetime-green-cutover-final/20260827_212626_867_9428d09d/RunMetadata.json`.

## CTA-S-27 — complete assignment semantics still came from `snAssignment` replay

**Status:** Resolved and verified for the outer assignment composite;
CTA-SEMA-01 remains open for its operand families and statements/bodies.

Before this slice, `ParseAssignment` handed the complete native node to the
generic expression adapter, and Sema rediscovered left/operator/right
structure from `asCScriptNode`. The repair adds pointer-free
`asSAssignExprAction`, carrying exact left/right ExprIds, an owned operator
spelling and copied offsets. Sema validates and applies typed assignment
semantics; Parser binds the returned exact parent identity while preserving
the native tree for LEGACY/reference/recovery.

Complete native assignment cases are now identity-only and fail closed with
`assignment-expression-action-missing`. The action contract first produced a
compile RED at
`Saved/Build/cta-s27-assignment-action-red/20260827_230010_667_f07a63d7/RunMetadata.json`.
The pre-wiring Parser gate then failed **0/1** at
`Saved/Tests/cta-s27-parser-assignment-action-red/20260827_230209_312_b8a5ba95/RunMetadata.json`.

Final evidence is direct action **1/1**, Parser exact/action **1/1**,
SemaAuthority **350/350**, ProductionCodeGen **114/114**, Canonical Semantics
**12/12** and native ScriptNode **32/32**. Parser `ActOnParsedExpr` calls fall
from 14 to 12. Exact paths, operator/range contract, recovery behavior and
non-claims are recorded in
`attachments/canonical-assignment-expression-typed-action-gate-2026-08-27.md`.

## CTA-S27-I1 — generic replay could hide a missing assignment Parser action

**Status:** Resolved in the permanent gate.

The first Parser fixture could still see a valid exact `AssignExpr` before the
dedicated Parser action was wired, because the generic
`ActOnParsedExpr(node, script)` route replayed the three-child native node.
AST-shape assertions alone would therefore have accepted the wrong
architecture.

The fixture now isolates `ParseAssignment` and requires
`BindAssignExprAction(` while forbidding `ActOnParsedExpr(`, in addition to
the direct pointer-free action test, exact AST facts and downstream execution
groups. This source-boundary assertion is a migration guard, not a substitute
for semantic/runtime evidence. It remains necessary until the general replay
entry is physically retired.

## CTA-S-28 — complete binary precedence still came from `snExpression` replay

**Status:** Resolved and verified for the complete flat binary/logical
composite; CTA-SEMA-01 remains open for expression terms, statements and
bodies.

Before this slice, `ParseExpression` handed its flat term/operator sequence to
the generic expression adapter, and Sema rediscovered operator spelling,
precedence, associativity and logical-vs-binary node kind from
`asCScriptNode`. The repair adds pointer-free `asSBinaryExprAction`, carrying
ordered exact operand ExprIds, copied token/spelling pairs and complete
offsets. Sema validates and folds those facts; Parser binds the returned exact
root while preserving the native flat tree for LEGACY/reference/recovery.

Complete native expression cases are now identity-only and fail closed with
`binary-expression-action-missing`. The action-contract build first failed at
`Saved/Build/cta-s28-binary-action-red/20260827_231901_382_1e38604c/RunMetadata.json`.
The pre-wiring Parser gate then failed **0/1** at
`Saved/Tests/cta-s28-parser-binary-action-red/20260827_232155_329_30dc0f50/RunMetadata.json`.

Final evidence is direct action **1/1**, Parser exact/action **1/1**,
SemaAuthority **352/352**, ProductionCodeGen **114/114**, Canonical Semantics
**12/12** and native ScriptNode **32/32**. Parser `ActOnParsedExpr` calls fall
from 12 to 10. Exact paths, precedence/operator contract and non-claims are
recorded in
`attachments/canonical-binary-expression-typed-action-gate-2026-08-27.md`.

## CTA-S28-I1 — generic replay could hide a missing binary Parser action

**Status:** Resolved in the permanent gate.

Before `ParseExpression` was wired to the dedicated action, the exact AST
fixture could already see a correct-looking `1 + (2 * 3)` tree because the
generic `ActOnParsedExpr(node, script)` route replayed the five-child native
node. AST shape alone would therefore have accepted the wrong authority
boundary.

The fixture now isolates `ParseExpression` and requires
`BindBinaryExprAction(` while forbidding `ActOnParsedExpr(`, in addition to
the direct pointer-free action test, exact precedence/identity facts and broad
execution groups. The source assertion is an architectural migration guard,
not a replacement for semantic/runtime evidence.

## CTA-S28-I2 — range-less same-operator direct action can alias a prior fold

**Status:** Resolved and verified.

`ActOnBinaryExpr` currently uses expression kind, source range and operator
spelling as its first interning discriminator. `ActOnBinaryExprAction` derives
each nested fold range from its exact operand expressions and falls back to
the action-wide range when those operand ranges are invalid. A synthetic
direct caller that supplies three or more range-less operands with the same
operator can therefore present the same discriminator to an inner and outer
fold and reuse the prior node without comparing exact children.

The first offset-zero probe passed because `FindExistingExpr` deliberately
disables reuse at source offset zero; it is not RED evidence. The corrected
nonzero fixture failed **0/1** at
`Saved/Tests/cta-s28-i2-same-operator-red2/20260827_234052_056_a01151d3/RunMetadata.json`,
proving the outer fold lost the third operand.

The repair moves binary lookup after conversion normalization and requires
both exact child identities in addition to kind/range/operator. This makes
the action robust for range-less synthetic operands while preserving replay
deduplication after conversions. Final evidence is focused **1/1**,
SemaAuthority **353/353**, ProductionCodeGen **114/114** and Canonical
Semantics **12/12** at the paths recorded in the CTA-S-28 gate attachment.

## CTA-S29-I1 — range-only unary interning aliased nested prefix/postfix stages

**Status:** Resolved and focused-green.

The first direct unary-action behavioral run was **0/1** because `post++`, `~`
and outer `-` shared the complete expression-term range. The old early unary
lookup reused the first node at that range without checking the exact operator
or operand, so the final root did not retain the requested outer operator.

Unary reuse now requires the canonical operator and exact child. Overloaded
unary-call reuse requires exact callee, receiver and child as well. The repair
build exits 0 and the direct pointer-free action fixture is **1/1 PASS**.
Evidence and exact paths are in
`attachments/canonical-unary-expression-typed-action-gate-2026-08-28.md`.

## CTA-S29-I2 — generic `snExprTerm` replay masks the missing Parser action

**Status:** Resolved and verified.

`asSUnaryExprAction` worked when called directly, but `ParseExprTerm` initially
had no `BindUnaryExprAction` route. Generic `ActOnParsedExpr(node, script)`
walked the retained native `snExprTerm` and could manufacture the same visible
`-~Value++` graph. The Parser RED therefore passed all graph/range/native-shape
facts but intentionally failed its source boundary assertion: **0/1**, with
the sole message that `ParseExprTerm` must publish through the dedicated typed
action.

The repair classifies pure prefix/postfix unary terms separately from
member/index/call postfix chains, carries the exact primary identity and copied
operator facts into the action, binds the returned exact parent, and makes
complete pure-unary `InternParsedExprTerm` handling identity-only. No generic
replay fallback remains on that completed CANONICAL family. Final gates are
Parser **1/1**, SemaAuthority **355/355**, ProductionCodeGen **114/114**,
Canonical Semantics **12/12**, native ScriptNode **32/32**, and a successful
Runtime/Editor build. Parser generic callbacks fall from 10 to 9.

This open issue does not change task checkboxes or the reported progress:
**87/125 (69.6%)** mechanical, **about 66%** weighted engineering, **about
38%** default-cutover readiness.

## CTA-S-30 — explicit cast still uses generic Parser replay

**Status:** Resolved and verified for explicit `Cast<T>(expr)`; construct/call
and structural postfix families remain open under CTA-SEMA-01.

The pointer-free `asSCastExprAction` and
`asCSema::ActOnCastExprAction` contract now compile. The incremental build ran
17/17 actions and exited 0 at
`Saved/Build/cta-s30-cast-action-api-green-build/20260828_002158_513_34cb2693/RunMetadata.json`.

The correctly addressed pre-wiring Parser fixture is **0/1 RED** at
`Saved/Tests/cta-s30-cast-parser-prewire-corrected/20260828_002418_434_ed8b382a/RunMetadata.json`.

`ParseCast` now binds exact target/operand/range actions on complete and
eligible recovery routes. Complete `snCast` handling is identity-only and
diagnoses `cast-expression-action-missing` instead of replaying the native
tree. Final focused Parser is **1/1**, SemaAuthority **357/357**,
ProductionCodeGen **114/114**, Canonical Semantics **12/12** and retained
native ScriptNode **32/32**, at the paths recorded in the cast gate
attachment. Parser generic callbacks fall from nine to six.

No OpenSpec parent checkbox or progress percentage is advanced at this
checkpoint.

## CTA-S30-I1 — `float` and `double` are not distinct targets in this Engine

**Status:** Resolved as a fixture-policy error; no production defect found.

The first direct action run failed its different-target non-alias assertion at
`Saved/Tests/cta-s30-cast-action-direct-green-corrected/20260828_002348_985_21539470/RunMetadata.json`.
The fixture used `ActOnQualType("float")` and `ActOnQualType("double")`, but the
test Engine retains the maintained-fork default `floatIsFloat64=true`. Both
spellings therefore resolve to the same canonical `float64` type and may
legitimately reuse the same exact conversion.

The direct test now uses explicit `float32` against the configured `float64`
target and passes **1/1** at
`Saved/Tests/cta-s30-cast-action-direct-green-fixed/20260828_003118_505_e0e40100/RunMetadata.json`.
The first post-wiring Parser run also exposed a hard-coded `float` stable-key
expectation for `Cast<float>`; it now derives the configured key through
`GetResolvedDefaultFloatTypeKey()` and passes **1/1**. These were test-oracle
corrections, not changes to AngelScript float semantics.

## CTA-S31-I0 — incomplete test selector matched zero tests

**Status:** Resolved as runner invocation error; excluded from evidence.

The first direct construct-action command omitted
`FCanonicalASTSemaAuthorityTests` from the fully qualified CQTest path. The
runner exited without exercising the intended method at
`Saved/Tests/cta-s31-construct-action-direct-green/20260828_005031_587_6d1d6286/RunMetadata.json`.
The corrected selector ran the actual method; only that result and its later
fixed rerun are counted. No product code changed for this issue.

## CTA-S31-I1 — direct class fixture assumed `ActOnClassDecl` populates a value type

**Status:** Resolved as fixture-contract error; no production defect found.

The first correctly selected direct action run failed **0/1** before invoking
`ActOnConstructExprAction` because the fixture read `ClassDecl::type` as an
expression-ready value type. This Sema declaration API does not promise that
field; existing direct constructor tests separately intern the canonical
named value type. Failure evidence:
`Saved/Tests/cta-s31-construct-action-direct-green-exact/20260828_005110_187_15d60d37/RunMetadata.json`.

The fixture now owns declaration `T` and independently interns
`asAST_TYPE_VALUE_OBJECT` key `T`. The direct action then passes **1/1** at
`Saved/Tests/cta-s31-construct-action-direct-green-fixed/20260828_005222_721_f15a5c38/RunMetadata.json`.

## CTA-S31-I2 — generic construct replay masked the missing Parser action

**Status:** Resolved and verified.

After the pointer-free action API existed but before `ParseConstructCall` was
wired, the Parser fixture could already observe correct-looking scalar and
object canonical nodes. The old `ActOnParsedExpr(node, script)` route was
still walking `snConstructCall`, re-reading the target/arguments and producing
those facts. The isolated source-boundary assertion therefore supplied the
valid RED: **0/1** at
`Saved/Tests/cta-s31-construct-parser-action-red/20260828_005256_110_f049d065/RunMetadata.json`.

Parser now builds and binds `asSConstructExprAction` from exact child
identities. Complete native `snConstructCall` handling is identity-only and
fails with `construct-expression-action-missing` if that publication is
absent. Final gates are Parser **1/1**, SemaAuthority **359/359**,
ProductionCodeGen **114/114**, Canonical Semantics **12/12** and native
ScriptNode **32/32**. Exact evidence paths are recorded in
`attachments/canonical-construct-expression-typed-action-gate-2026-08-28.md`.

## CTA-S31-B1 — named constructor arguments need the complete call-plan action

**Status:** Open bounded dependency; fails closed without fallback.

The bounded construct action owns ordered positional ExprIds but not argument
names or formal/source/default/hidden origin mapping. Parser therefore rejects
a named-argument wrapper at this boundary instead of silently discarding its
name or asking Sema to replay the native subtree. The ordinary/member/
constructor call migration must introduce one complete call-plan action that
owns argument provenance, receiver, scope, overload result and ABI route. This
does not invalidate the positional construct closure, but it remains part of
open Tasks 4.2, 5.2, 5.3, 5.4, 10.6 and 13.2.

No OpenSpec checkbox changes at CTA-S31: **87/125 (69.6%)** mechanical,
**about 66%** weighted engineering and **about 38%** default-cutover
readiness.

## CTA-S32-I1 — generic ordinary-call replay produced a false-green AST

**Status:** Resolved and verified.

After the pointer-free call action existed but before Parser wiring, the
qualified/named Parser fixture already observed the expected callee, argument
order and literals. Generic `ActOnParsedExpr(node, script)` still entered
`InternParsedCall` and reconstructed the call from retained `snScope`,
`snIdentifier`, `snArgList` and `snNamedArgument` nodes. The isolated
`ParseFunctionCall(bool notifySema)` source assertion was the intended RED:
**0/1** at
`Saved/Tests/cta-s32-call-parser-red/20260828_011200_242_1a0a8465/RunMetadata.json`.

Parser now publishes `asSCallExprAction`, and complete standalone native-call
adaptation is identity-only. The Parser fixture is **1/1 PASS**, the full
SemaAuthority gate is **361/361 PASS**, and the combined secondary gates are
**158/158 PASS** at the paths recorded in the CTA-S32 attachment.

## CTA-S32-I2 — offset-zero snippet fixture had no lexical TranslationUnit

**Status:** Resolved as a fixture-contract error; no production defect found.

The first broad CTA-S32 run failed
`InternParsedCallReusesOffsetZeroUnresolvedCall`. Its snippet helper installed
Sema but never called `ActOnTranslationUnit`; the old generic native adapter
used to synthesize that missing setup, whereas the pointer-free call action
correctly rejected an invalid owner. Product `ParseScript` already creates the
TU before expressions.

The fixture now creates its TU explicitly, proves Parser typed action owns the
offset-zero unresolved call, and then proves the retained `InternParsedCall`
entry can only reuse the exact full-range result. It passes in the focused
**2/2** and full **361/361** runs. No fallback or TU synthesis was added to
the production action.

## CTA-S32-I3 — empty trailing ArgList recovery shell suppressed a recognized construct

**Status:** Resolved and verified.

The first broad CTA-S32 run also failed
`ParserActOnConstructTemporaryBeforeArgListCloseFails`. `FValue(` is parsed as
an ordinary function-call-shaped node because the maintained Parser
deliberately leaves `type()` ambiguity to Sema. At end of input,
`ParseArgList` publishes one empty condition shell; the strict action builder
treated it as a real argument with no exact ExprId and therefore did not
publish the already-recognized zero-argument call prefix. The sealed
constructor, `MaterializeTemporary` and `Cleanup` nodes disappeared.

Parser recovery now omits only the final argument shell when it contains no
authored leaf token at all. A completed prefix such as `G(3` retains its exact
argument and conversions, while malformed authored syntax such as a lone
operator is not silently reinterpreted as zero arguments. The focused
recovery run is **2/2 PASS** and the complete SemaAuthority run is **361/361
PASS**. This repair passes copied values/IDs only and does not restore native
AST semantic replay.

CTA-S32 closes only standalone ordinary calls. Named constructor arguments
remain the bounded CTA-S31-B1 dependency, while receiver sequencing for
member/index/postfix calls remains the next action slice. Progress remains
**87/125 (69.6%)** mechanical, **about 66%** weighted engineering and **about
38%** default-cutover readiness.

## CTA-S33-I1 — structural native-node replay could publish a receiver twice

**Status:** Resolved and verified.

The former `InternParsedExprTerm` adapter iterated the primary and every
postfix stage into a `Sequence`. It contained special receiver-removal logic
for transparent call results, but raw member/index stages could still leave
the previous receiver as an independent sequence element. That shape makes a
side-effectful receiver eligible for double evaluation and also proves the
retained native tree remained a second semantic authority.

The corrected Parser RED failed **0/1** specifically because
`v.Next(1)[2]` had a replay-shaped Sequence instead of an Index that owned the
nested member call:
`Saved/Tests/cta-s33-structural-parser-valid-red/20260828_014347_398_d5689f11/RunMetadata.json`.

Parser now publishes one ordered pointer-free
`asSStructuralPostfixExprAction`. Each member/call/index/unary stage consumes
the immediately preceding exact ExprId; the final term has no receiver copy
in a sibling Sequence. Complete structural adaptation is identity-only, and
the old `InternParsedCall` plus receiver-comparison helpers have been deleted.
Final evidence is focused **4/4**, SemaAuthority **363/363** and secondary
gates **158/158**, at the paths recorded in the CTA-S33 gate attachment.

## CTA-S33-I2 — Canonical Index discarded all but the first `opIndex` argument

**Status:** AST/Sema resolved; multi-argument Bytecode ABI emission remains
open and fails closed.

Maintained LEGACY compilation sends the complete `CompileArgumentList` to
`opIndex`, but the old Canonical adapter lowered only the first argument. The
AST verifier also required exactly two children and CodeGen consumed only
`children[1]`. A multi-argument overload could therefore be selected
incorrectly or silently miscompiled.

CTA-S33 changes the action and Sema contract to retain every argument,
including copied names where applicable, resolve against the complete vector,
and publish Index as base plus all argument children. The verifier now accepts
base plus one-or-more arguments. Current CodeGen explicitly rejects a shape
other than base plus exactly one argument; it no longer emits a plausible but
wrong first-argument-only program.

This is deliberately not marked fully resolved. Complete multi-argument
Index Runtime ABI emission, execution and differential coverage remain under
Tasks 9.5/9.7 and block the default switch.

## CTA-S33-I3 — first Parser RED fixture failed before the authority boundary

**Status:** Corrected test design; excluded from RED evidence.

The first fixture combined a handle form with a return/postfix-mutation chain
that the bounded test Engine rejected before the intended structural action
assertion. Its result at
`Saved/Tests/cta-s33-structural-parser-red/20260828_014232_896_6bbacd8f/RunMetadata.json`
is retained only as non-evidence. A valid value-object fixture using
`v.Next(1)[2]` reached the boundary and produced the authoritative RED cited
in CTA-S33-I1. No product semantics were weakened to accommodate the test.

## CTA-S33-I4 — physical replay removal exposed three replay-coupled tests

**Status:** Resolved as required test migration.

After deleting `InternParsedCall`, the first build failed because three test
references still invoked that native-node bridge directly:
`Saved/Build/cta-s33-structural-replay-removed-build/20260828_015144_732_e0cc0dd7/RunMetadata.json`.
The tests now exercise Parser typed-action ownership, a single offset-zero
unresolved call, and same-begin/different-full-range anti-alias behavior.
Production replay was not restored. The follow-up build is green at
`Saved/Build/cta-s33-structural-replay-removed-green-build/20260828_015308_221_259f3d5a/RunMetadata.json`.

## CTA-S33-I5 — migrated test incorrectly invoked one typed action twice

**Status:** Corrected test contract; no product defect found.

An intermediate migrated test called `ActOnCallExprAction` twice and expected
the second active publication to behave like the removed replay adapter. That
assumption failed in a **3/4** run at
`Saved/Tests/cta-s33-structural-replay-removed-focused/20260828_015334_953_c6a1a247/RunMetadata.json`.
The intended contract is one Parser publication followed by exact-identity
reads, not repeated semantic action execution. The obsolete assertion was
removed; the useful full-range anti-alias assertion remains. Final focused
evidence is **4/4 PASS**.

CTA-S33 does not complete an umbrella task row. The recorded ratio remains
**87/125 (69.6%)**. The weighted estimate advances conservatively to **about
67%**, and default-CANONICAL readiness to **about 39%**. Exactly two generic
Parser expression callbacks remain, both for initializer lists.

## CTA-S34-I1 — direct declaration initializer lists bypass `ParseExprTerm`

**Status:** Resolved and verified.

The first focused GREEN attempt showed that missing-`}` declaration recovery
uses `ParseDeclaration -> ParseInitList` directly. Once the `snInitList`
consumer became exact-identity-only, that retained native entry had no typed
action identity and the recovery assertion failed. Parser now publishes the
same pointer-free initializer-list action at direct global/class/local
declaration list sites. It does not restore a generic native-tree replay path.

The initial focused run was **4/6** at
`Saved/Tests/cta-s34-init-list-typed-action-focused-1/20260828_022655_379_6c639bef/RunMetadata.json`;
the direct-entry correction advanced it to **5/6**, and final fixture closure
is **6/6 PASS** at
`Saved/Tests/cta-s34-init-list-typed-action-focused-green/20260828_023334_744_3f274e52/`.

## CTA-S34-I2 — `Identifier = {...}` selects the native typed-list grammar

**Status:** Recorded grammar sharp edge; no Parser semantic change.

The maintained grammar gives `[TYPE '='] INITLIST` priority, so `Box = {4,5}`
produced a typed temporary with target spelling `Box` instead of an anonymous
list assigned to variable `Box`. Diagnostic AST evidence is retained at
`Saved/Tests/cta-s34-init-list-nested-diagnostic/20260828_023132_144_de242c61/RunMetadata.json`.
The source fixture now uses `(Box) = {4,5}` to exercise the anonymous
assignment production. CANONICAL does not perform declaration lookup to
reinterpret the native syntax after parsing.

## CTA-S34-I3 — omitted/default list elements lack a durable Canonical form

**Status:** Open CodeGen/AST breadth dependency; fails closed.

Native Parser/LEGACY accepts `{1,,3}` when empty list elements are enabled.
Canonical AST currently has no node/fact that preserves the default-element
meaning through seal and `EmitListFactoryInto` cannot emit it faithfully.
CTA-S34 retains the omitted action entry long enough to diagnose
`initializer-list-omitted-element-unsupported`, publishes no malformed
Construct and never silently drops the slot. A future CodeGen breadth slice
must define the durable representation and Runtime ABI before enabling it.

## CTA-S34-I4 — nested list AST is complete before list-pattern CodeGen breadth

**Status:** Open backend dependency; unsupported lowering must fail closed.

Nested initializer lists are now exact nested Construct children with selected
target/list-factory facts where applicable. Current Canonical
`EmitListFactoryInto` is still a flat repeat-element emitter, while native list
patterns also cover nested patterns, repeat/repeat-same, wildcard slots,
defaults and default constructors. CTA-S34 therefore closes Parser/Sema
authority but does not claim those forms executable through Canonical CodeGen.

## CTA-S34-I5 — final generic expression replay removal

**Status:** Resolved and verified.

Production Parser/Sema contains zero `ActOnParsedExpr` calls, declarations or
implementations. `snInitList` consumption is identity-only, while
`ParseInitList`, `snInitList`, `asCScriptNode`, Builder, `asCCompiler` and
LEGACY remain intentionally retained. Final evidence is build green,
initializer focus **6/6**, empty/trailing focus **1/1**, SemaAuthority
**367/367**, and ProductionCodeGen + Canonical Semantics + native ScriptNode
**158/158** at the paths recorded in the CTA-S34 gate card.

CTA-S34 completes no umbrella checkbox row, so the mechanical ratio remains
**87/125 (69.6%)**. Weighted engineering completion advances to **about 68%**
and safe default-CANONICAL readiness to **about 40%**. The next authority slice
is declaration adapters plus statement/control/body/default/local-initializer/
lifetime typed actions.

## CTA-S35-I1 — parameter defaults still crossed a completed native node

**Status:** Resolved and verified.

Parameter headers already crossed a pointer-free declaration action, but the
default expression still used `ActOnParameterDefaultFromNode`, and declaration
Sema re-read the completed `asCScriptNode` through `InternParamDefaultExpr`.
That left a declaration-level second semantic authority after generic
expression replay had been removed.

CTA-S35 replaces it with `asSParameterDefaultAction`: exact parameter DeclId,
exact already-published ExprId, copied authored text, copied half-open range and
recovery fact. Sema validates the source contract, makes identical repeats
idempotent and rejects conflicting rebinding before mutation. The old adapter
and helper are physically gone from production, while native
`ParseParameterList`, parameter nodes and LEGACY remain.

Final evidence is the GREEN build, focused **5/5**, SemaAuthority **369/369**
and downstream **158/158** recorded in the CTA-S35 gate attachment.

## CTA-S35-I2 — transparent Parser wrappers do not always own a root ExprId

**Status:** Bounded architectural fact; no product defect found.

For simple default expressions, especially literals, the retained native
assignment wrapper may not itself have an action identity. Parser therefore
cannot require a direct root lookup. It uses the existing exact-identity walk
to accept exactly one distinct action-published descendant and rejects an
ambiguous set. This walk does not inspect or reconstruct expression semantics,
and no node crosses into Sema. It is intentionally retained as transient
Parser identity normalization until all native wrappers publish roots directly.

CTA-S35 completes no umbrella checkbox row. The report remains **87/125
(69.6%)**, **about 68%** weighted implementation and **about 40%** safe
default-cutover readiness. Enumerator/global/local initializer, function/lambda
body, statement/control and lifetime node adapters remain on the critical path.

## CTA-S36-I1 — explicit enumerator values still crossed a native node

**Status:** Resolved and verified.

Although enum/enumerator names were already typed actions, explicit values used
`ActOnEnumeratorInitializerFromNode`. Declaration Sema unwrapped the retained
`snAssignment` and called `ActOnExprFromNode`, leaving a declaration-level
native-node authority and allowing repeat publication to duplicate inits.

CTA-S36 replaces the route with `asSEnumeratorInitializerAction`: exact
enumerator DeclId, exact action-published ExprId, copied half-open range and
recovery fact. Sema validates ownership/source, freezes the exact constant,
makes identical repeats idempotent and rejects conflicting rebinding before
mutation. The old adapter is physically gone. Native Parser/AST/LEGACY remain.

The focused gate also proves that a non-constant expression fails closed: it
diagnoses, adds no init and leaves the provisional implicit value intact. No
unexpected product defect was found. Final evidence is focused **5/5**,
SemaAuthority **372/372** and downstream **158/158** at the paths in the
CTA-S36 attachment.

CTA-S36 closes no umbrella task row. Status remains **87/125 (69.6%)**,
**about 68%** weighted implementation and **about 40%** safe default readiness.
Global/class/local variable initializer adapters, callable bodies, generic
statements/control and lifetime families remain.

## CTA-S37-I1 — field initializer text was a second, lossy semantic form

**Status:** Resolved and verified.

The global/field node adapter called `IntegerInitText`, which recursively found
the first native integer token. A field initialized by `40 + 1` could therefore
carry `defaultArg="40"` next to the authoritative Binary init. This was not a
faithful source spelling or evaluated value and created avoidable ambiguity.

CTA-S37 removes the node adapter and the entire numeric-node text walker.
Fields retain one exact init ExprId. Globals retain the exact init plus their
existing normalized constant text/value required by scalar publication. The
new pointer-free action also makes exact repeats idempotent and rejects a
conflicting rebind.

## CTA-S37-I2 — direct/dynamic global initialization is not backend-complete

**Status:** Open backend breadth dependency; fails closed.

The action contract represents direct construction with ordered exact argument
IDs, and CANONICAL now fully parses the parenthesized form instead of using a
superficial native initializer. Current prepared global publication still
supports scalar constants and the no-initializer value-object lifecycle, not
general dynamic/non-scalar Construct execution. Such global forms remain a
CodeGen/runtime Tasks 9.5/9.7 blocker and must not silently fall back.

CTA-S37 final evidence is focused **5/5**, SemaAuthority **374/374** and
downstream **158/158**, recorded in its gate attachment. No task checkbox row
closes: **87/125 (69.6%)** mechanical, **about 69%** weighted implementation and
**about 41%** safe default readiness. The local declarator/statement adapter is
next.

## CTA-S38-I1 — local declarators retained a hidden expression replay route

**Status:** Resolved and verified.

Local headers already had exact typed DeclIds, but
`ActOnLocalVariableDeclaratorFromNode` still accepted the completed native
initializer. Ordinary initializers re-entered `ActOnExprFromNode`; direct
construction walked native arguments and recreated every expression. This was
a declaration/statement-level second semantic authority after the generic
Parser expression callbacks had been removed.

CTA-S38 replaces the adapter with `asSLocalVariableDeclaratorAction`: exact
local DeclId, explicit initializer kind, exact expression or ordered exact
constructor arguments, copied source range and recovery state. Sema validates
all facts before mutation and owns DeclStmt/init/default-construction statement
publication. The old adapter is physically gone; native Parser/AST/compiler and
LEGACY remain.

## CTA-S38-I2 — typed local initialization is not complete cleanup closure

**Status:** Open statement/lifetime and CodeGen dependency; fails closed.

The action now preserves the exact initializer and uses the existing typed
default-construction/assignment plan, but it does not by itself prove complete
destruction and cleanup placement for value objects across return, loop and
switch transfers or exceptional exits. That work remains under the body,
statement/control, lifetime and detached CodeGen gates. Unsupported cleanup
shapes must not use the retained native AST as fallback semantic authority.

CTA-S38 final evidence is focused **5/5**, SemaAuthority **376/376** and
downstream **158/158**, recorded in its gate attachment. No task row closes:
**87/125 (69.6%)** mechanical, **about 70%** weighted implementation and
**about 42%** safe default readiness. Callable body, statement/control and
lifetime node adapters are next.

## CTA-S42-I1 — an exact control target exists before its final range

**Status:** Resolved for while/do-while/for/foreach; switch remains.

Break and continue need an exact ancestor target while Parser is still inside
the body. At that time the loop's final end coordinate is unknowable. Treating
kind+complete-range as identity therefore either delays target publication or
requires a fragile rediscovery step.

The two-phase action now returns an exact header `StmtId`, pushes it before body
parsing, and expands only that private statement's range at finish time through
the Seal-protected AST Context API. Nested transfers and the finish action both
carry the exact ID. Recovery pops only when that exact ID is the current top;
pre-header recovery creates a non-pushed bounded statement and cannot corrupt
an enclosing loop/switch.

## CTA-S42-I2 — `for` multi-increment replay could lose order or identity

**Status:** Resolved and verified.

The deleted `ActOnForStmtFromNode` walked every native increment child after
parsing and reconstructed expressions through `ActOnExprFromNode`. Parser now
copies each exact increment ExprId into `asSForStatementAction` in source
order. Sema validates the IDs and owns the one/many choice, constructing one
ordered `SequenceExpr` only for the many case. The dedicated node adapter and
its recursive token-span helpers are physically gone.

## CTA-S42-I3 — foreach variable typed action result was discarded

**Status:** Resolved and verified.

`ActOnForeachVariableAction` already returned the correct DeclStmt, but Parser
discarded it. The completed foreach adapter later walked `snDeclaration` to
rediscover the statement. Parser now binds the returned StmtId to its exact
short-lived node, and the finish action passes value/key/range/body IDs directly
to Sema's existing protocol/lifetime lowering.

## CTA-S42-I4 — public AST header invalidation exceeded the first build budget

**Status:** Environment/build-budget issue, resolved without source workaround.

Adding `SetStmtRange` to the shared AST Context header invalidated 168 actions.
The first GREEN build reached the 180-second runner timeout without a compiler
error. Re-running with the supported 600-second budget completed successfully
(144 actions). This is recorded because it can otherwise be mistaken for a
product regression.

CTA-S42 loop evidence is focused **12/12** and SemaAuthority **386/386**;
for/foreach evidence is new **3/3**, regressions **10/10**, and final
SemaAuthority **389/389**, all PASS. RED/build/report paths and the precise
non-claims are in
`attachments/canonical-loop-foreach-typed-action-gate-2026-08-28.md`.

`switch/case/default`, fallthrough-next-case assembly, the temporary
kind/owner/file/start bridge, full lifetime/cleanup closure and backend breadth
remain open. No umbrella task row closes: **87/125 (69.6%)** mechanical,
**about 73%** weighted implementation, **about 46%** safe default readiness and
**about 95%** action-only Sema.

## CTA-S39-I1 — callable attachment could reconstruct an already-built Block

**Status:** Resolved and verified.

The old `ActOnFunctionBodyFromNode` first searched for a Block by range but
could fall back to `InternParsedCompoundStmt`. Function/lambda signatures were
typed, yet the final declaration-body edge could still be derived from a
completed native body.

CTA-S39 replaces this with `asSFunctionBodyAction`, containing exact callable
DeclId, exact function-owned Block StmtId, copied range and recovery state.
Sema validates exact owner/kind/range identity, marks the function-entry safe
point, records captures, supports exact-repeat idempotence and rejects a
conflicting body. The old adapter/helper are physically gone.

## CTA-S39-I2 — statement identity lookup is transitional, not authority closure

**Status:** Open statement/control typed-action dependency; fails closed.

Parser currently obtains the already-built Block through an exact pointer-free
kind/owner/full-range lookup. This removes the body-node boundary, but the
Block and its children are still produced through `ActOnParsedStmt`,
`ActOnStmtFromNode`, `ActOnForStmtFromNode` and compound/child native-node
assembly. The lookup must disappear or become unnecessary as direct statement
actions return exact StmtIds. It is not a replacement for typed statement
actions and cannot be used to claim the semantic-authority gate complete.

CTA-S39 final evidence is focused **5/5**, SemaAuthority **377/377** and
downstream **158/158**. Mechanical progress remains **87/125 (69.6%)**,
weighted implementation **about 70%**, safe default readiness **about 43%**
and action-only Sema **about 85%**.

## CTA-S40-I1 — leaf Parser callbacks still crossed completed native nodes

**Status:** Resolved and verified.

Expression statements, returns, break, continue and fallthrough still called
`ActOnParsedStmt(node, script)`. `ActOnStmtFromNode(snReturn)` additionally
owned value-object transfer cleanup and signature-driven numeric conversion,
so a semantically important return plan was still reconstructed from the
native statement.

CTA-S40 adds `asSLeafStatementAction`: bounded kind, exact callable owner,
optional exact expression, copied source range and recovery state. Parser uses
the action on success and missing-semicolon recovery paths. Sema freezes the
return plan and control-transfer target. The five leaf cases are physically
gone from both generic node adapters; missing typed publication fails closed.

## CTA-S40-I2 — transfer targets still depend on node-based control setup

**Status:** Open loop/switch typed-action dependency; fails closed.

The leaf action itself is pointer-free, but break/continue target selection
still consumes `controlStack`, which is currently populated by
`BeginParsedControl(asCScriptNode*, ...)`. This preserves exact current target
behavior without completing control authority. Loop/switch header actions must
return/push exact control StmtIds before their bodies. Fallthrough's next-case
target and case-order validation remain with the later switch/case slice.

## CTA-S40-I3 — Block assembly still maps native children back to typed leaves

**Status:** Open Block/If typed-action dependency; fails closed.

Each leaf Parser path now receives the exact returned StmtId, but the current
Parser API discards it. `ParseStatementBlock` still invokes generic
`ActOnParsedStmt` for the retained native child, and compound construction
looks up the already-published leaf by kind/range. This no longer replays leaf
meaning, but it remains an identity adapter and cannot be the final
Parser-to-Sema contract. Ordered exact child StmtIds must cross in the Block
action before generic statement replay is removed.

CTA-S40 final evidence is focused **17/17**, SemaAuthority **380/380** and
downstream **158/158**, recorded in its gate attachment. Mechanical progress
remains **87/125 (69.6%)**; weighted implementation is **about 71%**, safe
default readiness **about 44%**, and action-only Sema **about 88%**.

## CTA-S41-I1 — Block/If completed semantics replayed native nodes

**Resolved.** `asSBlockStatementAction` and `asSIfStatementAction` now carry
exact pointer-free AST identities. `ParseStatementBlock` and `ParseIf` publish
those actions directly. Completed `snStatementBlock` and `snIf` semantic cases
are removed from `ActOnParsedStmt` and `ActOnStmtFromNode`.

## CTA-S41-I2 — structured parents needed exact child statement identity

**Resolved for migrated statements.** Parser now keeps a short-lived local
native-node-to-`StmtId` binding table. It connects already-published typed
children to enclosing typed actions without sending a native pointer across
the Sema boundary. Local declaration sequences are explicit construction
carriers and are flattened only by the Block action.

## CTA-S41-I3 — completed ranges did not match early control stubs

**Resolved as a bounded transition.** The first full SemaAuthority run failed
15 loop/foreach/switch/recovery cases with
`statement-action-identity-missing`. Old control adapters publish a stub before
body parsing, so the final end coordinate differs. The bridge now finds the
unique existing statement by kind/owner/file/start. The 15-case recheck and
full **383/383** suite pass.

## CTA-S41-I4 — remaining controls still cross native adapters

**Open; next critical slice.** `for`, `foreach`, `while`, `do-while`, `switch`
and `case` still use `BeginParsedControl` / `ActOnParsedStmt`. CTA-S42 must add
typed actions for their ordered phases, targets and recovery, then delete the
start-coordinate identity bridge. The bridge is not a durable semantic or
snapshot identity model.

## CTA-S41-I5 — native kind routing still mentions Block/If

**Open transition, not a native-AST deletion request.** `StmtKindForNode` and
`InternParsedCompoundStmt` retain Block/If kind/identity mapping for remaining
compound adapters. This does not restore completed Block/If semantic replay,
but physical removal of the mappings must be reassessed after CTA-S42. The
native AST itself remains intentionally retained.

## CTA-S41-I6 — recovery state is construction-only

**Open design note.** The typed actions copy `recovered`; If uses it to bound a
missing branch, while Block does not persist it as a public AST property. This
is acceptable for the current construction contract but should be revisited
with final diagnostic/recovery metadata closure.

CTA-S41 evidence is focused **8/8**, repaired-control recheck **15/15**, final
SemaAuthority **383/383** and downstream **158/158**, recorded in
`canonical-block-if-typed-action-gate-2026-08-28.md`. Mechanical progress
remains **87/125 (69.6%)**; weighted implementation is **about 72%**, safe
default readiness **about 45%**, and action-only Sema **about 91%**.

## CTA-S42-I1 — remaining loop/switch controls crossed native adapters

**Resolved and verified.** While, do-while, for, foreach, switch, case and
default now use exact two-phase typed actions. Header publication establishes
the exact control target before nested bodies; finish actions fill that same
identity and pop only their owned control. Completed native control nodes are
absent from the generic semantic adapters.

## CTA-S42-I2 — temporary start-coordinate control identity was not durable

**Resolved and physically removed.** `BeginParsedControl` and
`FindStatementActionIdentity` no longer exist in Parser/Sema. Structured
parents receive exact returned StmtIds through Parser-local construction state
and typed action payloads.

## CTA-S42-I3 — switch case order and fallthrough target were implicit

**Resolved.** Case/default actions publish exact ordered child StmtIds and the
switch finish action publishes exact ordered Case StmtIds. Sema validates the
parent target and wires each fallthrough to the next exact case. Default has an
explicit action kind and no invented expression.

## CTA-S42-I4 — removing final native cases left invalid adapter scaffolding

**Resolved; recorded build failure.** The first implementation build failed
C4065 because `ActOnParsedStmt` retained a C++ switch containing only a default
label after the switch/case cases were deleted. It is now a direct fail-closed
delegation. The repaired build, focused tests and all regression gates pass;
no native semantic branch was restored.

## CTA-S42-I5 — control authority is complete but lifetime authority is not

**Open next critical dependency.** Structured control identity, phases and
targets are action-only, but the wider statement umbrella still includes
explicit value lifetime/materialization/cleanup and uncommon body surfaces.
This is why no `tasks.md` umbrella row is checked and why default cutover is
still blocked.

CTA-S42 final evidence is focused **3/3**, switch/control regression **10/10**,
SemaAuthority **392/392**, downstream **158/158**, plus the GREEN build. Exact
paths are in `canonical-switch-case-typed-action-gate-2026-08-28.md`.
Mechanical progress remains **87/125 (69.6%)**; weighted implementation is
**about 74%**, safe default readiness **about 47%**, and action-only Sema
**about 98%**.

## CTA-S43-I1 — CQTest matcher-message placement blocked the first RED build

**Resolved; test-authoring failure retained as evidence.** The first build of
the physical-retirement test failed C4002 because a diagnostic string was
passed as a second `ASSERT_THAT` macro argument instead of through the
`IsFalse` matcher. The corrected build passed and the test then produced the
expected semantic/source-contract **0/1 RED** against the still-present
adapters. The initial build is not counted as the semantic RED.

## CTA-S43-I2 — deleted-method slice tests could pass falsely

**Resolved for the affected adapter tests.** Several source-contract tests
located a method by name, sliced its body and searched only that substring.
After physical deletion the slice could be empty or clamped and therefore
appear green without proving the boundary. They now assert whole-source
absence of `ActOnParsedStmt` or `ActOnStmtFromNode`, and a dedicated test checks
all six retired adapter names while separately proving native Parser AST
construction remains.

## CTA-S43-I3 — one regression test depended on a retired diagnostic route

**Resolved as a test-contract repair.** The first complete SemaAuthority run
was **392/393** because
`ParserLocalLoopVariableFamiliesUseTypedActionsWithoutDeclarationReplay`
expected `local-declaration-action-missing`, text owned solely by the deleted
`ActOnParsedStmt` adapter. The repaired test verifies physical absence of both
the adapter and obsolete diagnostic route. The exact recheck is **1/1 PASS**
and the final full gate is **393/393 PASS**.

## CTA-S43-I4 — residual native-node identity helpers are not replay adapters

**Open bounded semantic-authority audit.** Physical deletion of the six
generic completed expression/statement adapters must not be overstated as
zero native-node input across all Sema construction. Parsed declaration,
expression-type and scope-owner identity/lexical helpers still accept
build-time `asCScriptNode *` values. They are not a fallback that reconstructs
completed expression/statement meaning, but each must be classified, replaced
or explicitly justified before whole-Sema action-only authority can reach
100%.

CTA-S43 final evidence is expected RED **0/1**, final SemaAuthority **393/393**
and downstream **158/158**, recorded in
`canonical-native-sema-replay-adapter-retirement-gate-2026-08-28.md`.
Mechanical progress remains **87/125 (69.6%)**; weighted implementation is
**about 75%**, safe default readiness **about 48%**, and whole-Sema action-only
authority remains conservatively **about 98%**.

## CTA-S44-I1 — lexical value cleanup was implicit in the function epilogue

**Partially resolved for initialized direct lexical value objects.** Sema now
seals distinct reverse-live cleanup statements for normal block exit and every
transfer that leaves the block. CodeGen consumes those statements and prevents
normal-path epilogue double destruction. Deferred/out, global, exception and
suspend/resume lifetime families remain open.

## CTA-S44-I2 — scope-exit cleanup could name the wrong destructor owner

**Resolved for sealed `scope-exit` expressions.** The verifier now requires one
exact variable `DeclRef`, a value-object target, an exact destructor and stable
type-owner equality. The wrong-owner test produced the expected **30/31 RED**
and the complete verifier group is now **31/31 PASS**.

## CTA-S44-I3 — prepared generated destructors had no Runtime shell

**Resolved and kept as a regression.** The first full ProductionCodeGen run
was **114/115**: explicit cleanup could not resolve a generated destructor for
a prepared script value type. The old epilogue had silently skipped it.
Generated accessors and destructors now share one detached pending-object-
function closure and publish only during the aggregate commit. The exact test
asserts `asBEHAVE_DESTRUCT` publication and that entry bytecode calls its ID;
final ProductionCodeGen is **115/115 PASS**.

## CTA-S44-I4 — test selection produced two invalid evidence attempts

**Recorded and excluded.** One invocation used unsupported `-Target` instead
of `-TestPrefix`; another exact CQTest filter omitted the class segment and
selected zero tests. Neither is counted. The stable verifier class prefix
produced the real RED and all final gates use non-empty result counts.

## CTA-S44-I5 — destructor mapping and lifetime breadth remain incomplete

**Partially resolved by CTA-S45; broad cutover blocker remains open.** Direct
initialized owning reference-object and funcdef locals now have a sealed
lexical `scope-release` plan and a real Runtime release route. Deferred/out,
template/container, global init/shutdown, capture ownership, exception edges,
suspend/resume and direct TypedASTJIT/AOT cleanup consumption remain open.
Source `typedef` is primitive-only and is not a reachable value-object
lifetime family. Therefore Tasks 5.7/5.8 and all default-cutover rows remain
unchecked.

CTA-S44 final evidence is SemaAuthority **394/394**, ProductionCodeGen
**115/115**, and downstream **159/159 PASS**, recorded in
`canonical-lexical-value-cleanup-plan-gate-2026-08-28.md`. Mechanical progress
remains **87/125 (69.6%)**; weighted implementation is **about 76%**, safe
default readiness **about 49%**, and whole-Sema action-only authority remains
**about 98%**.

## CTA-S45-I1 — implicit-handle ownership is not encoded by local qualifiers

**Resolved and recorded as a type-model constraint.** The first Sema test
assumed an implicit handle local would carry `HANDLE` or `AUTO_HANDLE`; the
actual sealed local type is `REFERENCE_OBJECT` with zero qualifier bits, while
the factory return carries `AUTO_HANDLE`. Ownership classification therefore
uses the Canonical type kind plus the explicit absence of `REFERENCE`, not
`IsHandle()`/`IsAutoHandle()`. The first qualifier-assumption run is retained
as invalid evidence; the corrected test produced the clean missing-contract
**0/1 RED**.

## CTA-S45-I2 — reference release must not impersonate a destructor call

**Resolved for sealed lexical plans.** `scope-release` deliberately has an
invalid `resolvedDecl`. The verifier rejects a destructor binding and requires
one exact owning reference-object or funcdef variable `DeclRef`. This keeps
reference counting distinct from value-object destruction and prevents a
backend from selecting the wrong ABI route.

## CTA-S45-I3 — normal and transfer cleanup liveness are different

**Resolved for direct lexical releases.** Normal block cleanup releases the
tracked slot and retires its compile-time object entry so the common epilogue
cannot release it again. Transfer cleanup statements are separate AST
identities and do not retire that shared compile-time entry, because their
bytecode belongs to alternate return/break/continue/fallthrough routes. This
matches the existing CTA-S44 value-object control-flow contract.

## CTA-S45-I4 — common epilogue release also missed implicit handles

**Resolved with one shared Runtime classifier.** Canonical CodeGen now treats
explicit handles, funcdefs, and reference objects that are not value objects
as owned-reference slots. Both sealed `scope-release` and common object
destruction use the same `asBC_FREE` plus `asOBJ_UNINIT` helper, avoiding a
second qualifier-only ownership interpretation.

## CTA-S45-I5 — lifetime breadth and direct AOT consumption remain incomplete

**Open cutover blocker.** CTA-S45 closes initialized direct local
reference-object/funcdef release only. Deferred/out values,
template/container ownership, delegates/lambda captures, globals, exception
edges, suspend/resume frames, and direct TypedASTJIT/AOT cleanup visitors still
need explicit sealed contracts and execution evidence. Unsupported families
must remain fail-closed; they must not fall back to native-tree replay or
reintroduce HIR/dump transport.

CTA-S45 final evidence is SemaAuthority **388/388**, ProductionCodeGen
**111/111**, verifier **29/29**, and the combined downstream gate **160/160
PASS**, recorded in
`canonical-lexical-owning-release-plan-gate-2026-08-28.md`. Mechanical
progress remains **87/125 (69.6%)**; weighted implementation is **about 77%**,
Canonical Bytecode/Runtime closure **about 73%**, safe default readiness
**about 50%**, direct Canonical-AST AOT **about 55%**, and whole-Sema
action-only authority remains **about 98%**. The default remains LEGACY.

## CTA-S46-I1 — explicit `@` source handles are disabled

**Observed and excluded from the migration target.** The first default-null
fixture used `Type@ Local`, which this maintained fork rejects before either
compiler can establish comparable semantics. Those runs are retained as
language-surface evidence but are not counted as the clean CANONICAL RED. The
gate does not expand the source language.

## CTA-S46-I2 — host funcdefs require `asOBJ_IMPLICIT_HANDLE`

**Resolved in the shared fixture and recorded as a Runtime registration
constraint.** A registered funcdef is not automatically valid in by-value
local spelling. Its current `asCTypeInfo` must carry
`asOBJ_IMPLICIT_HANDLE`; after adding the flag, LEGACY and CANONICAL accept the
same source. The flag is not persisted as durable numeric TypeId identity.

## CTA-S46-I3 — funcdef/null comparison is not a valid parity oracle

**Observed and excluded.** The maintained LEGACY surface rejected the trial
`funcdef != nullptr` expression. The final parity test therefore proves common
build/execution behavior and separately inspects the sealed null initializer,
release plans, bytecode publisher and zero LEGACY invocations. CTA-S46 does
not add unrelated comparison semantics.

## CTA-S46-I4 — zeroed VM storage did not prove AST initialization

**Resolved AST-first.** VM allocation already clears the pointer slot, which
could hide the empty `Decl.inits` defect in execution-only tests. Sema now
publishes a direct `NullLiteral` and assignment, making initialized-null live
state explicit for detached Bytecode and direct AST AOT as well as the VM.

## CTA-S46-I5 — verifier accepted release without an initializer

**Resolved for `scope-release`.** A forged owning release targeting a
declaration with no initializer now fails with
`scope-release-cleanup-uninitialized` on `asAST_EDGE_DECL_INIT`. Backends no
longer receive malformed permission to release an arbitrary uncleared slot.

## CTA-S46-I6 — remaining lifetime and backend breadth is still open

**Open cutover blocker.** Default-null implicit-handle funcdef locals are now
sealed, verified and executable. Deferred/out values, template/container and
delegate/lambda capture ownership, globals, exception edges, suspend/resume,
complete detached Bytecode metadata and direct TypedASTJIT/AOT cleanup
consumption remain. Unsupported forms must stay fail-closed; native-tree
semantic replay, HIR and dump transport must not return.

CTA-S46 final evidence is verifier **30/30**, SemaAuthority **389/389**,
ProductionCodeGen **112/112**, and the combined downstream gate **161/161
PASS**, recorded in
`canonical-funcdef-default-null-lifetime-gate-2026-08-28.md`. Mechanical
progress remains **87/125 (69.6%)**; weighted implementation is **about 77%**,
Canonical Bytecode/Runtime closure **about 73%**, safe default readiness
**about 50%**, direct Canonical-AST AOT **about 55%**, and whole-Sema
action-only authority remains **about 98%**. The default remains LEGACY; the
native AngelScript AST remains retained and HIR remains deleted.

## CTA-S47-I1 — dead native-node semantic walkers remained in completed Sema units

**Resolved.** `RangeOf`, `NodeText`, `ScopeText`, `ExprRange` and
`ResolveScopeOwner` had no callers but still preserved a physical route for
walking completed `asCScriptNode` structure. They and the unused
`as_scriptnode.h` includes are now removed from declaration/expression/
statement Sema units. A source-architecture test prevents their return while
leaving Parser and LEGACY native-AST ownership intact.

## CTA-S47-I2 — native AST retention and CANONICAL semantic input are separate contracts

**Resolved as an architecture boundary.** The native AngelScript AST remains
available for Parser, LEGACY, recovery, reference and differential testing.
It is not a second semantic IR for CANONICAL Sema. Completed Sema units now
consume copied typed actions, ranges and scope segments without including the
native node definition.

## CTA-S47-I3 — build-local node identity bridges still remain

**Open migration debt.** `as_sema.cpp/.h` still maps exact node pointer or one
unambiguous section/token coordinate to an already-created Canonical
`DeclId`, `ExprId` or `QualType`. These helpers do not walk children or decode
operator/type/call semantics, but Parser action composition, Builder prepared
Runtime shells and LEGACY body reparse still use them. They must eventually be
replaced with pointer-free parse-action identity; deleting them now would
break lambda and target-type reparse association.

## CTA-S47-I4 — the first RED build was invalid test evidence

**Resolved and explicitly excluded.** The initial source-gate test used the
CQTest assertion macro incorrectly and failed to compile with C4002. After
repair, the test binary built and produced a clean **0/1 RED** solely because
the product source retained the native-node walkers. Both paths are preserved
in `canonical-sema-native-node-dependency-audit-2026-08-28.md` so a harness
error is not presented as a compiler defect.

## CTA-S47-I5 — task 13.2 remains open

**Open cutover blocker.** Removing dead walkers does not close the remaining
Parser/Builder identity bridge, body-reparse migration, final AST-first static
matrix or direct backend/AOT coverage. CTA-S47 final evidence is build PASS,
focused **1/1 PASS** and complete SemaAuthority **397/397 PASS**. Mechanical
progress remains **87/125 (69.6%)**, weighted implementation **about 77%** and
whole-Sema action-only authority **about 98%**. LEGACY remains the default;
the native AST remains retained and HIR remains deleted.

## CTA-DOC-01 — embedding migration guide contradicted current implementation

**Resolved and Task 11.4 closed.** The public guide simultaneously claimed
that explicit CANONICAL Build used sealed-AST CodeGen and that production
Build still used `asCCompiler`; it also said HIR oracle types remained. The
current implementation instead keeps LEGACY as the independent compiler
selection, routes explicit CANONICAL through `asCBytecodeCodeGen`, and has
physically deleted HIR while retaining the native AST/Builder/Compiler.

## CTA-DOC-02 — CompileFunction and AST V1 migration rules were incomplete

**Resolved in Chinese-first and English guides.** The notes now cover product
header/version, trailing module slots, `structSize`/`apiVersion`, append-only
views, foreign IDs, retention timing, normal null acquisition, lease/current
generation behavior, detached versus `ADD_TO_MODULE` snapshot policy,
Cache/SaveByteCode/dump separation, stable pointer-free persistence and the
no-concrete-node-ABI rule. An old incomplete V1 vtable layout is explicitly a
rebuild boundary, not a claimed compatible binary.

Evidence and non-claims are recorded in
`embedding-client-canonical-ast-migration-notes-2026-08-28.md`. This closes
documentation only; default cutover, full-language CodeGen, final publisher
audit and native compiler removal remain open.

Task 11.4 final evidence is Module Snapshot **10/10 PASS**, strict OpenSpec
PASS and parent/plugin diff-check PASS. Mechanical progress is now **88/125
(70.4%)**. Weighted implementation remains **about 77%** and the default
remains LEGACY.

## CTA-S48-I1 — a property getter is not an `&out` lvalue

**Resolved for primitive property out.** The first AST-first RED showed
`Fill(GetValue(Box))`: the getter call had already lost the required setter
write-back semantics. Sema now replaces only an exact primitive out-only
property argument with `DeferredOut`, carrying the exact formal type, exact
setter declaration and opaque receiver. Direct local out arguments remain
ordinary lvalues.

## CTA-S48-I2 — receiver evaluation and setter identity were backend-implicit

**Resolved in the sealed graph.** The receiver is wrapped by one
`OpaqueValue` and retained as the sole receiver/child edge. The setter is
matched by sealed owner plus `accessorField` and exact value type, not by
`Get`/`Set` naming. The verifier rejects a forged global-function target with
stable detail `deferred-out-setter`, and the dump publishes setter plus
receiver identity.

## CTA-S48-I3 — the AST Context receiver API initially admitted only calls

**Resolved.** The first implementation failed verification with
`deferred-out-receiver`; the generic `SetExprReceiver` guard only accepted
CALL. An adjacent first patch briefly modified `SetExprCallDispatch` instead.
The corrected contract restores dispatch to CALL-only and permits receiver
edges on CALL or DEFERRED_OUT.

## CTA-S48-I4 — setter calls can overwrite the primary return registers

**Resolved for the bounded family.** CodeGen now captures a non-void primary
result before performing any deferred setter calls. It evaluates and stores
the receiver address once during argument evaluation, passes a primitive
temporary by reference, then invokes the exact setter after the primary call
in reverse-formal order. Primitive non-handle reference returns remain
fail-closed until their alias lifetime is explicit.

## CTA-S48-I5 — two test-fixture failures were not compiler REDs

**Resolved and excluded from product evidence.** A successful Build released
its AST because the test had not selected snapshot retention. After fixing
retention, Engine-global lookup could not find a module-local script type; the
test now uses `Module->GetTypeInfoByName`. A non-unique patch also caused one
invalid C++ test build and was immediately restored. All three attempts and
their corrections are retained in
`canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

## CTA-S48-I6 — deferred/out lifetime breadth remains incomplete

**Open cutover blocker.** CTA-S48 closes primitive generated-property
`T&out`. Non-POD/value-object out, property `&inout`, reference-return
aliasing, exception/suspend lifetime, globals/imports and direct AST AOT
consumption remain. Unsupported forms must stay fail-closed; neither native-
tree semantic replay nor HIR/dump transport may return.

CTA-S48 final evidence is build PASS, focused Sema/verifier and production
**1/1 PASS**, direct local out **1/1 PASS**, complete SemaAuthority **391/391
PASS**, and complete ProductionCodeGen **113/113 PASS**. Mechanical progress
remains **88/125 (70.4%)**; weighted implementation is now **about 78%**,
Canonical Bytecode/Runtime about **74%**, direct Canonical-AST AOT about
**55%**, safe default readiness about **50%**, and action-only Sema authority
about **98%**. LEGACY remains the default; native AST retention and HIR
deletion are unchanged.

## CTA-S49-I1 — cleanup fields existed but production never populated them

**Resolved for verified-empty plans.** Backend/provider diagnostics already
owned pointer-free cleanup, exception, suspend and transfer-coverage fields,
but `BuildSemanticFunctionDiagnostic()` stopped after Canonical-AST
verification. A new same-generation sealed-AST visitor now publishes
`VerifiedEmpty` and complete transfer coverage when the exact structural body
contains no cleanup action.

## CTA-S49-I2 — a zero-selection test command is not RED evidence

**Resolved and excluded.** The first method-shaped prefix omitted CQTest's
generated class segment and selected zero tests. The class prefix selected two
real tests and produced the valid **1/2 RED** at the new production assertion.
Both metadata paths and the exact distinction are retained in
`canonical-aot-cleanup-facts-gate-2026-08-28.md`.

## CTA-S49-I3 — provider lifetime facts must not retain AST ownership

**Resolved for this transport.** Lifetime analysis executes while the existing
generation snapshot lease is alive and returns only enum/bool facts. Provider
bindings, registry snapshots and dump records receive copies; no Context,
Decl, node pointer or lease is stored in the diagnostic result.

## CTA-S49-I4 — verified empty is not non-empty cleanup support

**Open cutover blocker.** Any `CleanupExpr` still leaves the lifetime facts
`Unverified`. Script destructor/scope-release classification, reverse live-only
ordering on every transfer, partial construction, exception regions,
suspend/resume frames, mutable globals/imports, call-site fallback and the
remaining dependency publication stay under Tasks 5.8 and 7.5. Unsupported
families must remain fail-closed.

CTA-S49 final evidence is build PASS, backend dependency **2/2 PASS**,
CanonicalASTMigration **11/11 PASS**, complete TypedASTJIT **40/40 PASS**, and
parent/plugin diff-check PASS. Mechanical progress remains **88/125 (70.4%)**;
weighted implementation stays **about 78%**, direct Canonical-AST AOT becomes
about **57%**, Bytecode/Runtime stays about **74%**, safe default readiness
about **50%**, and action-only Sema authority about **98%**. LEGACY remains the
default; the native AST remains retained and HIR remains physically deleted.

## CTA-S50-I1 — non-empty cleanup facts collapsed to `Unverified`

The sealed Canonical graph already distinguished owning release from exact
destructor cleanup, but the CTA-S49 visitor tracked only whether any cleanup
node existed. Consequently both `scope-release` and `scope-exit` collapsed to
`Unverified` in production diagnostics. CTA-S50 classifies them as `NonEmpty`
and `ScriptDestructor` respectively, while unknown forms remain fail-closed.

## CTA-S50-I2 — classification is not transfer-edge liveness proof

Seeing one valid cleanup action does not prove that every return, break,
continue and fallthrough contains the reverse live-only plan required by its
exited lexical scopes. CTA-S50 deliberately leaves
`bCleanupPlanCoversAllTransfers=false` for every non-empty result. A later
structural liveness pass must compare the sealed scope stack with each transfer
edge; Task 7.5 remains open.

## CTA-S50-I3 — scalar cleanup wrappers are not Runtime cleanup actions

Canonical scalar expressions can carry a `cleanup` wrapper for sequencing and
value-category semantics without a destructor or release. Counting every
`asAST_EXPR_CLEANUP` as a Runtime action would misclassify those functions.
CTA-S50 treats only scalar literal `cleanup` wrappers as transparent and leaves
any unrecognized non-scalar/unbound form `Unverified`.

## CTA-S50-I4 — direct object cleanup was not an HIR-era AOT capability

The deleted HIR-era direct TypedASTJIT cleanup regression covered scalar
control transfers with one explicit empty universal plan. HIR tests for
non-empty, partial construction and script destructors verified compiler
metadata; they did not execute object locals through the native emitter. The
current scalar-only emitter therefore may preserve capability by publishing
truthful facts and falling back per function. Adding native object storage,
construction-live bits, destructor/release routing and exceptional frame
cleanup would be a separate ABI expansion, not a diagnostic repair.

## CTA-S50-I5 — one zero-selection run is excluded

The first test command ran before the new C++ test was compiled and matched
zero tests. It is excluded. After a successful registration build, the valid
RED was **11/12** with only the new `scope-release` assertion failing.

CTA-S50 final evidence is build PASS, adapter and CanonicalASTMigration
**12/12 PASS**, and complete TypedASTJIT **41/41 PASS**. Full detail:
`attachments/canonical-aot-nonempty-cleanup-facts-gate-2026-08-28.md`.

## CTA-S51-I1 — transfer cleanup included an unconstructed later declaration

**Resolved for ordinary lexical blocks.** The Sema pass previously supplied
the full block declaration list to every exiting transfer. A return before a
later cleanup-requiring local therefore received a cleanup `DeclRef` for an
object that was not live and not yet bound, failing Seal with
`unresolved-identifier:Later`. The pass now activates a lifetime only after
crossing its exact direct `DeclStmt` and attaches only the reverse active list.

## CTA-S51-I2 — missing required actions could masquerade as verified empty

**Resolved for the proven lifetime families.** The earlier AOT visitor inferred
`VerifiedEmpty` only from the absence of a cleanup node. A malformed sealed
fixture with a cleanup-requiring local but no normal/transfer plan could
therefore look vacuously safe. The independent structural verifier now derives
the required release/destructor actions from exact declarations and types;
missing or mismatched actions publish `Unverified` and coverage false.

## CTA-S51-I3 — consumer and producer lifetime rules can drift

**Open architecture risk.** Sema authors the plans while the AOT consumer
independently derives expected actions. This prevents blind trust in producer
metadata but duplicates the current type-route rules. New lifetime families
must update both sides and their negative tests. Final closure should expose a
versioned Canonical lifetime protocol or verifier-authenticated protocol
revision without reducing the consumer's structural checks.

## CTA-S51-I4 — special loop/foreach and exceptional lifetime phases are not proven

**Open cutover blocker.** Ordinary block trailing actions and direct transfers
are structurally proven. Standalone loop/foreach phase actions, partial
construction, exception regions and suspend/resume frames remain conservative
`Unverified`/fallback territory. Dedicated source fixtures for every targeted
transfer and special phase are still required.

## CTA-S51-I5 — truthful lifetime facts are not a native object-frame ABI

**Open capability boundary.** The current TypedASTJIT emitter remains a
scalar native backend. Publishing `ScriptDestructor` plus exact transfer
coverage does not implement object storage, construction-live bits,
destructor/release routing or exceptional native-frame cleanup. Such functions
must continue per-function BytecodeJIT/VM fallback until that ABI is designed
and tested explicitly.

## CTA-S51-I6 — the first Sema RED fixture mixed two failure causes

**Recorded and excluded.** The initial fixture returned `Later.Value`, so a
later source use could also explain `unresolved-identifier:Later`. The clean
fixture returned a scalar constant after the declaration and reproduced the
same exact error. Only the clean **0/1 RED** is used as authority evidence; the
initial metadata remains in the attachment for chronology.

CTA-S51 final evidence is build PASS, clean Sema **0/1 RED -> 1/1 PASS**,
AOT coverage **0/1 RED -> 1/1 PASS**, real-source bridge **1/1 PASS**,
adapter **14/14 PASS**, complete SemaAuthority **392/392 PASS**, and complete
TypedASTJIT **43/43 PASS**. Full detail:
`attachments/canonical-aot-reverse-live-only-cleanup-proof-2026-08-28.md`.
Mechanical progress remains **88/125 (70.4%)**; weighted implementation is
**about 79%**, direct Canonical-AST AOT **about 61%**, action-only Sema
**about 99%**, Bytecode/Runtime **about 74%**, and safe default readiness
**about 50%**.

## CTA-S52-I1 — legal foreach fourth cleanup phase was classified but unproven

**Resolved for the exact value-object iterator protocol.** The prior AOT
visitor classified the iterator's script destructor but rejected the fourth
`Foreach` child as an unsupported standalone cleanup, leaving transfer
coverage false. The analyzer now recognizes exactly four children, derives
exactly one generated cleanup-requiring iterator, and requires the fourth
phase to match its declaration/type/destructor identity.

## CTA-S52-I2 — the synthetic iterator initializer is not an ordinary lexical scope

**Resolved.** A value-object iterator is declared in a synthetic initializer
`Block`, but its lifetime spans body and increment. Applying ordinary
block-tail cleanup rules would destroy it before the loop. CTA-S52 traverses
the initializer's authored children while binding the generated iterator to
the enclosing `Foreach` phase.

## CTA-S52-I3 — loop transfers use both lexical children and loop-frame routes

**Resolved for this exact phase.** `break` targeting the foreach enters the
common cleanup label; `continue` targets increment and keeps the iterator
live; normal exhaustion enters the cleanup label; `return` and escaping
transfers use active loop-frame cleanup. The verifier now reasons over exact
target IDs rather than requiring all actions to be duplicated as transfer
children.

## CTA-S52-I4 — producer, verifier and backend lifetime protocols can drift

**Open architecture risk.** Sema authors the fourth child, Bytecode CodeGen
consumes it, and the AOT analyzer independently derives and validates it. This
is safer than blind trust but duplicates protocol knowledge in three places.
Final closure should expose a versioned/verifier-authenticated Canonical
lifetime protocol revision and retain negative structural tests.

## CTA-S52-I5 — partial construction cannot be inferred from ordinary transfer plans

**Open cutover blocker.** Initializer failure requires an exceptional edge and
a precise constructed-live set. A sequence of declarations plus normal or
explicit transfer children is insufficient. The retired HIR tests modeled
this as compiler metadata; a pointer-free Canonical protocol must represent
the failure edge explicitly before AOT can prove it.

## CTA-S52-I6 — exception and suspend facts must not be fabricated

**Open cutover blocker/boundary.** The retired compiler-exception test injected
test-only external region metadata that the current Canonical AST does not
carry. The retired suspend test also established that `asBC_SUSPEND` polling
is not a cooperative resumable state machine. Until explicit Canonical facts
exist, exception regions remain fail-closed and `bHasSuspendState=false`
remains truthful.

## CTA-S52-I7 — a proven cleanup phase is not a native object-frame ABI

**Open capability boundary.** `ScriptDestructor` plus complete transfer
coverage still does not implement native object storage, construction-live
bits, destructor/release invocation or exceptional unwinding. The scalar
TypedASTJIT emitter must continue per-function BytecodeJIT/VM fallback for
these functions.

CTA-S52 final evidence is build PASS, focused **0/1 RED -> 1/1 PASS**, adapter
**15/15 PASS**, production object-iterator CodeGen **1/1 PASS**,
SemaAuthority **392/392 PASS**, and complete TypedASTJIT **44/44 PASS**. Full
detail:
`attachments/canonical-aot-foreach-lifetime-phase-proof-2026-08-28.md`.
Mechanical progress remains **88/125 (70.4%)**; weighted implementation stays
**about 79%**, direct Canonical-AST AOT is **about 63%**, action-only Sema
**about 99%**, Bytecode/Runtime **about 74%**, and safe default readiness
**about 50%**.

## CTA-S53 static review checkpoint — Clang lifetime comparison

This checkpoint began as a record-only static review. The B2 lifetime
architecture was approved on 2026-08-28 and is now normative in the OpenSpec;
it is not implemented by this documentation update. This checkpoint does not
change the Sidecar schema, close an umbrella task, switch the product default,
remove the native Parser AST, or restore HIR.
Task 7.8 is reconciled closed from existing physical-retirement evidence and
Tasks 15.1-15.11 make the approved implementation work explicit, producing a
mechanical record count of **89/136 (65.4%)** without changing weighted
implementation readiness.
The complete evidence and alternatives are recorded in
`reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md`.

## CTA-S53-I1 — the Clang cleanup analogy conflated three distinct layers

**Resolved in the OpenSpec record on 2026-08-28.** Clang AST stores resolved construction,
temporary, destructor, materialization and lifetime-extension facts; its
Analysis CFG is an optional derived projection; its EH/normal cleanup stack is
backend-local CodeGen state. Clang does not serialize a fully expanded
initializer-abort cleanup list on every AST edge. `design.md`, the spec deltas
and `attachments/llvm-ast-architecture.md` now preserve those three layers.

## CTA-S53-I2 — publication verification is weaker than AOT lifetime proof

**Open correctness blocker.** `Seal()` and publication verification validate
individual cleanup expression shape but do not prove the complete reverse,
live-only, exactly-once normal/transfer plan. Bytecode consumes that weaker
state while TypedASTJIT privately performs the stronger proof. One sealed AST
can therefore be accepted by Bytecode and rejected by AOT.

## CTA-S53-I3 — local lifetime activation occurs after the declaration statement

**Open partial-construction blocker.** Canonical local lowering emits a
`DeclStmt` followed by an exact initializer `Assign ExprStmt`. VM `asOBJ_INIT`
is emitted only after construction/copy succeeds, but the AOT lifetime proof
currently activates the object when it visits the earlier `DeclStmt`. A failed
initializer must not make the current object live or run its destructor.

## CTA-S53-I4 — base/member/array construction needs committed-prefix state

**Open partial-construction blocker.** Constructor init expressions are
ordered, but there is no shared step-level activation/exception plan. On step
N failure only successfully committed steps 0..N-1 may be destroyed in reverse
order; the failed step and later steps are not live. Arrays additionally need
a pointer-free progress count/cursor, and complete-object destruction is legal
only after a distinct complete-construction commit.

## CTA-S53-I5 — positional and string cleanup encoding is not a durable protocol

**Approved architecture boundary; implementation remains open.** `"scope-exit"`, `"scope-release"` and the foreach
fourth child are independently decoded by Sema, verifier, Bytecode and AOT.
The approved correction is a named, versioned, snapshot-owned Canonical
lifetime protocol containing exact action, activation, region and phase facts,
plus a shared deterministic transient derived lifetime/control view. The
implementation and negative-test plan is Tasks 15.1-15.11; current encodings
remain migration inputs until exact equivalence is proven.

## CTA-S53-I6 — the derived view must not become a renamed HIR

**Resolved on 2026-08-28 by Task 15.5.** `asCASTLifetimeView` is the single
transient/rebuildable owner for typed scope edges, authenticated record
ordinals, committed-live sets and reverse live-only cleanup. It follows exact
Sema-authored snapshot IDs and verifies their structural/type relationship;
it performs no name/overload/destructor selection, AST mutation or backend
lowering. The view has no Context setter, DTO, encode/decode or publication
surface and does not enter Cache, Provider, detached artifacts or dump
transport. Backend labels, slots, cleanup/EH stacks and frame ABI remain
backend-local. Repeated reconstruction, nested scopes, wrong/duplicate/
foreign facts and a dedicated dump-independent `LTV1` digest are covered by
Verifier; evidence: `canonical-lifetime-derived-view-gate-2026-08-28.md`.

## CTA-S53-I7 — `asCASTContext` ownership and ID admission are under-specified

**Resolved on 2026-08-28 by Tasks 15.1 and 15.2.** Task
15.1 made the raw arena owner explicitly noncopyable/nonmovable and made every
const/mutable Decl/Stmt/Expr/Type Context lookup reject nonzero public
`snapshotOwner` values. The AST-first gate moved from exact **6/8 RED** to
focused **8/8 PASS**; Runtime/Editor build and complete Frontend CanonicalAST
**154/154 PASS** also passed. Public snapshot adapters retain the separate
responsibility to validate their token before converting a public ID to the
owner-zero internal coordinate. Evidence:
`canonical-lifetime-context-admission-gate-2026-08-28.md`.

Task 15.2 then replaced the overloaded boolean with the ordered, adjacent and
one-shot `Building -> SemaFinalized -> LifetimePlanned ->
Frozen/Publishable` state contract. Skipped, repeated, stale and post-freeze
mutation attempts fail closed. Verifier, Module/Cache, Sidecar encode,
Bytecode, StaticJIT snapshotting and TypedASTJIT now use `IsPublishable()` as
their only Canonical consumer admission predicate; Sidecar decode is the
construction inverse and accepts only a fresh `Building` target before
completing the same lifecycle. Runtime/Editor build, Frontend **156/156**,
Sidecar **22/22** and TypedASTJIT CanonicalASTMigration **16/16** all pass.
Evidence: `canonical-lifecycle-admission-gate-2026-08-28.md`.

This closes the ownership/state/admission issue only. Task 15.3 subsequently
made `LifetimePlanned` carry revisioned snapshot-owned lifetime records;
Tasks 15.4 and 15.5 now author success-sensitive local facts and authenticate
the shared derived view. Compatibility parity and backend-only consumption
remain open under 15.6-15.10.

## CTA-S53-I8 — diagnostic rendering currently influences compiler provenance

**Partially resolved by Tasks 15.3 and 15.5; broader Bytecode issue remains
open.** Lifetime protocol identity now uses fieldwise typed hashing, and the
derived view uses its own `LTV1` typed structural domain. Both are independent
of `asCASTDump()` and covered by deterministic tests/source scans. Bytecode
still computes a broader Canonical digest from rendered dump text; removing
that unrelated compiler-provenance dependency remains required by 15.11 and
the final default-cutover gate.

## CTA-S53-I9 — status and capability non-claims

**Recorded.** HIR remains physically deleted. The native `asCScriptNode`
Parser AST, Builder and `asCCompiler` remain available behind explicit LEGACY
selection. Product default remains LEGACY. A truthful lifetime protocol does
not by itself implement native object-frame storage/destruction ABI, full
exception/abort/timeout/suspend semantics, or close Tasks 5.7, 5.8, 7.5, 9.5
or 9.6.
