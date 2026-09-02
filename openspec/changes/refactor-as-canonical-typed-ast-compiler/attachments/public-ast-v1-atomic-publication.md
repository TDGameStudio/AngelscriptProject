# Public AST V1 — guarded acquire/publication repair

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`
Date: 2026-08-23

## Problem repaired

The original V1 public snapshot implementation had a use-after-free window:
an acquiring thread read `astSnapshot`, then called `AddRef()` without sharing
any lifetime gate with the publisher. A rebuild could replace the module-owned
pointer and release the old snapshot between those two operations. The plain
`bool currentGeneration` was also read by public callers while publication
wrote it, which is a separate data race.

This is a narrow public-snapshot lifetime repair. It does not change the
default compiler pipeline or claim a complete public AST protocol.

## Implemented protocol

`asCModule` now owns a mutable `FCriticalSection astSnapshotLock`. It guards
the only three operations that transfer or acquire the module-owned snapshot
reference:

```text
AcquireASTSnapshot(V1)                 PublishCanonicalASTSnapshot()
----------------------                 -----------------------------
lock snapshot gate                     build, seal, and allocate candidate
  current = astSnapshot                lock snapshot gate
  if current: AddRef()                    previous = astSnapshot
unlock snapshot gate                      astSnapshot = candidate
return current                            retire previous generation flag
                                       unlock snapshot gate
                                       Release(previous)
```

`ReleaseCanonicalASTSnapshot()` uses the same gate to detach and retire the
current module-owned snapshot before it releases that reference outside the
lock. Candidate construction/sealing/allocation remain outside the lock, so
readers are not serialized with compilation work. Allocation or sealing
failure leaves the prior published generation untouched.

`asCASTSnapshot::currentGeneration` is now `mutable volatile int32`. Its
public read and publication write use the existing `FPlatformAtomics`
compare-exchange/exchange façade, respectively. The Standalone Compat layer
gains only the small `FCriticalSection`, `FScopeLock`, and atomic operations
needed by this maintained-fork code.

## Tests added

The architecture CTest is the deterministic test-first oracle. Before the
production edit it failed because no shared gate or atomic generation state
existed. It now requires all three module operations to use the same gate and
requires atomic public generation reads/writes.

The UE native SDK test adds
`AcquireDuringRebuildOnlyReturnsStableLeases`. One thread repeatedly obtains
and releases `asIASTSnapshot` leases through the public module method while
the building thread creates 64 replacement generations. Every lease is
traversed through the V1 Decl view before release; the test also asserts that
the last generation remains current. This is a stress regression and does not
pretend to be a formal race detector.

## Validation evidence

| Stage | Result |
| --- | --- |
| Architecture RED | `cta-public-ast-atomic-red_01_Standalone` — **20/21 passed**; only `AngelscriptStandalone.Architecture` failed, reporting missing shared lifetime gate and non-atomic generation state. |
| First implementation compile | The first Standalone attempt exposed a const-correctness issue in `IsCurrentGeneration()`: the atomic API needs a writable volatile address. The field was deliberately made `mutable volatile int32`; this was a compile diagnostic, not a green result. |
| Standalone green | `Plugins/Angelscript/Standalone/out/build/win64-msvc/Testing/Temporary/LastTest.log` after the correction — **21/21 passed**, including Architecture and CanonicalAST. The outer suite wrapper timed out while child CTest continued, so this is recorded from CTest's final log rather than as a fabricated Saved report. |
| UE build | `Saved/Build/build/20260823_041517_253_6983fe29` — `AngelscriptProjectEditor` **166/166 actions**, UBT `Result: Succeeded`, process and runner ExitCode `0`. Existing C4191/C5038/C4996 warnings only. |
| Public Snapshot + Hot Reload | `Saved/Tests/cta-public-ast-atomic-runtime/20260823_041852_541_7ab81f60` — **10/10 passed**, 0 failed, 0 skipped, 0 timed out. This includes the 64-generation acquire/rebuild stress test and all existing Hot Reload lease fixtures. |
| Diff hygiene | `git -C Plugins/Angelscript diff --check` — clean (only existing line-ending warnings). |

## Deliberate non-claims

Do **not** check OpenSpec 13.7 or 13.8, and do not mark Wave E complete from
this repair.

- `GetCanonicalASTContext()` still exposes an unleased raw context pointer.
  The matching-profile HIR dump derives its context from its held lease (see
  `hirdump-snapshot-lease-consumer.md`) and the StaticJIT generation snapshot
  now owns V1 leases as documented in
  `staticjit-generation-snapshot-lease.md`. Remaining callers still require a
  lease-based ownership design before that pointer can be considered safe.
- AST IDs remain raw snapshot-local indices. Equal numeric IDs from two
  generations can still be mistaken for each other; this requires a
  generation-aware opaque-ID contract and negative foreign-ID tests.
- This locking protocol protects acquire versus one normal module publication
  path. It is not a general promise that simultaneous publishers, all module
  mutation APIs, or raw internal AST access are concurrently safe.
- `CompileFunction` still has no complete snapshot merge/retention contract.
- Cache V2 DTO fidelity, SourceManager lifetime, semantic authority,
  full-language CodeGen, and the default LEGACY-to-CANONICAL compiler cutover
  are entirely separate work.

Together with the V1 view-capacity and trailing-vtable repairs, this closes a
specific unsafe public API operation, not the larger compiler migration.
