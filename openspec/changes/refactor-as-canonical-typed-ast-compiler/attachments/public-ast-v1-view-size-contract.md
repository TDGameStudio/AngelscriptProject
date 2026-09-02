# Public AST V1 — view-size contract hardening

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`
Date: 2026-08-23

## Purpose

The V1 public AST view structs begin with `structSize` and `apiVersion`, but
`asCASTSnapshot::GetDecl/GetStmt/GetExpr/GetType` previously treated the
output pointer as a full current struct unconditionally. A caller compiled
against a smaller layout could therefore be written past its declared storage.
Existing regression tests zero-initialized their views, which accidentally hid
the missing input contract.

This increment makes the V1 capacity rule explicit and fail-closed. It is a
small ABI-safety repair, **not** a declaration that the public AST ABI or
snapshot protocol is finished.

## V1 contract

Before every `asIASTSnapshot::Get*View` call, the caller must write:

```cpp
asSASTDeclView view = {};
view.structSize = sizeof(view);
const int result = snapshot->GetDecl(id, &view);
```

The same rule applies to `asSASTStmtView`, `asSASTExprView`, and
`asSASTTypeView`.

```text
caller buffer
    structSize >= complete V1 layout
        -> getter fills the complete V1 view, including output apiVersion

    structSize < complete V1 layout
        -> asINVALID_ARG
        -> no output field is written or cleared
```

`apiVersion` remains an output field. Version selection is still performed by
`AcquireASTSnapshot(requestedApiVersion)`, rather than by treating an
uninitialized output struct as an input-version request. A larger caller
buffer is accepted; a V1 getter never attempts a partial write into a smaller
buffer.

## Test-first evidence

The snapshot API test first supplied a `structSize` ending immediately before
`asSASTDeclView::kind`, with sentinel values in `structSize`, `apiVersion`, and
`kind`. The pre-change getter returned success and overwrote the sentinels, so
the new assertion was a real red test.

After the guard was installed, it requires `asINVALID_ARG` and verifies all
three sentinels remain untouched. The implementation uses the same check in
all four V1 getters before ID lookup or the first output write.

## Changed surface and caller audit

- `Source/AngelscriptRuntime/Core/angelscript.h`
  - documents `structSize` as caller-provided writable capacity for all V1
    `Get*View` methods.
- `ThirdParty/angelscript/source/as_ast_public_view.cpp`
  - rejects an incomplete Decl, Stmt, Expr, or Type view before mutation.
- `AngelscriptNativeASTSnapshotAPITests.cpp`
  - initializes successful V1 Decl views and adds the short-buffer/no-write
    canary.
- `AngelscriptCanonicalASTSnapshotReloadTests.cpp`
  - initializes both Hot Reload callers, including the reader-thread loop.
- `Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp`
  - initializes the independent-host V1 view caller.

Repository search found no other direct public `Get*View` consumer in the
checked-in UE or Standalone test/runtime paths at this point. This is a call
site audit, not proof that arbitrary external binary consumers have already
adopted the new contract; the public-header comment is the compatibility
notice for those consumers.

## Validation

| Stage | Result |
| --- | --- |
| Test-source build (RED) | `Saved/Build/build/20260823_034115_921_4516818e` — succeeded |
| Short-buffer RED | `Saved/Tests/cta-public-ast-view-size-red/20260823_034132_824_42cfc97b` — **4 total: 3 passed, 1 failed**; only the new short-buffer expectation failed |
| Full public-header implementation build | `Saved/Build/build/20260823_034247_439_e590ee4c` — UBT **196/196**, succeeded (the interactive wrapper timed out while UBT continued; the UBT log and final result are successful) |
| Clean standard build record | `Saved/Build/build/20260823_034847_025_c1013a45` — succeeded, target up to date |
| Snapshot API GREEN | `Saved/Tests/cta-public-ast-view-size-green/20260823_034547_900_d0f96fea` — **4/4 PASS** |
| Hot Reload GREEN | `Saved/Tests/cta-public-ast-view-size-hotreload/20260823_034631_954_c606a940` — **5/5 PASS** |
| Standalone Debug CMake/CTest | `cta-public-ast-view-size-standalone_01_Standalone` — **21/21 PASS** |

The Standalone result rebuilds the maintained fork and validates its separate
host; it specifically includes `AngelscriptStandalone.CanonicalAST`.

## Deliberate non-claims and remaining blockers

This hardening does **not** close OpenSpec tasks 13.7 (public ABI) or 13.8
(snapshot protocol), and does not justify checking any prior public-AST task
box.

- The AST methods are still located in the existing `asIScriptModule` vtable
  placement. A compatible solution requires an append-only or extension
  interface migration and an explicit product-version compatibility decision;
  a size guard cannot repair an already shifted binary vtable.
- AST IDs are still raw snapshot-local indices. A robust foreign-snapshot-ID
  contract needs generation-aware opaque IDs (or equivalent ownership
  validation), not a local bounds check that might make index collisions look
  valid.
- Snapshot publication/acquisition still needs an atomic lifetime protocol:
  construct and verify a new immutable snapshot, atomically exchange it, and
  retain within that same acquisition protocol. Initializing the reader's view
  capacity does not prove that concurrent acquire/publish is race-free.
- V1 exposes only its current thin Decl/Stmt/Expr/Type views. It does not make
  canonical AST semantic authority, Cache V2 DTO fidelity, StaticJIT leasing,
  or default CANONICAL CodeGen complete.

The next public-API work must tackle these as a designed protocol change with
ABI and concurrency tests, rather than silently broadening the V1 size rule.
