# Cache V2 Execution Plan

This plan turns the frozen Cache V2 contracts into dependency-ordered work
packets. It replaces the pre-refactor implementation narrative as the current
execution handbook. The full former plan remains byte-for-byte under
`history/pre-refactor-2026-08-09/implementation-plan.md`.

## 1. Scope and invariant boundaries

The deliverable is a Runtime-owned incremental AngelScript artifact cache that:

- keeps unchanged function, type and module artifacts when their stable inputs
  remain valid;
- persists granular records but activates a module atomically;
- can build an initial generation on first Editor, PIE, Development or Shipping
  startup and publish later generations incrementally;
- treats loose `.as` source as authoritative;
- works whether or not a StaticJIT native provider exists; and
- directly replaces `PrecompiledScript.Cache` without a compatibility reader,
  migration, dual-write or fallback. `Binds.Cache` is unrelated and remains.

The frozen delta specs, wire documents, matrices, authorities and golden vectors
own behavior and bytes. This plan may sequence them but may not reinterpret them.
In particular:

1. There is exactly one seven-kind decoded-record factory, candidate transaction,
   shared controller allocation, canonical payload owner and promotion boundary.
2. There is exactly one module graph traversal before Manifest reachability.
3. SourceIndex and ModuleInterface migrate into the common factory; no permanent
   transitional wrapper or second public owning token survives.
4. Test seams observe or inject checkpoints on the production path. They never
   decode, validate, own, traverse or publish an alternative path.
5. Record storage may be granular; ModuleState and active ModuleSnapshot
   publication are atomic.
6. StaticJIT consumes stable function identity/content/profile through a sibling
   provider contract. Live Coding may refresh that provider but does not own Cache
   freshness or validity.
7. Only pure immutable preparation is parallel. Each AngelScript engine has one
   serialized mutation gate and the Store has its separately ordered namespace
   lock.

## 2. Dependency graph

```text
A identity/archive baseline
          |
          v
B seven-kind private decoder/factory -----> B module graph
          |                                      |
          |                         +------------+
          v                         v
C Pack/Manifest pure data plane --> C generation reachability
          |
          v
D immutable generation Store
          |
          v
E source planning/compiler reuse/VM attachment/module assembly
          |
          v
F engine/editor/PIE/runtime lifecycle
          |
          v
G direct legacy cutover/package/real acceptance
```

Pure Pack and Manifest declaration/codec/determinism slices C2–C5 may run beside
B. C6 generation reachability and C7 generation construction may not bypass the
sole factory or B11 graph. Store work starts only after the C2–C5 data-plane API
is stable. Compiler and lifecycle integration do not start from placeholder
records.

## 3. Backlog slices and work-packet contract

The checkboxes in `tasks.md` are bounded dependency/backlog slices. They are not all
immediately assignable work packets: exact files, commands and prerequisites can
change as earlier slices land. Before the primary agent assigns any slice, it must
materialize that slice under the `Current ready packet` section of this plan. There
is only one current ready packet at a time unless disjoint file ownership and frozen
inputs explicitly permit more.

Every materialized work packet must state in its handoff:

- exact task ID and goal;
- files owned and files explicitly forbidden;
- frozen input SHA or named normative sections;
- prerequisites confirmed before editing;
- complete test-TU compile command for a RED boundary, when applicable;
- focused GREEN command and expected evidence level, or an explicit `N/A` for an
  authority/review-only packet;
- whether exact-SHA independent review is required; and
- resulting source SHAs, logs, remaining failures and next safe handoff.

The primary agent alone updates current OpenSpec ledgers. Parallel workers may
return code and evidence, but must not edit `status.md`, `tasks.md`,
`implementation-issues.md` or `verification.md`. Workers must not share production
files, frozen test authorities or review candidates.

## 4. File and ownership map

The precise file list must be confirmed against the repository before each
packet; these are the intended ownership regions.

| Area | Primary location | Responsibility |
|---|---|---|
| Stable artifact values | `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/` | Hashes, keys, profiles and reusable pointer-free values. |
| Record/archive core | `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/` | Wire cursors, Budget, semantic values, seven-kind factory, graph and Pack/Manifest. |
| Store and service | `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/` | Namespace, immutable I/O, pointers, sessions, compaction, engine-owned service. |
| Compiler/VM bridge | existing builder and VM-private files under `Plugins/Angelscript/Source/AngelscriptRuntime/` | Kind-tagged compile hook, dependency capture, bytecode codec and attachment. |
| Editor lifecycle | `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/` plus Runtime interfaces | Reload transaction DTOs, PIE state and safe publication. |
| Test code | `Plugins/Angelscript/Source/AngelscriptTest/Cache/` | Pure wire/value, factory/graph, Store, integration and lifecycle tests. |
| Package tools | `Tools/` and staging configuration | Loose NonUFS scripts and isolated real package smoke. |
| Current ledgers | this OpenSpec root | Status, task, issue, verification and traceability authority. |

Cache ownership must move out of `StaticJIT/`; the move is not permission to
delete numeric registration transport still needed by the sibling StaticJIT
change before that provider reaches parity.

## 5. Milestone A — accepted foundation

Milestone A is a retained behavior-GREEN baseline, not a claim that Cache V2 is
integrated. It includes full-width identity/profile types and goldens, the record
envelope, common canonical archive primitives, and the SourceIndex/ModuleInterface
Task 2B-1 boundary. Re-run affected evidence only when common factory migration or
shared Budget behavior changes those consumers.

Exit condition: the exact identity and common archive vectors remain green after
B migration, without compatibility wrappers or double charging.

## 6. Milestone B — sole seven-kind record boundary

### B1–B4: stabilize the paused frontier

- B1 freezes the current IC-138/139 test candidate only after its complete test TU
  compiles and an independent review accepts the exact SHA.
- B2 adds the normal TypeSchema producer RED for every canonical-local semantic
  obligation. B3 then implements the producer validator and fresh-compiles the
  exact production/test TUs. IC-145 records that focused B3 Automation cannot link
  until both the B5–B7 private decoder bridge and C2 Manifest declaration are real;
  B3 remains behavior-open until that earliest joint prerequisite closes, while
  its compiled source may feed B5 without creating a task cycle.
- B4 finishes fresh independent review and focused evidence for the interrupted
  factory/allocation repair, including Shipping-disabled seam scans.

No TypeSchema decoder GREEN uses assertions, missing symbols or test-only semantic
construction as its RED.

The deferred B3 prefix is
`Angelscript.TestModule.Cache.Archive.TypeSchema` through
`Tools\RunTests.ps1`. It runs immediately when B5–B7 and C2 make a truthful full
module link possible, and B12 runs it again in the complete regression. A missing
header, unresolved bridge, disabled registration or stale binary is never accepted
as the behavior result.

### B5–B7: TypeSchema private decoder

Implement in strict layers so an error has one owner:

1. B5 physical decode and captured offsets, including trailing-data precedence.
2. B6 local field/cross-field semantics and the twelve named checkpoints.
3. B7 recomputed LayoutInput, property storage/fingerprint, enum authority and
   final layout hashes, with legal resolver ordering and exact error precedence.

Every layer decodes into a local candidate. No const owning handle is observable
until all required validation, RecordId recomputation, allocation reconciliation
and promotion succeed.

### B8–B12: unify all records and graph

- B8 migrates SourceIndex and ModuleInterface behind the sole private factory,
  preserving their validated algorithms and deleting transitional ownership.
- B9 implements the remaining four semantic decoders plus FunctionBody and
  DebugSidecar opaque boundaries exactly as frozen.
- B10 closes all seven dispatch alternatives, candidate allocation chronology,
  fault exits and one-shot publication.
- B11 implements `ValidateModuleSnapshotGraph` with exactly-once reachable opaque
  validation, compact ordinal indexes, resolver ordering and atomic empty output.
- B12 runs the complete record/factory/graph prefix, common-archive regression,
  bounded concurrency/equivalence tests and non-test symbol/size scans.

Exit condition: every record enters through one factory and every selected module
enters through one graph, with focused Behavior GREEN and reviewed shared-safety
boundaries.

## 7. Milestone C — pure Pack and Manifest

- C1 is the already approved 26-method declaration-first RED and its frozen wire.
- C2 implements deterministic Pack value/declaration construction.
- C3 implements Manifest roots and exact location/index values.
- C4 implements checked None/Zlib physical codec, canonical recompression and one
  cumulative read Budget.
- C5 proves byte-identical serial/forward/reverse/seeded-random construction.
- C6 validates exact generation reachability through B10/B11 and rejects pack
  extras/duplicates/range/identity faults at their frozen stages.
- C7 builds a complete immutable in-memory generation without filesystem or live
  engine dependencies.
- C8 runs Archive/PackFormat/Manifest GREEN and affected factory/graph regression.

Exit condition: the same logical records always yield the same canonical payload,
index, PackId and GenerationId; validation has one decoder/graph path.

## 8. Milestone D — immutable generation Store

Proceed in this order:

1. D1 freezes path, pointer, containment and store-error REDs.
2. D2 implements canonical Saved-only namespaces, recognized temporary names and
   injectable atomic-file capabilities.
3. D3 writes and validates immutable Pack/Manifest finals without replacement.
4. D4 implements the namespace lock, reread/rebase and atomic slot publication.
5. D5 implements pinned read sessions and cumulative validation Budget.
6. D6 implements explicit two-phase compaction outside startup.
7. D7 proves fault/cancel/indeterminate outcomes and serial/parallel/multi-process
   determinism with focused Store GREEN.

Exit condition: Current/Previous/PendingColdStart are recoverable old-or-new
atomic states; invalid new work never damages committed state; startup never
compacts.

## 9. Milestone E — source and compiler integration

E is integrated in dependency order:

- E1 source inventory and provider/hook stable fingerprints;
- E2 SourceIndex production discovery and exact-snapshot planning;
- E3 per-engine environment-symbol catalog;
- E4 typed mutation/invalidation matrix;
- E5 deterministic minimum-closure planner;
- E6 maintained-fork kind-tagged builder descriptor and NotCacheable paths;
- E7 compiler hit/miss hook and actual dependency capture;
- E8 pointer-free VM artifact codec and fail-before-mutation attachment;
- E9 module-atomic ModuleState restore/rebuild;
- E10 declaration-first TypeSchema/ModuleSnapshot assembly, stable route rebuild,
  exact-warm zero-work proof and controlled one-body-edit proof.

Exit condition: exact source/profile restores without preprocess/parse/compile;
one isolated body edit recompiles only its correct closure; structural/global work
remains module-atomic.

## 10. Milestone F — lifecycle and routing

- F1 freezes cold/warm/failure/two-engine lifecycle REDs.
- F2 adds one engine-owned Cache service and explicit mutation gate.
- F3 freezes pointer-free publication DTO capture at the successful transaction
  boundary and separates active Current from cold-start candidate.
- F4 implements Editor/PIE code-only versus structural state transitions.
- F5 implements bounded shutdown flush with no shutdown compilation.
- F6 adds deterministic settings, public C++/Blueprint APIs and console commands.
- F7 implements packaged Disabled/Manual/Automatic safe-point reload and
  `RequiresRestart` for structural changes.
- F8 verifies diagnostics and the StaticJIT isolation bridge: provider availability
  changes Native/VM routing only, never Cache generation validity.

Exit condition: first launch can generate a generation, later launches reuse and
increment it, Editor hot reload safely maintains it, and runtime structural changes
cannot mutate incompatible active classes.

## 11. Milestone G — direct cutover and acceptance

- G1 proves legacy artifacts cannot satisfy Cache V2 while `Binds.Cache` remains.
- G2 removes legacy cache reader/writer, DataGuid correctness, pointer/FunctionId
  relocation and forced-exit generation after V2 parity.
- G3 stages editable `Script/` as loose NonUFS and removes package pre-generation.
- G4 implements isolated Cache package-smoke tooling and suite registration.
- G5 runs the full Cache and affected HotReload/StaticJIT prefixes.
- G6 runs real PIE cold/warm/body-edit/structural/error acceptance.
- G7 runs real Development and Shipping multi-launch matrices last.
- G8 captures benchmarks, updates Chinese guidance first and completes final build,
  configured suites, strict OpenSpec, legacy-reference classification and diff
  verification.

Exit condition: no production legacy path remains, first-launch and incremental
reuse are proven in actual packages, and final evidence is recorded by exact log
and report paths.

## 12. Completed packet — IC-154 decoder cardinality authority repair

### Goal, evidence level and owner

- Repair only the existing decoder test method
  `RelationKindsFormsCardinalitiesAndReferenceKindsAreCartesian` so forbidden
  relation coordinates with two distinct locally valid targets expect
  `InvalidPresence`, while allowed singleton coordinates continue to expect
  `ConflictingKey` and the existing earlier wrong-reference result remains
  `WrongReferenceKind`.
- Sole owned source file:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`.
- This is an executable-authority correction plus complete-TU compile and
  exact-SHA review. It does not add Slice-3 normal-producer methods, modify
  Runtime, run focused Automation through IC-145, or close B2/B3.
- The primary agent alone updates OpenSpec ledgers. The implementer may write only
  the owned test TU and `.superpowers/sdd/b2-slice3-decoder-cardinality-repair-report.md`.

### Frozen inputs and starting point

- Exact approved Slice-2 candidate SHA-256:
  `6408703A2A3DD6E981D92FAC97EAC20B0D85ACDD4F3CE13425D1F8A2EBD905F5`;
  plugin blob `64478db37c4dfb8613b3b5f1d5aba501eb8f4cc0`, 513,810 bytes,
  11,594 LF, zero CRLF/bare CR, 58 methods and final LF.
- Normative authority: `type-schema-matrix-v1.md` relation cardinality/error
  table, `type-layout-authority-v1.md`, and
  `reviews/b2-slice3-authority-correction.md`.
- Rejected independent authority review:
  `reviews/b2-slice3-authority-correction-review.md`, SHA-256
  `FDC924CF0B95E0D677FFEE722072E943228A8D836766CF297450F6F2AEFB53F4`,
  0 Critical / 1 Important / 0 Minor. Its sole Important finding defines the
  repair boundary.
- Fixed allowed form/kind coordinates for the existing Cartesian fixture are:
  ClassNone permits Base and ImplementedInterface; OrdinaryUClass permits Base,
  ShadowSuper, CodeSuper and ImplementedInterface; StaticsUClass permits
  CodeSuper; InterfaceNone permits ImplementedInterface; all other coordinates,
  including every Compose coordinate, are forbidden. ImplementedInterface is the
  only `0..N` coordinate; Base is `0..1`; required ShadowSuper/CodeSuper rows are
  exactly one where named by the frozen matrix.

### Required edit and prohibited shortcuts

1. Keep the existing Cartesian loops and fixture construction. Introduce the
   smallest fixed form/kind permission table or switch needed to distinguish an
   allowed singleton from a forbidden coordinate independently of
   reference-kind validity and cardinality.
2. Preserve result precedence exactly: success first; for a nonzero row with the
   invalid reference case, `WrongReferenceKind`; otherwise count two is
   `ConflictingKey` only for an allowed non-ImplementedInterface coordinate;
   remaining invalid cells are `InvalidPresence`.
3. Do not call a production semantic helper, duplicate production validation,
   add a new general semantic predicate, change fixture inputs, add/remove a test
   method, or edit any Runtime/decoder/producer/OpenSpec file.
4. Preserve all Slice-1/Slice-2 bytes outside the narrow method edit. Do not mix
   in `NormalProducerRejectsRelationRulesAtomically` or LayoutInput Slice-3 work.

### Compile, freeze and review gate

Compile the complete TU only through the repository wrapper:

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 `
  -Label cache-b2-slice3-decoder-cardinality-authority-repair-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

Require wrapper/process exit zero, exactly one complete
`AngelscriptCacheTypeSchemaTests.cpp` compile action and no compiler/linker
diagnostic. Then record SHA-256, plugin blob, bytes, LF/CRLF/bare-CR, final-LF,
method count, exact diff and artifact path. Freeze the unchanged bytes into the
plugin object database and obtain independent exact-SHA review with required
disposition 0 Critical / 0 Important; every Minor is explicit.

After the source review approves, rerun a fresh read-only review of the four
normative corrections against the repaired exact test SHA. Only both approvals
close IC-153/IC-154 and permit the queued Slice-3 packet to become current.

## 13. Completed compile-authority packet — B2 Slice 3 Relations and LayoutInputs

### Goal, evidence level and owner

- Add exactly two methods to the existing TypeSchema CQTest class:
  `NormalProducerRejectsRelationRulesAtomically` and
  `NormalProducerRejectsLayoutInputRolesAndPairingAtomically`.
- Sole owned source file:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`.
  The implementer may also write only
  `.superpowers/sdd/b2-slice-3-report.md`; the primary agent owns OpenSpec.
- Every behavioral observation calls normal
  `SerializeTypeSchema(const FAngelscriptCachedTypeSchema&, TArray<uint8>&)` via
  the existing failure/success immutability helpers. Physical decode, guarded
  writer, graph/current resolver and engine fixtures cannot decide expectations.
- Evidence ceiling is complete-TU SingleFile compile plus frozen exact-SHA review.
  IC-145 still forbids claiming focused returned-result RED or B2/B3 completion.

### Frozen starting point and authority

- Repaired, reviewed starting candidate SHA-256:
  `AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`;
  plugin blob `4164f9f66e8f89915d13ae3dc25c131822925b1e`; 514,861 bytes,
  11,622 LF, zero CRLF/bare CR, 58 methods and final LF.
- Fresh combined authority rereview
  `reviews/b2-slice3-authority-correction-rereview.md`, SHA-256
  `02C09AAD8C242E83BF455E8B934BB07D52646BCC30B12B31F077E6D6A8C2DCC3`,
  approved 0 Critical / 0 Important / 0 Minor and closes IC-153/IC-154.
- Normative inputs remain exact SHA-256:
  `type-schema-matrix-v1.md` `DAB6D0C6...F159`,
  `type-layout-authority-v1.md` `B9D20D1C...44D4`,
  `record-wire-v1-remaining.md` `98121B7B...82B6`, and
  `producer-b2-coverage-audit.md` `4BD7D466...EC1`.
- The original Slice-3 audit
  `.superpowers/sdd/b2-slice-3-authority-audit.md` supplies the obligation
  inventory but is superseded where its table mapped a forbidden count-two
  relation to `ConflictingKey`. The approved four-pattern cardinality rule and
  repaired 495-cell oracle are controlling.

### Relations method

Use fixed literal table data, not a computed semantic predicate, for all 11 forms
× five relation kinds × cardinalities zero/one/two. Each of the 165 cells calls
the normal producer and has a literal result:

- `0..N`: zero/one/two success;
- allowed `0..1`: zero/one success, two distinct targets `ConflictingKey`;
- exact one: zero `InvalidPresence`, one success, two distinct targets
  `ConflictingKey`; and
- forbidden, including Compose: zero success, one/two `InvalidPresence`.

Use ScriptType for Base and the plain-Class/Interface direct-interface legal
coordinates; EnvironmentSymbol for ShadowSuper, CodeSuper and ordinary-UClass
direct interfaces. A forbidden coordinate uses a locally well-formed ABI-bearing
ScriptType only to isolate form/cardinality. Preserve all other required relations;
for a selected ordinary-UClass ShadowSuper/CodeSuper singleton, reuse the peer's
target. Mechanically maintain BaseType/CodeRoot masks, SuperIsCodeClass and coupled
dependencies only far enough that the named relation result is first.

In the same method add distinct literal rows for raw relation kinds 0/6/255;
ordinal forbidden/missing, first/last gaps not already owned by B1, middle/last duplicates and
complete-row noncanonical order; duplicate direct interface; self-reference; zero
key; missing ABI; and wrong-reference controls for every distinct legal
relation/form target rule. Do not duplicate the already approved B1/Slice-1
singleton duplicate/conflict, representative ordinal gap, Struct-forbidden Base
or direct-interface semantic-order positive. Exclude resolved target kind,
owner/ABI, closure and code-root semantics owned by ModuleGraph. The exact method
inventory is 195 normal-producer calls: 165 literal table cells plus 30 named
additional rows, including 16 wrong-reference controls.

### LayoutInputs method

Call the normal producer for thirteen legal form/root/derived baseline successes.
They contain exactly five required LayoutInput instances across four non-empty
schemas: plain BaseType, root CodeRoot, derived BaseType+CodeRoot and UStruct
StructHeader. The other nine schemas contain no LayoutInputs. Report 13 calls /
five instances; do not invent a sixth witness.

Add literal failure rows for:

- raw InputKind 0/4/255;
- five distinct required-absence coordinates: plain and derived BaseType, root and
  derived CodeRoot, and StructHeader;
- 34 BaseType/CodeRoot/StructHeader forbidden-extra form/role coordinates over all
  thirteen baselines;
- three wrong-role replacements using the single-input plain Base, root CodeRoot
  and UStruct baselines;
- eight exact pairing rows: Base key-only/ABI-only; CodeRoot different from both
  equal peers key-only/ABI-only; only CodeSuper different key-only/ABI-only; and
  only ShadowSuper different key-only/ABI-only. Every reference remains
  individually valid and expects `InvalidQualifierCombination/LocalSemantic`;
- twelve literal optional-mask failures: BaseType required mask 3 against 0/1/2;
  root CodeRoot required 3 against 0/1/2; derived CodeRoot required 2 against
  0/1/3; and StructHeader required 1 against 0/2/3;
- zero key and missing ABI once for each role;
- BaseType EnvironmentSymbol and CodeRoot/StructHeader ScriptType wrong-kind rows,
  plus ScriptFunction controls without collapsing form/presence precedence;
- alignment zero and non-power-of-two three for BaseType and CodeRoot;
- five above-INT32 boundary/alignment coordinates for BaseType, root CodeRoot and
  StructHeader, using `static_cast<uint32>(MAX_int32) + 1u`; and
- one stale LayoutInputHash row mutated after finalization, expected
  `DerivedHashMismatch` without rehash.

Do not duplicate existing unordered canonicalization, identical/conflicting
LayoutInput singleton rows, common raw StableReference enum coverage, dependency
coverage, graph/current-layout or resolver cases.

The exact LayoutInputs inventory is 100 normal-producer calls: 13 legal baseline
successes; 3 raw kind; 5 required absence; 34 forbidden extra; 3 wrong role; 8
pairing; 12 optional mask; 3 zero key; 3 missing ABI; 6 wrong reference; 4 invalid
alignment; 5 overflow; and 1 stale hash. Slice 3 therefore owns exactly 295 new
normal-producer calls across the two methods.

### Test discipline and prohibited shortcuts

Each method owns one `FNoDiscardAsserter`, one accumulated `bPassed` and one final
fatal matcher. A failure row starts from a legal baseline, mutates only its named
coordinate, repairs mechanically coupled DTO fields and calls
`FinalizeValidFixtureHashes`. Nine hash-precondition rows are explicit exceptions:
raw InputKind 0/4/255, and zero key/missing ABI for each of the three roles, start
from a finalized legal baseline, mutate only that field and retain the old hashes;
their field-local error must precede hash comparison. The stale-hash row separately
mutates only LayoutInputHash after finalization. Success rows use the existing normal success/
immutability helper. Caller input remains byte-identical and failure output empty.

No new shared semantic validator, dynamic expected-error predicate, serializer,
decoder, hash implementation, resolver, trace/offset API, AS engine, UObject,
World, registration shortcut or Runtime edit is allowed. Existing fixture builders
and small method-local construction lambdas/tables are allowed only when they do
not decide general semantic validity. Do not edit the candidate during review.

### Compile, freeze and review

Run only the repository wrapper from the worktree root:

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 `
  -Label cache-b2-typeschema-producer-red-slice3-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

Require wrapper/process exit zero, exactly one complete-TU compile action and no
compiler/linker diagnostics. Record final SHA/blob/shape, exact immutable diff,
method count, row counts, exclusions and artifact. Freeze the unchanged candidate
in the plugin object database and obtain independent exact-SHA review of the full
two-method slice with required 0 Critical / 0 Important disposition.

Do not run full link or focused Automation while IC-145 still reproduces the real
C2 Manifest-header and B5–B7 private-bridge prerequisites. After approval, Slice 4
becomes the next B2 authoring packet; B2 remains unchecked.

### Final execution disposition

Slice 3 is complete at the source/compile-authority ceiling. Exact candidate
SHA-256 is
`3CC1A95A748106A05291CD0DE8D7B57ABCE61E807A8F89E2F4F204D6B23D2338`,
plugin blob `653f8b05ad7a398f151690d44647571aa50380e9`, 556,261 bytes,
12,707 LF, zero CR, final LF and 60 `TEST_METHOD` definitions. The immutable
predecessor/candidate diff is +1,085/-0 and contains exactly 195 Relations plus
100 LayoutInputs normal-producer calls.

The fresh complete-TU SingleFile artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice3-tu/20260809_042228_503_9dce9428/`
succeeded with process/wrapper `0/0`. Independent exact-blob review
`.superpowers/sdd/b2-slice-3-review.md`, SHA-256
`F3D0874865042668BAB4ABBFB8F1AF65F567918C5EF688395D176A82D908BB16`,
approved `0 Critical / 0 Important / 0 Minor` and released this exact candidate.
This is not linked focused RED, B2 completion or B3 permission.

## 14. Current HOLD packet — B2 Slice 4 Properties and Layout Replay

Status: **CANDIDATE PACKET AWAITING INDEPENDENT REVIEW. DO NOT IMPLEMENT UNTIL
0 CRITICAL / 0 IMPORTANT PACKET APPROVAL AND REVIEWER FINAL.**

### Goal, evidence level and owner

- Add exactly one method to the existing TypeSchema CQTest class:
  `NormalProducerRejectsPropertyStorageFlagsAndLayoutReplayAtomically`.
- Sole source owner:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`.
  The implementer may additionally write only a Slice-4 implementation report
  under `.superpowers/sdd/`; the primary agent owns OpenSpec.
- Every one of the exact 660 observations calls normal
  `SerializeTypeSchema(const FAngelscriptCachedTypeSchema&, TArray<uint8>&)`
  through the existing exact success/failure immutability helpers. Decoder,
  physical-byte patching, graph/current resolver and engine fixtures cannot
  choose expectations.
- Evidence ceiling is four complete-TU SingleFile compile checkpoints plus final
  frozen exact-blob review. IC-145 still forbids a linked focused run and B3.

### Frozen starting point and authority

- Required starting TU SHA-256:
  `3CC1A95A748106A05291CD0DE8D7B57ABCE61E807A8F89E2F4F204D6B23D2338`;
  readable plugin blob `653f8b05ad7a398f151690d44647571aa50380e9`;
  556,261 bytes, 12,707 LF, zero CR, final LF and 60 methods.
- Slice-3 exact review:
  `.superpowers/sdd/b2-slice-3-review.md`, SHA-256
  `F3D0874865042668BAB4ABBFB8F1AF65F567918C5EF688395D176A82D908BB16`,
  approved 0C/0I/0M.
- Slice-4 research:
  `.superpowers/sdd/b2-slice-4-research.md`, SHA-256
  `18045B2ABB5ED44B13B787CF3EFD85C932ED3F34B9F7DF01C6926A9E0E064237`.
- Frozen normative inputs remain `record-wire-v1.md`,
  `record-wire-v1-remaining.md`, `type-schema-matrix-v1.md` and
  `type-layout-authority-v1.md`; `producer-b2-coverage-audit.md` is the corrected
  implementation routing attachment.
- IC-166 is closed: Slice 4 has no stale stored-hash failure. Slice 6 owns stale
  StorageLayoutHash, PropertyLayoutFingerprint and final TypeLayoutHash while
  prior Slices 2/3 retain Enum/LayoutInput witnesses.
- IC-167 freezes PrimitiveType raw `13/255` as literal `UnknownEnumValue` normal
  producer failures. Known sentinel `0` remains `InvalidPresence`. Current
  producer behavior is not the oracle.

### Exact total and method discipline

The method owns exactly **660 normal-producer calls: 83 legal and 577 negative**.
Its four sequential regions are:

| Region | Success | Negative | Total |
|---|---:|---:|---:|
| A — owners, identity, ordinals, access, raw storage and datatype envelope | 7 | 40 | 47 |
| B — StorageKind × DataTypeKind × qualifier matrix | 21 | 491 | 512 |
| C — property flags, replication metadata and condition | 50 | 19 | 69 |
| D — legal layout controls, replay, ranges and checked arithmetic | 5 | 27 | 32 |
| **Total** | **83** | **577** | **660** |

Use exactly one method-local `FNoDiscardAsserter`, one
`bool bPassed = true` accumulator and one final fatal `ASSERT_THAT`. Every region
has explicit nonfatal success/failure/total counters. No call may be conditional
on the current producer result. Expected results are literal at tables or call
sites.

### Region A — exactly 47 calls

Seven new legal calls are: empty Delegate normalized layout; property baselines
for Class+None, ordinary root UClass, ordinary script-derived UClass, Struct+None
and Struct+UStruct; and legal Protected access. Public/private, nonempty Delegate
and other normalized positive forms are cited from B1/Slices 1–3 and not repeated.

Forty negatives are exactly:

1. six forbidden property-owner forms: StaticsClass, Interface+None, Enum+None,
   Enum+UEnum, Typedef+None and Funcdef+None -> `InvalidPresence`;
2. property ordinals `[0,2,3]` / `[0,1,3]` -> `OrdinalGap`, `[0,0,2]` /
   `[0,1,1]` -> `DuplicateOrdinal`, stored rows `1,0,2` / `0,2,1` ->
   `NonCanonicalOrder`;
3. zero PropertyKey -> `ZeroStableKey`; empty name -> `InvalidPresence`;
4. access raw `0/255` -> `UnknownEnumValue`;
5. StorageKind raw `0/255` -> `UnknownEnumValue`; B1 already owns raw `3`;
6. the 20 uncontroversial CanonicalDataType envelope calls enumerated in
   `b2-slice-4-research.md` section 3.4: raw DataTypeKind 0/5/255, unknown
   qualifier 0x40/0xffffffff, invalid union presence, wrong reference kinds,
   zero key/missing ABI, invalid Auto payload and Void property;
7. PrimitiveType raw `13/255` -> literal `UnknownEnumValue` per IC-167.

Do not repeat B1's first-ordinal gap, raw Access 4, raw StorageKind 3 or generic
property metadata duplicate/conflict rows.

### Region B — exact 512-cell matrix

Exercise every coordinate of:

```text
StorageKind {InlineValue=1,ObjectHandle=2}
× DataTypeKind {Primitive=1,ScriptType=2,EnvironmentType=3,Auto=4}
× QualifierMask {0x00..0x3f}
```

The only 21 successes are the literal list:

- Inline Primitive: `00`;
- Inline ScriptType and EnvironmentType independently: `00`, `02`;
- ObjectHandle ScriptType and EnvironmentType independently:
  `04`, `06`, `0c`, `0e`, `24`, `26`, `2c`, `2e`.

All other 491 calls pass literal `InvalidQualifierCombination`. Enumerate failure
coordinates through the fixed, disjoint partitions frozen in research section
3.3: Inline Primitive `32+16+8+4+2+1`; each Inline Script/Environment
`32+16+8+4+2`; Inline Auto 64; ObjectHandle Primitive 64; each ObjectHandle
Script/Environment `32+16+8`; ObjectHandle Auto 64. Do not use `bExpected`, a
legal-membership predicate or production validation to route success/failure.

Maintain a mechanical `Seen[2][4][64]`-equivalent ledger used only to detect
duplicate/missing coordinates. It must not return an expected result. Each cell
is marked exactly once; final ledger count is 512. ObjectHandle rows use the
frozen V1 handle layout constants and an exactly adjusted aggregate layout.

### Region C — exactly 69 calls

Fifty legal calls are the explicit research section 3.5 list:

- 18 ordinary-UClass nonzero allowed-bit closures;
- 15 legal non-None replication conditions `1..15` on closed mask `0x00401`;
- 16 UStruct allowed-bit closures; and
- one ordinary metadata positive with `ReplicatedUsing` but no RepNotify.

Nineteen negatives are exactly: unknown masks `0x80000/0xffffffff`; missing
BlueprintReadable prerequisite; RepNotify without Replicated; ReplicatedUsing
absent and present-empty for mask `0x4401`; condition on nonreplicated property;
SkipReplication conflicts with Replicated, RepNotify and a non-None condition;
condition raw `17/255`; UClass Has+Skip; UStruct Replicated,
RepNotify+metadata and Config; and HasUnreal on PlainClass, PlainStruct and
Delegate. Use literal errors from research: unknown values `UnknownFlags` or
`UnknownEnumValue`, closed owner-forbidden rows `InvalidPresence`, and implication
conflicts `InvalidQualifierCombination`. B1 owns the generic other-bit-without-Has
and NetGroup=16 rows.

The source must contain the exact 18 and 16 positive mask lists; it may not call
`IsExpectedPropertyMaskValid`, `ExpectedPropertyMaskError` or a replacement
predicate.

### Region D — exactly 32 calls

Five legal controls are: exact three-property padding/tail layout; one property
raising exact aggregate alignment to 16; exact BaseType contribution with maximum
16; exact CodeRoot boundary/shadow contribution with maximum 16; and the existing
UStruct StructHeader boundary-only `(16,8,16)` fixture.

Twenty-seven literal negatives are:

- six aggregate-alignment rows: zero, power-of-two below initial 8, surplus 16,
  and below property/Base/CodeRoot contribution;
- seven layout/boundary rows: boundary above size, size/alignment/boundary above
  INT32, and disagreement with Base/CodeRoot/StructHeader contribution;
- four cursor/tail rows: offset below boundary, overlap, aligned wrong cursor with
  the same terminal size 16, and missing mandatory tail padding;
- five storage scalar rows: size zero, alignment zero/three, size above INT32 and
  alignment above INT32;
- five checked-arithmetic rows: offset above INT32, property-end uint32 wrap,
  property-end INT32 crossing, pre-property AlignUp crossing and terminal AlignUp
  crossing.

Use the exact literal `Overflow` versus `InvalidQualifierCombination` mapping in
research section 3.6. For the aligned wrong cursor, change final offset 8 to 12,
keep size 16, legally re-finalize, expect `InvalidQualifierCombination` and also
assert the legal/wrong PropertyLayoutFingerprint and TypeLayoutHash differ. This
is not a stale-hash submission.

### Hash finalization and precedence discipline

`FinalizeValidFixtureHashes` runs after a non-hash mutation only when the common
hash preconditions remain valid. It is permitted for owner/presence, ordinal,
access, well-formed property-specific storage mismatch, flags/conditions,
layout/boundary/offset/tail and overflow rows.

It is forbidden after raw StorageKind/DataTypeKind/Primitive values, unknown or
internally contradictory common datatype flags, union-arm presence/reference
errors, wrong reference kind, zero key/missing ABI, zero PropertyKey, empty name,
metadata duplicate/conflict or a deliberately stale hash. Those rows copy a fully
finalized baseline, mutate only the named field and retain old hashes so the
earlier field/common error wins. Do not add `TryFinalizeIfValid`, use hash-helper
success as legality evidence, or reimplement a hash.

### Checkpointed implementation and compile commands

Do not author all regions without a checkpoint. Starting from the exact approved
Slice-3 SHA, implement A, stop for primary source/count review, then compile;
repeat for B, C and D. Each checkpoint keeps the one method syntactically complete
with the one final assertion. The root may release the next region only after the
candidate SHA and region inventory are recorded.

Use only the repository wrapper from the worktree root, with labels:

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 `
  -Label cache-b2-typeschema-producer-red-slice4-a-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

Change only the label suffix `a` to `b`, `c` and `d`. Every run requires
`TimedOut=false`, process/wrapper `0/0`, exactly one complete-TU
`AngelscriptCacheTypeSchemaTests.cpp` compile action and no compiler/linker
diagnostic. A compile failure is diagnosed under systematic debugging and
recorded as the next IC issue; it is not a RED.

After D, record final SHA/blob/bytes/newlines/method count, immutable delta from
blob `653f8b05...80e9`, exact 660-call counters, owned-file-only diff and all four
artifacts. Freeze the unchanged candidate and obtain independent exact-SHA review
of the full method with required 0 Critical / 0 Important. Do not run full link
or focused Automation under IC-145. B2 stays unchecked and B3 prohibited.

### Prohibited shortcuts and exclusions

Do not add or use a dynamic expected-error predicate, decoder, physical writer as
oracle, byte patcher, test serializer, expected-hash implementation, producer
trace/offset API, resolver argument, AS engine, UObject, World, disk fixture,
Runtime edit, registration shortcut, disabled test or new shared semantic helper.
Graph/current ownership, target entity/type/layout ABI, live UE capability,
resolved inherited layout and dependency completeness remain later layers.

## 15. Retained whole-B2 closure contract — not a ready packet

The following whole-B2 authoring/behavior contract is retained for later slices.
Its old B1 starting snapshot and six-slice wording are historical context, not an
assignable packet or current source identity; every later slice must be freshly
materialized from the latest approved exact candidate.

### Goal, evidence level and owner

- Task: B2 test authoring only. Expand the accepted B1 representative span into
  explicit normal `SerializeTypeSchema` evidence for every canonical-local
  producer obligation in `producer-b2-coverage-audit.md`.
- Sole owned source file:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`.
- Add eleven scenario-oriented `NormalProducer...` methods in the existing CQTest
  class, plus at most one narrow success/canonicalization assertion helper. Reuse
  the accepted failed-producer/immutability helper and legal fixture builders.
- This packet may reach complete-TU compile and exact-SHA reviewed-authority state.
  It cannot close B2 or claim behavior RED until IC-145's real B5–B7 decoder bridge
  and C2 Manifest declaration make the focused test modules truthfully link.
- Production source, physical writer, decoder/factory, graph, ArtifactIdentity and
  frozen normative authorities are read-only. B3 Runtime changes are prohibited
  before a returned-result focused RED is observed.

### Frozen inputs and starting point

- Approved B1 starting candidate SHA:
  `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`,
  467,181 bytes, 10,678 LF, 55 `TEST_METHOD` definitions and final LF.
- Exact B1 review:
  `reviews/b1-typeschema-red-review-183B7AF5.md`, SHA-256
  `09EAAB56B73EDA7A85F0631EB5E0C8DE5479E7F49F2BFAEFA72B3E910D63DBD2`,
  0 Critical / 0 Important / 0 Minor.
- Normative inputs: `type-layout-authority-v1.md`,
  `type-schema-matrix-v1.md`, `record-wire-v1-remaining.md`; B2 must not revise
  them to match current producer behavior.
- Gap inventory and obligation routing:
  `producer-b2-coverage-audit.md`.
- Current producer source remains exact read-only SHA
  `DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`.
- IC-146 is an explicit expected RED row: an otherwise valid Funcdef with
  `bMulticast=true` must return `InvalidQualifierCombination`, not the current
  `InvalidBoolean`.

### Test shape and prohibited shortcuts

Implement these six authoring slices, compiling after each:

1. success helper plus set canonicalization and header/string/type-flag methods;
2. kind-payload, enum, callable and typedef method, including IC-146;
3. relation and LayoutInput methods;
4. property/storage/flags/layout-replay method;
5. independent method/VFT and behavior methods; and
6. reflection, dependency and frozen-hash/resolver-independence methods.

The final eleven methods and their exact obligation groups are named in
`producer-b2-coverage-audit.md`. Every invalid row supplies a literal expected
error. Do not use `IsExpectedTypeSemanticFlagMaskValid`,
`IsExpectedClassReflectionMaskValid`, `IsExpectedPropertyMaskValid`,
`ExpectedPropertyMaskError` or a new dynamic semantic predicate to determine
producer expectations.

Additional guardrails:

1. Normal `SerializeTypeSchema` is the behavior under test. A physical snapshot
   may prove input immutability but cannot determine semantic legality.
2. For a non-hash fault, rehash a legal baseline so the named fault is isolated.
   For a stale-hash row, never call the rehash helper after corrupting that hash.
3. Accumulate all row results in each method and use one final fatal assertion so
   a future focused RED reports the whole scenario group.
4. No test-local serializer, semantic decoder, expected-hash implementation,
   producer trace/offset API, resolver argument, UObject/World/AS-engine fixture,
   placeholder Runtime symbol or disabled registration is allowed.
5. Do not edit the candidate while an exact-SHA independent review is active.

### Compile, freeze and review commands

After each authoring slice, complete-TU compile from the worktree root with a
slice-specific label; the final form is:

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 -Label cache-b2-typeschema-producer-red-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

For every slice require wrapper/process exit zero, exactly one complete
`AngelscriptCacheTypeSchemaTests.cpp` action and no hidden compile diagnostic.
After the sixth slice:

1. recompute SHA, bytes, LF/CRLF, method count and final LF;
2. prove the source delta is limited to the owned test file plus OpenSpec records;
3. run strict OpenSpec and whitespace/diff checks;
4. freeze the candidate; and
5. obtain independent review of the complete exact SHA.

The reviewer must map every frozen canonical-local obligation to a normal producer
row or explicit positive, confirm all expected errors are literal rather than a
second validator, verify the inactive producer tuple/output/input contract, confirm
the five stored hashes and IC-139 literals reach normal serialization, and prove
the producer signature accepts no current resolver. Required disposition is
0 Critical / 0 Important; every Minor is explicit.

### Deferred focused RED and handoff

Do not run a full build or claim RED while IC-145 still reproduces the C2 missing
Manifest header and B5–B7 unresolved private decoder bridge. The compiled/reviewed
B2 candidate remains an authority frontier and B2 stays unchecked.

Progress B4/B5–B7 and real C2 through their already approved RED lanes. At the
earliest joint link, run:

```powershell
& .\Tools\RunTests.ps1 `
  -TestPrefix 'Angelscript.TestModule.Cache.Archive.TypeSchema.NormalProducer' `
  -Label cache-b2-typeschema-normal-producer-red `
  -TimeoutMs 600000
```

Require all eleven methods to be discovered and executed. Legitimate RED is a
returned `SerializeTypeSchema` result/output mismatch with exact pass/fail counts;
crash, check, timeout, missing test, missing header or unresolved symbol is not RED.
Only after that run and the exact-SHA review may B2 close and B3 modify Runtime.
B3 must route producer and decoder through the sole canonical-local semantic owner,
not add another producer-only rule table. Focused GREEN then reruns the same prefix,
and B12 reruns it in the complete record/factory/graph regression.

## 16. Current RELEASE — B2 Slice 5 single-test-TU source-authoring packet

Slice 5 did not inherit section 15 as an executable packet. Historical read-only
research from final Slice-4 source SHA
`9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`
is preserved at `.superpowers/sdd/b2-slice-5-research.md`, SHA-256
`FE79C93FFD9F924D77FB257DD51A4F4A234189022D732B81EE2D2A9FEDFBBAED`.
Its `121/1967/2088` and 41-focused figures are superseded discovery evidence:
IC-182 proved seven empty TypeKinds undercount eleven real forms, while IC-184
proved the focused partition was both arithmetically inconsistent and incomplete
against the released authority.

Exact proposal
`b2-slice5-authority-correction.md` received 0 Critical / 0 Important / 1 Minor
RELEASE. After two rejected IC-183 candidates, exact authority repair-2 packet
`0C978C15083B81EDCDF298881238C1CEEA2F4D92FB4A6CDB3D785D0B37E8A144`
received fresh 0 Critical / 0 Important / 0 Minor RELEASE. Neither release is a
source-edit authorization. The authority now closes:

- unobservable zero-parameter/`HasDefaultConstructor` assumptions, including
  three already-approved Slice-1 reverse producer rows and a decoder test;
- unencoded empty-Behavior ghost coordinates;
- Behavior owner presence versus exact graph owner;
- statics identification after later Reflection without forbidden look-ahead; and
- duplicate FunctionKey, exact-row reorder and zero-owner/optional-owner literal
  precedence.

The first rematerialized candidate
`A06F117FF4556C01D9E78EB380736D32F0DBEEBA1287780C080FBF22D92C3FD7`
was rejected by independent exact-file review with 0 Critical / 3 Important / 3
Minor. Its arithmetic passed, but it overgeneralized decoder owner coordinates,
omitted mechanical companion recipes behind the 101 product successes and
published a PowerShell wrapper that did not parse. The full rejected review is
preserved at `reviews/b2-slice5-ready-packet-review-A06F117F.md`.

Repair 1
`9E3222C92135C01BE4A8712BE26D9F982BD49C386AAD8764CAD3C4E607F38A6D`
closed IC-186–188 and all three initial Minors, but two independent rereviews
agreed on 0 Critical / 2 Important / 1 Minor HOLD. Its exact-alias recipe copied
an absent owner into an earlier Construct/Factory peer, and its CopyFactory
no-peer mutation could leave Class counts at `1/0`. Both reviews are preserved at
`reviews/b2-slice5-ready-packet-rereview-9E3222C9.md` and its `-secondary`
counterpart.

The released source-authoring packet is `b2-slice5-ready-packet.md`, SHA-256
`2B51C3601888B53DABDFB2C021605138113DF937773C2450DA653C43D47AF625`,
36,113 bytes / 713 LF / 0 CR / final LF. It retains:

```text
Method/VFT producer       121 =  20 success +  101 failure
Behavior producer        1994 = 118 success + 1876 failure
-------------------------------------------------------
Slice-5 producer total   2115 = 138 success + 1977 failure
```

The Behavior ledger is eleven empty-form successes, 1,902 represented nonempty
rows after two named B1 exclusions, seventeen statics negatives and 64 focused
rows. The focused partition removes singleton-overflow duplicates already present
in the cardinality-two product, adds per-kind gaps/duplicates, embeds three
ordinal-winning owner pairs, and adds copy no-peer/Environment anti-alias controls.
It deliberately retains one abstract-Class constructor-group cross-field success.

The repaired candidate also freezes five existing default-constructor failure-to-success
repairs, four retained decoder error/coordinate repairs, two Class-count physical-
row coordinate repairs, removal of 952 ghost decoder calls, eleven decoder empty
forms and five decoder owner-precedence calls. IC-185 forbids broad dependency
deletion when clearing Behavior and requires exact dependency closure plus final
hash regeneration for every representable non-hash mutation.

IC-186 now assigns decoder row/target/owner failures to exact captured subfields
and freezes every paired-owner PrimaryIndex. IC-187 adds static companion recipes
for Class Construct/Factory counts, Destruct flags, script-copy peers, the complete
Delegate cleanup route and Environment anti-alias controls; the runner still may
not derive expected legality. IC-188 repairs the only allowed PowerShell wrapper.
IC-189 splits Script Copy companions by owner shape so an absent primary has no
invalid earlier peer. IC-190 removes both exact Factory and its solely balancing
Construct for the CopyFactory no-peer row, keeping Class counts at `0/0`. All four
previous Minors are repaired: exact section links, exact IC-173 method name, the
TemplateCallback gap setup and the Section-6 Behavior-producer subject.

Two independent exact-file reviews now return 0 Critical / 0 Important / 0 Minor
RELEASE: primary SHA
`B7CF20870BB8D26E8B85ABCBA65D000B400B7E589319DA20BF283E1ACD27A119`
and secondary SHA
`0B5E420B093C0578076CFD4D94BFFBFEAB061A934A28C739664A92CE4CB4CA23`.
Source authoring may therefore start in the one frozen test TU and must follow the
packet checkpoints, then complete-TU compile and obtain fresh exact-source review.
No Runtime source changes are authorized yet. IC-145 continues to forbid
link/focused RED, B2 completion and B3 authorization.

## 17. Historical checkpoint — Slice 5 materialized and compiled

The released packet has now been materialized only in
`AngelscriptCacheTypeSchemaTests.cpp`. Current SHA-256 is
`18A55226D0786BC0C9C7E120492D55A9DB487CBC0070A1612BE3AB1BE356D5F9`:
680,701 bytes, 15,693 LF, zero CR, final LF and 63 test methods. The exact Method/
VFT `121 = 20/101` and Behavior `1994 = 118/1876` partitions compile, along with
IC-172/173/177 repairs and five paired-owner decoder cases. Detailed fixture,
arithmetic and command evidence is in `b2-slice5-source-report.md`.

The first wrapper run exposed IC-191, a test-wire coordinate spelling mismatch.
Logical `BehaviorDeclaringOwner` is observed through existing test span field
`BehaviorDeclaringOwnerOptionalTag` at secondary index `1`; the minimal test-only
mapping repair compiled in artifact
`Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_103033_382_7db8e595`.
No Runtime/header field was added.

This was not an independent exact-source review or behavior RED. It is retained as
the predecessor to the linked checkpoint below; current authority is no longer the
`18A552...D5F9` source.

## 18. Current checkpoint — B5 GREEN, B2/B6 RED, shared validator next

The minimum TypeSchema decoder bridge and Manifest/Pack declaration/stub surface
now compile and link in artifact
`Saved/Build/cache-b5-b7-c2-linked-frontier/20260809_105449_324_a3d8c373`.
IC-145 is therefore closed as an evidence-order/link constraint. Manifest/Pack
functions still return `UnexpectedRecord`; this is not C2 behavior completion.

IC-193 and IC-194 repaired common-reader truncation coordinates and error
classification. IC-195 repaired one independent test coordinate: Property DataType
node fields require `(PropertyIndex, PreOrderNode)`, so the optional-tag assertion
now uses `(0, 0)`. The old exact source remains historical. Current test authority:

```text
SHA-256  2ACBD5E2005141805586D2D04FFE815E72B564F38FAE203D9C92D8810023E5EB
Git blob 1d9709a896e1b493b08fdbeeb94d740a7a0dbec7
bytes    680,785
LF/CR    15,695 / 0
methods  63
```

The five-method physical/captured-coordinate focus passes 5/5 at
`Saved/Tests/cache-b5-physical-focused-green/20260809_111346_019_36ca749b`,
closing B5. A B6 Behavior decoder method fails normally at
`Saved/Tests/cache-b5-behavior-kinds-red/20260809_105855_049_5c3939e3`,
and the matching normal-producer Behavior method fails normally at
`Saved/Tests/cache-b2-behavior-producer-red/20260809_111447_046_077c5b75`.
These are returned semantic/output mismatches, not link failures or crashes.

The next executable plan is serial:

1. execute all eleven `NormalProducer...` methods and record exact discovery,
   pass/fail/skip counts; B2 stays unchecked until this behavior authority is
   complete;
2. implement one shared canonical-local TypeSchema validator used by normal
   producer B3 and private decoder B6;
3. rerun the full normal-producer prefix plus focused decoder-local methods;
4. continue B7 hashes/checkpoints only after the local stage is GREEN.

The validator must own only frozen canonical-local truth. It may not resolve graph
targets/owners/modules, inspect current engine state, derive legality from tests or
create separate producer/decoder rule tables. Publication remains atomic and all
local failures precede current-resolver use.

## 19. Current checkpoint — B2 complete, shared Behavior slice GREEN

The eleven-method normal-producer authority is now fully materialized and has
executed without crashes, checks, unresolved symbols or timeouts. Its trustworthy
initial mixed RED (`1/11` GREEN, `10/11` RED) closes B2. After the first B3 family,
the current prefix is `2/11` GREEN and `9/11` expected implementation failures.

The shared Runtime architecture established by the Behavior slice is now the
template for subsequent families:

```text
normal producer ─┐
                 ├─> ValidateProducerShape
private decoder ─┘          │
                            ├─ field-local validation
                            │    no later-field look-ahead
                            │
                            ├─ all later field-local passes
                            │
                            └─ cross-field closure
                                 before derived hashes/publication

producer result: Stage=None, ByteOffset=0
decoder result : LocalSemantic + optional logical coordinate -> captured offset
```

Behavior specifically uses `ValidateBehaviorFieldLocal` for raw kind, stable
target, owner presence, ordinal/group order and TypeKind-local role rules.
`ValidateBehaviorCrossFieldClosure` runs after Dependencies field-local checks and
owns statics, singleton cardinality, Class Construct/Factory counts, script-copy
aliases and constructor/destructor flag coupling. This phase split closes IC-203
and preserves IC-175's no-look-ahead rule.

The exact focused build/test frontier is:

```text
Saved/Build/cache-b3-b6-dependency-before-alias-linked/
  20260809_120215_108_6bcca30a
Saved/Tests/cache-b3-b6-behavior-phase-split-green-2/
  20260809_120235_410_1be0ff56  => 5/5 PASS
Saved/Tests/cache-b5-physical-regression-green/
  20260809_115744_789_776dd23c => 5/5 PASS
```

Next work remains serial on the main thread. Implement the remaining nine producer
families in authority order, extending the same shared validator and coordinate
channel. Do not start B7 current-layout/hash consumption until B3/B6 local
semantics are complete; do not turn the Manifest/Pack link stubs into an implied
C2 completion claim.

## 20. Current checkpoint — Header/String/TypeSemanticFlags producer GREEN

The second B3 family is now GREEN on the normal production path. The shared
`ValidateProducerShape` owner validates the frozen payload version, module/type
keys, raw TypeKind, canonical strings, known/required/allowed type flags and the
flag-to-Behavior closure. It does not accept a resolver and publishes no bytes on
failure.

IC-205 records why the first post-implementation run was not treated as a Runtime
contract failure: the test did not actually retain embedded NUL characters, the
physical trace path could not observe an intentionally unknown union discriminator,
and Delegate's complete baseline already had Construct. The repairs remain
test-only observation/fixture changes except for the Runtime test-only physical
trace branch; normal serialization is still strict.

Current evidence:

```text
linked build  Saved/Build/cache-b3-header-flags-fixture-fix2-linked/
              20260809_121449_770_bbe0d936
focused       Saved/Tests/cache-b3-header-flags-focused-green-3/
              20260809_121508_408_8012ea2b => 1/1 PASS
producer      Saved/Tests/cache-b3-normal-producer-progress-header-flags/
              20260809_121545_510_187f063f => 3/11 PASS, 8 expected RED
B5 regression Saved/Tests/cache-b5-physical-after-unknown-kind-green/
              20260809_121630_317_2699ef2d => 5/5 PASS
```

Continue serially with the next one of the eight failing normal-producer families.
For each family, first implement the canonical-local rule in the sole shared
validator, then add/verify the decoder logical coordinate and frozen checkpoint at
the proper field-local or cross-field phase. B3 is not checked until the whole
producer prefix is GREEN; B6 is not checked from producer evidence alone.

## 21. Current checkpoint — shared Relations producer/decoder GREEN

The next vertical family is complete at focused behavior level without creating a
second rule owner:

- `ValidateRelationsFieldLocal` owns raw relation kind, structural target,
  target-reference kind, canonical order, duplicate target and direct-interface
  ordinal checks without consulting Reflection or a resolver;
- `ValidateRelationsCrossFieldClosure` owns the frozen form/cardinality matrix,
  ordinary-`UClass` Shadow/Code companion coordinate and required/forbidden row
  closure only after all field-local passes through Dependencies have succeeded;
- both the normal producer and private decoder call those same functions;
  producer failures retain normalized stage/byte presentation, while decoder
  failures use the shared logical coordinate to select the exact retained row or
  Reflection discriminator offset; and
- the phase remains `Relations field-local -> ... -> Dependencies field-local ->
  Relations cross-field -> Behavior cross-field`, so later form knowledge cannot
  hide an earlier malformed Dependency.

IC-206 records two fixture defects discovered by the full Cartesian product. The
fixture now uses `CompareDependencies`, and only ordinary `UClass` creates the
required same-target Shadow/Code pair. Runtime precedence was not weakened.

Verification is intentionally bounded but visible in the Automation log:

```text
build      Saved/Build/cache-b6-relations-structured-logs-linked/
           20260809_125232_234_9d8fb5ae
relations  Saved/Tests/cache-b3-b6-relations-structured-green/
           20260809_125251_480_9d10a235
result     total=5 passed=5 failed=0 skipped=0
producer   195 scenarios = 165 matrix + 30 focused
decoder    495 cells = 167 expected success + 328 expected failure
prefix     Saved/Tests/cache-b3-normal-producer-progress-relations/
           20260809_124905_758_a5c519a1 (4/11 PASS, 7 expected RED)
behavior   Saved/Tests/cache-b3-b6-behavior-after-relations-green-2/
           20260809_125105_450_15079206 (5/5 PASS)
B5 rerun   Saved/Tests/cache-b5-physical-after-relations-green-2/
           20260809_125645_939_761a4a12 (5/5 PASS)
```

Current source identities:

```text
Runtime TypeSchema.cpp
  SHA-256  8B61282B213D1D2E90587AADF9275CA1C8B18BD56C51018F7205C7E131C729F4
  Git blob e91d019243cc7b685d4f552d747dd462a07a8a43
  bytes/LF 121,834 / 3,814
  CR/final 0 / yes

TypeSchemaTests.cpp
  SHA-256  BE7188DA18DF1BB4FCEC811A3F5F2344BD101157C2C9BC2F42E389980B4682B5
  Git blob 1258600c7616566f4ccf2a7759754fe9693d7355
  bytes/LF 691,742 / 15,928
  CR/final 0 / yes
  methods  65
```

The next TDD slice is `LayoutInputs`: first preserve the existing focused producer
RED, then implement role/reference/order/presence/pairing through the same shared
field-local/cross-field boundary and prove exact decoder coordinates. B7
`LayoutInputHash` and other derived-hash/current-layout work remains a separate
later gate; it must not be pulled forward to make local semantics appear GREEN.

## 22. Current checkpoint — shared LayoutInputs producer/decoder GREEN

The LayoutInputs vertical family now uses the same production validator for the
normal serializer and private decoder. Its field-local pass owns raw role,
structural/reference-kind validity, optional contribution masks, signed-range and
power-of-two alignment constraints, per-row `LayoutInputHash`, canonical order
and singleton duplicate/conflict detection. Its cross-field passes own exact
form-role presence plus Base/Shadow/Code Relation pairing. Missing BaseType uses
the requiring Base Relation coordinate; missing CodeRoot/StructHeader uses the
Reflection discriminator; present malformed inputs use their exact physical row.

The frozen phase order remains deliberate:

```text
Relations field-local
  -> LayoutInputs field-local
  -> later field-local passes through Dependencies
  -> Relations form/cardinality closure
  -> LayoutInputs form presence
  -> Behavior closure
  -> Relation/LayoutInput pairing
```

This is why two `ExpectedAbi` mutations are logged as Dependency-precedence
controls rather than reachable pairing failures. IC-207 records the corresponding
producer/decoder authority corrections. IC-208 records and repairs one test-only
`TArray` self-alias crash. IC-209 records the old Relations Cartesian fixture's
newly visible LayoutInput co-faults, the two rejected Runtime-precedence
experiments and the final single-fault fixture repair; no experimental Runtime
rule survives.

The bounded Automation logs provide audit-friendly counts:

```text
producer
  legal=13 raw-kind=3 missing=5 extra=34 wrong-role=3
  pairing=6 dependency-precedence=2 optional-mask=12
  zero-key=3 missing-abi=3 wrong-reference=6
  invalid-alignment=4 overflow=5 stale-hash=1 total=100

decoder role matrix
  4 roles x 4 contribution masks = 16 cells
  expected-success=4 expected-failure=12
  target-checks=16 missing-checks=4 total=36

decoder focused presence
  present-zero=1 role-mask-negatives=2 wrong-reference=1 duplicate=1 total=5

decoder closure
  pairing=6 forbidden-form=1 noncanonical=1 duplicate=1 conflict=1 stale-hash=1
  total=11
```

Final executable evidence:

```text
build       Saved/Build/cache-b6-relations-isolated-layout-fixture-linked/
            20260809_132607_778_17d405af
layout      Saved/Tests/cache-b3-b6-layoutinputs-structured-final/
            20260809_132735_879_327c67af (4/4 PASS)
relations   Saved/Tests/cache-b6-relations-isolated-layout-fixture-green/
            20260809_132624_956_445b1450 (1/1 PASS, 495 cells)
regression  Saved/Tests/cache-b3-b5-b6-after-layoutinputs-regression-final/
            20260809_132701_941_ccd52550 (15/15 PASS)
producer    Saved/Tests/cache-b3-normal-producer-progress-layoutinputs-final/
            20260809_132853_348_ee69f1be
result      11 total, 6 passed, 5 expected implementation failures, 0 skipped
```

The sixth GREEN producer method is the adjacent set-like canonicalization method,
which became satisfied by the shared rules; it is counted as observed behavior,
not relabeled as a separately completed semantic family. The five remaining
producer failures are Dependency coverage/conflicts; KindPayload/Enum/Callable/
Typedef; Method/VFT; Property/LayoutReplay; and Reflection.

Current source identities:

```text
Runtime TypeSchema.cpp
  SHA-256  958BA18F5F867AD0E2938FADAF5CB1BC4F71B8A9E531E25E890EAC8E48B8D76F
  Git blob 0183b8de3a73eb889c15edf3ac623232793ffd00
  bytes/LF 133,627 / 4,173
  CR/final 0 / yes

TypeSchemaTests.cpp
  SHA-256  3E458B206CD01E539FB8A1D22A80D498BDDE496F7DE4D1B0526B732444E29CEC
  Git blob fe94a1b077448ce4eb9269ee502dba00d831d27f
  bytes/LF 703,160 / 16,196
  CR/final 0 / yes
  methods  66
```

B3/B6 remain open. The next serial family is Dependency coverage/conflicts,
because it is the next earlier field-local authority and already owns precedence
over later alias/pairing closure. B7 prospective/current-layout resolution and
property/enum/final hash checkpoints remain deferred.
