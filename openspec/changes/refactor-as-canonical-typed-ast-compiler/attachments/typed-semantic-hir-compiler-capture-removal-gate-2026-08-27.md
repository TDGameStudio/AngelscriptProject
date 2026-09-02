# CTA-HIR-05 — TypedSemantic compiler-capture removal gate (2026-08-27)

## Outcome

The function-local `asCTypedSemanticIRBuilder` and every HIR hook in
`as_compiler.h/.cpp` have been physically removed. The change deletes 3,763
lines from `as_compiler.cpp` and 23 lines from `as_compiler.h` relative to the
current plugin HEAD while preserving the later LEGACY invocation counter,
Canonical publisher observation, diagnostic source mapping, and lambda parser
layout fix.

This is deliberately asymmetric: native `asCScriptNode`, `asCBuilder`,
`asCCompiler`, and `asCOMPILER_PIPELINE_LEGACY` remain. Only the later HIR
capture injected into `asCCompiler` was removed.

## Method and preservation boundary

HIR was introduced by plugin commit `ed22fbd` (`[StaticJIT] Feat: add
typed-semantic HIR and TypedASTJIT backend`). Its exact `as_compiler` hunks were
reversed one at a time through `apply_patch`. Of 107 `as_compiler.cpp` hunks,
106 applied; the only rejected hunk was the include block because later work
had added `as_module.h`. The rejected hunk contained no remaining HIR include,
and the final compiler scan is zero. All five `as_compiler.h` hunks applied.

This avoided replacing `asCCompiler` with the pre-HIR file wholesale and kept
post-HIR Canonical/LEGACY fixes that are not part of HIR ownership.

## RED → GREEN evidence

- RED build:
  `Saved/Build/cta-hir-delete-compiler-capture-check/20260827_185803_475_618fd2f2/RunMetadata.json`
- The Runtime module compiled and linked. The only compile error was the
  HIR-only `AngelscriptNativeTypedSemanticIRExpressionContextTests.cpp`, which
  asserted the now-deleted `asCExprContext::typedSemanticExpression` field.
- That test represented only the removed HIR carrier field; it was physically
  deleted rather than relabelled as Canonical AST coverage.
- GREEN build:
  `Saved/Build/cta-hir-delete-compiler-capture-green/20260827_185829_260_87cda3ca/RunMetadata.json`
- `AngelscriptProjectEditor Win64 Development` passed, including Runtime,
  Editor/test module compilation and linkage.

## Current scans

- HIR terms in `as_compiler.h/.cpp`: **0**.
- `asCTypedSemanticIRBuilder` files under `Source`/`Standalone`: **0**.
- Remaining file counts are still non-zero: `asCTypedSemanticFunction` 77,
  `GetTypedSemanticFunction` 54, `captureTypedSemanticIR` 2,
  `VerifiedTypedHIR` 21, and broad `TypedSemanticIR` 83.

These remaining matches are the next deletion frontier: ScriptFunction
storage/accessors, Engine configuration, TypedASTJIT legacy overloads/oracles,
diagnostic/Provider compatibility fields, Standalone target wiring, and old
HIR tests.

## Problems encountered

1. Treating the HIR introduction commit as a whole revert would also remove
   the TypedASTJIT product and unrelated StaticJIT work. The removal therefore
   used exact compiler-file hunks only.
2. One reverse hunk rejected because the current include context legitimately
   contains a later `as_module.h` include. It was not forced; a corrected
   direct scan proved no HIR include or symbol remained.
3. The first build failed in an obsolete HIR carrier-field test, not Runtime.
   Restoring the field would have preserved the wrong architecture, so the
   HIR-only test was deleted and the same build gate rerun.

## Non-claims

- Task 10.5 is not complete.
- `asCTypedSemanticFunction` and its function-owned storage/accessors still
  exist at this checkpoint.
- TypedASTJIT still has HIR-named compatibility/test APIs and many old tests.
- The Canonical compiler is not yet the default.
- The native AngelScript AST/Parser/Builder/Compiler is intentionally retained
  and is not part of the HIR forbidden-symbol count.

