# Canonical module candidate-replacement design — 2026-08-23

## Trigger and red test

`asCModule::Build()` currently calls `InternalReset()` before it parses,
seals, or emits the next source generation.  The bytecode CodeGen artifact
now keeps its own types, globals, imports, and script functions detached until
`Commit()`, but that local transaction cannot recover a module generation that
was already destroyed by the caller.

The new production regression
`CanonicalFailedRebuildKeepsLastSuccessfulModuleExecutable` demonstrates the
observable failure:

```text
generation A: int Stable() { return 7; }       -> Build succeeds, Stable() == 7
generation B: int Broken() { try { ... } ... } -> Canonical Build rejects it
expected: generation A remains published and executable
actual:   Module->GetFunctionByDecl("int Stable()") is null
```

The focused RED evidence is
`Saved/Tests/cta-failed-rebuild-red/20260823_131813_592_c0c0fc46/RunMetadata.json`:
`0/1` passed, with the sole assertion failure at the retained `Stable()`
lookup.  The initial generation did compile and execute; this is neither a
fixture nor a runtime-context failure.

## Why simply delaying `InternalReset()` is not safe

It is tempting to leave the active module alone until the new CodeGen has
returned success.  That alone is not a valid replacement protocol:

1. The builder and Sema would still see old `globalFunctions`, local types,
   and engine availability maps.  New source could accidentally resolve a
   declaration from the old generation.
2. A same-name script type would be rejected as a redeclaration, even though
   replacement is supposed to create a new generation of that type.
3. Committing candidate declarations directly into the active module leaves
   both old and new owner lists alive.  A later reset would then also destroy
   new declarations.
4. A separate engine module would change the `asIScriptModule*` identity seen
   by callers, snapshots, the editor, and cache consumers.  That is not an
   acceptable implementation shortcut.

The build lock obtained by `engine->RequestBuild()` means no competing build
can consume IDs during this transaction.  It does *not* make stale
declarations semantically safe.

## Selected protocol: private staging owner plus in-place promotion

The canonical branch of `asCModule::Build()` gains a private, unregistered
`asCModule` candidate.  It is an implementation owner only: it is never added
to `engine->scriptModules` or `scriptModulesByName`, and callers keep the
original module pointer throughout.

```text
              active module A (public identity; generation N)
                         |
       temporarily hide A's availability entries
                         |
                         v
builder source + AST/Sema ---> candidate owner C (not engine-registered)
                                    |
                                    | detached CodeGen artifact -> C Commit
                                    v
                         candidate generation N+1 is internally complete
                                    |
                  +-----------------+-----------------+
                  |                                   |
               failure                              success
                  |                                   |
      destroy C, restore A visibility      reset A's old generation
      keep A snapshot/functions            retarget and swap C ownership into A
                  |                                   |
                  +-----------------+-----------------+
                                    |
                         publish generation N+1 snapshot
```

### Phase 1 — build the candidate in an isolated semantic owner

- Preserve active `A`'s executable containers and immutable snapshot.
- Remove only `A`'s current script declaration/global/function *availability*
  entries while compilation is in progress.  Their owning arrays and Engine
  function/global storage remain intact, so the running generation can be
  restored without re-parsing.
- Construct `C` with the same Engine, default namespace, access mask, imported
  module view, and build-artifact callback configuration needed by the build.
- Rebind the already accumulated source builder to `C` before parse/Sema.  The
  original module owns the builder allocation; `C` never owns that pointer.
  This prevents canonical Sema from finding declarations in A's local owner
  tables.
- Parse and seal using that candidate owner.  Generate bytecode into C.  The
  existing CodeGen artifact remains the inner transaction: its function,
  import, global-property, and script-type entries stay detached until its
  own commit.

### Phase 2 — failure path

For parse, seal, publication-verifier, or CodeGen failure:

1. delete the source builder and candidate owner;
2. restore exactly A's previously hidden availability entries;
3. do **not** call `A.InternalReset()`;
4. retain the last successful publisher/digest and snapshot generation;
5. finish the Engine build request and return the canonical diagnostic.

No new snapshot is published.  An existing snapshot lease remains current.

### Phase 3 — promotion on success

Once `C` has successfully committed a complete CodeGen result:

1. destroy A's former executable generation with `A.InternalReset()`;
2. swap the candidate-owned, allocation-free containers into A (functions,
   global-function map/list, imports, globals map/list, script type lists,
   local-type map, and any supported type side tables);
3. retarget every moved function, imported signature, global property, and
   local script type from owner `C` to owner `A`;
4. retain the Engine function/global/type slots already installed by the
   candidate; only the module owner pointer changes;
5. move the candidate CodeGen publisher/digest metadata to A, discard C's
   now-empty containers, adopt the sealed AST on A, then run the existing JIT,
   `PrepareEngine`, snapshot publication, and global-init steps.

The transfer uses container `SwapWith` operations rather than re-inserting
each declaration after the old module has been reset.  This avoids a second
allocation/partial-publication window in the promotion phase.  `asCMapByName`
needs the same private `SwapWith` capability already present on
`asCArray`/`asCSymbolMap`.

## Ownership and visibility matrix

| State | Active A owns old | Candidate C owns new | Engine availability | Public module pointer |
|---|---:|---:|---|---|
| Before build | yes | no | A | A |
| Parse/seal | yes | metadata only | A entries hidden | A |
| CodeGen before commit | yes | detached artifact | A entries hidden | A |
| Candidate committed | yes | yes | C entries | A |
| Candidate failure | yes | destroyed | A restored | A |
| Promotion success | old destroyed | moved into A | promoted entries | A |

`funcdef`, enum, typedef, template-instance, external declaration, and class
reload/reference-update surfaces are not treated as implicitly supported by
this first promotion slice.  The transfer helper must either move each one
with its documented Engine registry or reject candidate promotion before
mutating A.  The canonical CodeGen currently publishes script object types,
globals, imports, and script functions; that is the initial supported set.

## Non-goals and safety boundary

- This protocol does not change `LEGACY` build behavior.
- It does not make unsupported Canonical constructs (`try/catch`, unlowered
  fallthrough, incomplete funcdef/lambda/container paths, and similar) valid.
- It is not a Cache V2 restore protocol and must not reinterpret cache
  ownership.
- It does not alter public `asIScriptModule` ABI or engine module registries.
- It does not claim all allocator-failure paths are transactionally proven;
  promotion is deliberately limited to allocation-free swaps after CodeGen
  has completed.

## Required tests before marking R09 complete

1. The RED regression above turns green: failed replacement keeps the same
   public module, old function, and executable result.
2. A successful function-only replacement proves old symbols disappear and
   new symbols execute through the original module pointer.
3. A same-name script-type replacement proves old type visibility is hidden
   during candidate CodeGen, new type ownership is retargeted to A, and
   `Discard()` removes it from `allScriptDeclaredTypes`.
4. A retained-AST snapshot test proves failed generation B leaves generation A
   current, while successful B advances the generation and keeps A leases
   traversable.
5. Existing transaction tests continue to prove that a failure inside
   `asCBytecodeCodeGen::Generate()` publishes no candidate table entries.

Until those tests and the broader Canonical language closure pass, task 13.6
remains intentionally unchecked.

## Implemented evidence — 2026-08-23

The selected protocol is now implemented for the currently supported
Canonical declaration set. The public `asIScriptModule*` remains `A`; `C` is
not inserted into the engine module registry. On a failed parse/seal/CodeGen,
the candidate is deleted and `A`'s hidden lookup availability is restored. On
success, A resets only after C has committed; owned containers are swapped into
A and owner pointers are retargeted without a second publication/allocation
phase.

Focused production evidence:

- failed rebuild retains and executes the previous function generation;
- successful rebuild replaces an old global function generation through the
  same public module pointer;
- successful same-name script-type rebuild replaces its type generation and
  `Discard()`/GC removes the promoted type from `allScriptDeclaredTypes`.
- a retained snapshot from the successful generation remains `current` after
  a rejected replacement; a fresh `AcquireASTSnapshot()` returns that same
  generation key rather than a partial or synthetic successor.

`Saved/Tests/cta-canonical-transaction-and-rebuild-regression/20260823_140315_025_f278eb11/RunMetadata.json`
records those three regressions as **3/3 PASS**. This closes the old
module-reset failure mode only; it is not evidence for funcdefs, Cache V2
restore, snapshot atomicity, or a default compiler-pipeline switch.

`Saved/Tests/cta-canonical-failed-rebuild-snapshot-green/20260823_141051_644_63c57e0f/RunMetadata.json`
records the retained-snapshot failure-path regression as **1/1 PASS**. It
proves current-generation preservation on the rejected source-build path, but
does not replace the separate concurrent Acquire/publish stress requirement.
