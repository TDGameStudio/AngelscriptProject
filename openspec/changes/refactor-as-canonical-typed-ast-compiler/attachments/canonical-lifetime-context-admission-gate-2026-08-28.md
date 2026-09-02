# Canonical lifetime Context ownership/admission gate — 2026-08-28

## Scope

This attachment records the TDD evidence for CTA-S53 Task 15.1. The slice is
intentionally limited to `asCASTContext` ownership and internal/public ID
admission. It does not claim the Task 15.2 lifecycle state machine, lifetime
protocol records, derived liveness view, Bytecode/AOT cleanup parity, partial
construction or safe-default cutover.

## Baseline and root cause

The pre-change focused Context prefix passed **6/6**:

- `Saved/Tests/cta-s53-context-baseline/20260828_164010_453_99d26382/Report/index.json`

Static inspection then found two independent ownership-boundary defects:

1. `asCASTContext` owns arena blocks and destroys them in bulk, but its class
   declaration did not suppress implicit copy construction/assignment. A copy
   could therefore duplicate ownership of the same allocations.
2. `GetType()` rejected a nonzero public `snapshotOwner`, while
   `GetDecl()`, `GetStmt()` and `GetExpr()` admitted the same foreign owner when
   its numeric index happened to exist. Their mutable counterparts inherited
   the same inconsistent admission. This allowed a public snapshot coordinate
   to masquerade as an internal owner-zero coordinate.

This is distinct from normal public snapshot access. `asCASTSnapshot` owns the
public token boundary: its adapters first validate `OwnsPublicId()` and only
then construct the owner-zero internal ID used by `asCASTContext`.

## AST-first RED

Two tests were added to
`AngelscriptNativeCanonicalASTContextTests.cpp` before the production fix:

- `ContextOwnerCannotBeCopiedOrMoved` checks copy/move constructibility and
  assignment at compile time through type traits;
- `ContextRejectsPublicOwnerTokensForEveryNodeClass` creates valid internal
  Decl/Stmt/Expr/Type coordinates, applies the same foreign public owner token
  to their numeric indices, and requires every Context/ownership lookup to
  reject them.

The test-only build passed, proving the test source was valid:

- `Saved/Build/cta-s53-context-owner-red/20260828_164132_655_c085b58a/RunMetadata.json`

The focused test then produced the exact expected **6/8 RED**:

- copyability assertion failed;
- foreign declaration lookup assertion failed first in the runtime admission
  test;
- report:
  `Saved/Tests/cta-s53-context-owner-red/20260828_164132_655_c085b58a/Report/index.json`.

No production behavior was changed before this RED was observed.

## Minimal production change

The implementation makes only the ownership/admission changes demanded by the
RED:

- deletes `asCASTContext` copy construction, copy assignment, move
  construction and move assignment;
- requires `snapshotOwner == 0` in const `GetDecl/GetStmt/GetExpr/GetType`;
- applies the same owner-zero predicate to mutable Decl/Stmt/Expr lookups;
- leaves public snapshot-token generation and validation unchanged.

The change does not add a second identity domain, pointer identity, numeric
Engine TypeId storage, a compatibility bypass or a consumer-specific lookup
rule.

## GREEN and regression evidence

Runtime/Editor build:

- **PASS**, 168 actions;
- `Saved/Build/cta-s53-context-owner-green/20260828_164234_788_24255680/RunMetadata.json`.

Focused Context prefix:

- **8/8 PASS**;
- `Saved/Tests/cta-s53-context-owner-green/20260828_164517_529_d8452646/Report/index.json`.

Complete Frontend CanonicalAST prefix:

- **154/154 PASS**, zero failures, warnings or not-run tests;
- `Saved/Tests/cta-s53-context-owner-frontend/20260828_164557_115_160da2cd/Report/index.json`.

The broader prefix covers Context, public snapshot/type identity, Sema,
CodeGen, transaction, sidecar, TypedASTJIT-facing frontend contracts and
Verifier behavior. It demonstrates that valid public access still crosses the
snapshot adapter and that internal consumers already use owner-zero IDs.

## Remaining issue boundary

CTA-S53-I7 is only partially resolved. `asCASTContext::sealed` still combines
structural immutability with publication/cache/consumer admission, and multiple
consumers still add their own weaker or stronger conditions. Task 15.2 must
replace that boolean meaning with the ordered
`Building -> SemaFinalized -> LifetimePlanned -> Frozen/Publishable` contract,
including skipped/repeated/stale/post-freeze negative tests and one shared
admission predicate for Sidecar, Bytecode and AOT.

The build retained pre-existing compiler warnings; this slice introduced no
new warning-driven acceptance claim. Final section 15 and whole-change gates
remain open.
