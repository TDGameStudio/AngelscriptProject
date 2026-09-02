# Canonical interface publication implementation review — 2026-08-29

## Review verdict

> **Superseded by follow-up rereview:** the verdict below describes the
> evidence available when commits `e474dc4` / `d6fcfb76` were created. A later
> independent static audit reopened three publication-transaction gates. See
> `canonical-interface-publication-followup-review-2026-08-29.md`. The original
> verdict is retained as review history, not as the current merge verdict.

No blocking correctness or architecture finding remains in the implemented
Approach A interface-publication slice after the final RED/GREEN cycle and
broad regression matrix. The slice is suitable for its plugin-first and
parent-gitlink/OpenSpec commits.

This verdict is deliberately narrower than the whole change. It does not
approve default CANONICAL cutover, full 9.5 language/lifetime coverage,
complete 13.2 semantic independence, Standalone adaptation, or retirement of
the native AngelScript AST.

## Findings resolved during implementation

### High — Prepared Hot Reload selected Runtime type identity globally

The first implementation used general stable-key lookup while an old and new
same-name generation were both live. That made a valid current Builder type
ambiguous. The corrected design carries the exact sealed stable declaration
key on `sClassDeclaration` and supplies a current-module transient type view to
all later bridge resolution. This is the right ownership boundary: the stable
key is durable identity; the pointer and numeric TypeId are projections owned
by one generation.

### High — Prepared graph failure could leave source metadata published

Source coordinates were copied onto the Stage 2 shell before read-only graph
authentication. Moving `FillFunctionSourceMetadata()` after body detachment
restores transaction symmetry: metadata, bytecode and references now share the
same candidate `ScriptFunctionData` lifetime.

### High — pure-constant flags were outside rollback

The property and Builder-description flags could be mutated before a later
body failure. Both original values are now journaled, restored by
`RollbackPreparedGlobals()` and published only by `CommitPreparedGlobals()`.

### Medium — native PreClass edges used the wrong Runtime field

The Canonical graph correctly contains a class-like native type view, but the
prepared Runtime representation uses `shadowType`; treating it as
`derivedFrom` rejected a legal shell. The authentication code now explicitly
separates projected native bases from authored script bases.

### Medium — expected dispatch planning could read the graph under review

A local authored function with a live Stage 2 `vfTableIdx` could previously
seed the expected plan, making authentication partially self-referential. The
planner now accepts a live slot only for external Runtime dependencies with no
local object binding. Current-batch slots must be derived from the completed
sealed relation plan.

### Medium — detached and Prepared ownership shared one attachment helper

Removing Runtime rematching from detached publication initially prevented
Prepared-only generated accessors from entering their Stage 2 owner. Call-site
ownership is now explicit: detached Commit installs the complete validated
plan; Prepared generated closure appends only new Sema-generated methods that
had no Stage 2 shell.

## Architecture assessment

### Semantic authority

The strongest part of the design is that interface implementation selection
now has one authoritative home. Canonical Sema records exact declaration
edges; the verifier proves ancestry, exact Canonical callable signature,
uniqueness and complete interface coverage. CodeGen no longer asks “which
method matches this requirement?” It asks only “does this exact declaration
binding produce the mechanically expected Runtime graph?”

This is materially closer to the useful Clang AST pattern than the former
Builder/Runtime arrangement: semantic relationships are explicit typed AST
facts, downstream consumers use stable declaration identity, and target ABI
state is created later in a generation-owned lowering context. It is not a
claim of Clang API or ownership parity; it is the same separation of semantic
identity from backend-local representation.

### Detached versus Prepared publication

The two paths now have intentionally different graph ownership:

- Detached CodeGen owns candidate type/function shells and the dispatch graph;
  it prepares everything off to the side and installs through Commit.
- Prepared Stage 2 already owns the live candidate graph; CodeGen recomputes an
  expected non-owning plan and compares it read-only before detaching bodies or
  global state.

That distinction avoids an unsafe “half transaction” in which Prepared
CodeGen could mutate method/vtable arrays that ordinary body rollback does not
own. Failure is fail-closed; there is no repair, name fallback or legacy
compiler invocation.

### Runtime identity model

The dynamic TypeId problem is handled by separating three identities:

1. Canonical stable type/declaration key — durable nominal identity.
2. Snapshot/generation owner — determines which declaration and Runtime view
   the key belongs to.
3. Runtime pointer/numeric TypeId/FunctionId/vtable coordinates — local
   installation state for that generation only.

The `preparedRuntimeTypes` view shadows older published types during one
prepared transaction, but it still rejects duplicate matches inside the
current candidate. This keeps Hot Reload deterministic without pretending a
numeric TypeId is stable across rebuilds. It also avoids persisting a Runtime
pointer or scanning a dump to restore identity.

### Transaction and lifetime discipline

Source metadata, body data, reference acquisition, global constant flags,
constant storage, initializer ownership, publisher and digest now have visible
candidate/rollback/commit phases. The new tests deliberately reuse the same
Builder after failure, which is stronger evidence than checking only that one
call returned an error.

The interface projection also accounts for independent Runtime reference
ownership by method tables and every vtable occurrence. Interface pointer
arrays remain non-owning as required by the maintained fork.

## Static source audit

- Final scan finds no `DoesMethodExist` or
  `IsSignatureExceptNameAndReturnTypeEqual` call in
  `as_bytecode_codegen.cpp`.
- The retained complete-signature comparison is a compatibility de-duplication
  predicate for inherited interface method inventory. It runs after exact
  interface/method identity is established and does not choose an
  implementation.
- `methodRelations` are consumed only as exact declaration-edge inputs.
- `interfaceVFTOffsets` and `vfTableIdx` are validated/published as Runtime
  projection state and do not enter the Sidecar or Public AST.
- Prepared object binding uses producer-carried record identity, not a
  same-name engine search.

## Residual risks and follow-up ownership

### Stable-key capture must remain ephemeral

`sClassDeclaration::canonicalASTStableDeclKey` is valid only while the Builder
and its sealed snapshot participate in the same generation. It must not become
a Cache V2 persistent pointer substitute or be compared without the snapshot/
generation boundary.

### Transient type shadowing is intentionally candidate-first

Future prepared declaration categories must add their current candidate types
to the same view before signature lowering. Falling back to global engine
enumeration when a same-key candidate exists would reopen the Hot Reload bug.
Conversely, two same-key entries inside the candidate view must remain an
error, not first-match selection.

### Source metadata belongs to detached body state

Future prepared body/factory additions must call source metadata publication
only after allocating their detached `ScriptFunctionData`. Writing source
coordinates to the Builder shell before all validate-only gates is a rollback
violation.

### Prepared graph authentication is not graph construction

If Stage 2 changes method ordering, interface DFS rules, offsets or vtable
layout, it must be updated to implement the same sealed plan and retain a
focused RED. CodeGen must not start “repairing” Stage 2 arrays, because body
rollback cannot restore them.

### Broader compiler work remains

The successful interface slice advances but does not close:

- 0.2 across every still-open compiler item;
- 4.3 remaining type/template/namespace authority;
- 4.5 remaining declaration registration/conflict/default/editor rules;
- 9.1 all declaration categories and publication boundaries;
- 9.5 complete language/lifetime/exception coverage;
- 13.2 remaining expression/statement/lifetime adapters; and
- 13.6 complete production backend and final cutover.

Standalone remains deferred by explicit user direction. The native
`asCScriptNode` AST remains retained for LEGACY/reference/syntax recovery and
future syntax-support comparison; only HIR stays removed.

## Verification reviewed

- Build: PASS.
- ProductionCodeGen: `135/135`.
- Compiler CanonicalAST: `614/614`.
- Frontend CanonicalAST: `175/175`.
- StaticJIT PrimaryCanonicalASTGenerate: `12/12`.
- Module CanonicalAST Snapshot: `10/10`.
- Hot Reload Canonical snapshot: `12/12`.
- Focused interface Sema: `6/6`.
- Focused interface Runtime dispatch: `9/9`.
- Cache ASTBodySidecar V8: `23/23`.

Exact report paths and every implementation RED are recorded in
`attachments/canonical-interface-publication-gate-2026-08-29.md`.

Final plugin implementation commit:
`e474dc4 [CanonicalAST] Refactor: authenticate prepared interface dispatch`.
