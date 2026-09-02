# TypedASTJIT canonical-only input boundary — 2026-08-24

> Historical transition snapshot. CTA-HIR-03 subsequently physically deleted
> the Editor HIR dump command/Commandlet; remaining unit-test HIR oracles and
> TypedASTJIT compatibility paths are still scheduled for deletion under Task
> 10.5. See `hir-editor-dump-retirement-gate-2026-08-27.md`.

## Outcome

The production TypedASTJIT eligibility, call-closure, backend graph, StaticJIT
generation snapshot, and Editor generation-dump path now consume the sealed
canonical AST only. A structurally valid legacy HIR without an exact sealed
canonical function declaration fails closed. Legacy HIR remains available only
as an explicitly selected unit-test oracle compiled beneath
`WITH_ANGELSCRIPT_UNITTESTS`.

```text
production source generation
        |
        v
sealed canonical AST + exact function DeclId
        |
        +--> TypedASTJIT eligibility / call closure / emission
        |
        +--> generation snapshot / developer deterministic dump

valid HIR without canonical AST --------------------X fail closed

unit-test-only legacy capability oracle
        |
        +--> WITH_ANGELSCRIPT_UNITTESTS
        +--> bUseLegacyTypedHIRForTesting == true
```

## AST-first gate

- Test source:
  `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp`
- Exact method:
  `HirOnlyProductionEligibilityFailsClosedWithoutCanonicalAst`
- Fixture facts:
  a valid integer-return HIR with valid source spans and an explicit verified
  empty cleanup plan is passed to the production evaluator without a canonical
  AST.
- RED:
  `Saved/Tests/cta-typedastjit-hir-only-red-final-fixture/20260824_200106_478_c5709b84`
  — `0/1 PASS`; the old evaluator incorrectly accepted HIR-only input.
- GREEN:
  `Saved/Tests/cta-typedastjit-hir-only-canonical-boundary-green/20260824_201223_246_c086bd99`
  — `1/1 PASS`; production now rejects the same valid HIR-only input and reports
  the missing canonical AST boundary.

## Production boundary changes

- Removed `TypedHIR` from `FAngelscriptTypedASTJITEligibilityInput` production
  shape. The only remaining HIR pointer/selection flag is inside
  `WITH_ANGELSCRIPT_UNITTESTS` and must be explicitly opted into.
- Production `EvaluateAngelscriptTypedASTJITEligibility` always evaluates the
  canonical Decl/Type/Stmt/Expr graph after root validation.
- The HIR eligibility evaluator is an explicitly named test oracle rather than
  a fallback selected by absence of canonical input.
- Call-closure traversal uses the exact canonical function declaration. Its HIR
  traversal is compiled and selected only for the explicit unit-test oracle.
- Removed `VerifiedTypedHIR` pointers from the official generation function and
  compiled-function view structures.
- StaticJIT graph compatibility diagnostics report `bHasVerifiedTypedHIR=false`;
  the generation graph no longer scans or retains HIR pointers.
- The compatibility-named `AngelscriptHIRDump` command now captures
  `VerifiedCanonicalAST`, emits deterministic canonical AST text/JSON, and no
  longer includes `as_typed_semantic_ir`, calls `GetTypedSemanticFunction()`, or
  emits `normalizedHIR`. The dump schema revision advanced from 2 to 3. The
  command/file names are retained temporarily as external-entry compatibility
  aliases; they are not evidence of a live HIR payload.

## Verification

- Runtime/Editor/plugin build:
  `Saved/Build/cta-typedastjit-canonical-only-boundary-final/20260824_201841_677_d464db6d`
  — PASS (`Result: Succeeded`); this is the final incremental build after
  source-format cleanup. The earlier full boundary build also passed at
  `Saved/Build/cta-typedastjit-canonical-only-boundary-green/20260824_201135_718_018eeb30`.
- Full CanonicalASTMigration adapter group:
  `Saved/Tests/cta-canonical-ast-migration-hir-boundary-green/20260824_201406_981_1393251d`
  — `15/15 PASS`.
- TypedASTJIT eligibility and direct-call closure:
  `Saved/Tests/cta-typedastjit-eligibility-canonical-only-green/20260824_201455_992_15ecd17d`
  — `30/30 PASS`.
- Deterministic generation dump compatibility group:
  `Saved/Tests/cta-hirdump-canonical-ast-payload-green/20260824_201301_355_88739bd8`
  — `5/5 PASS`.

## Remaining HIR deletion work

This checkpoint closes production TypedASTJIT and generation-dump reads; it
does not yet complete physical HIR deletion. The maintained compiler still has
typed-semantic-IR builder/storage/accessor code and historical compiler/cache
tests. Final Task 10.5 requires migrating or deleting those oracles, removing
the capture/builder/accessor implementation, and renaming stable fallback/
diagnostic categories that still contain `TypedHIR` for compatibility.
