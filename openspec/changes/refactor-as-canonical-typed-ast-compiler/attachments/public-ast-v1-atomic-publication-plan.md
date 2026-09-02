# Public AST V1 — atomic publication sub-plan

Worktree: `D:\as-cta`  
Change: `refactor-as-canonical-typed-ast-compiler`  
Date: 2026-08-23

## Goal

Remove the public `AcquireASTSnapshot()` use-after-free window without making
unrelated legacy compiler, Cache V2, StaticJIT, or default-pipeline claims.

## Selected design

Use a module-local mutex, not a lock-free raw-pointer protocol. The current
fork has only increment/decrement atomics; a raw pointer load followed by
`AddRef()` cannot be made safe by changing memory ordering alone because the
publisher may delete the object between those operations.

```text
AcquireASTSnapshot(V1)                     Publish a new retained snapshot
-----------------------                    -------------------------------
lock module snapshot gate                  build + seal candidate outside gate
  current = astSnapshot                    candidate allocation succeeds?
  if current: AddRef()                       no -> keep prior generation intact
unlock gate
return current                              lock module snapshot gate
                                               previous = astSnapshot
                                               previous.current = false
                                               astSnapshot = candidate
                                             unlock gate
                                             Release(previous) outside gate
```

The gate covers pointer selection and reference acquisition, so a publisher
cannot remove its module-owned reference until an acquiring reader either has
its own reference or sees no current snapshot. Building/sealing/allocation stay
outside the gate to avoid blocking readers on compilation.

`currentGeneration` becomes an atomic integer flag through the existing UE
platform-atomic façade. This removes the separate data race between readers
calling `IsCurrentGeneration()` and a publisher retiring the old generation.

## Scope and file map

- `ThirdParty/angelscript/source/as_module.h`
  - add a private mutable `FCriticalSection astSnapshotLock`.
- `ThirdParty/angelscript/source/as_module.cpp`
  - lock the public acquire path around pointer selection plus `AddRef`;
  - detach/retire the current snapshot under that same gate;
  - construct and seal a candidate before replacing the old pointer; and
  - release a detached old snapshot only after unlocking.
- `ThirdParty/angelscript/source/as_ast_public_view.h/.cpp`
  - replace the plain `bool currentGeneration` with atomic load/store methods.
- `Standalone/Compat/HAL/CriticalSection.h` and `Standalone/Compat/Misc/ScopeLock.h`
  - provide the narrow UE lock façade required by the maintained fork.
- `Standalone/Compat/UECompat.h`
  - add only the `FPlatformAtomics` exchange/compare-exchange operations used
    by the atomic generation flag.
- `Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`
  - first add the source-contract oracle for guarded acquire/exchange and
    atomic generation state; it must be red before production edits.
- `AngelScriptSDK/Module/AngelscriptNativeASTSnapshotAPITests.cpp`
  - add a repeated-build/acquire stress fixture that keeps every acquired
    lease traversable and releaseable while publication changes generations.

## Out of scope

- `GetCanonicalASTContext()` still exposes a raw internal context pointer.
  StaticJIT conversion to an `asIASTSnapshot` lease is a later Wave E/G task.
- Snapshot IDs still have no generation cookie; foreign-ID validation needs a
  public opaque-ID design, not a publication mutex.
- `CompileFunction` still has no complete-snapshot merge policy.
- This does not close 13.7, 13.8, 3.2, 3.4, 3.7, or 11.4; it is one necessary
  component of their acceptance criteria.

## TDD and verification sequence

1. Add the Standalone architecture assertion. Current source must fail because
   `AcquireASTSnapshot()` has no gate and `currentGeneration` is plain `bool`.
2. Implement only the gate/atomic state and compatibility façade.
3. Run the full Standalone suite to verify source contract plus the separate
   maintained-fork host.
4. Add and run the UE repeated acquire/publication stress test.
5. Run the public Snapshot and Hot Reload Snapshot prefixes, then the normal
   `-NoXGE` build.

All results, including any diagnostic failed runs, are recorded in the
follow-up implementation attachment rather than used to check broad OpenSpec
task boxes.
