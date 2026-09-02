# Canonical lexical owning-handle release gate (2026-08-31)

Sema already authors three `scope-release` Cleanup encodings for
`CTrackedHandle Object = MakeTrackedHandle()` (one normal exit, two returns).
The remaining failure is CodeGen: `Object.Value` PSF-addresses the handle
slot, assignment `CopyVar`s two live counted pointers, and transfer cleanup
does not retire `objects[].live`, so the epilogue `FREE`s the same object
again.

This advances `5.7`, `5.8`, `5.9`, `9.5`, and `13.6` for one lexical REF
implicit-handle family. It does not close those umbrellas, list factories, or
native factory selection.

### Gate card: lexical owning-handle local is a pointer slot with one sealed release

- **OpenSpec task(s):** `5.7`, `5.8`, `5.9`, `9.5`, `13.6` (slice)
- **Source fixture:** `int RunOwnedHandleCleanup(const bool Early)` with
  `CTrackedHandle Object = MakeTrackedHandle(); return Object.Value;` on both
  early and fallthrough exits. Native surface is `asOBJ_REF | asOBJ_IMPLICIT_HANDLE`
  with AddRef/Release/factory. Test method
  `CanonicalLexicalOwningHandleExecutesSealedReleasePlansExactlyOnce`.
- **Canonical fact:** three sealed `CLEANUP` `"scope-release"` encodings target
  `Object`; CodeGen consumes `RELEASE_REFERENCE` exit plans; `DECL_REF` of a
  non-reference handle is a PshVPtr slot, not PSF of pointer storage; owning
  assign is `REFCPY` (or move), not `CopyVar`; sealed `FREE` retires
  `objects[].live` so epilogue does not emit a second `FREE`.
- **AST test:** ProductionCodeGen method above in
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`. The method already
  asserts the three sealed plans before execute; execute then requires
  `FINISHED` + return `42` and balanced AddRef/Release.
- **AST-red:** focused prefix
  `...ProductionCodeGen.FCanonicalASTProductionCodeGenTests.CanonicalLexicalOwningHandle`
  `cta-owning-handle` `20260831_203623_934_da0a1c87`. Build succeeds; execute
  at the method's `FINISHED`/`42` assertion fails.
- **AST-green:** same prefix `cta-owning-handle` `20260831_205912_615_6cc51baf`
  **1/1**. Repair: `EmitLValueAddress` returns the handle `DECL_REF` slot;
  owning assign uses `REFCPY`; sealed `FREE` retires `objects[].live`.
- **CodeGen/provenance:** `as_bytecode_codegen.cpp` `EmitLValueAddress` `DECL_REF`,
  handle `ASSIGN`, `EmitOwnedReferenceRelease` / transfer `EmitExitPlan`.
- **Lifecycle:** N/A.
- **Focused regression:** implicit-handle prvalue receivers stay 2/2
  (`cta-implicit-handle` `20260831_210143_130_11bb9d3c`). Full ProductionCodeGen
  `cta-ast-first-codegen` `20260831_210231_401_c5b5ef43` **196/196**. SemaAuthority
  `cta-ast-first-sema` `20260831_210925_209_182346b4` **474/474**. This card
  does not close 5.7/5.8/5.9/9.5/13.6.
- **Remaining boundary:** nested/omitted list-pattern CodeGen, exception/suspend
  tables, product-default cutover.
