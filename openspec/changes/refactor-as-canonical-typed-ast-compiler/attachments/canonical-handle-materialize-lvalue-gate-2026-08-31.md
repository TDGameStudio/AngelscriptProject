# Canonical implicit-handle prvalue lvalue receiver gate (2026-08-31)

Sema may seal `MakeTrackedHandle().Step()[1].Value` as MEMBER_REF / GetX on a
`MaterializeTemporary` or CALL whose QualType is an implicit object handle.
CodeGen `EmitLValueAddress` previously accepted only non-handle VALUE
storage (`PSF` + `PopRPtr`). A handle prvalue already stores the object
pointer in the evaluation slot; `EmitMember` `PshVPtr`s that slot.

This advances `5.9` / `9.5` / `13.6` for one handle-receiver family. It does
not close those umbrellas, list factories, or native factory selection.

### Gate card: handle MaterializeTemporary/Call is a valid member receiver

- **OpenSpec task(s):** `5.9`, `9.5`, `13.6` (slice)
- **Source fixture:** `return MakeTrackedHandle().Step()[1].Value;` plus the
  native-exception unwind variant in
  `CanonicalImplicitHandleReceiverIsReleasedDuringNativeExceptionUnwind`.
- **Canonical fact:** the sealed graph keeps the handle temporary and the
  exact `Value` field (or GetX) on that receiver; CodeGen must not fail with
  `invalid materialized lvalue receiver ... typeKey=CTrackedHandle`.
- **AST test:** SemaAuthority is not the owner; ProductionCodeGen methods
  `CanonicalImplicitHandleCallResultsAreReleasedAfterExpressionUse` and
  `CanonicalImplicitHandleReceiverIsReleasedDuringNativeExceptionUnwind` in
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
- **AST-red:** ProductionCodeGen `cta-ast-first-codegen`
  `20260831_202647_790_1f6cdc65`, **188/196**, FailAt former line 5526
  `invalid materialized lvalue receiver function=Entry() typeKey=CTrackedHandle`.
- **AST-green:** focused prefix
  `...ProductionCodeGen.FCanonicalASTProductionCodeGenTests.CanonicalImplicitHandle`
  `cta-implicit-handle` `20260831_203537_181_c5d37f11` **2/2**.
- **CodeGen/provenance:** `as_bytecode_codegen.cpp` `EmitLValueAddress`
  returns `EmitExpr` for handle MaterializeTemporary and handle CALL results.
- **Lifecycle:** N/A (no Cache/snapshot identity).
- **Focused regression:** full ProductionCodeGen still has factory/list/owning-handle
  failures; this card does not cover them.
- **Remaining boundary:** lexical owning-handle scope-release execution,
  native factory selection, list-pattern `{41}` Marker payload.
