# CTA-S50 — Canonical AOT non-empty cleanup-facts gate

Date: 2026-08-28

## Outcome

TypedASTJIT lifetime diagnostics now distinguish the two exact non-empty
lexical cleanup families already sealed by Canonical Sema:

- `scope-release` publishes `NonEmpty`;
- `scope-exit`, or another cleanup action bound to an exact destructor,
  publishes `ScriptDestructor`.

Scalar `cleanup` wrappers remain transparent lifetime/value-category facts and
do not manufacture a Runtime cleanup action. An unrecognized non-scalar or
unbound cleanup form remains `Unverified`. Non-empty classification does not
set `bCleanupPlanCoversAllTransfers`: reverse live-only transfer coverage still
needs an independent structural proof.

This advances OpenSpec Task 7.5 but does not close it. It does not add object
locals to the current scalar-only TypedASTJIT C++ ABI, and it does not claim
partial-construction, exception-cleanup, suspend/resume, mutable-global/import,
call-fallback or complete Provider-dependency closure.

## Architecture finding

The Canonical compiler already has the source-semantic cleanup protocol:

```text
Parser typed actions
    -> Canonical Sema lexical lifetime stack
        -> scope-exit    (value object + exact destructor DeclId)
        -> scope-release (owned ReferenceObject/FuncDef + exact local DeclRef)
        -> reverse live-only copies on return/break/continue/fallthrough
    -> verifier checks target/type/destructor/initializer
    -> Canonical Bytecode emits CALL or FREE and retires normal-path state
```

The missing edge was in the direct Canonical-AST TypedASTJIT visitor. CTA-S49
could prove only `VerifiedEmpty`; every non-empty action remained
`Unverified`, even though the sealed graph already distinguished release from
destruction.

The current TypedASTJIT emitter is intentionally scalar-only:

- local declarations must have a reviewed scalar C++ spelling;
- the VM bridge ABI accepts reviewed by-value primitive scalars;
- value-object/reference-object local storage, construction-live state,
  destructor/release entry routing and exceptional native-frame cleanup are
  not present.

The retired HIR-era direct TypedASTJIT cleanup regression supported only an
explicit **empty** universal cleanup plan for scalar transfers. Non-empty,
partial-construction and script-destructor cases were compiler/HIR semantic
metadata oracles, not proof that the old native emitter executed object
cleanup. Therefore this change should preserve current capability by deriving
the corresponding facts from sealed AST and failing closed to BytecodeJIT/VM
for object lifetime forms. Expanding direct native object-local eligibility is
a separate ABI capability decision, not a prerequisite that may be inferred
from a diagnostic enum.

## Implementation

`FCanonicalLifetimeFactsVisitor` now classifies cleanup nodes while walking the
exact function body through `asCASTTraverse`:

1. `scope-release` records a release action;
2. `scope-exit` or an exact resolved destructor records a destructor action;
3. a scalar `cleanup` wrapper records no Runtime action;
4. any other cleanup form makes the result fail closed as `Unverified`;
5. destructor state takes precedence if a body contains both destruction and
   release actions;
6. only a body with no Runtime cleanup actions is `VerifiedEmpty` with complete
   transfer coverage.

The result stays pointer-free and is consumed by the existing CTA-S49
backend/provider diagnostic-copy route while the snapshot lease is alive.

## TDD evidence

### Invalid selection, excluded

The first command ran before the new C++ test had been built and selected zero
tests. It is not RED or implementation evidence:

`Saved/Tests/cta-s50-aot-nonempty-cleanup-facts-red/20260828_133824_542_4d1b3808/RunMetadata.json`

### Clean RED

After the test-registration build, the adapter class selected twelve real
tests. Eleven passed; the new method failed only because the exact
`scope-release` plan remained `Unverified`:

```text
total=12 passed=11 failed=1 skipped=0
```

Evidence:

- registration build PASS:
  `Saved/Build/cta-s50-aot-nonempty-cleanup-facts-red-build/20260828_133901_565_5e53205c/RunMetadata.json`;
- clean RED:
  `Saved/Tests/cta-s50-aot-nonempty-cleanup-facts-red-class/20260828_133934_526_c5eabfcb/RunMetadata.json`.

### GREEN and regressions

- Runtime/Editor build: PASS
  - `Saved/Build/cta-s50-aot-nonempty-cleanup-facts-green-build/20260828_134321_125_3e38d294/RunMetadata.json`
- adapter class: **12/12 PASS**
  - `Saved/Tests/cta-s50-aot-nonempty-cleanup-facts-green-class/20260828_134335_659_d8435603/RunMetadata.json`
- complete CanonicalASTMigration: **12/12 PASS**
  - `Saved/Tests/cta-s50-canonical-ast-migration-regression/20260828_134455_947_24c1bfac/RunMetadata.json`
- complete TypedASTJIT: **41/41 PASS**
  - `Saved/Tests/cta-s50-typed-ast-jit-regression/20260828_134604_650_a1cf5108/RunMetadata.json`

The build still prints the pre-existing unsafe function-pointer cast warning
in the AOT frame-recursion test and the pre-existing possible-uninitialized
`DividePosition` warning in the adapter test. CTA-S50 introduced neither.

## Remaining Task 7.5 closure

1. Prove reverse live-only cleanup coverage for every transfer from the sealed
   statement tree instead of inferring it from the presence of an action.
2. Derive `PartialConstruction`, `bHasExceptionCleanup` and constructor-failure
   live sets from exact Canonical facts.
3. Derive suspend/resume frame ownership or keep the function in the existing
   typed fallback category.
4. Complete mutable global/import and call-site fallback eligibility.
5. Publish the remaining stable Provider dependency families without AST or
   Engine pointer retention.
6. Preserve object/container/lifetime fallback unless a separately reviewed
   native object-frame ABI is deliberately added.

## Progress accounting

No umbrella task closes. Mechanical completion remains **88/125 (70.4%)**,
weighted implementation remains **about 78%**, safe default-CANONICAL
readiness remains **about 50%**, and action-only Sema authority remains **about
98%**. Direct Canonical-AST AOT is now estimated at **about 58%**: empty and
non-empty cleanup diagnostics are structurally truthful, while non-empty
transfer/exception proofs and the other Task 7.5 families remain open.

The product default remains LEGACY. The original AngelScript native AST,
Parser, Builder and Compiler remain available for LEGACY/recovery/reference;
TypedSemantic HIR remains physically deleted.
