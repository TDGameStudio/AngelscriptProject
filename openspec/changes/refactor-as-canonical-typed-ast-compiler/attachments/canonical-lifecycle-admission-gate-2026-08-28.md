# Canonical lifecycle admission gate — 2026-08-28

## Scope

This attachment records CTA-S53 Task 15.2: replacing the overloaded Canonical
`sealed` boolean meaning with one ordered state contract and one backend/cache
admission predicate. It follows the Task 15.1 ownership/ID gate recorded in
`canonical-lifetime-context-admission-gate-2026-08-28.md`.

This slice deliberately does not claim the revisioned lifetime records of Task
15.3, success-sensitive local activation of 15.4, the shared derived lifetime
view of 15.6, Bytecode/AOT cleanup parity of 15.7/15.8, partial construction or
safe-default cutover.

## Previous architecture and root cause

The old Context stored one `bool sealed`. `Seal()` structurally verified the
graph and set that bit, while downstream paths interpreted it independently:

- publication verification added required-target checks;
- Sidecar encode/decode mixed immutability, destination freshness and schema
  checks;
- Module/Cache retention treated the bit as snapshot readiness;
- Bytecode reached it indirectly through publication verification;
- StaticJIT and TypedASTJIT used direct `IsSealed()` tests plus their own
  conditions;
- dump/traversal/diagnostics used the same bit as a read-only traversal gate.

The result had no observable distinction between completed Sema, completed
lifetime planning, structural freeze and actual consumer admission. A caller
could not prove that a backend saw the same readiness definition as Cache or
Sidecar.

## TDD RED

Two Context tests were authored first:

- `ContextLifecycleTransitionsAreOrderedAndOneShot` requires the four states,
  adjacent transitions, unchanged state on skipped/repeated/stale attempts,
  mutation rejection after Sema finalization/freeze and publication admission
  only at the terminal state;
- `SealCompatibilityCompletesTheOrderedLifecycleOnlyOnce` requires the existing
  convenience surface to execute the ordered lifecycle once and reject a
  repeated terminal transition.

The build failed for the intended reason: the state enum,
`GetLifecycleState()`, `AdvanceLifecycle()`, `IsPublishable()` and the invalid
transition result did not exist. Evidence:

- `Saved/Build/cta-s53-lifecycle-red/20260828_165315_340_c0c35657/RunMetadata.json`.

The compile RED is API-shaped rather than an unrelated fixture failure: every
reported error named one missing lifecycle contract element.

## Implemented state contract

The maintained-fork internal state is now:

```text
Building
   -> SemaFinalized
       -> LifetimePlanned
           -> Frozen/Publishable
```

`AdvanceLifecycle(expected, next)` requires both a fresh expected state and
the exactly adjacent successor. Skips, repeats, stale expectations and
terminal repeats return `asAST_VERIFY_INVALID_LIFECYCLE_TRANSITION` without
changing state. The final transition performs structural verification before
publication readiness becomes visible.

General Context mutation is admitted only in `Building`. This ensures the
snapshot cannot be structurally changed after Sema finalization while leaving
room for Task 15.3 to add narrowly scoped lifetime-record APIs during the
SemaFinalized-to-LifetimePlanned phase.

`Seal()` remains for the existing maintained-fork callers and tests. It first
verifies the Building graph, then executes all three adjacent transitions. It
does not jump the state machine and it is deliberately non-idempotent: a second
call reports an invalid lifecycle transition. This is an internal migration
surface, not a new public embedding ABI.

## One consumer admission predicate

`IsPublishable()` is now the only Canonical consumer gate:

- `asCASTVerifyPublication()` and therefore both Bytecode CodeGen entry points;
- Module publication and Cache clean-capture/restore;
- Sidecar encode and function-record collection;
- StaticJIT generation snapshot capture;
- TypedASTJIT eligibility, analysis, call closure and backend paths;
- runtime identity binding and immutable traversal/diagnostic tools.

Sidecar decode is necessarily the construction inverse rather than a consumer:
it accepts only a fresh `Building` destination, reconstructs the DTO, and
returns success only after `Seal()` reaches Frozen/Publishable. A
SemaFinalized/LifetimePlanned/stale destination fails closed and cannot be
published.

The Canonical `IsSealed()` alias was removed. A complete `Source/` scan finds
remaining `IsSealed()` calls only on the unrelated bind registration
collection; no `asCASTContext` consumer retains the weaker spelling.

## Consumer-focused tests

The lifecycle tests are supplemented by three admission surfaces:

- Frontend verifier rejects Building, SemaFinalized and LifetimePlanned before
  accepting Frozen/Publishable;
- Bytecode CodeGen rejects the same three nonterminal states;
- Sidecar encode rejects every nonterminal state, decode rejects a non-Building
  target, and a fresh decode publishes a Frozen/Publishable Context;
- TypedASTJIT returns its existing `MissingCanonicalAST` fallback for every
  nonterminal state and crosses admission only after freeze.

## GREEN evidence

Initial Context implementation build:

- **PASS**, 168 actions;
- `Saved/Build/cta-s53-lifecycle-context-green/20260828_165404_889_7d6131e1/RunMetadata.json`.

Focused Context after the ordered transition implementation:

- **10/10 PASS**;
- `Saved/Tests/cta-s53-lifecycle-context-green/20260828_165651_147_c8d1ae5e/Report/index.json`.

Final consumer-admission build:

- **PASS**, 168 actions;
- `Saved/Build/cta-s53-lifecycle-consumers-green/20260828_170023_237_d85e15f2/RunMetadata.json`.

Complete Frontend CanonicalAST:

- **156/156 PASS**;
- `Saved/Tests/cta-s53-lifecycle-frontend/20260828_170322_096_d4c52711/Report/index.json`.

Cache ASTBodySidecar:

- **22/22 PASS**;
- `Saved/Tests/cta-s53-lifecycle-sidecar/20260828_170405_497_bee3d96f/Report/index.json`.

TypedASTJIT CanonicalASTMigration:

- **16/16 PASS**;
- `Saved/Tests/cta-s53-lifecycle-typed-ast-jit/20260828_170442_586_8a973d64/Report/index.json`.

The builds retain pre-existing warning families, including the existing
CanonicalASTJITAdapter `C4701`; this task makes no warning-cleanliness claim.

## Remaining correctness boundary

`LifetimePlanned` is currently an ordered lifecycle milestone over the
existing Sema-authored cleanup facts. It is not yet proof that the B2
snapshot-owned lifetime protocol exists. Task 15.3 must add the revisioned,
pointer-free protocol records and require the SemaFinalized-to-LifetimePlanned
transition to validate that storage. Task 15.6 must then reconstruct and verify
the shared transient view. Until those tasks pass, the lifecycle gate prevents
premature consumption but does not claim complete lifetime semantics.

Sidecar remains V6 because this task adds no persisted semantic record. Product
default remains LEGACY; native Parser AST/Builder/Compiler remain retained and
HIR remains deleted.
