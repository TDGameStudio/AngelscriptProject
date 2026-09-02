# Canonical constructor partial-construction evidence — 2026-08-29

## Status and scope

This attachment records the implementation and verification evidence for
CTA-S53 Task 15.9. The supported production slice is complete in the working
tree: Canonical Sema authors constructor lifetime facts, the shared lifetime
view and verifier authenticate them, Canonical Bytecode lowers them to a
committed-prefix VM protocol, detached/module restore re-authenticates the
physical identities, UASClass has an incomplete-object abort route, and
TypedASTJIT publishes a pointer-free typed fallback summary.

Task 15.9 is closed only together with the final OpenSpec validation, diff
audit and dual-repository commits recorded at the end of this attachment.

The following boundaries remain deliberate:

- Standalone is excluded and was neither changed nor run.
- The product default remains `LEGACY`.
- HIR remains physically absent and is not recreated by this work.
- Native `asCScriptNode` / `asCBuilder` / `asCCompiler` remain available for
  explicit LEGACY, syntax/recovery, reference and differential routes.
- There is no production `dual` backend and no silent LEGACY fallback.
- Task 15.10 owns array/aggregate committed cursors.
- The Canonical Parser/Sema does not yet author explicit `super(...)` or a
  same-class delegating-constructor source syntax. Task 15.9 authenticates the
  delegating typed shape for future source support; it does not claim that the
  current source language authors that shape.

## Implemented semantic model

### Sema-authored records

Every cleanup-requiring non-delegating constructor step is one
`asSASTLifetimeRecord`:

```text
subjectKind       = CONSTRUCTION_SUBOBJECT
subject           = exact base class or field Decl
actionKind        = DESTROY_VALUE or RELEASE_REFERENCE
actionTarget      = exact destructor Decl or owning-reference field Decl
activationPoint   = exact constructor init Expr; success commits the step
semanticRegion    = owning constructor Decl
phase             = CONSTRUCTOR_BASE or CONSTRUCTOR_MEMBER
supportedExitMask = EXCEPTION
constructionStep  = zero-based semantic execution order
completeCommit    = false
```

Primitive/POD members remain typed initializer expressions but do not enlarge
the abort cleanup prefix because they own no cleanup action.

A distinct final record represents complete-object commit:

```text
subjectKind       = CONSTRUCTION_SUBOBJECT
subject           = owner class Decl
actionKind        = DESTROY_VALUE
actionTarget      = exact complete-object destructor Decl
activationPoint   = constructor body block success boundary
semanticRegion    = owning constructor Decl
phase             = COMPLETE_OBJECT
supportedExitMask = NORMAL
constructionStep  = number of cleanup-requiring base/member steps
completeCommit    = true
```

Generated constructors receive a typed empty body when necessary, so complete
commit has a distinct statement-success boundary and is never inferred from
the final initializer.

The authenticated future delegating shape is deliberately different:

```text
subjectKind       = CONSTRUCTION_SUBOBJECT
subject           = owner class Decl
actionKind        = DESTROY_VALUE
actionTarget      = exact complete-object destructor Decl
activationPoint   = exact same-owner delegating constructor call Expr
semanticRegion    = owning delegating constructor Decl
phase             = CONSTRUCTOR_DELEGATING
supportedExitMask = EXCEPTION
constructionStep  = 0
completeCommit    = true
```

Successful return from the delegating target completes the object. A later
failure in the delegating body must therefore be able to reach the full
destructor. The verifier forbids base/member records or a second body-success
complete record in that plan. This follows the Clang/C++ lifetime model
recorded in
`../reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md` without
inventing a new AngelScript source syntax.

### Shared deterministic construction view

`asCASTBuildLifetimeView()` derives one construction plan per constructor:

```text
Constructor Decl
  ordered record indices
  complete-object record index

step N success:
  liveBefore   = records [0, N)
  liveAfter    = records [0, N]
  abortCleanup = reverse(records [0, N))

non-delegating complete success:
  liveBefore = all committed base/member records
  liveAfter  = base/member records + complete-object record

delegating target success:
  liveBefore   = empty
  liveAfter    = delegating complete-object record
  body failure = complete-object cleanup
```

Construction records do not manufacture lexical compatibility cleanup
statements or normal/transfer/foreach exit plans. They use the typed
construction plan and success-sensitive commit points instead, so a normal
constructor return cannot accidentally destroy the object it completed.

The verifier rejects wrong owner, subject, action, activation, phase, order,
step, complete boundary or revision; gaps and duplicates; a failed-current
step in abort cleanup; base/member disagreement with the exact initializer;
foreign IDs; invalid delegating ownership; multiple/early complete commits;
and lexical compatibility cleanup encodings attached to construction records.
Repeated view construction produces the same construction plan and structural
digest.

## Implemented Canonical Bytecode and VM protocol

The snapshot protocol remains pointer-free. Canonical CodeGen resolves the
authenticated plan into generation-local Runtime operands in
`ScriptFunctionData`:

- `constructorCleanupInfo` is a linear physical directory in semantic
  construction order;
- `constructorCommittedCountOffset` names a private `ttUInt` VM-frame dword;
- each physical entry carries the already-selected cleanup kind, Runtime
  type/action identity and receiver-relative object offset;
- the committed-count slot is published through the Runtime/JIT scalar
  temporary directory but is excluded from the optimizer's disposable
  temporary set.

The early implementation card proposed zero-sized commit markers. The final
implementation intentionally does not use that mechanism. CodeGen initializes
the private dword to zero and emits `asBC_SetV4` only after an authenticated
initializer succeeds. This preserves success sensitivity directly in emitted
bytecode and gives VM, BytecodeJIT and detached restore one exact frame state
to authenticate:

```text
committed = 0
base succeeds       -> committed = 1
member A succeeds   -> committed = 2
member B throws     -> cleanup entries [1, 0]
complete succeeds   -> committed = cleanup directory length
```

For non-delegating reference objects, Canonical CodeGen emits
`asBC_FinConstruct` after the body and normal local cleanup succeed but before
publishing the complete-object committed count. If the finish hook itself
fails, exception cleanup still reaches only the committed base/member prefix.

On exception, the VM:

1. reads and clears the private committed count before invoking cleanup;
2. clamps corrupted state to the authenticated physical directory length;
3. destroys/releases only the committed prefix in strict reverse order;
4. excludes the failed current step;
5. reaches only the complete-object action if a complete record was committed;
6. authenticates the immediately calling `ALLOC` before retiring a pending
   raw allocation;
7. clears the caller destination before any re-entrant retirement hook;
8. frees raw SDK storage, or calls the UASClass incomplete-object abort route,
   without invoking the complete destructor a second time.

Canonical factory allocations are non-owning but JIT-addressable while
construction is pending. Their physical metadata is:

- `partialConstructionObjectType`;
- `partialConstructionObjectOffset`;
- `partialConstructionConstructorId`.

They are deliberately absent from the ordinary owning object-variable cleanup
directory. Successful `LOADOBJ` clears the pending allocation role; an abort
frees only storage after the constructor frame has already unwound its exact
committed prefix.

For UObjects, `UASClass::AbortConstructObject()` removes the matching active
initializer and marks the incomplete UObject as garbage. It does not publish
script defaults and does not route through the complete AngelScript
destructor. Normal UObject GC owns final storage reclamation.

## Artifact serialization and restore authentication

The physical cleanup directory is retained by both detached function
artifacts and complete module bytecode. Runtime pointers and numeric function
IDs are serialized through the existing semantic type/function/property
reference tables and resolved against the receiving Engine generation.

The version changes are intentional and fail closed:

- module bytecode stream: revision `2 -> 3`;
- detached function artifact stream: revision `5 -> 6`.

Restore validates the mutually dependent semantic tail as one protocol. For a
constructor it requires a valid committed-count coordinate and non-empty
cleanup directory. For a partial factory it requires the exact object type,
constructor and coordinate. It rejects negative or beyond-`variableSpace`
coordinates.

An in-range pointer coordinate alone is not sufficient authority. Restore
cross-authenticates the semantic tail against the exact generated factory
bytecode role:

- the function is a global factory;
- its return type is a handle of the authenticated partial object type;
- exactly one `PSF` addresses the authenticated slot;
- exactly one `ALLOC` names the authenticated type and constructor;
- exactly one `LOADOBJ` clears that same slot;
- the order is strictly `PSF < ALLOC < LOADOBJ`.

This prevents a forged artifact from redirecting exception cleanup to an
unrelated but otherwise in-frame pointer local.

After stack translation, restore deterministically reconstructs:

- the committed-count `ttUInt` Runtime/JIT scalar directory entry; and
- the non-owning factory pointer directory entry.

It does not rediscover either identity by destructor spelling, dump text,
type-family heuristics or incidental debug tables.

## TypedASTJIT and Provider result

TypedASTJIT consumes the same authenticated shared lifetime view. It copies a
pointer-free partial-construction summary containing stable/ABI action and
phase identity, not snapshot/protocol pointers, snapshot-local IDs or dynamic
Engine numeric TypeIds.

The current native emitter does not have a complete native object-frame ABI.
It therefore records cleanup plan state `PartialConstruction` and emits the
precise per-function fallback reason
`AuthenticatedConstructorPartialConstructionRequiresNativeObjectFrameABI`.
It does not publish a partial native cleanup plan, does not enable a production
dual path, and does not silently invoke the LEGACY compiler.

Provider validation distinguishes construction commits from lexical transfer
cleanup. An authenticated `PartialConstruction` summary may have zero lexical
exit plans; an ordinary non-empty lexical cleanup summary must still carry its
authenticated exit plans.

## TDD issue ledger and resolutions

1. **CTA-S53-15.9-I1 — protocol fields existed without a legal construction
   view.** `constructionStep` and complete-object enum values were
   foundation-only and rejected by view construction. Resolved by the typed
   per-constructor derived plan, deterministic hash participation and verifier
   matrix.
2. **CTA-S53-15.9-I2 — Canonical source has no explicit-super/delegating Sema
   action.** Resolved only at the correct boundary: authenticate the typed
   future delegating shape, test its verifier/AOT behavior, and retain the
   source-language limitation as an explicit non-claim.
3. **CTA-S53-15.9-I3 — whole-object cleanup on raw allocation failure was not a
   committed-prefix protocol.** Resolved with the Sema-authored plan, physical
   cleanup directory, committed-count frame state and non-owning pending
   factory allocation.
4. **CTA-S53-15.9-I4 — Canonical constructors omitted `asBC_FinConstruct`.**
   Resolved by emitting it only at the authenticated non-delegating completion
   boundary, before complete commit.
5. **CTA-S53-15.9-I5 — the first design delayed delegating complete commit
   until body success.** Corrected to make successful target-constructor return
   the sole complete commit, matching the Clang/C++ lifetime rule.
6. **CTA-S53-15.9-I6 — optimizer-disposable temporary and Runtime scalar local
   are different roles.** The first committed-count slot could be removed or
   reused by ordinary temporary optimization. Resolved with a dedicated
   Runtime scalar allocation that remains in the JIT directory but outside the
   disposable temporary set.
7. **CTA-S53-15.9-I7 — detached restore lost the Runtime scalar directory.** A
   restored committed-count coordinate was not enough for BytecodeJIT address
   resolution. Resolved by reconstructing the exact `ttUInt` directory entry
   from authenticated metadata after stack translation.
8. **CTA-S53-15.9-I8 — factory raw allocation needed two apparently conflicting
   properties.** It must not be an owning object local, but PSF/LOADOBJ and JIT
   must address it. Resolved as a non-owning, JIT-addressable pointer local and
   deterministic restore directory entry.
9. **CTA-S53-15.9-I9 — Provider assumed every non-empty lifetime summary has a
   lexical exit plan.** Construction commits are success-sensitive progress,
   not lexical transfers. Resolved by admitting zero lexical plans only for an
   authenticated `PartialConstruction` summary.
10. **CTA-S53-15.9-I10 — partial factory coordinates lacked an upper-bound
    check.** A positive offset beyond `variableSpace` could reach outside the
    VM frame. An AST/artifact RED proved acceptance; restore now rejects it.
11. **CTA-S53-15.9-I11 — an in-range coordinate was not tied to the exact
    factory bytecode slot.** A forged tail could redirect cleanup to another
    pointer local. An artifact RED proved acceptance; restore now requires the
    exact unique `PSF/ALLOC/LOADOBJ` role and order.
12. **CTA-S53-15.9-I12 — the independent restore primitive test retained the
    old stream-v2 contract.** Updated the current contract to v3 and added an
    explicit fail-closed assertion proving v2 cannot carry constructor cleanup
    identities.

## RED/GREEN evidence

All paths are relative to the `D:\as-cta` worktree.

| Slice | RED evidence | GREEN evidence |
|---|---|---|
| Sema-authored construction facts | `Saved/Tests/cta-s53-15-9-sema-red-valid/20260829_001119_156_54e18c39` — `0/1`, no committed-prefix facts | `Saved/Tests/cta-s53-15-9-sema-green/20260829_003336_091_dcfa2f60` — `1/1` |
| Shared view/verifier matrix | verifier implementation began from the construction-view rejection gate; build `Saved/Build/cta-s53-15-9-verifier-red-build/20260829_002540_344_2cda5649` | `Saved/Tests/cta-s53-15-9-verifier-green/20260829_003258_244_572f911c` — `47/47` |
| Bytecode committed prefix and detached artifact | `Saved/Tests/cta-s53-15-9-artifact-red/20260829_014917_543_1696c439` — `0/1`, committed-count frame identity lost on restore | `Saved/Tests/cta-s53-15-9-artifact-reader-role/20260829_020749_298_3ddf5a04` — `1/1`; `Saved/Tests/cta-s53-15-9-module-roundtrip/20260829_021314_645_d8077fdc` — `1/1` |
| TypedASTJIT construction summary/fallback | `Saved/Tests/cta-s53-15-9-aot-construction-red/20260829_021725_716_aa345ca6` — `0/1` | `Saved/Tests/cta-s53-15-9-aot-construction-green/20260829_022057_855_04eb0181` — `1/1`; delegating future shape `Saved/Tests/cta-s53-15-9-aot-delegating/20260829_022306_876_df85d294` — `1/1` |
| UASClass incomplete-object abort | `Saved/Tests/cta-s53-15-9-uasclass-abort-red/20260829_023426_173_0bf56a96` — `0/1` | `Saved/Tests/cta-s53-15-9-uasclass-abort-green/20260829_024325_068_965d16f7` — `1/1` |
| Runtime/JIT committed-count directory | `Saved/Tests/cta-s53-15-9-jit-temp-directory-red2/20260829_025723_343_6031474c` — `0/1`, missing `ttUInt` directory identity | `Saved/Tests/cta-s53-15-9-jit-frame-restore-green/20260829_030123_329_bf478cd7` — `1/1` |
| Provider construction-vs-lexical distinction | `Saved/Tests/cta-s53-15-9-provider-partial-red/20260829_031250_064_27604f8c` — `0/1` | `Saved/Tests/cta-s53-15-9-provider-partial-green/20260829_031429_991_cc73bffc` — `1/1` |
| Partial factory upper bound | build `Saved/Build/cta-s53-15-9-factory-offset-red-build/20260829_033232_782_d5ec6e61`; test `Saved/Tests/cta-s53-15-9-factory-offset-red/20260829_033300_201_dfff4fa9` — `0/1` | build `Saved/Build/cta-s53-15-9-factory-offset-green-build/20260829_033420_235_2878bbf2`; test `Saved/Tests/cta-s53-15-9-factory-offset-green/20260829_033600_898_a4ab965d` — `1/1` |
| Partial factory exact slot authentication | build `Saved/Build/cta-s53-15-9-factory-slot-auth-red-build/20260829_034458_886_1d42b4bb`; test `Saved/Tests/cta-s53-15-9-factory-slot-auth-red/20260829_034516_449_2aa10d2a` — `0/1` | build `Saved/Build/cta-s53-15-9-factory-slot-auth-green-build/20260829_034652_362_37b3ba31`; test `Saved/Tests/cta-s53-15-9-factory-slot-auth-green/20260829_034705_975_bbb5d532` — `1/1` |
| Bytecode stream revision contract | `Saved/Tests/cta-s53-15-9-bytecode-stream-version-red/20260829_034145_422_39df6cf4` — `0/1`, stale v2 expectation | build `Saved/Build/cta-s53-15-9-bytecode-stream-version-green-build/20260829_034245_633_17d8a403`; test `Saved/Tests/cta-s53-15-9-bytecode-stream-version-green/20260829_034301_702_49e4ab25` — `1/1` |

## Final regression evidence

The final implementation build after the static restore audit passed:

- `Saved/Build/cta-s53-15-9-static-audit-build/20260829_035017_303_d1ea503c`

Relevant full/focused automation gates are green:

| Gate | Result | Evidence |
|---|---:|---|
| ProductionCodeGen + RestorePrimitives | 129/129 | `Saved/Tests/cta-s53-15-9-production-restore-full-green/20260829_035033_950_9d73ad79` |
| TypedASTJIT | 50/50 | `Saved/Tests/cta-s53-15-9-typedastjit-full-green/20260829_031607_804_795840aa` |
| Canonical SemaAuthority | 402/402 | `Saved/Tests/cta-s53-15-9-sema-full-green/20260829_032415_914_15c5b586` |
| Frontend CanonicalAST | 171/171 | `Saved/Tests/cta-s53-15-9-frontend-full-green/20260829_032506_463_c5627588` |
| UASClass ObjectConstruction | 2/2 | `Saved/Tests/cta-s53-15-9-asclass-construction-green/20260829_032547_085_616e7a46` |
| AOT installed diagnostics | 4/4 | `Saved/Tests/cta-s53-15-9-aot-installed-full-green/20260829_032630_885_53dc3318` |
| CodeGenTransaction regression | 20/20 | `Saved/Tests/cta-s53-15-9-codegen-transaction-regression2/20260829_024746_957_454d3adc` |

The six non-overlapping final gate groups in the first table total `758/758`
passing tests. The CodeGenTransaction gate is reported separately rather than
being folded into that total.

## Completion audit and non-claims

Task 15.9 proves the following supported shapes:

- source-authored default script base construction;
- cleanup-requiring value and owning-reference members in declaration order;
- zero, one and multiple committed cleanup steps;
- failure at a later step destroys only earlier committed steps in reverse;
- the failing current step is excluded;
- successful construction reaches a distinct complete commit;
- complete-object destruction is unreachable before that commit;
- authenticated delegating future typed shape and safe TypedASTJIT fallback;
- detached function and module artifact round trip;
- raw SDK allocation and UASClass incomplete-object retirement.

Task 15.9 does **not** prove or claim:

- source-level explicit `super(...)` or same-class delegating syntax in the
  current Canonical Parser/Sema;
- array/aggregate partial-construction cursors or nested aggregate unwinding;
- a native TypedASTJIT object-frame ABI;
- default Canonical cutover;
- Standalone parity;
- removal of the native AngelScript Parser AST, Builder or Compiler;
- resurrection of HIR;
- production dual-backend execution or silent LEGACY fallback;
- completion of the broader CTA-S53 boundary gate in Task 15.11.

Task 15.10 remains responsible for arrays/aggregates. Task 15.11 remains
responsible for the final Sidecar, typed structural identity, HIR absence,
native-LEGACY boundary, default-backend and pointer/numeric-TypeId leakage
scans.

## Closure evidence

- OpenSpec validation: `openspec validate
  "refactor-as-canonical-typed-ast-compiler"` passed on 2026-08-29.
- Plugin and parent `git diff --check`: passed on 2026-08-29; Git reported only
  the repository's LF-to-CRLF checkout warnings and no whitespace errors.
- Plugin staged diff audit: `27` expected files, `4063` insertions and `28`
  deletions; no unstaged drift or whitespace errors.
- Plugin commit: `cb32ef0 [CanonicalAST] Refactor: preserve constructor
  committed-prefix lifetime`.
- Parent OpenSpec/gitlink commit: this attachment, the checked Task 15.9 and
  the plugin gitlink are committed atomically; the containing parent commit is
  the authoritative identifier.
