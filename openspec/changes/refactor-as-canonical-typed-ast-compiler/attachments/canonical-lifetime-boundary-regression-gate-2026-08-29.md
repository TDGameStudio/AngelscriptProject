# CTA-S53 15.11: Canonical lifetime boundary and regression gate

Date: 2026-08-29
Status: Complete — implementation, required regressions, exact-warm restore, validation and source scans pass
Scope: `refactor-as-canonical-typed-ast-compiler` Task 15.11 only
Explicitly deferred: Standalone adaptation and Standalone validation

## Required outcome

Task 15.11 closes the boundary around the lifetime protocol completed by
Tasks 15.1-15.10. It must prove that a verified snapshot, its decoded Sidecar
form, Canonical Bytecode, detached artifacts and TypedASTJIT all preserve one
semantic authority without introducing HIR, a dump-driven compiler input,
durable Runtime identities, or an implicit LEGACY compiler fallback.

The accepted boundary is:

```text
Canonical Sema
    -> sealed, versioned, pointer-free lifetime records
    -> shared verifier-authenticated transient view
    -> Canonical Bytecode / VM and TypedASTJIT backend-local lowering

Sidecar / module stream / detached artifact
    -> stable semantic facts only
    -> generation-local Runtime resolution after decode
```

Product default remains LEGACY. Standalone is excluded by explicit user
direction and is not part of any result in this attachment.

## Issue chronology

### I1 — Sidecar V6 silently erased the Sema-authored lifetime protocol

The Task 15.10 claim that no schema bump was yet justified covered the record
shape, not the actual Sidecar payload. Static inspection of V6 showed that it
encoded source, types, declarations, statements and expressions, then sealed
the decoded Context without writing or reconstructing
`lifetimeProtocolRevision` or any `lifetimeRecords`.

This is semantic loss, not a transient-view reconstruction gap. Destructor or
release selection, activation point, semantic region/phase, supported exits,
construction step and complete-object commit are Sema decisions. A backend or
cache reader cannot legally guess them from expression shape without becoming
a second semantic compiler.

The AST-first test
`SidecarRoundTripPreservesCanonicalLifetimeProtocol` constructs a valid sealed
aggregate plan, encodes and decodes it, then compares protocol revision, record
count, typed protocol hash and every record field. After rebuilding the test
module, the unmodified V6 implementation produced the required semantic RED:

- `Saved/Tests/cta-s53-15-11-sidecar-lifetime-red/20260829_071120_475_75ba6d26`
- **22/23 PASS**, exactly one failure;
- failure: `Sidecar restore must not erase Sema-authored lifetime facts`.

An earlier stale-binary/no-match attempt is infrastructure evidence only and
is deliberately excluded from the behavioral ledger.

### I2 — Sidecar V7 is the minimal lossless repair

The valid RED satisfies the OpenSpec condition for a schema revision. V7
appends the protocol revision, record count and exact pointer-free record
fields after the existing expression DTOs. Node references persist only typed
node class plus graph-local ordinal; a nonzero `snapshotOwner` is rejected and
is never encoded. The decoder restores records through Context APIs before
`Seal()`, so the ordinary verifier authenticates the same protocol before the
snapshot becomes publishable.

V7 does not persist a pointer, Runtime object, numeric TypeId, backend label,
stack/frame coordinate, dynamic committed cursor or Provider object. The
graph-local ordinal is an internal DTO edge required to rebuild the candidate
snapshot; it is resolved before publication and is not a durable public
snapshot-owner token.

### I3 — the first V7 build exposed an `asDWORD`/`asUINT` decode mismatch

The initial implementation passed `record.supportedExitMask` directly to a
reader that accepts `asUINT&`, while the field is declared `asDWORD`. This was
a compile-time integration error rather than a semantic test result. Decode
now reads an `asUINT`, validates its bounds, and explicitly converts to the
record field. No stale DLL was counted as GREEN.

- failed integration build:
  `Saved/Build/cta-s53-15-11-sidecar-lifetime-green-build/20260829_071253_852_bdfa1f0c`;
- successful corrected build:
  `Saved/Build/cta-s53-15-11-sidecar-lifetime-green-build/20260829_071341_256_b4940446`.

### I4 — corrupted lifetime fields must destroy the candidate snapshot

Roundtrip equality alone did not prove the ownership/rollback boundary. The
AST-first test now corrupts the final `completeObjectCommit` value to an
out-of-domain value. Decode returns `asAST_SIDECAR_MALFORMED`, invokes the
common `DecodeFail` path, destroys the candidate Context and leaves no
publishable snapshot or retained candidate lifetime records.

The final Sidecar plus default-disabled Cache boundary is:

- `Saved/Tests/cta-s53-15-11-lifetime-cache-v7-boundary/20260829_071505_505_4f1e8fdb`;
- **30/30 PASS**, zero failures/skips.

### I5 — the original Builder boundary wording contradicted accepted Task 13.1

The first Task 15.11 wording said native Parser AST/Builder/Compiler were used
only by explicit LEGACY routes. Source inspection found the already accepted
prepared-module architecture still passes `asCBuilder&` into
`asCBytecodeCodeGen::GeneratePreparedModule()`. This Builder carries the
Stage 1/2 Runtime module, Engine, type/function/import registration shells and
transaction state.

That is not legacy expression/statement semantic authority. The CANONICAL
path does not traverse `asCScriptNode` structure there, invoke `asCCompiler`,
or reconstruct body semantics from Builder. Task 13.1 and existing
architecture records explicitly accept this shared Runtime shell.

The corrected normative boundary is therefore:

- native `asCScriptNode` semantic traversal and `asCCompiler` function-body
  publication are confined to explicit LEGACY/syntax/recovery/reference
  routes;
- CANONICAL may reuse `asCBuilder` only as a non-semantic prepared Stage 1/2
  Runtime registration/transaction shell;
- CANONICAL must not derive expression/statement semantics from the native
  tree or invoke the legacy compiler;
- one build still has exactly one publishing compiler and no silent fallback.

This correction is reflected in `tasks.md`, `design.md`, `proposal.md` and the
Clang lifetime review. It does not broaden CANONICAL semantic authority or
schedule native AST deletion.

### I6 — the additional ExactWarm gate exposed a public-ID/internal-ID test mismatch

Task 15.11 requires the Sidecar/default-disabled Cache gate. An additional
ExactWarmStartup run was added because exact warm restore is the strongest
integration consumer of the decoded snapshot. Its first final-source run was
**10/15 PASS**. One normal retained-snapshot assertion passed the public AST V1
owner-qualified `ChildId` directly to the internal graph-local
`asCASTContext::GetDecl()` API. The Context correctly rejected that ID as
foreign; after the concrete snapshot selected the owning Context, the test now
uses the graph-local ordinal for the internal lookup.

The same run found that four negative mutation helpers still walked an older
Sidecar field layout. They skipped source bytes but not the appended source
provenance-range table, so they mutated unrelated bytes rather than the enum,
declaration, type and statement-owner fields named by the tests.

- first integration run:
  `Saved/Tests/cta-s53-15-11-final-exact-warm-start/20260829_072830_598_60eaba15`;
- result: **10/15 PASS**;
- production restore remained fail-closed; the failures were assertions that
  the intended corruptions had not reached their target fields.

### I7 — the first mutation-walker repair exposed one more schema omission

Shared bounded helpers now read Sidecar integers, skip byte ranges, skip source
anchors and skip the complete source-provenance range table. The first repair
raised ExactWarmStartup to **12/15 PASS**. The remaining declaration-mutation
tests then exposed a second stale assumption: their declaration walkers omitted
the `accessSpecifier` field between `accessorField` and `origin`.

- first repair build:
  `Saved/Build/cta-s53-15-11-exact-warm-fix-build/20260829_073217_890_b2b3f21f`;
- first repair run:
  `Saved/Tests/cta-s53-15-11-final-exact-warm-start-green/20260829_073235_370_70d33513`;
- result: **12/15 PASS**.

### I8 — exact-warm corruption coverage is current without weakening production decode

After both declaration walkers account for `accessSpecifier`, the second build
and full ExactWarmStartup gate pass:

- build:
  `Saved/Build/cta-s53-15-11-exact-warm-fix2-build/20260829_073456_294_ce4f5d54`;
- run:
  `Saved/Tests/cta-s53-15-11-final-exact-warm-start-green2/20260829_073513_634_5ed4b8ce`;
- result: **15/15 PASS**, zero failures/skips.

No production decoder, owner check, verifier rule or retained-policy validation
was relaxed. The changes only make the negative test walkers match Sidecar V7
and distinguish public owner-qualified IDs from internal graph-local ordinals.

## Boundary audit

### Typed structural identity

TypedASTJIT lifetime identity uses domain-separated
`FAngelscriptArtifactCanonicalWriter` inputs:

- `CanonicalLifetimeRecord.v2`;
- `CanonicalLifetimeSummary.v2`;
- `CanonicalLifetimeABI.v2`.

The inputs are verified typed action/subject/owner identities, protocol shape,
aggregate element count and nested parent ordinal. Dump text, JSON and DOT are
diagnostic outputs only and are not read by the compiler, cache or Provider.

### HIR and compiler selection

- Function-owned TypedSemantic HIR implementation, storage, accessors, build
  symbols and production consumers remain physically absent.
- Remaining production `HIR` text matches are provenance/retirement comments,
  not types or consumers.
- `asCOMPILER_PIPELINE_DUAL` remains absent.
- Product defaults remain `canonicalCompilerPipeline = false` and
  `bUseCanonicalStagedCompiler = false`.
- Explicit opt-in selects CANONICAL; there is no unsupported-node automatic
  fallback into `asCCompiler`.

### Durable identity and ownership

- Detached and Provider-facing facts use stable type ABI/member identities and
  typed hashes, never Runtime pointers or public numeric TypeIds.
- Snapshot-local typed IDs are consumed only while the leased snapshot is
  alive; no raw `Decl`/`Stmt`/`Expr`/lifetime pointer crosses the Provider
  boundary.
- Generation-local relocation may contain resolved pointers or public TypeIds
  only after stable identity/ABI validation under the owning generation lease.
- Sidecar decode and detached/module restore build candidates transactionally;
  malformed input is rejected before publication and candidate ownership is
  released through the common failure path.

## Evidence ledger

| Gate | Evidence | Result |
|---|---|---|
| AST-first Sidecar RED | `Saved/Tests/cta-s53-15-11-sidecar-lifetime-red/20260829_071120_475_75ba6d26` | **22/23 PASS**, the sole failure proves V6 erased required Sema facts. |
| Sidecar V7 build | `Saved/Build/cta-s53-15-11-sidecar-lifetime-green-build/20260829_071341_256_b4940446` | **PASS** after the recorded decode-type integration repair. |
| Sidecar V7 roundtrip | `Saved/Tests/cta-s53-15-11-sidecar-lifetime-green/20260829_071353_641_00bc5616` | **23/23 PASS**, exact protocol reconstruction. |
| Corruption/default-disabled boundary | `Saved/Tests/cta-s53-15-11-lifetime-cache-v7-boundary/20260829_071505_505_4f1e8fdb` | **30/30 PASS**, malformed protocol fails closed and disabled Cache remains bypassed. |
| Final four-prefix regression | `Saved/Tests/cta-s53-15-11-final-full-regression/20260829_072428_373_0598c3de` | **752/752 PASS**, zero failures/skips across Frontend CanonicalAST, SemaAuthority, ProductionCodeGen and TypedASTJIT. |
| ExactWarm first integration RED | `Saved/Tests/cta-s53-15-11-final-exact-warm-start/20260829_072830_598_60eaba15` | **10/15 PASS**; exposed public/internal ID misuse and stale negative-mutation walkers. |
| ExactWarm intermediate repair | `Saved/Tests/cta-s53-15-11-final-exact-warm-start-green/20260829_073235_370_70d33513` | **12/15 PASS**; exposed the omitted declaration `accessSpecifier` field. |
| ExactWarm final integration | `Saved/Tests/cta-s53-15-11-final-exact-warm-start-green2/20260829_073513_634_5ed4b8ce` | **15/15 PASS**, zero failures/skips; retained restore and all intended corruption cases pass. |
| Exact required final build | `Saved/Build/cta-s53-lifetime-protocol/20260829_073810_020_d4f98b66` | **PASS**, target up to date after the final test-source repairs. |
| Final Sidecar/default-disabled Cache boundary | `Saved/Tests/cta-s53-15-11-final-cache-boundary-after-exact-warm/20260829_073832_102_ab202dc0` | **30/30 PASS**, zero failures/skips after the final test-module build. |
| OpenSpec/diff/source scans | Final-source rerun recorded below | **PASS**: OpenSpec valid; diff checks clean; HIR/dual and forbidden semantic traversal/compiler invocations absent; product defaults remain LEGACY. |

## Final-source scan results

- `openspec validate "refactor-as-canonical-typed-ast-compiler"` reports the
  change valid.
- Plugin and parent-scope `git diff --check` pass; Git reports only the existing
  LF-to-CRLF working-copy normalization warnings.
- production HIR symbols: **0**;
- dual-mode symbols: **0**;
- native-tree `firstChild`/`lastChild`/`->next` traversal in Canonical Sema:
  **0**;
- `asCCompiler`/legacy body-compile invocations in Canonical Sema and Bytecode
  CodeGen: **0**;
- defaults remain `bUseCanonicalStagedCompiler = false` and
  `canonicalCompilerPipeline = false`;
- lifetime identity domains are exactly `CanonicalLifetimeRecord.v2`,
  `CanonicalLifetimeSummary.v2` and `CanonicalLifetimeABI.v2`.

## Nonclaims

- Product CANONICAL default cutover is not claimed; section 10 remains open.
- Native `asCScriptNode`, Parser, `asCBuilder`, `asCCompiler` and explicit
  LEGACY remain available. Their later physical deletion or availability
  narrowing belongs to a separate OpenSpec.
- Reusing Builder as a prepared Runtime shell is not permission to use its
  native syntax tree as CANONICAL semantic input.
- Native aggregate element-frame ABI, full source exception/suspend semantics
  and section 5/7/9/13 umbrellas are not closed by this gate.
- Cache V2 remains default-disabled and is not promoted to the compiler-cutover
  critical path.
- Standalone was not built, tested or modified.
