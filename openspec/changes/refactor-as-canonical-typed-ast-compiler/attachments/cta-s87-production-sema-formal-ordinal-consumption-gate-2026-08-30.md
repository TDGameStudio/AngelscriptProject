# CTA-S87 production Sema formal-ordinal consumption gate — 2026-08-30

## Outcome

CTA-S87 closes the reviewed production-Sema half of the sealed
`ParamDecl.formalIndex` contract. Canonical declaration `children` remain an
ownership/traversal/source container; production call planning, signature
matching, contextualization, conversion and Runtime projection now resolve
parameter slot N only through `asCASTContext::GetFormalDecl(owner, N)`.

This slice does not sort declaration children, does not change authored call
evaluation order, and does not reconstruct a parameter relation when an exact
formal is missing or duplicated. The independent relations remain:

```text
source/name order       -> spelling, named lookup and provenance
formal-slot identity    -> ParamDecl.formalIndex and Runtime ABI slot
evaluation/storage order -> sealed call records/children, including reverse-formal storage
```

The production review found no remaining high-risk consumer in
`as_sema.cpp`, `as_sema_decl.cpp` or `as_sema_expr.cpp` that treats the nth
`ParamDecl` structural child as formal slot N. Remaining raw `PARAM` scans in
those files are name lookup, count-only, singleton or kind guards and are
order-neutral.

## Production changes

### Common call relation and generated records

- `as_sema_expr.cpp` `BuildCallableFormalView` builds direct, method, mixin,
  import, lambda and canonical-funcdef formal views by exact formal index.
- `AppendCallArgumentFormal` retains the exact declaration-owned
  `formalIndex`; it no longer publishes plan position as identity.
- `as_sema.cpp` generated `ActOnCall` fallback pairs the existing reverse
  argument storage order with exact formal slots.

Named/default lookup is still name-driven at the selection boundary. Once a
parameter is selected, its sealed formal index drives final placement.

### Declaration relation, contextualization and construction

- `as_sema_decl.cpp` `CanonicalMethodSignaturesEqual` compares override and
  interface candidates by the same exact formal slot on both sides.
- Lambda/funcdef viability and lambda contextualization join formals by exact
  index, preventing inferred types from moving to a reordered sibling.
- Constructor selection and argument conversion enumerate exact formal slots.
- Binary operator conversion consumes supplied operands against exact slots.

### Runtime projection and special call shapes

- Current-module/external-script and automatic-import matching joins Runtime
  signature vector index N to canonical formal N.
- Native global, method and constructor/factory behavior projection use the
  same exact Runtime-slot join and fail closed on an incomplete relation.
- Mixin origin is exact formal zero, not the first object-shaped parameter
  child.
- Generated property setters and deferred-out setters require exactly one
  formal and read exact formal zero.
- Unresolved-call signature and rank diagnostics enumerate exact formal order.

The setter/deferred-out paths were already order-neutral for verifier-valid
singleton shapes; their exact-formal conversion is consistency hardening, not
claimed as a separate production defect. Likewise, ordinary legal operators
normally have zero or one explicit formal, but exact lookup removes the last
positional assumption without changing their language contract.

## TDD evidence

### Named/default call plan

- RED: `Saved/Tests/cta-s87-sema-formal-plan-red/20260830_103251_461_50a8cffc`
- GREEN: `Saved/Tests/cta-s87-sema-formal-plan-green/20260830_103355_674_e36767c0`
- Fixture: `ReorderedParamChildrenDoNotChangeNamedDefaultCallPlan`

The fixture creates same-typed parameters, reorders only their structural
children, and proves that the named argument remains formal 0 while the
default argument remains formal 1 in the pre-existing stored/evaluation order.

### Generated call records

- RED: `Saved/Tests/cta-s87-generated-call-formal-red/20260830_103509_844_a3d87752`
- GREEN: `Saved/Tests/cta-s87-generated-call-formal-green/20260830_103605_008_7942987c`
- Fixture: `ReorderedParamChildrenDoNotChangeGeneratedCallRecords`

### Override/interface matching

- RED: `Saved/Tests/cta-s87-method-relation-red/20260830_104218_479_dda85a3f`
- GREEN: `Saved/Tests/cta-s87-method-relation-green/20260830_104312_133_540db5e2`
- Fixture: `ReorderedParamChildrenDoNotChangeOverrideAndInterfaceMatching`

### Lambda/funcdef contextualization

- Viability RED: `Saved/Tests/cta-s87-lambda-formal-red/20260830_104455_695_e37a8d35`
- Contextualization RED: `Saved/Tests/cta-s87-lambda-context-red/20260830_104551_735_09844fc5`
- GREEN: `Saved/Tests/cta-s87-lambda-context-green/20260830_104645_271_f5cbb2c4`
- Fixture: `ReorderedParamChildrenDoNotChangeLambdaFuncdefContextualization`

The two-stage RED separated candidate viability from the later type-writing
path so the repair did not hide one positional consumer behind the other.

### Constructor selection/conversion

- RED: `Saved/Tests/cta-s87-constructor-formal-red/20260830_104824_088_12dc08d5`
- Build GREEN:
  `Saved/Build/cta-s87-constructor-formal-green-build-r2/20260830_105106_936_7c9e5ae1`
- GREEN: `Saved/Tests/cta-s87-constructor-formal-green-r2/20260830_105214_005_6573e2d7`
- Fixture: `ReorderedParamChildrenDoNotChangeConstructorSelectionAndConversion`

### Native projection and mixin receiver

- Grouped RED:
  `Saved/Tests/cta-s87-sema-projection-origin-red/20260830_105543_751_2c6772ba`
  — **4/6 PASS**, with the two new defects failing as expected.
- Build GREEN:
  `Saved/Build/cta-s87-sema-projection-origin-green-build/20260830_105730_450_1e75f4a9`
- Grouped GREEN:
  `Saved/Tests/cta-s87-sema-projection-origin-green/20260830_105741_786_64225d29`
  — **6/6 PASS**.
- Fixtures:
  `ReorderedParamChildrenDoNotDuplicateNativeGlobalProjection` and
  `ReorderedParamChildrenDoNotChangeMixinReceiverOrigin`.

The projection fixture proves that re-entering the native global projection
path reuses the exact existing declaration rather than publishing a duplicate.
The mixin fixture proves origin is formal zero even when a later object formal
appears first in the structural child array.

## Regression gates

| Gate | Result | Evidence |
| --- | ---: | --- |
| ProductionCodeGen | **137/137 PASS** | `Saved/Tests/cta-s87-production-codegen-green/20260830_105832_328_91b6dc08` |
| Canonical CodeGen transaction/rollback | **21/21 PASS** | `Saved/Tests/cta-s87-codegen-transaction-green/20260830_105910_068_5297e7b2` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **713/713 PASS**, 0 failed, 0 skipped | `Saved/Tests/cta-s87-compiler-typedjit-nativebridge-full-green/20260830_105943_978_22e0dcb7` |

The broad gate logged the existing provider-reload HTTP timeout warning, but
the Automation report and process both completed with exit code 0.

## Execution issues recorded

Two issues occurred while constructing the gate; neither is a retained product
failure:

1. The first constructor repair incorrectly wrapped `GetFormalDecl()` in
   `GetDecl()`. Compilation proved the API already returns `const asCDecl*`.
   The misuse was removed and the succeeding build is the evidence above. The
   failed build is retained at
   `Saved/Build/cta-s87-constructor-formal-green-build/20260830_105041_353_c46dc8d9`.
2. The first constructor GREEN command omitted the CQTest class segment and
   selected no tests. It is excluded from correctness evidence. The no-match
   run is retained at
   `Saved/Tests/cta-s87-constructor-formal-green/20260830_105125_919_4764adec`;
   the exact fully-qualified rerun passed 1/1.

These are examples of why a grouped TDD loop still needs selector validation:
a zero-test command is never counted as GREEN, and compiler feedback is not
converted into a semantic success claim.

## Static residual audit and backlog

The production residual audit classifies remaining raw parameter scans as
order-neutral name/count/singleton/kind checks. It recommends future direct
fixtures for current-module/external projection, native method projection,
native behavior projection and unresolved-call diagnostic order. Shared
production matchers are already exact and the complete broad matrix is green;
these fixtures are test-hardening, not a known default-cutover defect.

The existing cross-layer hardening backlog also remains:

- direct Verifier negative table for duplicate/out-of-range/missing/wrong-owner
  parameter ordinals;
- Sidecar V10 raw ordinal corruption, identity mutation and independent
  structural/formal reorder fixtures;
- two-formal public-view compatibility/relation fixture;
- synthesized/detached Runtime-shell `defaultArgs` metadata contract.

The last item is independent of structural child reordering.

## Non-claims

- Tasks 7.2 and 7.4 remain open for complete call/language/provider breadth;
  Task 7.5 remains open for final lifetime/provider closure.
- Product default remains LEGACY. CTA-S87 does not authorize the default
  switch or replace the final focused/All cutover matrix.
- Standalone is excluded by current user scope and was not changed or tested.
- The original native AngelScript parser AST remains intentionally retained
  for parsing, recovery, explicit LEGACY, differential/reference work and
  syntax support.
- HIR remains physically absent and was not recreated.
- Diagnostic dump/JSON remains read-only tooling and is not an AOT or Cache
  semantic input.

## Record validation

- `openspec validate refactor-as-canonical-typed-ast-compiler --strict`:
  PASS (`Change ... is valid`).
- Parent `git diff --check`: PASS.
- Plugin-submodule `git diff --check`: PASS.
- Both diff checks emitted only the repository's existing LF-to-CRLF checkout
  warnings; neither reported a whitespace error and both exited 0.
- Formal checklist count remains **102/136 = 75.0%**. CTA-S87 advances the
  implementation evidence under the still-open umbrella rows 7.2/7.4; it does
  not falsely close those rows before the remaining family-wide requirements.
