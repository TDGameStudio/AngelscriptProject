# Formal-ordinal production consumer audit — 2026-08-30

## Scope and outcome

This review cross-checks the CTA-S85 sealed `ParamDecl.formalIndex` contract
against production consumers. Three read-only subagent audits examined
Bytecode, production Sema, and all remaining Runtime/cache/StaticJIT consumers.
They did not edit files or run build/test commands. The primary thread verified
their findings against the current worktree and owns all CTA-S86 implementation
and test evidence.

The outcome was initially split; CTA-S87 has now closed the production-Sema
findings identified by this audit:

- CTA-S86 closes the reviewed Bytecode/VM positional consumers. No known
  `as_bytecode_codegen.cpp` path still derives Runtime parameter ABI from the
  nth ParamDecl child.
- Runtime bridge, verifier, Sidecar V10, Cache, public view and TypedASTJIT are
  formalIndex-safe in the reviewed paths.
- CTA-S87 closes the reviewed production Sema nth-PARAM-child consumers across
  call planning/records, method relations, lambda/funcdef, constructor/operator,
  native/external projection, mixin origin and diagnostic enumeration. The
  broad post-fix matrix is **713/713 PASS**.

## Severity summary

| Severity | Finding | Disposition |
| --- | --- | --- |
| High | `BuildCallableFormalView` builds direct/method/mixin/import/lambda/canonical-funcdef plans from child order and writes plan position as `formalIndex` | Fixed by CTA-S87 exact formal view; named/default RED→GREEN |
| High | generated `ActOnCall` fallback pairs reverse arguments with child-derived formals | Fixed by CTA-S87 exact formal lookup with storage order unchanged |
| High | production override/interface matching compares the next PARAM child on each side | Fixed by CTA-S87 exact comparator; interface RED→GREEN |
| High | lambda/funcdef viability and contextual type inference use positional child arrays | Fixed by CTA-S87 exact viability/contextualization joins |
| High | constructor selection/conversion and operator conversion consume ParamDecl child position | Fixed by CTA-S87 exact traversal; constructor RED→GREEN |
| High | external/native/global/method/behavior signature projection compares Runtime slots to child-derived candidates | Fixed by CTA-S87 exact Runtime-slot joins; native-global RED→GREEN |
| Medium | direct negative Verifier table for duplicate/out-of-range/missing/wrong-owner ParamDecl ordinals is absent | Add test evidence; production verifier is already exact |
| Medium | Sidecar V10 lacks direct raw ParamDecl-ordinal corruption and identity mutation coverage | Add strict fail-closed/identity tests |
| Low | public-view and Sidecar positive tests do not adversarially reorder declaration children | Add relation-vs-structure fixtures |
| Caveat | synthesized/detached Runtime shells currently push null parameter `defaultArgs` | Separate contract test; not the reorder bug |

## Correct relation boundary

Three independent orders must remain separate:

```text
source/name order
  parameter spelling, named-argument lookup, authored provenance

formal-slot identity
  ParamDecl.formalIndex, GetFormalDecl(owner, slot), Runtime ABI arrays

evaluation/storage order
  sealed callArguments/children order, including reverse-formal storage
```

The repair must not sort declaration children or call children. Named lookup may
scan names, but once it selects a ParamDecl it must use that declaration's
formalIndex. Runtime positional consumers must use exact formal slots. Call
evaluation must retain sealed record order and use `formalIndex` only for final
placement.

## Production Sema findings and CTA-S87 disposition

All high-risk findings below are now implemented and verified. Full evidence,
including the seven reordered-child fixtures, grouped **6/6** gate,
ProductionCodeGen **137/137**, transaction/rollback **21/21** and broad
**713/713** matrix, is recorded in
`attachments/cta-s87-production-sema-formal-ordinal-consumption-gate-2026-08-30.md`.

### Common call-plan producer — highest priority

Before CTA-S87, `as_sema_expr.cpp` `BuildCallableFormalView` scanned raw
ParamDecl children for free functions, methods, constructors, mixins, imports,
lambdas and canonical funcdefs. `AppendCallArgumentFormal` assigned
`plan.GetLength()` as the formal index. Its downstream users cover:

- positional, named, default and hidden argument planning;
- overload ranking and conversions;
- durable `asSASTCallArgument` publication;
- import candidates and implicit mixin receivers.

Changing only the stored index is insufficient because the plan array itself
would still be child-ordered. The plan must be built by exact ordinal, failing
closed for a missing or ambiguous slot. Runtime-only indirect funcdefs remain a
separate safe fallback because their Runtime signature vector is the only
available formal table.

The first implemented RED was:

`ReorderedParamChildrenDoNotChangeNamedDefaultCallPlan` in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.

Create `F(int A, int B = 7)`, swap only the same-typed ParamDecl children, then
run production call planning for `F(A: 3)`. The sealed records must remain:

```text
stored record 0 -> default B -> formalIndex 1
stored record 1 -> named   A -> formalIndex 0
```

The former child-derived planning marked B as slot 0 and A as slot 1, so the
publication verifier rejected the graph. The exact-formal repair is green and
covers named lookup, default ownership, record production and formal identity
without requiring VM execution.

### Generated call fallback

`as_sema.cpp` `ActOnCall` has a fallback path that collects raw ParamDecl
children, pairs them with reverse arguments and writes the loop index as
`formalIndex`. It does not pass through `BuildCallableFormalView` and needs an
independent exact-formal loop. The descending storage loop must remain
descending; only the formal lookup changes.

### Override/interface relation

`as_sema_decl.cpp` `CanonicalMethodSignaturesEqual` advances through the next
PARAM child on both sides. A legal relation can be missed and diagnosed as a
missing override/interface implementation before verifier publication. The
verifier already contains the correct exact-count/exact-slot comparison; the
production matcher should use the same pure relation rule.

### Lambda/funcdef and constructor/operator consumers

Both lambda/funcdef viability and contextualization build child-ordered
parameter arrays. Contextualization can therefore assign an inferred type to
the wrong ParamDecl. Constructor overload selection, constructor conversion and
operator conversion also align actual arguments with child position. All must
join by exact formal ordinal while retaining authored/evaluation ordering.

### Native/external projection and mixin/setter consumers

Current/external script function dedup, native global/method/behavior matching
and constructor/factory projection compare positional Runtime vectors to
child-derived Canonical parameters. Mixin origin currently chooses the first
suitable object ParamDecl instead of exact formal zero. Property setter value
selection similarly takes the first ParamDecl rather than exact formal zero.
These should fail closed through exact formal lookup.

Diagnostic-only parameter printing may remain lower priority, but should also
enumerate exact formal order so a malformed or transformed graph does not emit
misleading rank/signature diagnostics.

## Safe reviewed consumers

The following boundaries are already exact or order-neutral:

- `asCASTContext::GetFormalDeclCount` and `GetFormalDecl`;
- publication verifier ParamDecl and call-argument relation checks;
- verifier method-signature authentication;
- stable callable keys and Runtime type/declaration bridge;
- TypedASTJIT stored-evaluation/formal-placement call lowering;
- TypedASTJIT root-entry formal binding;
- Sidecar V10 serialization, strict decode and structural/reference identity;
- Cache clean capture, restore admission and Runtime-ordinal records;
- append-only public declaration view;
- Runtime VM signature arrays after exact Canonical/Runtime authentication;
- child scans that only ask zero parameters, count parameters or validate an
  exactly-one-parameter shape.

## Test-hardening backlog

1. Add a table-driven Verifier negative test for duplicate, out-of-range,
   sentinel/missing, non-PARAM, wrong-owner and incomplete ParamDecl ordinal
   relations.
2. Mutate a V10 Sidecar declaration ordinal to duplicate/out-of-range and
   require strict decode to clear the candidate graph.
3. Prove changing only ParamDecl formalIndex changes the appropriate sidecar
   structural/reference identity.
4. Reorder same-typed ParamDecl structural children before Sidecar encode and
   prove structural order and exact formal order both round-trip independently.
5. Add a two-formal public-view fixture proving full-size callers recover the
   exact relation while old-size callers remain memory-safe but relation-blind.
6. Add lambda, named/default, explicit import, detached in/out import and
   funcdef sibling guards after the common Sema fix.

Old-size public-view compatibility means old callers are not overrun; it does
not mean they can read the new relation. Any future external AOT consumer must
request the full current view or fail/fallback explicitly. It must never infer
formal identity from structural children.

## Implemented order and remaining hardening

1. Completed: reordered same-type named/default call-plan RED and exact common
   formal view.
2. Completed: generated `ActOnCall`, method signature, lambda/funcdef,
   constructor/operator, mixin/setter and native/external projection repairs.
3. Completed: exact diagnostic enumeration and rank lookup.
4. Completed: focused, ProductionCodeGen, transaction/rollback and broad
   Compiler CanonicalAST + TypedASTJIT + NativeBridge regressions.
5. Remaining as test hardening: direct Verifier/Sidecar/public-view negative
   matrices and additional current-module/native method/native behavior/
   diagnostic reorder fixtures. No known reviewed production consumer depends
   on those additional fixtures for correctness.

CTA-S86 evidence is recorded in
`attachments/cta-s86-bytecode-formal-ordinal-consumption-gate-2026-08-30.md`.
CTA-S87 evidence is recorded in
`attachments/cta-s87-production-sema-formal-ordinal-consumption-gate-2026-08-30.md`.
This review still does not claim that all 7.2/7.4 language and call families
are complete, does not authorize default cutover and does not include
Standalone.
