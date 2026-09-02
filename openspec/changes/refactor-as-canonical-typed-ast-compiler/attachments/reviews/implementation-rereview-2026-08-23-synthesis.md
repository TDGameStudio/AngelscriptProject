# Implementation rereview synthesis — 2026-08-23

Worktree: `D:\as-cta`  
Change: `refactor-as-canonical-typed-ast-compiler`

## Verdict

**Not ready to merge or switch the default pipeline.** The canonical path is
an increasingly useful opt-in subset, but the remaining blockers are still
semantic authority and publication correctness, not merely test count.

This attachment synthesizes the fifth and seventh independent source reviews.
Those reviews did not run builds themselves. Their saved-test observations are
historical evidence, not validation of the final dirty worktree.

## Findings that remain release/cutover blockers

1. **Canonical CodeGen is not a detached, atomic artifact installation.**
   Type/global/import/function state can still become engine/module-visible
   during generation. A failed route needs either genuinely detached storage
   or a complete transaction journal across every affected table, ID allocator,
   behaviour table, and module collection.
2. **Canonical coverage must be exact or fail closed.** Every declaration
   shape needs a supported ownership/namespace/type-install route or a
   pre-mutation stable rejection. Successful build must never silently omit
   declarations or register a member as a global.
3. **Verifier completeness remains below the spec sentence.** Exact
   declaration/statement/expression ownership, cycles, nearest transfer
   targets, required callees/destructors, switch/fallthrough structure,
   signature/stable-reference checks, and cleanup plans are still required
   before treating the sealed graph as backend authority.
4. **Cache V2 AST restoration is not an exact body DTO.** Body semantics,
   profile/source identity, resolved links, lifetimes, and dependency fidelity
   need pointer-free encoding, exact reconstruction, verification, and
   body/profile change invalidation before ExactStartup claims.
5. **Parser/Sema and SourceManager are not yet authoritative.** The parser
   still feeds substantial meaning through `asCScriptNode` and source remap
   does not fully validate content/line identity. This prevents 13.2 and
   default-cutover closure.

## Findings superseded by subsequent verified repairs

The reviews correctly identified these boundaries at the time. They are now
partly or fully repaired by later, narrower work and must not be repeated as
live findings without a new source review:

- Public AST V1 view capacity/version handling and the trailing-vtable
  placement were repaired; see `public-ast-v1-view-size-contract.md` and
  `public-ast-v1-trailing-vtable.md`.
- Public snapshot acquire/publication now shares a lifetime gate and atomic
  current-generation state; see `public-ast-v1-atomic-publication.md`.
- StaticJIT generation snapshots now own public V1 AST leases rather than
  borrowing their raw context; see `staticjit-generation-snapshot-lease.md`.
- Successful `CompileFunction(asCOMP_ADD_TO_MODULE)` now invalidates an
  incomplete current AST rather than publishing stale authority; see
  `compilefunction-retained-snapshot-invalidation.md`.
- The bounded class-type and `DECL_IMPORT` rollback holes have source-level
  RED-to-GREEN coverage: a later CodeGen emitter failure now removes their
  module and engine entries and permits a same-module retry. This is a
  compensating journal for the exercised paths, **not** evidence that finding
  1's broader detached/complete-transaction requirement is closed; see
  `canonical-codegen-transaction-rollback-2026-08-23.md`.
- Generated class methods, constructors, and destructors are now associated
  with their `asCObjectType` only at Commit, after every body emits. This
  removes a pre-rollback stale-ID teardown ordering; it is still not a claim
  of complete CodeGen declaration coverage or detached publication.
- The default LEGACY lambda layout and narrow-width CodeGen ABI findings need
  current-source rereview, because subsequent focused tests/repairs landed;
  historical review text alone is not proof that they remain live.

## Next implementation priority

Keep the default pipeline LEGACY. Before broad language expansion, treat
production canonical CodeGen installation as a transaction boundary:

```text
sealed verified AST
  -> validate complete supported declaration graph
  -> emit detached descriptions/bytecode/references
  -> validate artifact
  -> one publication transaction (or complete rollback journal)
  -> publish AST and module state together
```

Add adversarial production tests for declaration coverage and injected failure
at each install boundary. A green compatibility suite or a true `Ready()`
capability flag is not sufficient evidence for Wave G.
