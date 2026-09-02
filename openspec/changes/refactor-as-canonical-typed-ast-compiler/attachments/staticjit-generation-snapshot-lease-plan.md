# StaticJIT generation snapshot — public AST lease plan

> Historical plan. Its StaticJIT snapshot-lease outcome remains active, while
> the HIR dump consumer referenced below was physically retired by CTA-HIR-03.
> See `hir-editor-dump-retirement-gate-2026-08-27.md`.

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`  
Date: 2026-08-23

## Why this is a real lifetime issue

`BuildAngelscriptStaticJITGenerationSnapshot()` currently records one raw
`asCASTContext*` in every `FAngelscriptStaticJITGenerationFunction` through
`asCModule::GetCanonicalASTContext()`. The TypedASTJIT backend later reads the
same `SealedAST` while doing eligibility, dependency analysis, emission, and
loop checks. A raw context pointer has no ownership relation to the immutable
generation snapshot.

The public V1 snapshot now has a guarded `AcquireASTSnapshot()` operation,
but that safety is lost if the StaticJIT capture path immediately bypasses it.
In particular, a module generation replacement can retire the module-owned
snapshot after the raw pointer was captured, while StaticJIT still owns its
generation snapshot.

The audit also found that `FAngelscriptHIRDumpCommand::Execute()` requests
`VerifiedTypedHIR` but did not request AST retention. StaticJIT artifact
generation already requests retention for this capture profile. The developer
dump must use the same prerequisite once the snapshot builder no longer
accepts an internal pending-context pointer.

## Narrow contract to establish

For a `VerifiedTypedHIR` StaticJIT generation graph:

```text
source module --AcquireASTSnapshot(V1)--> public snapshot lease
                                                |
                                                v
immutable generation snapshot owns lease ----> sealed context pointer
                                                |
                                                v
TypedASTJIT reads SealedAST only while the owning generation snapshot lives
```

The builder attempts to acquire one V1 public snapshot lease for each compiled
module before it records that module's function rows. When a module has
retained a public AST, this lease is retained by the immutable
`FAngelscriptStaticJITGenerationSnapshot`, not separately by each function.
Each function merely borrows the sealed context from the module's lease.

`VerifiedTypedHIR` makes the lease mandatory: a missing lease or a lease
without a sealed context fails capture. Bytecode capture deliberately keeps a
different compatibility rule: it may proceed without an AST, but if a caller
asked the module to retain one, the generation snapshot still owns that lease
and fills the function `SealedAST` identity fields. Existing AST-identity
fixtures use this latter Bytecode-plus-retention form; treating it as a typed
only feature would silently erase valid identity metadata.

The implementation uses an exported, RAII lease holder behind a thread-safe
`TSharedPtr`. This keeps the containing snapshot copyable and makes release
occur when the final generation-snapshot owner drops. It avoids storing
untyped `void*`, duplicating raw `AddRef`/`Release` operations at each function,
or trusting `asCModule`'s internal `pendingCanonicalAST` state.

## Failure behaviour

If typed capture is enabled and a compiled module does not expose a V1 lease,
or the lease does not yield a sealed canonical context, construction of the
generation snapshot fails closed with a module-specific diagnostic. It does
not fall back to `GetCanonicalASTContext()` and it does not silently emit a
typed graph that is missing the AST half of its same-compilation proof.

The project source-graph caller remains explicit about retention:

- StaticJIT artifact generation already sets `ASTRetentionPolicy = 1` for
  `VerifiedTypedHIR`.
- The developer HIR-dump request will set the same retention policy.

This is intentionally not a global rule that ordinary runtime compilation or
the LEGACY compiler must retain ASTs.

## Test-first boundary

The Standalone architecture CTest will first require that the StaticJIT
snapshot builder has no `GetCanonicalASTContext()` read, keeps named AST lease
owners on the immutable snapshot, calls `AcquireASTSnapshot`, and routes the
typed capture context through `asCASTSnapshot::GetContext()`. It will also
require that the developer HIR-dump request explicitly retains its AST.

A StaticJIT/primary HIR-dump narrow automation prefix will then confirm the
normal source-generation path still succeeds. The CTest is not a race detector;
the existing public snapshot acquire/rebuild stress test remains the concurrent
regression oracle for the underlying V1 lease protocol.

## Scope and non-claims

This is a bounded consumer migration inside the existing public AST V1 work.
It does **not** complete OpenSpec 13.7 or 13.8, nor Wave E:

- `GetCanonicalASTContext()` remains an unsafe internal compatibility API for
  callers not migrated by this package; its presence must not be interpreted
  as public lease ownership.
- The generation snapshot still contains other engine-local function, module,
  type, and descriptor pointers; those remain valid only during the owning
  generation engine/consumer lifetime.
- This does not solve foreign snapshot-local AST IDs, `CompileFunction`
  merge/retention, Cache V2 DTO fidelity, SourceManager lifetime, semantic
  authority, full CodeGen, or default-pipeline cutover.
- No task checkbox is changed by this bounded repair.
