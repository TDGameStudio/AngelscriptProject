# StaticJIT generation snapshot — public AST lease implementation

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`  
Date: 2026-08-23

## 2026-08-30 follow-up — Engine teardown revokes AST leases

The original document below correctly replaced an unowned context with a
public AST lease during StaticJIT generation, but its final-owner lifetime
claim was too broad. `asCASTSnapshot` can retain an `asCRuntimeTypeGeneration`
and retired `asCModule`; destroying that retained module consults the owning
script Engine's function/type tables. Therefore an external shared generation
snapshot must not postpone the public AST `Release()` until after
`asCScriptEngine::ShutDownAndRelease()`.

The complete ownership rule is now:

```text
generation Engine alive
  -> CanonicalASTLeases own public V1 snapshots
  -> SealedAST borrows are usable

Engine replaces result or begins shutdown
  -> revoke every AST lease while the script Engine is still alive
  -> retained Runtime type generation / retired module is released safely
  -> GetContext() returns null and IsComplete() fails closed
  -> external shared snapshot may still read copied pointer-free audit data
```

The pointer-free `NativeCallInventory`, stable keys, hashes and copied text
remain snapshot-owned. Engine-local module/function/type/descriptor pointers
and `SealedAST` borrows remain invalid after Engine teardown, exactly as the
snapshot contract already requires.

The RED was found by the combined CanonicalAST/Generation/TypedASTJIT run at
`Saved/Tests/cta-s94-canonical-generation-typedjit-nativebridge-regression/20260830_183031_005_b9060d12/RunMetadata.json`.
`GenerationNativeCallInventoryIsEngineOwnedAndSurvivesOwnerTeardown` crashed
when the externally retained snapshot finally destroyed an old module after
both generation Engines were gone; the stack entered
`asCObjectType::ReleaseAllFunctions()` through
`asCRuntimeTypeGeneration::Release()`.

`FAngelscriptStaticJITGenerationASTLease` now exposes an idempotent,
mutex-protected pre-shutdown release operation. `FAngelscriptEngine` invokes it
before both snapshot replacement and Engine shutdown, even when external
shared owners remain. The regression also asserts that all lease contexts are
null after Engine A teardown while Engine A's pointer-free native-call
inventory remains readable and Engine B remains unaffected.

Evidence:

- build: PASS at
  `Saved/Build/cta-s95-generation-snapshot-lease-detach-build/20260830_183552_875_93b9c217/Build.log`;
- exact lifecycle regression: **1/1 PASS** at
  `Saved/Tests/cta-s95-generation-snapshot-lease-detach-focused-green/20260830_183718_660_ffaadd66/Report/index.json`;
- the complete combined regression is still required before this bounded
  fix contributes to the final default-cutover gate.

This follow-up supersedes later statements in this document that say the AST
lease is always held until the final shared generation-snapshot owner is
destroyed. The final owner still destroys the empty lease holder, but the
Engine-local AST reference itself ends at snapshot replacement or Engine
shutdown.

## Outcome

`FAngelscriptStaticJITGenerationSnapshot` no longer fills a function's
`SealedAST` by borrowing `asCModule::GetCanonicalASTContext()`. It now owns
the public V1 AST snapshot reference that establishes the context lifetime.
The context is borrowed only from that owned lease for the lifetime of the
immutable generation snapshot.

```text
module compilation
  |
  +-- optional retained asIASTSnapshot (public V1)
  |       |
  |       +-- AcquireASTSnapshot(V1) transfers one ref
  |               |
  |               +-- FAngelscriptStaticJITGenerationASTLease (RAII)
  |                       |
  |                       +-- generation snapshot's CanonicalASTLeases[]
  |                               |
  |                               +-- function SealedAST borrows sealed context
  |
  +-- no retained AST
          |
          +-- Bytecode capture: supported, no SealedAST identity
          +-- VerifiedTypedHIR: fail closed with module-specific diagnostic
```

The lease holder takes the reference returned by `AcquireASTSnapshot()` and
calls `Release()` only when the final thread-safe shared generation-snapshot
owner is destroyed. It validates V1 and exposes a context only when the
public snapshot is an `asCASTSnapshot` with a sealed context.

## Important compatibility boundary found during verification

The first implementation acquired a lease only when the artifact profile was
`VerifiedTypedHIR`. `CanonicalASTIdentity` then failed seven identity cases:
the fixtures intentionally compile with the **Bytecode** StaticJIT profile
while explicitly setting `asAST_RETAIN_SNAPSHOT`. They verify that a retained
AST can still supply stable declaration identity even where bytecode remains
the execution backend.

That failure was not a reason to weaken the typed prerequisite. The corrected
rule is:

- A StaticJIT generation builder attempts `AcquireASTSnapshot(V1)` for every
  compiled module.
- If a public snapshot exists, it owns it and populates `SealedAST` for every
  profile, including Bytecode.
- If no public snapshot exists, Bytecode capture remains valid and has no
  sealed-AST identity metadata.
- `VerifiedTypedHIR` alone rejects the absence of a public sealed lease.

This preserves the old supported identity behavior while replacing its raw
pointer lifetime with the public protocol.

## Caller contract tightened

`FAngelscriptProjectSourceGraph::Compile()` now rejects a
`VerifiedTypedHIR` request unless its AST retention policy is exactly
`asAST_RETAIN_SNAPSHOT`. The existing StaticJIT artifact route already made
that request. The developer `as.HIRDump` route now makes it explicit as well,
so a later generation snapshot has the AST that verified typed capture
requires.

The project-source-graph test suite has a positive retained typed request and
a negative request that must fail before invoking the consumer. This makes
the source-graph precondition observable rather than relying on a later,
less-local snapshot failure.

## Verification record

| Check | Evidence | Result |
| --- | --- | --- |
| Build after compatibility correction | `Saved/Build/build/20260823_045216_732_031aa873` | UBT `Result: Succeeded`, runner ExitCode `0` |
| Architecture RED | `cta-staticjit-lease-red-v2_Standalone` | **19/21**; Architecture was the only failing CTest and reported the two missing source contracts |
| Initial architecture green | `cta-staticjit-lease-green-v2_Standalone` / CTest `LastTest.log` | **21/21** before the identity regression was exposed |
| AST identity regression | `Saved/Tests/cta-staticjit-lease-identity/20260823_045039_285_321bce41` | Expected red diagnostic: **1 passed, 7 failed**, all absent `SealedAST` identity in retained Bytecode fixtures |
| Final UE build | `Saved/Build/build/20260823_045653_348_5c67bc53` | UBT `Result: Succeeded`, runner ExitCode `0` |
| Final Standalone suite | `Plugins/Angelscript/Standalone/out/build/win64-msvc/Testing/Temporary/LastTest.log` | **21/21** start rows and **21/21** `Test Passed.` rows; no CTest failure marker |
| Final retained-Bytecode identity | `Saved/Tests/cta-staticjit-lease-identity-v2/20260823_045411_135_5b0dfd07` | **8/8 passed**, 0 failed/skipped |
| Current semantic-key identity revalidation | `Saved/Tests/cta-staticjit-canonical-identity-semantic-float-green/20260823_191005_742_22d5d261/RunMetadata.json` | **8/8 passed**, 0 failed/skipped; source `float` is correctly matched as canonical `double` when `asEP_FLOAT_IS_FLOAT64=1` |
| Primary StaticJIT generation | `Saved/Tests/cta-staticjit-lease-primary-v2/20260823_045731_369_67f5ab20` | **9/9 passed**, 0 failed/skipped |
| HIR dump caller | `Saved/Tests/cta-staticjit-lease-hirdump-v2/20260823_045905_648_b0e6ec5b` | **5/5 passed**, 0 failed/skipped |
| Project source-graph contract | `Saved/Tests/cta-staticjit-lease-source-graph-v2/20260823_050023_350_3964dcc4` | **2/2 passed**, including the negative typed-without-retention contract |

The `LastTestsFailed.log` file in the Standalone CTest directory can be stale
after a successful run; final CTest status must be taken from `LastTest.log`.

## Scope and non-claims

- This migrates one generation-snapshot consumer. It does not make every
  `GetCanonicalASTContext()` caller safe; unleased uses remain an audit item.
- The snapshot still contains other engine-local pointers (functions, module
  descriptors, types, and descriptors). The new lease only establishes the
  public AST context lifetime.
- The current identity adapter reconstructs the stable key from Engine-local
  metadata. Its float-width normalization is now covered, but direct
  Sema-carried declaration identity remains the stronger final architecture.
- It does not complete semantic authority, foreign generation-aware AST IDs,
  `CompileFunction` retention/merge, Cache V2 DTO fidelity, full CodeGen, or
  the default LEGACY-to-CANONICAL pipeline cutover.
- No OpenSpec task checkbox is changed by this bounded repair.
