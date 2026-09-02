# Canonical lifetime protocol foundation — 2026-08-28

## Scope

This attachment records CTA-S53 Task 15.3. The completed slice defines the
revisioned, snapshot-owned lifetime protocol value model, stores it in
`asCASTContext`, authenticates it at the lifecycle planning boundary and gives
it deterministic typed equality/hash identity.

It deliberately does **not** claim production local activation/commit
authoring (15.4), the shared derived lifetime/control view (15.5), migration of
the existing cleanup encodings (15.6), Bytecode/AOT protocol consumption
(15.7/15.8), partial construction (15.9/15.10), section-wide regression closure
(15.11), product-default cutover or removal of the retained native AngelScript
AST.

## AST-first RED

Three tests were authored before the production contract:

- `LifetimeProtocolRecordsHaveDeterministicValueIdentity` requires trivially
  copyable value records, exact fieldwise equality and a structural hash that
  changes when construction order changes;
- `ContextOwnsAndFreezesRevisionedLifetimeProtocol` requires Context-owned
  revision/storage, typed protocol hashing, lifecycle authentication and
  post-freeze mutation rejection;
- `RejectsWrongLifetimeProtocolRevisionBeforePlanning` requires a wrong
  revision to fail specifically before the Context can enter
  `LifetimePlanned`.

The test-only Runtime/Editor build failed for the intended missing-contract
reason: `source/as_ast_lifetime.h` did not exist.

- RED: `Saved/Build/cta-s53-lifetime-protocol-red/20260828_171309_154_72794fdb/RunMetadata.json`.

## Implemented value protocol

`as_ast_lifetime.h/.cpp` defines protocol revision 1 and one typed record with
the following semantic fields:

| Contract fact | Representation |
|---|---|
| lifetime subject | subject kind + snapshot-local Decl/Stmt/Expr coordinate |
| exact action | action kind + snapshot-local action target |
| activation/commit | exact snapshot-local Expr or Stmt coordinate |
| semantic ownership | exact Decl/Stmt region + named phase |
| exits | typed normal/return/break/continue/fallthrough/exception mask |
| construction | step, deterministic order and explicit complete-object commit |

The record has no raw pointer, Engine-local numeric TypeId, backend label,
slot, stack/frame state, rendered dump identity, UE container or UObject. Its
node coordinates are meaningful only inside the owning Context and must keep
`snapshotOwner == 0`; public snapshot tokens fail authentication rather than
being reinterpreted as internal IDs.

Equality is fieldwise. Hashing is also fieldwise and includes the protocol
revision/count; it does not hash object padding, a dump, JSON, DOT or an
address. The Context owns the revision and an `asCArray` of copied records,
resets them with the arena and rejects mutation after Building.

## Lifecycle authentication

The 15.2 lifecycle remains:

```text
Building -> SemaFinalized -> LifetimePlanned -> Frozen/Publishable
```

The `SemaFinalized -> LifetimePlanned` transition now calls
`asCASTVerifyLifetimeProtocol()`. Authentication rejects:

- a revision other than `asAST_LIFETIME_PROTOCOL_REVISION`;
- invalid enum values or exit masks;
- non-deterministic record order;
- invalid, foreign-owner or missing node coordinates;
- a local subject that is not a variable declaration;
- a temporary subject that is not an expression;
- a destroy-value action whose exact target is not a destructor declaration;
- an invalid activation or semantic-region node class;
- complete-object commit outside the complete-object phase.

`asSemaAuthorLifetimeRecord()` is the intended Sema-owned authoring gate. In
this bounded slice it delegates to Context storage; real-source semantic
authoring starts in 15.4.

## Issues found and resolutions

### I1 — expected missing protocol contract

The RED build could not include `as_ast_lifetime.h`. This is the valid
contract-shaped TDD failure and was resolved by adding the maintained-fork
header/source and the Standalone source-list entry.

### I2 — test DLL link boundary

The first implementation build compiled but linked with an unresolved
`asSASTLifetimeRecord::operator==`. The small value operator was out of line
inside the Runtime module and was not exported to the test DLL. Moving the
fieldwise equality operator inline made its value semantics independent of a
DLL export and fixed the link without widening the public API.

- excluded link RED:
  `Saved/Build/cta-s53-lifetime-protocol-green/20260828_171536_916_f7a73b19/RunMetadata.json`.

### I3 — residual Standalone lifecycle spelling

The first Standalone build found one 15.2 migration residue in
`AngelscriptStandaloneCanonicalASTTests.cpp`: it still called the removed
`Context->IsSealed()`. The test now uses `IsPublishable()`, matching Sidecar,
Bytecode and AOT admission.

- failing build:
  `Saved/StandaloneTests/cta-s53-lifetime-protocol_01_Standalone/20260828_172349_172_1a7e1fc0/RunMetadata.json`;
- corrected run:
  `Saved/StandaloneTests/cta-s53-lifetime-protocol-green_01_Standalone/20260828_172551_668_2a0c8318/RunMetadata.json`.

### I4 — staged empty-protocol compatibility

A fresh Context starts at the current revision and an empty record array is
valid. This is intentional only so existing source graphs remain publishable
while Tasks 15.4–15.6 move real Sema lifetime facts into the protocol. It must
not be interpreted as proof that a lifetime-bearing function has a complete
plan. Later verifier/consumer tasks must fail closed for missing required
actions and disagreement with compatibility encodings.

## GREEN evidence

- Runtime/Editor build **PASS**:
  `Saved/Build/cta-s53-lifetime-protocol-green-2/20260828_171900_267_5a531959/RunMetadata.json`;
- focused Context **12/12 PASS**:
  `Saved/Tests/cta-s53-lifetime-protocol-context/20260828_172150_340_6af85661/Report/index.json`;
- focused Verifier **35/35 PASS**:
  `Saved/Tests/cta-s53-lifetime-protocol-verifier/20260828_172227_603_80ed9d81/Report/index.json`;
- complete Frontend CanonicalAST **159/159 PASS**:
  `Saved/Tests/cta-s53-lifetime-protocol-frontend/20260828_172309_372_625d2897/Report/index.json`;
- Standalone Debug **20/20 PASS**:
  `Saved/StandaloneTests/cta-s53-lifetime-protocol-green_01_Standalone/20260828_172551_668_2a0c8318/RunMetadata.json`.

The build retains pre-existing warning families; no warning-clean claim is
made. Sidecar V6 is unchanged because this slice adds no encoded fields and
15.11 has not produced the required schema-loss RED.

## Checkpoint boundary

After closing 15.3, literal OpenSpec progress is **92/136 (67.6%)**, with 44
rows open. Architecture-weighted implementation remains **about 79%** because
this is a protocol foundation, not end-to-end lifetime execution. Product
default remains LEGACY; HIR remains physically deleted; the original native
AngelScript AST/Parser/Builder/Compiler remain intentionally retained for the
explicit LEGACY, syntax/recovery and reference/differential paths.
