# Public AST V1 opaque snapshot-ID ownership (2026-08-23)

Worktree: `D:\as-cta` (canonical `refactor-as-canonical-typed-ast-compiler` worktree).

This is a bounded repair of the public V1 traversal contract. It is **not** a
completion of R05 (the broader public ABI task), R06 (the full snapshot
publication protocol), Cache DTO work, or canonical-default cutover.

## Problem

The first V1 shape exposed `asASTDeclId`, `asASTStmtId`, `asASTExprId`, and
`asASTTypeRef` as a single raw `asUINT`. Internally that integer is a valid
context-local array index, but externally it was claimed to be a
snapshot-local opaque ID.

Consequently, two independent retained snapshots both normally issued
translation-unit ID `1`. Passing the ID issued by snapshot A to
`snapshotB->GetDecl()` succeeded and returned B's root declaration. The API
could not distinguish a valid local index from a foreign snapshot ID.

## Contract now enforced

Each public AST ID has two fields:

```text
value          snapshot-local internal node index
snapshotOwner  non-zero token allocated when the public snapshot is created
```

`asCASTSnapshot` keeps the internal AST indexes unchanged. Its public boundary
performs the only translation:

```text
internal AST index --(Get* public view)--> { value, snapshotOwner }
{ value, snapshotOwner } --(same snapshot Get*)--> internal AST index
foreign / raw / owner-zero ID --(Get*)--> asINVALID_ARG, no view write
```

All public traversal outputs are tagged: `GetTranslationUnitDecl`, the `id`,
`parent`, and `type` values in declaration views, statement IDs and expression
edges in statement views, expression IDs/types, and type IDs. A public
`GetDecl`/`GetStmt`/`GetExpr`/`GetType` validates the owner before it reads the
internal context or writes caller output.

The maintained parser/Sema/CodeGen representation continues to construct IDs
with the one-argument constructor. Those internal IDs deliberately have
`snapshotOwner == 0`; no CodeGen, Sema, verifier, cache, or HIR code needs to
know public snapshot ownership.

## TDD evidence

New raw-SDK module test:

`AngelscriptNativeASTSnapshotAPITests.cpp` →
`SnapshotRejectsForeignOpaqueIds`

The test builds two separate retained modules, acquires A and B, verifies A
accepts its own translation-unit ID, then passes that ID to B. It asserts
`asINVALID_ARG` and verifies that B left `structSize`, `apiVersion`, and a
payload byte unchanged. This is a real public API observation, not a source
scan or a mocked snapshot.

| Stage | Command / label | Result |
| --- | --- | --- |
| RED build | `RunBuild.ps1 -Label cta-snapshot-foreign-id-red-build -NoXGE` | success |
| RED test | `RunTests.ps1 -TestPrefix Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot -Label cta-snapshot-foreign-id-red` | **6/7**, new test failed because B returned `0` (success) |
| GREEN build | `RunBuild.ps1 -Label cta-snapshot-foreign-id-green-build -NoXGE` | success, 196 actions; pre-existing C5038/C4191 warnings only |
| GREEN test | `RunTests.ps1 -TestPrefix Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot -Label cta-snapshot-foreign-id-green` | **7/7**, zero failures/skips |
| Standalone | `RunTestSuite.ps1 -Suite Standalone -LabelPrefix cta-snapshot-foreign-id-standalone` | **21/21 CTest**, zero failures |

Saved evidence roots:

- `Saved/Build/cta-snapshot-foreign-id-red-build/20260823_061607_807_7bdf4aaf`
- `Saved/Tests/cta-snapshot-foreign-id-red/20260823_061711_436_dcd3ba42`
- `Saved/Build/cta-snapshot-foreign-id-green-build/20260823_061920_212_b3b4e800`
- `Saved/Tests/cta-snapshot-foreign-id-green/20260823_062247_999_45e06612`
- `Saved/StandaloneTests/cta-snapshot-foreign-id-standalone_01_Standalone/20260823_062341_710_c2ca0752`

## ABI and compatibility boundary

The `asIScriptModule` vtable remains unchanged; its V1 AST methods are still
trailing slots. The public ID structs, and therefore the V1 view structs that
contain them, increase in size in this worktree. This is intentional: a raw
single integer cannot encode both a local index and a snapshot owner.

The view `structSize` contract remains fail-closed: a caller compiled with a
smaller view advertises insufficient writable capacity and is rejected before
output is written. This preserves memory safety, but it is **not** a claim of
binary compatibility for an earlier incomplete V1 AST consumer. The final
product-facing ABI/version policy still belongs to Task 13.7 and must be
rereviewed before release.

`snapshotOwner` is an in-process, non-zero monotonic `asDWORD` allocation. It
is not persisted, is not a cache key, and must never be compared across engine
processes. The public contract is ownership validation during the lifetime of a
snapshot lease, not global identity or cross-process serialization.

## Still open

- R05 still needs full public ABI reconciliation and release/version policy.
- R06 still needs the complete publication/acquire protocol audit, including
  all raw-context surfaces and the documented `CompileFunction` completeness
  policy.
- R04 Cache V2 still needs a pointer-free, exact canonical AST DTO and restore
  validation.
- Production default remains `LEGACY` / `asCCompiler`; this has no effect on
  parser/Sema authority or default-canonical readiness.

Do not mark 3.2, 3.4, 3.7, 10.2, 13.7, 13.8, 13.9, or 13.11 complete solely
because this bounded foreign-ID repair is green.
