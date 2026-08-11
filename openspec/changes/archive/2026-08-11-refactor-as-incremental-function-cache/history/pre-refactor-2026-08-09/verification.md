# Implementation Verification Log — 2026-08-08

Implementation problems and rejected approaches are tracked progressively in
`implementation-issues.md`. That attachment records problem, impact, evidence,
decision, and closure requirements; this file remains the authoritative command
and result log. An issue is not considered resolved merely because it was added
to either file.

## Planning Baseline

The initial round recorded and validated the implementation design only. It did not modify `Plugins/Angelscript`, `Tools`, `Config`, tests, packaging behavior, Runtime/Editor code, the maintained AngelScript fork, or business `.as` source.

Recorded artifacts:

- proposal rewritten around Saved-only first-launch Cache V2 and loose authoritative source;
- progressive research covering current FunctionId/DataGuid pairing, mixed archive fields, module/type/global/function boundaries, builder seams, Editor/PIE/Shipping lifecycle, packaging, StaticJIT and Live Coding;
- decision-complete architecture for stable entity identity, FunctionInputDigest/ContentHash separation, environment symbol dependencies, six logical records, physical packs, module-atomic assembly, immutable generations, concurrency, runtime reload and shutdown;
- new `as-script-artifact-identity` capability;
- new `as-incremental-script-cache` capability;
- modified `as-cooked-packaging-runtime` delta removing the precompiled pre-step and requiring loose-source first-launch/multi-launch behavior;
- TDD-ordered `tasks.md` and file/API/command-complete `implementation-plan.md`;
- requirement-to-task/test/package mapping in `traceability.md`;
- benchmark schema/procedure under `benchmarks/README.md`;
- corrected cross-change boundary notes for `refactor-as-static-jit-external-module`.

## Implementation Status

- Isolated worktree/bootstrap and implementation-start seam audit: complete.
- Cache V2 task group 1 stable identity/value boundary: complete and independently approved.
- Cache V2 Task 2A minimal record envelope: complete and independently approved.
- Cache V2 semantic records/store/compiler/lifecycle implementation: not started; the next action is Task 2B-1 canonical primitives, SourceIndex, and ModuleInterface RED tests.
- New C++/Blueprint/console interfaces: not started.
- Unit/runtime/PIE/package tests: not started.
- Loose NonUFS package staging and package smoke runner: not started.
- Legacy cache removal: not started.
- Real PIE and Development/Shipping evidence: not yet available and explicitly scheduled last.

Tasks 1.1 through 1.5 and 2.1 are checked. This claims the pure stable identity,
canonical encoding/path boundary/cross-change vectors and the minimal
memory-only record envelope. It does not claim that a complete semantic record,
manifest, pack, disk store, compiler capture, restore, publication, packaging,
or lifecycle behavior exists yet.

## Isolated Worktree And Clean Baseline

Implementation is isolated at `D:\Workspace\AngelscriptProject\.worktree\as-cache` on branch `refactor-as-incremental-function-cache`. The parent base is `cd5cc87c9aa63b6d7035934ca549b53f357efe02`; the nested `Plugins/Angelscript` worktree base is `4899ff5e37725ef32ba78329d28f62a763360b32`. The main checkout's source and user changes were not copied or edited; only the two previously prepared OpenSpec directories were copied into the isolated parent worktree.

The original long path was discarded before source edits because UHT action paths exceeded Windows' 260-character boundary. The shorter `.worktree\as-cache` path keeps the measured longest generated action path below that boundary.

Baseline commands and evidence:

```powershell
Tools\RunBuild.ps1 -Label worktree-baseline-incremental-cache-shortpath -TimeoutMs 1800000 -NoXGE
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label worktree-baseline-staticjit -TimeoutMs 1200000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.PrecompiledData" -Label worktree-baseline-precompileddata -TimeoutMs 1200000
```

- Build: exit `0`, 119 actions, report root `Saved/Build/worktree-baseline-incremental-cache-shortpath/20260808_024904_041_bac9a369/`.
- Focused legacy archive baseline: `4/4 PASS`, report `Saved/Tests/worktree-baseline-precompileddata/20260808_025544_710_da0ce585/Report/index.json`.
- Broad StaticJIT baseline: `19/30 PASS`; all 11 failures are AOT-only and report the same missing local `StaticJITAotFixture.Cache` plus matched generated `.jit.cpp/.jit.hpp` prerequisite. The report is `Saved/Tests/worktree-baseline-staticjit/20260808_025221_768_7c87a340/Report/index.json`. This clean-baseline condition is not attributed to Cache V2 implementation.

The implementation-start code seam audit corrected the plan before source edits: all builder compile families are explicit; `sFunctionDescription` is replaced by a kind-tagged invocation contract; VM-private instruction/reference and metadata reconstruction is mandatory; SourceIndex/environment capture is complete and per-engine; publication uses a post-ClassGenerator immutable DTO; AS mutations have a per-engine transaction gate; and StaticJIT receives an explicit compatibility bridge before legacy removal.

A second independent read-only review rechecked every finding from the first seam audit after the revisions. It classified all nine must-fix items and all four suggested-fix items as closed in the planning artifacts: compile-family/lambda/`NotCacheable` coverage; executable `FunctionSourceDigest` plus persisted-dependency input algorithm; VM-private codec boundary; DTO producer/freeze point; both environment initialization paths; complete SourceIndex and explicit root; normative per-engine mutation gate; retained StaticJIT compatibility transport; physical PackId identity; unique ModuleSnapshot/DebugSidecar linkage; final PIE acceptance ordering; isolated-worktree rule; and packaged nonzero startup failure contract. This is design closure only, not an implementation-complete claim.

## Task Group 1 — Stable Identity Evidence

The first TDD slice added pure Runtime value types and pure CQTests without
constructing an AngelScript engine or touching disk/store/lifecycle code.
Implementation is limited to:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h`;
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.cpp`;
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptArtifactIdentityTests.cpp`.

The tests first failed to compile because the new identity API did not exist.
An independent review then found three Important gaps: missing per-domain full
goldens, a raw absolute-path route into ModuleKey, and vacuous forbidden-field
locals. The repair cycle added a non-default/raw-string-constructible
`FAngelscriptLogicalVirtualPath`, fail-closed `TryCreateLogicalVirtualPath` /
`TryBuildModuleKey`, independent full 64-hex goldens for every identity/profile
domain including a synthetic function, insertion-order variants, and
compile-time descriptor-shape guards.

Repair TDD commands and evidence:

```powershell
Tools\RunBuild.ps1 -Label as-cache-identity-review-red -TimeoutMs 1800000
Tools\RunBuild.ps1 -Label as-cache-identity-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Identity" -Label as-cache-identity-green -TimeoutMs 600000
```

- Compile RED: exit `1` at the missing typed path/`Try*` API; log
  `Saved/Build/as-cache-identity-review-red/20260808_034335_282_5f4cd857/Build.log`.
- Golden RED after the API existed: `2` succeeded / `6` failed against
  placeholders; report
  `Saved/Tests/as-cache-identity-review-golden/20260808_034459_294_cf7080ea/Report/index.json`.
- Final build: exit `0`, `Result: Succeeded`; log
  `Saved/Build/as-cache-identity-green/20260808_034628_817_f1de971f/Build.log`.
- Final focused tests: `8` succeeded / `0` failed / `0` not run / `0`
  warnings; report
  `Saved/Tests/as-cache-identity-green/20260808_034653_199_0a4334e8/Report/index.json`.
- Plugin `git diff --check`: clean; the nested worktree contains only the two
  intended new source directories and has no staged files.

The final independent re-review is `Approve` with `0` Critical, `0` Important,
and `0` Minor findings. It verified all three repair items, the full-width
authority rule, the schema/domain/little-endian/UTF-8 writer, value separation,
the eight pure tests, and the RED/GREEN evidence. Detailed coordination reports
remain under the ignored `.superpowers/sdd/` directory.

The normative vectors and their complete fixture inputs are published in
`identity-golden-vectors.md`. The sibling StaticJIT change records its allowed
consumption boundary in
`../refactor-as-static-jit-external-module/shared-identity-contract.md`; it may
consume the public identity types and vectors but no Cache V2 storage or
lifecycle API.

## Artifact Consistency Checks

- Proposal capabilities map one-to-one to:
  - `specs/as-script-artifact-identity/spec.md`
  - `specs/as-incremental-script-cache/spec.md`
  - `specs/as-cooked-packaging-runtime/spec.md`
- `design.md` fixes identity algorithm, logical/physical granularity, ModuleState boundary, storage root, generation semantics, source authority, Editor/PIE policy, runtime reload API/defaults, Shipping first-launch behavior, package staging, StaticJIT boundary and final test order.
- `tasks.md` contains only implementation checkboxes and TDD/Non-TDD markers; research, metrics and verification commentary remain in separate files.
- `implementation-plan.md` identifies exact create/modify/retire areas, produced interfaces, red/green commands, package scenario assertions and final verification entry points.
- No packaged baseline, baseline/overlay lookup, source-free Shipping default, whole-binding-profile invalidation, one-file-per-function layout, SHA-256 identity, or UE 5.7/5.8 cross-reuse assumption remains normative.

## Pre-Schema-Correction Validation Evidence

Before the Task 2 semantic-record schema correction, the proposal/design/spec/
task and sibling-boundary artifacts were checked with these commands, which
returned exit code `0`:

```powershell
openspec status --change "refactor-as-incremental-function-cache" --json
openspec validate "refactor-as-incremental-function-cache" --strict
openspec status --change "refactor-as-static-jit-external-module" --json
openspec validate "refactor-as-static-jit-external-module" --strict
```

Both status results reported `isComplete: true` and both strict validators
reported `valid`. A recursive artifact audit reported:

- `27` OpenSpec files with clean trailing whitespace and final
  newlines;
- current Cache V2 checklist: `5` checked identity/baseline tasks and `49` unchecked implementation/verification tasks;
- `31` unchecked and `0` checked StaticJIT tasks;
- no old `as-function-artifact-identity` or `as-incremental-function-cache`
  target spec file;
- the scoped Git status contains only the two untracked OpenSpec change
  directories; no implementation file was part of that initial validation scope.

Those counts describe that earlier checkpoint and are retained as historical
evidence; they are superseded for the Cache V2 change by the schema-correction
validation below.

## Task Group 2 — Semantic Record Schema Correction

Before expanding the partial Task 2A envelope into semantic records, a
read-only field-ownership review compared the proposed Cache V2 schema with the
maintained fork, legacy `StaticJIT/PrecompiledData`, compiler/VM state, source
inventory, pack/store graph, and the future live-attachment boundary. The
review found twelve must-fix planning issues. They are now recorded formally:

1. `record-schema.md` is the normative implementation-facing, pointer-free
   semantic schema; legacy PrecompiledData is only a field inventory and test
   comparison source, never the Cache V2 wire model.
2. Reconstructible declarations, types, globals, imports, metadata, slots, and
   dependencies are explicit common-cache values instead of opaque schema or
   state blobs.
3. Common archive ownership, the VM-private execution/initializer/debug codec,
   and serialized per-engine attachment are separate layers.
4. SourceIndex uses stable mount/provider/hook/source/include keys, typed
   relative logical paths, relocation-stable fingerprints, and per-scope
   exact-fast-path eligibility; it never persists host absolute paths.
5. ModuleSnapshot and generation roots use entity-keyed links, validate owner/
   kind/coverage, and index exactly the reachable record graph.
6. V1 `ModuleState` exclusively embeds global/module initializer execution,
   solved order, hard values, and post-init semantics; initializer artifacts
   are not independently activated FunctionBody records.
7. TypeSchema is authoritative for enum declaration/value/reflection shape;
   ModuleState may retain only a checked derived hard-value fingerprint.
8. `ExpectedAbi` represents declaration/layout/storage/route ABI. Embedded
   implementation content, constants, and other hard values use separate typed
   content/value dependencies.
9. A missing DebugSidecar is an unset optional plus the shared
   `function-debug-absent` canonical-writer digest over exactly the full
   ProfileKey, not a zero-id/hash or empty-debug sentinel.
10. Envelope, semantic-record payload, and VM codec versions are independent
    validation axes.
11. Canonical set ordering is distinct from semantic ordinal sequences, and
    validation covers duplicates/conflicts, UTF-8/path rules, checked ranges,
    per-record plus cumulative budgets, integrity, graph ownership, and typed
    corruption-versus-eligibility outcomes.
12. Task 2 is split into Task 2A and no-live-engine Task 2B-1/2B-2/2B-3
    vertical slices. Task 2A was subsequently completed and approved as task
    2.1; it does not complete any semantic-record, manifest, or pack task.

The correction updates `design.md`, `implementation-plan.md`, `tasks.md`,
`research.md`, `traceability.md`, and the incremental-cache delta spec. This
record-only step changes no plugin source, tests, or sibling StaticJIT OpenSpec
artifact; it stages or commits nothing. It also makes no new build, runtime, or
test claim.

A final task-boundary review removed duplicated disk-store work from Task
2B-3. That slice now ends at pure keyed manifests, in-memory pack encode/read
validation, and cumulative budget/determinism tests. Repository task group 3
exclusively retains filesystem roots and immutable disk sessions,
Current/Previous/Pending, temporary publication and crash recovery,
system-wide locking/rebase, cancellation, source-aware fallback, retention,
and compaction.

After the corrected artifacts were written, strict validation returned exit
code `0` and reported the change `valid`:

```powershell
openspec validate "refactor-as-incremental-function-cache" --strict
```

A recursive audit scoped only to this change reported `14` files, `0`
trailing-whitespace or missing-final-newline issues, `5` checked tasks, and
`53` unchecked tasks (`58` total). The five checked items remain only the
previously proven Task Group 1 work; no `2.x` task is checked. Both commands
were rerun after this evidence paragraph was added so the final result covers
`verification.md` itself.

## Task 2A — Minimal Record Envelope Evidence

Task 2A added an explicit record envelope with a fixed 56-byte header, semantic uncompressed
RecordId hashing, full-width RecordId equality/order, typed validation results,
bounded reads, and thirteen pure CQTests. It remains a value-only memory
boundary: the payload is opaque to Task 2A, no live AngelScript engine is
constructed, and no filesystem/pack/store path is used.

The initial TDD pass produced a genuine missing-header RED, a two-golden RED,
and `9/9` GREEN. Independent review then found two Important public-boundary
defects: unchecked zero/unknown/intrusive-unset RecordId input and unsafe
input/output aliasing. The review-fix TDD pass removed the unchecked public
builder, added fail-closed `TryBuildRecordId`, typed invalid-view/alias errors,
checked `UPTRINT` allocation-range overlap, symmetric serialization and
deserialization alias rules, and a complete empty-payload vector.

Superseding commands and evidence:

```powershell
Tools\RunBuild.ps1 -Label as-cache-archive-envelope-review-fix-red2 -TimeoutMs 1800000
Tools\RunBuild.ps1 -Label as-cache-archive-envelope-review-fix-golden-build -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.Envelope" -Label as-cache-archive-envelope-review-fix-golden-red -TimeoutMs 600000
Tools\RunBuild.ps1 -Label as-cache-archive-envelope-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.Envelope" -Label as-cache-archive-envelope-green -TimeoutMs 600000
```

- Clean review-fix RED: wrapper exit `1`, with only missing
  `TryBuildRecordId`, `InvalidArrayView`, and `AliasedInputOutput` production
  contracts; log
  `Saved/Build/as-cache-archive-envelope-review-fix-red2/20260808_042117_495_4bdc00de/Build.log`.
- Review-fix implementation build: exit `0`, `Result: Succeeded`; log
  `Saved/Build/as-cache-archive-envelope-review-fix-golden-build/20260808_042323_404_f9875d96/Build.log`.
- Empty-vector RED: `12` succeeded / `1` failed / `0` not run / `0` warnings;
  the only failed test contains the intentional empty RecordId/envelope
  placeholders; report
  `Saved/Tests/as-cache-archive-envelope-review-fix-golden-red/20260808_042345_582_87702c85/Report/index.json`.
- Final build: exit `0`, `Result: Succeeded`; log
  `Saved/Build/as-cache-archive-envelope-green/20260808_042456_438_533302b4/Build.log`.
- Final focused tests: `13` succeeded / `0` failed / `0` not run / `0`
  warnings/errors; report
  `Saved/Tests/as-cache-archive-envelope-green/20260808_042513_872_2a2ebdf1/Report/index.json`.
- Plugin `git diff --check`: clean; no Task 2A file is staged or committed.

The final fresh independent re-review is `Approve` with `0` Critical, `0`
Important, and `0` Minor findings. It audited negative/positive-null/end-
overflow views, empty payload, complete allocation aliasing, unchecked-helper
reachability, validation precedence, both RED phases, final build, all thirteen
tests, and full-width goldens. The normative format, hashes, error boundary,
and exact evidence paths are published in `archive-format-vectors.md`.

After Task 2A was checked and its vector/evidence files were added, strict
validation and recursive formatting/task-count checks were rerun. They report
`15` change files, `0` formatting issues, `6` checked tasks, and `52` unchecked
tasks (`58` total).

## Task 2B-1 — Pre-RED Wire Contract Closure

A value-only executable-interface audit was completed before writing Task 2B-1
RED tests. Its fourteen must-close decisions are now normative in
`record-wire-v1.md` and synchronized into the schema, design, implementation
plan, tasks, research, and traceability:

1. SourceIndex has no global eligibility bool; `IneligibleScopes` is queried
   against only the target module/file/mount/provider/hook scopes, so unrelated
   scopes remain exact-hit eligible.
2. Six typed source sub-keys reuse the existing Task 1 artifact writer and the
   exact `cache-source-*`/`cache-preprocess-hook` domains; version,
   configuration, and content are snapshot fields rather than stable-key input.
3. Mount/provider/hook/file/input/edge subrecords, provider/hook capabilities,
   discovery filters, and input target presence are explicit.
4. `SourceFile.ModuleKey` is the only source-to-module wire authority.
5. Declaration is a complete tagged union with EntityKind, sorted unique
   identity traits, tagged type fields, parameters, flags, metadata, multi-slot
   data, and recomputed key/hashes.
6. DeclarationKind is Type/Function/Global/Property only; Import has one
   separate authority. Delegate/Typedef/Funcdef are Type entities, with new
   non-renumbering Task 1 EntityKind values 6/7 for Typedef/Funcdef; their
   signatures are Function declarations owned by the TypeKey.
7. Slots are independent from declaration set order and form per-kind complete
   ModuleInterface-wide ordinal sequences.
8. SignatureHash, TraitsHash, and InterfaceAbi have exact domain/input/exclusion
   rules; complete payload RecordId still covers their stored values.
9. Default-expression bytes are caller-visible interface semantics; an
   embedded resolved value still creates a later HardValue dependency.
10. Every dependency kind has one required/absent ExpectedContent matrix.
11. Strings are strict UTF-8 without NUL or Unicode normalization;
    code-point traversal plus one `FTextChar::ToLower` mapping per Unicode
    scalar value checks path collisions without changing identity bytes or
    performing multi-code-point full fold.
12. Source values require raw-byte BLAKE3-256/explicit fingerprints; Task 2B-1
    does not modify the current provider and never promotes its 64-bit state
    hash.
13. Namespace tables contain only used nonempty namespaces; declaration empty
    namespace represents global scope.
14. Existing envelope errors retain their values; one exhaustive
    `Classify(Error)` owns ValidationClass and each result adds RecordKind and
    ByteOffset.

V1 additionally fixes SourceKind to Game/Plugin/Memory, keeps
Generated/External as provider kinds, removes primitive Wildcard, canonicalizes
int/uint to Int32/UInt32, and requires Auto kind/qualifier agreement. Exact
scalar widths, field order, enum/flag numbers, collection comparators,
duplicate/conflict keys, ordinals, key domains, and derived-hash goldens are all
part of the RED contract.

DeclarationTraitFlags (`KnownMask=0x1ff`), ReflectionFlags
(`KnownMask=0x3fff`), and ParameterTraitFlags (`KnownMask=0x7`) are fully frozen
in V1. There is no residual call-mask field: SignatureHash derives call
semantics from the tagged declaration, types/passing, and these explicit flags.
Unknown producer features are NotCacheable/schema-bump cases and unknown reader
bits are malformed.

This is a record-only correction. It changes no plugin source, test, provider,
or sibling StaticJIT artifact and does not change any checkbox. No build or
test result is claimed.

After all synchronized documents were written, both strict validators returned
exit code `0` and reported `valid`:

```powershell
openspec validate "refactor-as-incremental-function-cache" --strict
openspec validate "refactor-as-static-jit-external-module" --strict
```

The recursive audit reported `16` Cache change files with `0` formatting
issues and the unchanged `6` checked / `52` unchecked tasks (`58` total). The
sibling StaticJIT change has `14` files, `0` formatting issues, and its
unchanged `0` checked / `31` unchecked tasks. Validation and audits were rerun
after this paragraph was added so the final evidence includes
`verification.md` itself.

### Cross-slice coverage correction before Task 2B-1 RED

The read-only Task 2B-2 interface audit identified one field that must exist in
ModuleInterface before 2B-1 can freeze bytes: exact TypeSchema and FunctionBody
coverage. The wire contract now adds explicit `SchemaCoverage` and
`BodyCoverage` enums (`Forbidden=1`, `Required=2`) to every declaration, includes
them in SignatureHash and InterfaceAbi, and defines the declaration-kind/body
presence matrix. V1 has no Optional or inferred state. A producer that cannot
capture a Required body marks the complete snapshot NotCacheable; later graph
validation compares Required sets to keyed links exactly and rejects links for
Forbidden entities.

This correction happened before any 2B-1 test or source file was written and
therefore changes no frozen implementation vector. It modifies only OpenSpec,
keeps tasks 2.2/2.3 unchecked, and makes no build/test claim.

The same pre-RED audit corrected Typedef/Funcdef identity before bytes could be
frozen. Shared `EAngelscriptArtifactEntityKind` reserves non-renumbering
`Typedef=6` and `Funcdef=7`; both are TypeKey entities. DeclarationKind now has
only Type/Function/Global/Property, while delegate/funcdef signatures remain
separate `DelegateSignature=37` FunctionKey declarations owned by their
TypeKey. The Cache and sibling StaticJIT identity documents are synchronized,
existing identity vectors remain unchanged, and Task 2B-1 must still implement
and test the two new enum values. No executable success is claimed here.

### Task 2B-1 implementation-feedback wire corrections

While 2B-1 implementation was being developed independently, its pure record
interfaces exposed additional one-way prose rules. The OpenSpec contract now
closes them without checking tasks 2.2/2.3 from this documentation pass:

- SourceEdge SemanticOrdinal is all absent or all present-contiguous per
  `{FromSourceFileKey, EdgeKind}` group; mixed presence is InvalidPresence.
- Each Provider/Hook capability has an exact same-scope/key missing reason in
  both directions. Missing capability requires it; present capability forbids
  it; an unrelated reason cannot substitute.
- SourceIndex resolves every Mount/Provider, scope, input, edge, generated key
  and Files-derived ModuleKey with fixed WrongReferenceKind/
  MissingGraphTarget/ConflictingKey precedence. Distinct Files sharing one
  GeneratedSourceKey conflict, so no dangling or ambiguous source authority is
  publishable.
- All six source keys have one public identity-only, shared-writer,
  zero-on-failure typed builder with independent full-hash RED vectors; encoder,
  Task 4 producer and tests cannot fork the hash algorithms.
- ImportKey has the same public builder rule, but its identity input excludes
  route ExpectedAbi/ReferenceKind/Slots; full Import validation owns those
  non-key fields and their failures separately.
- The pure eligibility query accepts validated SourceIndex+ModuleKey, computes
  file/mount/provider and fixed-point affected-Hook closure, returns canonical
  matching reasons, clears output for a missing module, and never stores a
  global boolean. Two-module evidence must prove scope isolation.
- ModuleInterface resolves every local owner through the callable matrix;
  Method accepts only Class/Struct/Interface, Property only Class/Struct,
  DelegateSignature only Delegate/Funcdef, and
  CrossModuleOwner/WrongReferenceKind/MissingOwner precedence is exact.
- CanonicalTypeSpelling/DeclaredType equality is layered honestly: 2B-1 proves
  presence/shape/hash only, producer derives both from one compiler type, and
  resolved TypeSchema/current authority performs semantic comparison. The pure
  reader has no canonical type-name resolver and does not parse spelling.

These are contract/test-obligation corrections. This subtask did not edit or
claim success for the parallel plugin implementation or its tests.

## Task 2B-2 — Remaining-Wire Record-Only Contract Closure

The read-only Task 2B-2 interface audit found twenty decisions that could not
be left to independent record serializers or the later graph validator. The
listed rows are normative in `record-wire-v1-remaining.md`, which reuses all
Task 2B-1 primitives. A later preflight found that the complete TypeSchema and
ModuleState matrices are still explicit RED blockers; omitted rows are not
silently decided by this earlier list:

- the five remaining records have independent payload version 1 axes and
  unsupported-version results carry kind/stage;
- every remaining derived hash has an exact domain/input/exclusion stream,
  while Task 1 function execution/present-debug hashes remain payload-only;
- ModuleState and DebugSidecar carry ProfileKey; debug absence is one shared
  `function-debug-absent` stream over the full profile and requires common
  Cache/StaticJIT goldens;
- TypeSchema fixes TypeKind, relation/property/method/behavior order, enum
  signed-int32 authority, type/property/class/reflection flags, replication,
  TypeKind payload, and reflection presence without duplicated authorities;
- ModuleState fixes canonical scalar bits, per-global init/cleanup, exact
  global/module initializer and post-init ownership, every-local-enum coverage,
  allocate/init/post-init/active and reverse-cleanup lifecycle, and forbids an
  opaque ModuleLifetime or persisted initialized bit;
- only execution/initializer/debug bytes are opaque; the injected validator
  returns validated hash, full-coordinate relocations, exact debug sources and
  owned name/string bytes for common graph checks;
- ModuleSnapshot redundantly keys interface/state links, FunctionBody solely
  owns optional sidecar links, and Task 2B-2 exposes per-module
  `ValidateModuleSnapshotGraph` without 2B-3 manifest reachability;
- one current-symbol resolver distinguishes missing symbol, ABI mismatch and
  content mismatch only after immutable graph consistency; and
- errors `44..64`, exhaustive classes, local→reachable-codec→graph→current
  precedence and one Limits-aware caller-owned envelope/token/child/graph/codec
  budget are exact.

Independent review during synchronization closed two additional contradictions.
First, the frozen class flags contain no Config bit, so the executable matrix
now says ordinary UClass has optional ConfigName (absence inherits superclass)
and required StaticClassGlobalName, while synthetic StaticsClass UClass and all
non-UClass forms forbid both; StaticsClass is bidirectionally constrained.
Second, Task 1 has no GeneratedDefaultDestructor EntityKind. V1 therefore maps
that InvocationKind to existing `EntityKind::Destructor=35` plus required
Generated trait and fixes the complete invocation/declaration graph matrix
without adding or renumbering shared identity values.

This is planning evidence only. No plugin source or test was modified, no
build/test was run, and tasks 2.2/2.3/2.4/2.5 remain unchecked. Executable completion
still requires five full record/envelope/RecordId goldens, shared debug-absent
goldens, deterministic fixture codecs, every `44..64` mutation, cumulative
budget tests and atomic graph output.

### Record-only validation and format audit

After the remaining-wire closure, sibling identity obligation, and 2B-1
implementation-feedback corrections were synchronized, both strict validators
returned exit code `0` and reported `valid`:

```powershell
openspec validate "refactor-as-incremental-function-cache" --strict
openspec validate "refactor-as-static-jit-external-module" --strict
```

The recursive format/task audit then reported:

- incremental cache: `19` change files, `0` trailing-whitespace findings,
  `0` missing final newlines, and unchanged `6` checked / `52` unchecked tasks
  (`58` total);
- sibling StaticJIT: `14` change files, `0` trailing-whitespace findings,
  `0` missing final newlines, and unchanged `0` checked / `31` unchecked tasks;
  and
- combined task-line recount: `89`.

These commands validate OpenSpec structure and documentation formatting only;
they are not a substitute for the pending RED/GREEN build and automation tests.
They were rerun after this evidence paragraph was added so the results include
the final `verification.md` bytes.

## Current Implementation Handoff

Implementation continues with Task 2B-1 common primitives/SourceIndex/
ModuleInterface, followed by the exact `record-wire-v1-remaining.md` Task 2B-2
records/codec seam/per-module graph and Task 2B-3 pure manifest/in-memory
pack-format validation. Filesystem store
publication/recovery remains task group 3; environment capture,
current-function routing, builder hooks, the actual VM codec, and live
attachment remain later slices.
The sibling StaticJIT provider may consume the identity vectors, but it does
not wait for or depend on Cache V2 packs/generations.

No Cache V2 persistence, restore, incremental invalidation, Editor/PIE,
Shipping, or package behavior is yet claimed implemented. Task-group-1 claims
refer only to the pure stable identity/value boundary; baseline claims refer to
the unmodified isolated baseline.

## Manifest/Pack And Store Contract Synchronization

The 2026-08-08 documentation-only continuation froze and synchronized two
normative boundaries before their RED tests:

- `manifest-pack-wire-v1.md` owns `UEASCV2M`/`UEASCV2P` schema 1, exact 33/65/
  122/32/96-byte structures, semantic-payload pack storage, RecordId versus
  RawChecksum versus whole-final-file PackId/GenerationId streams, canonical
  per-record Zlib, exact manifest reachability, allowed pack historical extras,
  `MaxGenerationPacks=4096`, stages `7..9`, and archive errors `65..71`;
- `store-publication-v1.md` owns the complete default/override root contract,
  full-hash names, 80-byte `UEASCV2C` pointers, same-directory temporary names,
  real platform atomic operations, immutable install validation, namespace
  locking/rebase, cancellation/commit states, handle-pinned read sessions,
  Current→Previous→cold-Pending fallback, physical roots, two-phase compaction,
  and separate store errors `0..21`.

`record-schema.md`, `design.md`, `implementation-plan.md`, `tasks.md`,
`research.md`, `traceability.md`, and the incremental-cache delta specs now
point to those authorities instead of leaving shorter sketches as competing
choices. The Hook clarification is also normative in `record-wire-v1.md`. All
Task 2B-3 and Task Group 3 implementation checkboxes remain unchecked.

The HookKey wording was also corrected without inventing a new error or graph
algorithm. Because HookKey hashes AffectedScopeStableKey, a self/multi-Hook
cycle satisfying every derived key would require a BLAKE3-256 fixed point;
valid producers build an acyclic authority chain from non-Hook scopes. A
manually forged cycle is rejected by the existing `DerivedHashMismatch` before
eligibility. The eligibility query still computes transitive fixed-point set
closure over a validated chain, with mandatory base→dependent, detached/
unrelated, and forged-cycle evidence.

This synchronization changed OpenSpec records only. It did not modify plugin
source, test source, host source, packaged behavior, or task completion state,
and it did not run a C++ build or automation test.

After all synchronization edits, both strict validators returned exit code
`0` and reported `valid`:

```powershell
openspec validate "refactor-as-incremental-function-cache" --strict
openspec validate "refactor-as-static-jit-external-module" --strict
```

The final documentation audit counted `19` incremental-cache change files and
`14` sibling StaticJIT change files including each hidden `.openspec.yaml`,
with zero trailing-whitespace findings and zero missing final newlines. Task
state is unchanged: incremental Cache remains `6` checked / `52` unchecked
(`58` total), StaticJIT remains `0` checked / `31` unchecked, and the combined
task-line count remains `89`.

## Task 2B-1 — Code-Freeze, Golden Evidence, And Independent Review RED

Task 2B-1 has reached a code-freeze/review loop, but it is not complete. The
evidence below deliberately distinguishes an early development snapshot,
temporary golden capture, the later frozen-golden runs, and the independent
review RED suite.

| Stage | Result | Saved evidence |
|---|---|---|
| Code-freeze Editor Development build | Succeeded, process/runner exit `0` | `Saved/Build/as-cache-code-freeze-compile/20260808_062252_470_c35def74/Build.log` and `RunMetadata.json` |
| Code-freeze focused development run | Not GREEN: process exit `3`, runner exit `1`; the run reported pending goldens and ultimately asserted in the SourceEdge fixture, so no complete JSON report was emitted | `Saved/Tests/as-cache-code-freeze-focused/20260808_062327_016_eec9c1c7/RunMetadata.json` and `Automation.log` |
| Temporary golden-emitter build and run | Build succeeded; `EmitPendingGoldensForDevelopment` succeeded `1/1` | `Saved/Build/as-cache-golden-emitter-build/20260808_062912_841_89669d02/Build.log` and `Saved/Tests/as-cache-golden-emitter/20260808_062925_404_0bdd9a47/Report/index.json` |
| Frozen enum/golden build | Succeeded, process/runner exit `0` | `Saved/Build/as-cache-enum-golden-build/20260808_063428_373_157a4e47/Build.log` and `RunMetadata.json` |
| Primitives frozen-golden run | `5/5` succeeded, `0` failed, `0` not run | `Saved/Tests/as-cache-primitives-golden-final/20260808_063439_093_44f51391/Report/index.json` |
| SourceInterface frozen-golden run | `15` total, `14` succeeded, `1` intentional RED | `Saved/Tests/as-cache-source-interface-golden-final/20260808_063510_819_e02041ea/Report/index.json` |
| Review-RED build | Succeeded, process/runner exit `0` | `Saved/Build/as-cache-review-red-build/20260808_064317_562_596623cc/Build.log` and `RunMetadata.json` |
| Review-RED SourceInterface run | `18` total, `14` succeeded, `4` expected failures | `Saved/Tests/as-cache-review-red/20260808_064338_788_393f888a/Report/index.json` |

The temporary emitter was a development-only evidence tool. After its output
was copied into independent named byte/hash assertions, the emitter method was
deleted. Its `1/1` result proves only that the evidence capture ran; it is not
part of the production architecture, public API, or final regression surface.

The Primitives `5/5` report covers the five named methods in the JSON report,
including independent primitive bytes, byte-exact round-trip, malformed and
budget rejection, reference/dependency/qualifier rules, and frozen enums,
flags, and validation classes. The SourceInterface `14/15` report has one
failure only: `SourcePathsCaseAndFingerprintPresenceFailClosed`, which freezes
the non-ASCII simple-fold case-collision obligation. It does not establish
full SourceInterface completion. The separate wire/graph precedence RED was
introduced in the following review suite.

The independent read-only review is recorded in
`.superpowers/sdd/task-2b1-review-report.md`. Its disposition is `0 Critical`,
`7 Important`, and `1 Minor`, with no approval for the reviewed snapshot. The
Important findings cover:

1. lost semantic-error `RecordKind` and enclosing-field `ByteOffset` after
   decode;
2. resident-budget consumption after string allocation plus unbudgeted deep
   copies during SourceSnapshot/declaration/interface hash validation;
3. incorrect SourceIndex local/wire and graph-phase error precedence;
4. ModuleInterface owner validation running before local shape/hash/order/
   duplicate validation;
5. incomplete Mount/File authority duplicate-versus-conflict comparison and
   incorrect exact-generated-duplicate ordering;
6. O(n^2) repeated graph/owner scans instead of typed indexes; and
7. the preserving-order test writer using `WITH_DEV_AUTOMATION_TESTS` instead
   of `WITH_ANGELSCRIPT_UNITTESTS`.

The Minor finding was missing forged self-cycle and detached Hook-chain
regressions. Targeted RED fixtures now cover those cases, but the original
report remains the immutable snapshot of what was reviewed and does not become
an approval retroactively. The allocation-before-check/deep-copy-budget and
O(n^2) findings also require structural review or a dedicated allocation/
lookup instrumentation seam; ordinary behavioral assertions alone cannot
reliably prove those properties.

The current review-RED build is healthy, while the focused suite is
intentionally RED at exactly four methods:

- `DecodedSemanticFailuresRetainRecordKindAndEnclosingFieldOffset`;
- `ModuleOwnerValidationRunsAfterLocalShapeHashOrderAndDuplicates`;
- `SourcePathsCaseAndFingerprintPresenceFailClosed`; and
- `SourceWirePhasePrecedenceAndAuthorityContentAreFrozen`.

Those four failures are active fix obligations, not accepted regressions. A
final Task 2B-1 completion claim requires all seven Important findings fixed,
fresh focused GREEN evidence, auditable evidence for budget/allocation and
lookup complexity, and a fresh independent re-review that explicitly approves
the corrected snapshot. Tasks 2.2 and 2.3 therefore remain unchecked while
the fixes are in progress. This documentation pass did not modify Runtime or
test source and did not run a new UE build or automation test.

## Task 2B-2 — Second Preflight Contract Correction

The record-only preflight was repeated against the implementation brief and
the current Task 2B-1 public surface. It found that the earlier sketch still
allowed three conflicting validation authorities: remaining-record
deserializers could call the opaque codec, callers could construct mutable
decoded DTO+byte aggregates, and later graph phases could repeat codec work.
The corrected normative contract now requires:

- all five remaining-record Deserializers perform wire/local/hash work only;
- an immutable factory-created token recomputes RecordId from canonical bytes,
  dispatches all seven decoders, captures trusted nested field offsets, and is
  also the only accepted SourceIndex graph input;
- graph step 1 discovers the requested snapshot's actual structural closure,
  invokes each reachable ModuleState initializer, FunctionBody, and body-owned
  DebugSidecar opaque validator exactly once, ignores unrelated records, and
  stores owning summaries in the candidate/validated graph;
- the validator and graph API receive the same `const ReadLimits&` and monotonic
  caller budget as the mandatory envelope budget overload/token decoders;
- validation stages are append-only, the old three-argument result constructor
  keeps `ByteOffset` in position three, and new staged failures use a named
  factory with frozen envelope-versus-payload offset bases;
- fixture magic is exactly `UEASOPQ1`, Debug opaque V1 has zero relocations,
  owned bytes use `{ReferenceKind, StableKey}` order, and golden wording means a
  fixed 56-byte envelope header followed by the complete payload;
- null services/wrong SourceIndex/zero selection fail before external work,
  current checks run source→profile→canonical dependency missing→ABI→content,
  and full-key indexes/counters prohibit O(n²) whole-pool rescans.

This correction deliberately does not claim RED readiness. Task 2B-1 needs
fresh independent approval first; only then may a mechanical private canonical
codec extraction run under unchanged old goldens. The exhaustive TypeSchema
and ModuleState matrices identified in `record-wire-v1-remaining.md` must also
be written and independently approved. No unspecified matrix row may be
implemented by inference.

The adjacent 2B-1 Unicode collision text was synchronized because leaving it
as per-TCHAR `FChar::ToLower` would contradict the audited code-point traversal.
The contract now freezes `FTextChar::GetCodepoint` plus one
`FTextChar::ToLower` mapping per Unicode scalar value, no multi-code-point full
fold, unchanged identity bytes, and CompatibilityKey isolation. ASCII, BMP and
supplementary-plane traversal vectors remain required evidence.

The UBT gate is also recorded without overstating evidence. Runtime
`PublicDefinitions` currently has a single-owner structure, but it has not yet
received fresh dynamic verification. The live unit-test/build guides, shared
compile-settings spec and Test Validation diagnostics are maintained outside
this change directory by the root task and were not overwritten here. E1/E0
definitions-header checks remain pending; Shipping compile/package stays in the
final validation phase.

This pass modified only OpenSpec records and the private implementation brief.
It modified no Runtime/test source, ran no UE build or automation test, and did
not check tasks 2.2, 2.3, 2.4, or 2.5.

Final record-only structure validation returned exit code `0`/`valid` for both
`openspec validate "refactor-as-incremental-function-cache" --strict` and
`openspec validate "refactor-as-static-jit-external-module" --strict`.
The audit counted `19` incremental-cache change files and `14` sibling
StaticJIT change files, plus `10` files in this preflight edit set; the edit set
had zero trailing-whitespace findings and zero missing final newlines. Task
state remained Cache `6` checked / `52` unchecked (`58` total) and StaticJIT
`0` checked / `31` unchecked. These are documentation/structure results only,
not C++ GREEN evidence.

## Task 2B-1 — Final Independent Read-Only Rereview (Still NOT APPROVED)

The 2026-08-08 final rereview inspected the corrected Task 2B-1 surface without
changing Runtime or test source. Its disposition is **NOT APPROVED**, with
`0 Critical / 4 Important / 3 Minor`.

Fresh evidence already present in the workspace was verified as follows:

| Evidence | Result | Artifact |
|---|---|---|
| Editor Development build after the focused fixes | Process/runner exit `0` | `Saved/Build/as-cache-review-focused-fix-build/20260808_071557_631_d182990c/RunMetadata.json` |
| SourceInterface focused suite | `18/18 PASS` | `Saved/Tests/as-cache-review-focused-green/20260808_071830_154_50dae7e3/Report/index.json` |
| Primitives focused suite | `5/5 PASS` | `Saved/Tests/as-cache-review-primitives-green/20260808_072015_620_01b97bcc/Report/index.json` |
| Identity focused suite | `10/10 PASS` | `Saved/Tests/as-cache-review-identity-green/20260808_072055_145_c8f59b96/Report/index.json` |
| Fresh `WITH_ANGELSCRIPT_UNITTESTS=0` build | Not supplied by this evidence set | Pending |

These passes close several findings from the earlier `0C/7I/1M` snapshot,
including decoded enclosing offsets, preallocation/hash-copy reductions, local
source order, ModuleInterface owner-phase precedence, fuller authority equality,
indexed hot paths, and the compile-gate test-writer boundary. They do not prove
that the final API and budget contract is approved. Four Important findings
remain:

1. Graph references are not processed in the normative phase order
   Mount -> Hook -> File -> Input -> Edge -> Ineligible, with resolved-authority
   conflicts deferred until every reference resolves.
2. Semantic validation, index construction, and query closure scratch are not
   all charged before allocation to one live-resident RAII reservation on the
   same caller-owned Budget. Persistent consumed counters must remain monotonic,
   temporary reservations must release on every exit, and failed reservation
   must neither consume nor allocate.
3. Serializer semantic failures can still escape without the established record
   kind. Codec entry must establish kind; serializer offsets are `0`, while
   decoder semantic failures retain their captured enclosing-field offsets.
4. Eligibility still accepts a raw DTO and can copy/re-prepare it. Decode must
   locally validate and build indexes, then move-publish a factory-only immutable
   `FAngelscriptValidatedSourceIndex`; query accepts only that token and explicit
   `Limits + Budget`.

The three Minor obligations are a true supplementary-plane source-fold vector,
a direct competing full-256-bit duplicate-group regression proving the smallest
second wire occurrence, and authoritative production CompatibilityKey assembly/
isolation. The existing generic canonical-input primitive is not that assembler;
the first production assembly must carry the versioned Unicode/lowercase policy.
Task 2B-1 does not own it, and this record does not claim it is implemented.

This OpenSpec correction freezes the corresponding RED and supplementary tests
in `record-wire-v1.md`, `implementation-plan.md`, and `tasks.md`; it is planning
evidence only. Tasks 2.2/2.3 remain unchecked, Task 2B-2 remains blocked, and no
Runtime/test source, UE build, or automation execution is part of this pass.

### Final record-only structure checks

The synchronized record passed both required strict validators with exit code
`0`:

```text
openspec validate "refactor-as-incremental-function-cache" --strict
Change 'refactor-as-incremental-function-cache' is valid

openspec validate "refactor-as-static-jit-external-module" --strict
Change 'refactor-as-static-jit-external-module' is valid
```

Parent and plugin `git diff --check`/`git diff --cached --check` returned exit
code `0`. An explicit scan of the seven synchronized OpenSpec files plus
`.superpowers/sdd/task-2b1-final-rereview.md` found zero trailing-whitespace
errors and zero missing final newlines. The cache task state remains `6` checked
and `52` unchecked (`58` total). Existing parent documentation, shared-spec,
plugin Runtime/Test, and sibling OpenSpec changes remain visible in the dirty
workspace and were not modified as part of this final record-only rereview
update.

## Task 2B-1 — Round-Two Finding Closure Candidate (Fresh Review Pending)

The root implementation pass then addressed every item in the preceding
`0C/4I/3M` disposition. This section records implementation and execution
evidence only; it deliberately does not override the independent disposition
above. Tasks 2.2 and 2.3 remain unchecked until a fresh reviewer approves the
result.

The candidate now has these properties:

- SourceIndex graph references execute in exact wire phase order
  Mount -> Hook -> File -> Input -> Edge -> Ineligible. The resolved
  File-to-Mount authority comparison runs only after all six reference phases.
  Hook-vs-File, Input-vs-Ineligible, and Edge-vs-Ineligible combination tests
  assert the earlier phase, established `SourceIndex` kind, and serializer
  offset zero.
- SourceIndex and ModuleInterface semantic decode calculate a conservative
  checked scratch bound, acquire one move-only live-resident RAII reservation
  before semantic indexes/sorts/queues allocate, and release it on success and
  failure. Eligibility uses the same caller `Limits + Budget`; retained query
  output is charged while scratch is active, so persistent resident plus active
  scratch cannot exceed the resident limit. Failed reservation leaves the
  counter unchanged, temporary release does not refund persistent counters,
  and peak temporary usage remains observable for regression tests.
- SourceIndex and ModuleInterface codec entry establishes `RecordKind`.
  Serializer semantic failures return that kind with offset zero; decoder
  semantic failures return the captured enclosing-field offset.
- Eligibility no longer accepts `FAngelscriptCachedSourceIndex`. Only the
  move-only, factory-populated `FAngelscriptValidatedSourceIndex` token plus an
  explicit `Limits + Budget` is accepted. The query reads the token through a
  const view and neither copies nor re-prepares the whole SourceIndex.
- The source path collision regression now includes the real supplementary
  Deseret pair U+10400/U+10428 while preserving raw identity bytes.
- A dedicated regression constructs two independent full-BLAKE3-256 provider
  authority groups whose sorted-key order disagrees with wire order. Swapping
  only the content equality of the two second occurrences proves that the
  smallest second wire occurrence selects `ConflictingKey` versus
  `DuplicateKey`.
- Production CompatibilityKey assembly remains explicitly deferred to the
  first production assembler; neither this implementation nor its evidence
  claims that the generic Task 1 primitive is that assembler.

### Fresh build matrix

| Configuration | Result | Artifact |
|---|---|---|
| Editor Development, tests disabled | `105` actions, process/runner exit `0` | `Saved/Build/as-cache-review-unit-tests-disabled/20260808_074514_442_3d21dce5/RunMetadata.json` |
| Editor Development, tests restored | `105` actions, process/runner exit `0` | `Saved/Build/as-cache-review-unit-tests-restored/20260808_074705_028_4cb7f321/RunMetadata.json` |

In the disabled build, both generated definitions headers contained
`ANGELSCRIPT_RUNTIME_UNITTEST_POLICY_OWNER=1` and
`WITH_ANGELSCRIPT_UNITTESTS=0`. After restoring
`Config/DefaultAngelscriptCompileOptions.ini` to `true` and rebuilding, both
headers contained the same owner sentinel and
`WITH_ANGELSCRIPT_UNITTESTS=1`. This is dynamic evidence that Runtime Build.cs
is the single policy owner and that Test consumes the public definition in both
states.

### Fresh focused GREEN evidence

| Prefix | Result | Artifact |
|---|---|---|
| `Angelscript.TestModule.Cache.Archive.SourceInterface` | `20/20 PASS`, including exact/one-byte-short resident limits, success/late-failure/early-failure RAII release, and side-effect-free failed reuse/acquisition | `Saved/Tests/as-cache-review-round2-reservation-side-effect-green/20260808_075606_148_368955a3/Report/index.json` |
| `Angelscript.TestModule.Cache.Archive.Primitives` | `5/5 PASS` | `Saved/Tests/as-cache-review-round2-primitives-green/20260808_074942_891_c1014556/Report/index.json` |
| `Angelscript.TestModule.Cache.Identity` | `10/10 PASS` | `Saved/Tests/as-cache-review-round2-identity-green/20260808_075012_453_680c0645/Report/index.json` |

The final focused Runtime/test edit built successfully at
`Saved/Build/as-cache-review-round2-reservation-side-effect-build/20260808_075536_815_0c866f41`.
The enabled builds emitted the existing expected compiler warnings only and no
new errors. The candidate has been handed to a fresh independent, read-only
review. Until that review explicitly returns APPROVED, this evidence is not a
gate decision and Task 2B-2 remains blocked.

## Task 2B-1 — Nested Semantic Offset and Final Gate Closure Candidate

The follow-up read-only review returned `0 Critical / 1 Important / 3 Minor`.
The root implementation pass addressed all four findings without changing the
published wire shape:

- `FReader` now maintains a top-level semantic enclosing-field offset. Physical
  parse failures still use the first failing byte (including explicit primitive
  enum and optional-tag byte offsets), while complete-read semantic failures in
  `StableReference`, `SemanticDependency`, `DataType`, and `Parameter` use the
  captured `Declarations`, `Imports`, or `Dependencies` field start.
- A RED regression serialized one valid ModuleInterface and mutated nested
  semantic values. Before the reader fix the focused suite returned
  `20/21 PASS`; the first assertion reported actual offset `102` instead of the
  expected `Declarations` field offset `299`.
- The regression now covers nested declaration type flags, parameter flags,
  import `ExpectedAbi`, and dependency content hash, asserting error, record
  kind, exact enclosing offset, and complete output reset. A separate malformed
  data-type optional tag asserts the exact physical tag-byte offset.
- Graph-order combination coverage now freezes the previously missing adjacent
  boundaries Mount-before-Hook, File-before-Input, and Input-before-Edge.
- One caller-owned Budget now spans validated SourceIndex decode and eligibility
  query without `Reset()`. Exact and one-byte-short limits jointly count retained
  token bytes, active query scratch, and retained query output.
- ModuleInterface serializer rejection now directly asserts
  `RecordKind=ModuleInterface` and `ByteOffset=0`.

### RED and final focused GREEN evidence

| Evidence | Result | Artifact |
|---|---|---|
| Nested semantic offset RED build | process/runner exit `0` | `Saved/Build/as-cache-review-nested-offset-red-build2/20260808_081056_294_4b01e4f9/RunMetadata.json` |
| Nested semantic offset RED suite | `20/21 PASS`, expected offset failure | `Saved/Tests/as-cache-review-nested-offset-red/20260808_081121_106_d2cc9426/Report/index.json` |
| Final enabled incremental build | process/runner exit `0` | `Saved/Build/as-cache-review-nested-offset-green-build/20260808_081325_294_2c0857b8/RunMetadata.json` |
| SourceInterface final focused suite | `21/21 PASS` | `Saved/Tests/as-cache-review-nested-offset-green/20260808_081344_586_d8300acd/Report/index.json` |
| Primitives + Identity supporting suite | `15/15 PASS` | `Saved/Tests/as-cache-review-supporting-green/20260808_081440_634_1815d1c3/Report/index.json` |

### Final compile-gate matrix after source freeze

| Configuration | Result | Artifact |
|---|---|---|
| Editor Development, tests disabled | `105` actions, process/runner exit `0` | `Saved/Build/as-cache-review-unit-tests-disabled-final/20260808_081542_067_330467c6/RunMetadata.json` |
| Editor Development, tests restored | `105` actions, process/runner exit `0` | `Saved/Build/as-cache-review-unit-tests-enabled-final/20260808_081834_222_40a1c6a6/RunMetadata.json` |

The disabled build generated `WITH_ANGELSCRIPT_UNITTESTS=0` for both
AngelscriptRuntime and AngelscriptTest. After restoring
`bCompileAngelscriptUnitTests=true`, the enabled build generated value `1` for
both modules. A source scan found exactly one definition owner, Runtime
Build.cs. The configuration has no semantic diff from the checked-in enabled
state; the visible Git modification is line-ending-only.

This section is implementation and execution evidence, not an approval. Tasks
2.2 and 2.3 remain unchecked until a fresh independent reviewer reads the final
snapshot and explicitly returns APPROVED.

## Task 2B-1 — Public Token Surface and Exhaustive Matrix Closure Candidate

The next independent final review returned **NOT APPROVED** with
`0 Critical / 3 Important / 1 Minor`. It confirmed all preceding nested-offset,
phase-order, reservation, serializer-context, Unicode, duplicate-group, and
same-Budget findings closed, but identified these remaining obligations:

1. the production public SourceIndex decoder still published a mutable raw DTO;
2. Provider/Hook capability pairing tests did not freeze wrong scope/key/reason
   and unrelated-valid cases for every capability/authority pair;
3. the typed-reference test did not freeze valid/wrong/missing routing for
   every row in the normative matrix; and
4. ReadBudget copy/move plus check-only active-reservation Reset/underflow guards
   were unsafe in Shipping misuse paths.

The closure candidate addresses those findings as follows:

- Production `DeserializeSourceIndex` now accepts only
  `FAngelscriptValidatedSourceIndex&`. The raw DTO decoder is private to the
  implementation and is exposed only as the explicitly named
  `DeserializeSourceIndexForTests` surface under `WITH_ANGELSCRIPT_UNITTESTS`.
- Compile-time assertions freeze the public decoder signature, reject raw DTO
  decoder/query invocability, reject caller construction/copy of a validated
  token, and reject copy/move of ReadBudget.
- A unit-test-only whole-record copy counter instruments the raw SourceIndex copy
  constructor/assignment. Validated decode and eligibility query both assert
  zero whole-SourceIndex copies; publication remains move-only.
- ReadBudget is non-copyable and non-movable. `Reset()` returns `false` without
  changing any counter while a temporary reservation is active and returns
  `true` after release. The release path retains a real pre-subtraction branch,
  so Shipping does not depend on a compiled-out check to prevent underflow.
- The capability table now runs wrong-scope, wrong-key, unrelated-wrong-reason,
  and unrelated-valid cases for all four capability mappings across both
  Provider and Hook, in addition to the existing missing/exact/forbidden cases.
- The typed-reference table contains all 26 normative authority/tag routes.
  Every row runs valid, wrong-authority, and missing-authority cases with
  SourceIndex kind/offset/output-reset assertions. Separate rows freeze both
  File-versus-Mount resolved conflicts and File/Input/Edge internal reference
  precedence.

The first matrix run exposed a fixture error rather than a Runtime routing
defect: the File.Provider wrong-kind case selected the old SourceFile key and
then changed the File identity, so that key correctly became missing. Selecting
the independent live Hook authority made the fixture express the intended
wrong-kind case. The corrected full matrix passed without changing production
graph routing.

### RED, focused GREEN, and final build matrix

| Evidence | Result | Artifact |
|---|---|---|
| Public API/Budget compile RED | expected static assertions and active-Reset/copy-probe API failures | `Saved/Build/as-cache-public-api-budget-red/20260808_083552_762_45eaf61c/RunMetadata.json` |
| API/matrix enabled build | process/runner exit `0` | `Saved/Build/as-cache-api-matrix-green-build2/20260808_084341_739_015a6d2e/RunMetadata.json` |
| First table run | `21/22 PASS`, fixture classified missing instead of wrong | `Saved/Tests/as-cache-api-matrix-first-green/20260808_084237_585_3188faf5/Report/index.json` |
| Corrected SourceInterface table | `22/22 PASS` | `Saved/Tests/as-cache-api-matrix-green2/20260808_084358_802_49560db4/Report/index.json` |
| Supporting Primitives + Identity | `15/15 PASS` | `Saved/Tests/as-cache-api-matrix-supporting-green/20260808_084446_768_1dfce866/Report/index.json` |
| Final tests-disabled build | `105` actions, process/runner exit `0` | `Saved/Build/as-cache-api-matrix-disabled-final/20260808_084524_690_fc7a5f98/RunMetadata.json` |
| Final tests-enabled build | `105` actions, process/runner exit `0` | `Saved/Build/as-cache-api-matrix-enabled-final/20260808_084707_613_8b11929a/RunMetadata.json` |
| Post-restore combined focused suite | `37/37 PASS` (`22` SourceInterface, `5` Primitives, `10` Identity) | `Saved/Tests/as-cache-api-matrix-final-green/20260808_084839_259_578648b3/Report/index.json` |

The disabled build generated `WITH_ANGELSCRIPT_UNITTESTS=0` for Runtime and
Test; the restored build generated `1` for both. The compile option is restored
to `bCompileAngelscriptUnitTests=true` with no semantic diff from the checked-in
configuration. This section remains a closure candidate only. Tasks 2.2 and
2.3 stay unchecked until a new independent read-only approval explicitly
accepts this frozen snapshot.

## Task 2B-1 — Independent Final Approval

The fresh independent read-only review of the frozen Task 2B-1 snapshot returned
**APPROVED — 0 Critical / 0 Important / 0 Minor**.

The reviewer explicitly confirmed:

- production decode publishes only a factory-created, move-only validated token;
  the raw DTO decoder is available only to unit-test builds;
- compile-time API traits and the unit-test copy probe freeze the token-only
  production surface and zero whole-SourceIndex copies during decode/query;
- every Provider/Hook capability pair covers missing, exact, forbidden,
  wrong-scope, wrong-key, wrong-reason, and unrelated-valid cases;
- all 26 normative typed-reference authority routes cover valid, wrong, and
  missing targets, including resolved-authority conflicts and internal
  precedence;
- `FAngelscriptCacheReadBudget` is non-copyable/non-movable, active-reservation
  reset is side-effect-free, and the release underflow guard remains effective
  in Shipping; and
- the enabled/disabled compile matrix and final `37/37` focused suite provide
  sufficient dynamic evidence for this milestone.

Tasks 2.2 and 2.3 are therefore approved and complete. Later record families
remain gated by their own normative matrices, RED evidence, implementation,
and independent review.

## Task 2B-2 — TypeSchema and ModuleState Matrix Promotion

The two exhaustive research drafts were read against the complete relevant
sections of `record-wire-v1-remaining.md` and promoted into the OpenSpec change
as co-normative authorities:

- `type-schema-matrix-v1.md` freezes the complete TypeKind/payload/flag,
  reflection, relation, property/layout, method-slot, 17-kind behavior,
  dependency, and precedence predicates; and
- `module-state-matrix-v1.md` freezes the complete global/init-kind,
  CanonicalValue width/bit, cleanup, HardValue authority/comparator,
  initializer/module-initializer/post-init, hash, opaque-summary, budget, and
  precedence predicates.

The compact remaining-wire summary was reconciled with those matrices:
Delegate is a generated value type, behavior values `15..17` are append-only,
PropertySchema carries exact `SemanticByteOffset`, MethodSlot uses one global
ordinal domain, BehaviorSlot uses a typed StableReference plus optional script
owner, and the reflection allowlist is closed. ModuleState preserves module-
atomic global schema/initialization/cleanup while FunctionBody remains an
independent invalidation record.

This is specification evidence only. Task 2B-2 RED and tasks 2.4/2.5 remain
unchecked until a fresh independent read-only review explicitly approves both
promoted matrices and their reconciliation with the remaining-wire authority.

## Task 2B-2 Slice 0 — Private Canonical Codec Extraction

After the Task 2B-1 approval gate closed, the existing pointer-free canonical
writer/reader, strict UTF-8 decoder, budget-aware cursor, `BeginRead`, and enum
reader were mechanically moved from `AngelscriptCacheSemanticRecords.cpp` into
the Runtime-private `Cache/Private/AngelscriptCacheCanonicalCodec.h`. The
semantic-record translation unit imports only those private names. No public
header/API, field order, enum, hash stream, result mapping, or budget behavior
changed.

The first wrapper invocation outlived the tool's short initial yield but
completed normally and wrote final metadata; a second wrapper invocation then
correctly reported the target up to date.

| Evidence | Result | Artifact |
|---|---|---|
| Editor Development build after extraction | compiled `Module.AngelscriptRuntime.27.cpp`; process/runner exit `0` | `Saved/Build/as-cache-private-codec-extraction-green/20260808_090423_960_912d44ea/RunMetadata.json` |
| Follow-up build | target up to date; process/runner exit `0` | `Saved/Build/as-cache-private-codec-extraction-green2/20260808_090439_879_1b978e21/RunMetadata.json` |
| Full Cache automation prefix | `50/50 PASS`, failed/skipped `0` | `Saved/Tests/as-cache-private-codec-extraction-green/20260808_090515_152_271caed9/Report/index.json` |

This closes only the mechanical extraction portion of task 2.4. The task stays
unchecked because the independently approved matrix RED, five remaining record
families, opaque fixture seam, and per-module graph validation are not yet
implemented.

## Task 2B-2 Matrix Review — NOT APPROVED and Common Contract Reopened

The first independent reviews of both promoted matrices returned
**NOT APPROVED**. No RED was started and the reviewers made no file changes.

TypeSchema review: `1 Critical / 5 Important / 1 Minor`.

- The common Function declaration cannot distinguish an ordinary AS function
  from a required UFunction whose reflection flag mask is zero, including
  `UFUNCTION(NotBlueprintCallable)` and reflected module globals owned by the
  StaticsClass.
- Generated Delegate members are real, but their legal owners contradict the
  previously frozen ModuleInterface owner matrix.
- The layout rule incorrectly omitted terminal tail alignment and left initial
  object alignment non-executable.
- `PersistentInstance => InstancedReference` contradicted current producer and
  ClassGenerator semantics.
- canonical-set interface relations lost the product's observable direct-
  interface order.
- one MethodSlot sequence conflated `asCObjectType::methods` order with the
  distinct VFT order.
- the matrix named nonexistent `ArithmeticOverflow` instead of `Overflow`.

ModuleState review: `1 Critical / 8 Important / 0 Minor`.

- The restore algorithm ran every Default construction before every VM
  initializer, while the compiler/runtime use one dependency-solved sequence
  that interleaves them. This can change startup behavior and rollback order.
- CanonicalValue bytes incorrectly claimed a `u32` rather than inherited `u64`
  byte count.
- cleanup classification confused reference/value semantics, explicit handle
  syntax, Delegate ownership, and an environment ABI hash that exposes no
  storage category.
- top-level and initializer dependency completeness was not bidirectional or
  executable.
- post-init did not require executable body coverage and initializer callable
  traits were incomplete.
- physical decode/trailing/local/hash/RecordId precedence was contradictory.
- multiple initializer codec call order and fail-fast behavior were undefined.
- extra owned canonical byte rows were not rejected.
- live-resident scratch budget matrices were incomplete.

Because the TypeSchema findings require additive changes to the common
ModuleInterface declaration contract, the earlier approval remains valid
historical evidence for its old frozen snapshot but no longer completes the
expanded contract. Tasks 2.2 and 2.3 are deliberately reopened. They require
new RED/GREEN/build evidence and a fresh independent approval before the
remaining matrix gate can close.

## Task 2B-2 Matrix Reconciliation After NOT APPROVED Reviews

The corrective architecture is now explicit across the co-normative matrices
and shared OpenSpec authorities:

- TypeSchema stores ordered direct implemented interfaces and derives their
  base-first closure, rather than canonical-key-sorting an observable list.
- `asCObjectType::methods` and the VFT are two independent sequences with
  independent ordinals and reconstruction rules.
- `ReflectionSchema.OrderedUFunctionMembers` is the sole reflected-function
  membership/order authority for ordinary UClass methods and StaticsClass
  module globals. A target may have zero ReflectionFlags, so
  `UFUNCTION(NotBlueprintCallable)` does not require a new common declaration
  bit or an inference from a nonzero mask.
- object-like layout uses the schema constant initial alignment `8`, exact
  property offsets, and mandatory checked terminal `AlignUp`; the false
  `PersistentInstance => InstancedReference` implication was removed.
- ModuleState now separates a canonical InitializerUnit payload set from one
  dependency-solved `OrderedInitializationActions` sequence that interleaves
  `DefaultConstructGlobal` and `ExecuteInitializer`. Cleanup is a transient
  reverse action-attempt stack, not a persisted initialized bit.
- ScriptType cleanup is resolved by TypeKind; EnvironmentType cleanup requires
  the current resolver's explicit ValueStorageKind coordinate. Initializer
  codec calls use Execute-action order, exactly once and fail-fast, while owned
  name/string rows are an exact set.
- the common ModuleInterface owner contract documents the narrow
  Generated-trait-gated Delegate member exception; its code/tests remain the
  last open common-contract implementation item before reapproval.

The amendments were synchronized through `record-wire-v1.md`,
`record-schema.md`, `record-wire-v1-remaining.md`, the delta specification,
`design.md`, `implementation-plan.md`, and `tasks.md`. Strict validation and
whitespace validation both pass:

```text
openspec validate refactor-as-incremental-function-cache --strict
Change 'refactor-as-incremental-function-cache' is valid

git diff --check -- openspec/changes/refactor-as-incremental-function-cache
exit 0
```

The reconciled matrices still do not authorize Task 2B-2 RED. They require the
Task 2B-1 Delegate validator/test/build closure, a fresh Task 2B-1 independent
approval, and then an independent rereview of both matrices.

## Task 2B-1 Nested Semantic Diagnostic Regression Coverage

The current private canonical reader already contained the intended
enclosing-field diagnostic implementation: payload readers capture each
top-level semantic field, completed nested semantic validation routes through
`FailSemantic`, and byte-level parse failures retain the actual failed byte.
The preexisting regression matrix already covered nested DeclaredType,
Parameter, physical tag, Import zero-ABI, and Dependency zero-content cases.
Therefore no implementation was reverted merely to manufacture a RED.

Two missing direct Dependency mutations were added as honest regression
coverage: HardValue with absent content reports `InvalidPresence`, and a target
with zero ExpectedAbi reports `MissingExpectedAbi`. Both assert ModuleInterface
RecordKind, the captured Dependencies field offset, and cleared output. They
passed on their first run. Existing tests also directly cover the three missing
graph-priority boundaries, same-Budget token-decode/query live-resident union,
and ModuleInterface serializer kind/offset-zero behavior.

| Evidence | Result | Artifact |
|---|---|---|
| Fresh enabled Editor Development build | process/runner exit `0` | `Saved/Build/as-cache-nested-diagnostics-coverage-build/20260808_093334_121_a6ba1589/RunMetadata.json` |
| SourceInterface | `22/22 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-nested-diagnostics-coverage-source/20260808_093355_040_dff685b6/Report/index.json` |
| Primitives | `5/5 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-nested-diagnostics-coverage-primitives/20260808_093431_164_ebfd4396/Report/index.json` |
| Identity | `10/10 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-nested-diagnostics-coverage-identity/20260808_093503_855_a2155c83/Report/index.json` |

The tests-disabled compile remains intentionally deferred until the Generated
Delegate owner amendment freezes the final Task 2B-1 code snapshot.

## Task 2B-1 Generated Delegate Owner Amendment — RED/GREEN

The common owner contract now matches generated Delegate reality without
weakening ordinary owner rules or changing any wire byte, enum value, stable
key, ABI/hash stream, or existing golden:

- Property, Method, Constructor, and Destructor accept a Delegate owner only
  when both owner and member declarations carry `Generated`.
- GeneratedDefaultConstructor and InitDefaults accept a Delegate owner only
  when the member carries `Generated`; the owner trait is independently
  irrelevant at this common layer and TypeSchema later enforces the complete
  generated Delegate form.
- Factory remains Class/Struct-only for the Delegate value type.
- DelegateSignature remains its existing Delegate/Funcdef-only row.

The new `GeneratedDelegateMembersRequireExactGeneratedTraits` test produced a
real RED on the old phase-6 owner validator. The build succeeded, then the
SourceInterface prefix ran `23` tests with the new method as the sole failure at
its first positive generated-Property row. The production fix is limited to the
phase-6 resolved Type-owner predicate. A follow-up negative row for
owner-generated/member-not-generated GeneratedDefaultConstructor and
InitDefaults passed on first execution and is recorded as regression coverage,
not a manufactured RED.

| Evidence | Result | Artifact |
|---|---|---|
| RED build | process/runner exit `0` | `Saved/Build/as-cache-generated-delegate-owner-red-build/20260808_094018_900_2eb6477c/RunMetadata.json` |
| RED SourceInterface | `22 PASS / 1 FAIL / 0 not-run`; sole failure `GeneratedDelegateMembersRequireExactGeneratedTraits` | `Saved/Tests/as-cache-generated-delegate-owner-red/20260808_094038_047_4495a6cb/Report/index.json` |
| GREEN build | process/runner exit `0` | `Saved/Build/as-cache-generated-delegate-owner-green-build/20260808_094153_375_662be70f/RunMetadata.json` |
| GREEN SourceInterface | `23/23 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-generated-delegate-owner-green/20260808_094205_102_919c5efe/Report/index.json` |
| Supporting Primitives | `5/5 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-generated-delegate-owner-primitives/20260808_094244_585_57959e59/Report/index.json` |
| Supporting Identity | `10/10 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-generated-delegate-owner-identity/20260808_094317_497_ad1d31f6/Report/index.json` |
| Added negative Cartesian coverage build | process/runner exit `0` | `Saved/Build/as-cache-generated-delegate-member-coverage-build/20260808_094534_047_c3973256/RunMetadata.json` |
| Added negative Cartesian coverage SourceInterface | `23/23 PASS`, failed/not-run `0` | `Saved/Tests/as-cache-generated-delegate-member-coverage-source/20260808_094550_605_7020266c/Report/index.json` |

The Task 2B-1 code snapshot is now frozen for the final tests-disabled/enabled
compile matrix and independent read-only reapproval. Tasks 2.2 and 2.3 remain
unchecked until both complete.

### Final frozen compile matrix

The frozen common-record snapshot compiled in both feature configurations. Each
configuration change invalidated the generated makefile and executed `105`
actions, so neither result is an up-to-date no-op:

| Configuration | Result | Artifact |
|---|---|---|
| `WITH_ANGELSCRIPT_UNITTESTS=0` | `105` actions; process/final exit `0` | `Saved/Build/as-cache-task-2b1-freeze-disabled/20260808_094656_965_dd47eaf6/RunMetadata.json` |
| restored `WITH_ANGELSCRIPT_UNITTESTS=1` | `105` actions; process/final exit `0` | `Saved/Build/as-cache-task-2b1-freeze-enabled-restore/20260808_094838_393_f98107ba/RunMetadata.json` |

`Config/DefaultAngelscriptCompileOptions.ini` is restored to
`bCompileAngelscriptUnitTests=true`; the temporary false value has no semantic
diff. Git still reports the file's pre-existing line-ending/stat-only dirty
state, but HEAD/index blobs and normal/raw/numstat diffs are equal/empty. Parent
and plugin `git diff --check` both return exit `0` (with existing LF-to-CRLF
warnings only). No commit, archive, or push was performed.

## Task 2B-1 Eligibility Query Capacity — Independent Finding and RED/GREEN

The next independent Task 2B-1 review returned `0 Critical / 1 Important / 1
Minor`. The Important finding was real: the eligibility query registered three
hash arrays by logical element count, but populated three unreserved `TArray`s.
With 256 files for one ModuleKey, UE allocator slack grew each array from zero
to capacity 286. The three arrays allocated 27,456 bytes while the registered
upper bound was only 24,832 bytes. The Minor finding was a missing explicit
owner-false/member-false row in the Generated Delegate Cartesian.

The RED adds a cpp-private `WITH_ANGELSCRIPT_UNITTESTS` probe over the real query
arrays, a 256-file same-module fixture, and exact/one-byte-short checks over one
Budget containing decoded-token resident bytes, query scratch, and retained
output. The old implementation built successfully and then produced exactly
one failure in the new SourceInterface method; all previous 23 methods stayed
green. The production fix reserves all three arrays to `Canonical.Files.Num()`
only after the global scratch reservation succeeds and before any `Add`. The
test probe is absent from public headers and from tests-disabled compilation.
The Delegate loop now explicitly covers owner=false/member=false for Property,
Method, Constructor, and Destructor.

| Evidence | Result | Artifact |
|---|---|---|
| RED build | process/final exit `0`; 7 actions | `Saved/Build/as-cache-task-2b1-query-capacity-red-build/20260808_101054_253_2d705b1b/RunMetadata.json` |
| RED SourceInterface | `23 PASS / 1 FAIL`; only the new capacity method failed | `Saved/Tests/as-cache-task-2b1-query-capacity-red/20260808_101114_761_e5d04fcb/Report/index.json` |
| GREEN build | process/final exit `0`; 4 actions | `Saved/Build/as-cache-task-2b1-query-capacity-green-build/20260808_101208_306_fc8c4a0e/RunMetadata.json` |
| GREEN SourceInterface | `24/24 PASS` | `Saved/Tests/as-cache-task-2b1-query-capacity-green-source/20260808_101221_699_bd80e672/Report/index.json` |
| Supporting Primitives | `5/5 PASS` | `Saved/Tests/as-cache-task-2b1-query-capacity-green-primitives/20260808_101323_778_bd23daec/Report/index.json` |
| Supporting Identity | `10/10 PASS` | `Saved/Tests/as-cache-task-2b1-query-capacity-green-identity/20260808_101355_528_8bf6c2ad/Report/index.json` |

After root review of the production/test boundary, the final code snapshot was
rebuilt from both feature configurations. Each toggle invalidated the makefile
and executed all 105 actions:

| Configuration | Result | Artifact |
|---|---|---|
| `WITH_ANGELSCRIPT_UNITTESTS=0` | `105` actions; process/final exit `0` | `Saved/Build/as-cache-task-2b1-capacity-freeze-disabled/20260808_102100_365_d5c09b47/RunMetadata.json` |
| restored `WITH_ANGELSCRIPT_UNITTESTS=1` | `105` actions; process/final exit `0` | `Saved/Build/as-cache-task-2b1-capacity-freeze-enabled-restore/20260808_102305_534_01451f0d/RunMetadata.json` |

The checked-in worktree setting is restored to
`bCompileAngelscriptUnitTests=true`. Task 2B-1 still awaits one final independent
read-only approval before tasks 2.2 and 2.3 are checked.

## ModuleState Authority — Shared Ownership and Budget Closure

The second independent ModuleState review reduced the remaining issue to one
missing allocation family for the output graph's owning record handles,
published views, and retained indexes. The revised authority now freezes one
thread-safe shared const remaining-record handle; token/control/DTO bytes are
charged once at decode, and handle copy allocates nothing. OutGraph retains
reachable handles only and publishes compact ordinal-based RecordId, type,
global, function, initializer, and opaque-owner tables. Validation maps remain
temporary.

`MS-SCR-21` exhaustively covers those output containers. Candidate table and
opaque-summary capacity consumes monotonic total-decoded budget plus active
live-resident scratch before allocation. Step 11 atomically promotes the same
resident bytes to retained accounting without a second allocation or charge;
all pre-publication failures release candidate scratch and publish nothing.
The final focused rereview caught and corrected one stale MS-SCR-18 lifetime
label for nested opaque-summary arrays. A final independent rereview then
returned `APPROVED — 0 Critical / 0 Important / 0 Minor` for the ModuleState
authority. This approval does not independently approve TypeSchema or authorize
Task 2B-2 RED before the other recorded gates pass.

Mechanical checks after the synchronized authority update:

```text
openspec validate refactor-as-incremental-function-cache --strict
Change 'refactor-as-incremental-function-cache' is valid

git diff --check -- openspec/changes/refactor-as-incremental-function-cache
exit 0

git -C Plugins/Angelscript diff --check
exit 0 (existing LF-to-CRLF warnings only)
```

## Task 2B-1 Allocator-authoritative Scratch Closure

The subsequent final Task 2B-1 rereview returned `NOT APPROVED — 0 Critical / 1
Important / 0 Minor`. Explicit `Reserve` had removed Add-growth slack, but the
scratch helper still charged logical element bytes plus a fixed 256-byte
allowance rather than every container allocator's reserve capacity. That cannot
prove the frozen contract across allocators, and the remaining hook arrays also
needed direct coverage.

Several exploratory runs are intentionally **not** treated as target RED
evidence. The first `quantized-capacity-red` report was `24/24 PASS`; the current
machine allocator did not quantize the searched Hash/IndexedHash/uint8/int32
reserve capacities above their requested counts. A later dynamic fixture
reported `23/24`, but failed while decoding the expanded SourceIndex before the
target query assertion. Those artifacts remain diagnostic history only and do
not establish TDD failure.

The genuine RED observes the real four hook-query arrays. With one hook, the old
path produced capacities `HookKeyIndex/Reverse/Reached/Queue = 1/1/4/1`, while
the corresponding reserve authority requested `1/1/1/1`. `ReachedHooks` used
`SetNumZeroed(1)` without an explicit reserve, so it took grow slack. Actual
auxiliary allocation was 80 bytes while the registered allocator-authoritative
requirement was 77 bytes. SourceInterface produced `23 PASS / 1 FAIL`, with the
capacity method as the only failure.

Production now uses one checked `TryAddArrayReserveScratchBytes<ElementType>`
helper. Before any allocation it calls the exact `TArray` element allocator's
`CalculateSlackReserve`, including the element-alignment overload when required,
then checked-adds capacity bytes for all seven query arrays: three stable-hash
arrays, two indexed-hash arrays, the reached byte array, and the int32 queue.
Every real array follows matching explicit `Reserve` semantics;
`ReachedHooks.Reserve` now precedes `SetNumZeroed`. Capacity smaller than the
request fails closed as Overflow. The test probe compares real Max and
GetAllocatedSize against the same allocator authority and retains the exact,
one-byte-short, shared-Budget, pre-allocation-failure and RAII-release assertions.

| Evidence | Result | Artifact |
|---|---|---|
| Genuine allocator RED build | process/final exit `0` | `Saved/Build/as-cache-task-2b1-real-allocator-red-build/20260808_104050_999_06c30781/RunMetadata.json` |
| Genuine allocator RED SourceInterface | `23 PASS / 1 FAIL`; actual 80, authority 77 | `Saved/Tests/as-cache-task-2b1-real-allocator-red/20260808_104110_480_3b3b45d2/Report/index.json` |
| Allocator-authority GREEN build | process/final exit `0` | `Saved/Build/as-cache-task-2b1-allocator-authority-green-build/20260808_104356_067_46531f6f/RunMetadata.json` |
| Allocator-authority GREEN SourceInterface | `24/24 PASS` | `Saved/Tests/as-cache-task-2b1-allocator-authority-green-source/20260808_104409_306_572ac28c/Report/index.json` |
| Supporting Primitives | `5/5 PASS` | `Saved/Tests/as-cache-task-2b1-allocator-authority-green-primitives/20260808_104445_656_e8a95e4a/Report/index.json` |
| Supporting Identity | `10/10 PASS` | `Saved/Tests/as-cache-task-2b1-allocator-authority-green-identity/20260808_104516_242_cb7da501/Report/index.json` |

The production helper changed after the earlier compile matrix, so both feature
configurations were rebuilt again. Each toggle invalidated the makefile and ran
all 105 actions:

| Final configuration | Result | Artifact |
|---|---|---|
| `WITH_ANGELSCRIPT_UNITTESTS=0` | `105` actions; process/final exit `0` | `Saved/Build/as-cache-task-2b1-allocator-freeze-disabled/20260808_104634_961_8f586575/RunMetadata.json` |
| restored `WITH_ANGELSCRIPT_UNITTESTS=1` | `105` actions; process/final exit `0` | `Saved/Build/as-cache-task-2b1-allocator-freeze-enabled-restore/20260808_104819_932_fa6417e8/RunMetadata.json` |

The worktree is restored to `bCompileAngelscriptUnitTests=true`. The Cache files
are still untracked as a directory, so normal plugin `git diff --check` does not
enumerate them; explicit trailing-whitespace scans of both changed files pass.
At this pre-approval checkpoint, tasks 2.2/2.3 remained unchecked until an
independent reviewer approved the exact final code snapshot and evidence set.

### Final Task 2B-1 independent approval

The independent final rereview examined the allocator helper, every one of the
seven query arrays, allocation-before-budget ordering, genuine versus invalid
candidate RED evidence, focused GREEN suites, final disabled/enabled definitions
and complete common-contract regressions. It returned:

```text
APPROVED — 0 Critical / 0 Important / 0 Minor
```

The approval is limited to Task 2B-1 common primitives, SourceIndex,
ModuleInterface, the immutable validated SourceIndex token, and eligibility
query. It does not approve TypeSchema, Task 2B-2/2B-3, or the deferred production
CompatibilityKey assembler. Tasks 2.2 and 2.3 are now checked. The TypeSchema
matrix remains the only authority approval gate before Task 2B-2 RED because
the ModuleState matrix is already independently approved.

## Task 2B-2 TypeSchema Layout-Authority Review — NOT APPROVED

The next independent read-only TypeSchema review examined the final Task 2B-1
snapshot, the already-approved ModuleState matrix, the promoted TypeSchema
matrix, remaining wire, graph API and precedence. It changed no file and
returned:

```text
NOT APPROVED — 1 Critical / 2 Important / 0 Minor
```

The Critical finding was an unimplementable immutable-layout requirement. The
stored TypeSchema required exact replay of property offsets, Base/code-root/
UStruct boundaries, aggregate alignment and terminal size before calling any
current resolver, but neither the wire nor graph context supplied the numeric
property size/alignment and header/base inputs. ExpectedAbi and other hashes
cannot be inverted, legal external TypeSchemas are not automatically children
of the selected ModuleSnapshot, and moving live resolution earlier would
incorrectly turn `GraphAbiMismatch` into a normal current miss.

The two Important findings were:

1. no exhaustive TypeSchema allocation-family matrix equivalent to the approved
   `MS-SCR-*` inventory, despite the real Task 2B-1 `TArray` slack-capacity RED;
2. TypeSchema local order placed derived hashes before trailing-data exhaustion,
   contradicting the shared physical-decode precedence and approved decoders.

No Task 2B-2 RED, serializer, graph implementation, UE build, or automation run
was started in response to this result. Tasks 2.4 and 2.5 remain open.

### Maintained producer evidence and correction candidate

A separate read-only source audit verified the numeric producer rather than
copying legacy-cache assumptions:

- `ThirdParty/angelscript/source/as_builder.cpp:3484-3588` selects Base or
  pre-class cursor, consumes each property's effective storage branch/alignment,
  writes byte offsets and performs terminal alignment;
- `ThirdParty/angelscript/source/as_builder.cpp:2266-2275` applies shadow
  alignment before `LayoutClass`, so an ordinary UClass retains code-root shadow
  alignment even when a Script Base supplies its later cursor;
- `Core/AngelscriptEngine.cpp:5156-5182` obtains UClass code-root boundary from
  current `GetPropertiesSize()` but writes only `UASStruct::ScriptValueOffset`
  for UStruct;
- `ClassGenerator/ASStruct.h:16-31` defines that aligned header boundary and no
  separate builder-consumed header alignment;
- `ThirdParty/angelscript/source/as_datatype.cpp:680-768` proves storage size and
  alignment depend on the fully registered/instantiated live datatype and the
  maintained value versus non-value object branch;
- `ThirdParty/angelscript/source/as_builder.cpp:4520-4554` plus typedef use sites
  distinguish standalone Typedef `{alias size, alignment 4}` from the primitive
  datatype used by a property; and
- `ThirdParty/angelscript/source/as_typeinfo.cpp:456-470` proves Funcdef
  `{size=0, alignment=4}`, making the legacy pointer-size property shortcut
  unsuitable as V1 authority.

The corrective candidate is co-normative
`type-layout-authority-v1.md`. It adds hash-bound Property storage witnesses and
BaseType/CodeRoot/StructHeader LayoutInputs, permits a present-zero boundary
while keeping optional absence distinct, replays layout without a live resolver,
cross-checks linked same-module authorities, and defers legal external single-
witness equality to a separate required per-engine `CurrentLayouts` service.
It also freezes physical trailing-data precedence and the allocator-authoritative
`TS-SCR-01..22` inventory. The correction has been synchronized across the
remaining wire, TypeSchema matrix, semantic schema, design, implementation plan,
tasks, traceability, delta spec and research record.

This section is correction evidence, not approval. Strict validation/diff
checks and a fresh independent review of the combined TypeSchema/layout
authority remain required before Task 2B-2 RED.

During the first approval attempt on that candidate, root self-review paused the
review before a verdict because `CurrentLayouts` still conflated raw catalog
availability with a consumer's stored optional presence. One CodeRoot key has a
raw current boundary and shadow alignment, while a root UClass consumes both
and a script-derived UClass stores only the alignment contribution. Exact raw-
optional equality would therefore reject every derived consumer. The corrected
contract memoizes one raw role result by `{InputKind,ReferenceKind,StableKey}`
and applies each already-validated stored consumption mask before value/hash
comparison. The RED inventory now requires one raw CodeRoot result reused by
root and derived UClasses and proves at-most-once resolution. The independent
review must restart from the post-correction disk snapshot; no earlier partial
review is approval evidence.

## Task 2B-2 TypeSchema Combined Rereview — NOT APPROVED

The fresh independent read-only review of the post-consumer-mask snapshot
changed no file and returned:

```text
NOT APPROVED — 1 Critical / 1 Important / 0 Minor
```

It explicitly confirmed that the prior immutable numeric authority, exhaustive
allocator-family matrix, physical trailing precedence, and raw-role/consumer-
mask findings were closed. The new Critical found that step 10 still called
`CurrentLayouts` for selected-module Base/ScriptType coordinates. During a cold
exact hit those live types do not exist until cache restore creates them, so a
mandatory lookup would turn every legitimate warm generation into
`CurrentSymbolMissing`. The Important found that TypeSchema claimed wire-order
semantics while checking later KindPayload/Dependencies early and recomputing
LayoutInputHash after property hashes, leaving competing failures without one
implementable ByteOffset order.

No TypeSchema RED, serializer, graph implementation, UE build, automation run,
or task checkbox was started from this verdict. Tasks 2.4 and 2.5 remain open.

### Post-rereview correction candidate

The co-normative candidate now freezes selected-module graph closure before
lookup: local Script* dependencies, same-module Base/InlineValue ScriptType,
primitive storage, and ObjectHandle slots make zero current calls. Only external
Script*/EnvironmentSymbol dependencies and the explicit cross-module/environment
numeric-layout set are eligible. A missing required local child fails immutable
coverage. A zero-allocation prospective view over the validated local TypeKey
index lets an eligible environment recipe evaluate a nested local value subtype
before materialization without consulting a live selected-module AS type.
Primitive and ObjectHandle skips are still compared against the exact engine-
free maintained-build layout table; its bool/pointer/int64/double/alignment
coordinates are mandatory inputs to the future production CompatibilityKey
assembler.

The local order is also unique: complete physical decode, trailing exhaustion,
all field-local checks in exact top-level wire order, relation/LayoutInput and
dependency cross-coverage, layout replay, then TypeLayoutHash last. The derived-
hash dependency order is LayoutInputHash, per-property StorageLayoutHash then
PropertyLayoutFingerprint, EnumAuthorityHash, and final TypeLayoutHash. Required
paired RED now records exact Error, Stage, RecordKind, and captured ByteOffset.

This remains correction evidence rather than approval. Mechanical checks and a
fresh independent read-only review of the stable synchronized snapshot are still
required before Task 2B-2 RED.

### Post-rereview correction mechanical checks

The synchronized 22-file OpenSpec snapshot was frozen and checked on 2026-08-08:

```text
openspec validate refactor-as-incremental-function-cache --strict
PASS: Change 'refactor-as-incremental-function-cache' is valid

parent git diff --check + cached diff check
PASS (line-ending conversion warnings only)

Plugins/Angelscript git diff --check + cached diff check
PASS (line-ending conversion warnings only)

explicit change-scope trailing-whitespace scan
PASS: 22 files, no trailing whitespace

known stale resolver/hash-order phrase scan
PASS: no known stale contract phrases
```

No Runtime/test source or task checkbox changed in this correction pass and no
UE build/automation test was claimed. The disk snapshot is now ready for the
required independent read-only combined TypeSchema/layout rereview.

## Task 2B-2 TypeSchema Combined Approval

Two independent read-only reviews completed against the stable synchronized
snapshot on 2026-08-08. Neither review modified files, wrote `Saved/`, or ran
UE build, Automation, PIE, or packaging commands.

The complete TypeSchema/ModuleState/layout-authority cross-document review
returned:

```text
APPROVED — 0 Critical / 0 Important / 0 Minor
```

It explicitly confirmed that the prior cold-start circular dependency and
validation/hash-order findings are closed. Selected-module Script* coordinates
are graph-closed, eligible external/environment coordinates alone reach the
current resolvers, missing required local TypeSchema authorities fail before
current lookup, and the zero-allocation prospective local-layout view is a
bounded immutable graph facade. It also confirmed one physical-decode/trailing
pass, exact top-level field-local wire order, cross-field layout/dependency
checks, and the unique derived-hash order ending with `TypeLayoutHash`.

The focused maintained-source audit of build-layout constants and the cold
resolver split returned:

```text
APPROVED — 0 Critical / 0 Important / 1 Minor
```

The sole Minor is deliberately downstream: the first production
CompatibilityKey assembler still has to freeze its canonical input spellings
while adding the already-required cache-layout schema, bool size, pointer byte
width, int64/double alignment, handle alignment, object initial alignment, and
type-info initial alignment inputs. This does not block Task 2B-2 RED and is not
claimed as implemented by the current Task-1 descriptors.

The combined approval closes only the Task 2B-2 design gate. It does not prove
the Task 2B-2 RED/GREEN implementation, production CompatibilityKey assembler,
real PIE, packaging, or multi-start acceptance. Tasks 2.4 and 2.5 remain open
until their own evidence is captured.

## Task 2B-2A TypeSchema RED

The first focused Task 2B-2 RED slice added only
`AngelscriptCacheTypeSchemaTests.cpp` under the plugin Cache tests. It contains
18 CQTest methods under
`Angelscript.TestModule.Cache.Archive.TypeSchema`, is gated by
`WITH_ANGELSCRIPT_UNITTESTS`, and has no prototype-only test methods. The test
surface freezes the desired immutable decoder boundary, independent payload
version, explicit V1 values, one complete payload/RecordId/envelope golden,
round trip, seven TypeKinds, exhaustive `7 x 256` type-flag predicates,
reflection, relations, present-zero layout input, property/layout replay,
independent methods/VFT/behaviors, signed enum authority, Typedef/Funcdef,
physical trailing precedence, local derived-hash order, build-layout constants,
resolver-free local decode, budget edges, and atomic output reset.

The exact required command ran on 2026-08-08:

```powershell
Tools\RunBuild.ps1 -Label as-cache-typeschema-red -TimeoutMs 1800000 -NoXGE
```

Result: expected RED, exit code `1` (`UBT` process exit `6`) after `73.547 s`.
The first and only blocking compile error is the deliberately missing production
boundary:

```text
AngelscriptCacheTypeSchemaTests.cpp(3,1): fatal error C1083:
Cache/AngelscriptCacheTypeSchema.h: No such file or directory
```

Evidence:

```text
Saved/Build/as-cache-typeschema-red/20260808_131839_898_8462c89c/Build.log
Saved/Build/as-cache-typeschema-red/20260808_131839_898_8462c89c/UBT.log
Saved/Build/as-cache-typeschema-red/20260808_131839_898_8462c89c/RunMetadata.json
```

The other emitted diagnostics were pre-existing C4996 widget deprecation
warnings. No TypeSchema production file existed during this build. This proves
only the focused TypeSchema missing-interface RED; Task 2.4 remains open until
the other four remaining-record and ModuleGraph RED families are captured, and
Task 2.5 remains open until complete GREEN plus independent review.

After the test file added the remaining explicit Property-flag,
ReplicationCondition, and ValidationStage integer assertions, the exact RED
command was rerun against the frozen 1252-line test snapshot. This final RED is
the authoritative run:

```text
Saved/Build/as-cache-typeschema-red/20260808_132132_202_cef035fa/Build.log
Saved/Build/as-cache-typeschema-red/20260808_132132_202_cef035fa/UBT.log
Saved/Build/as-cache-typeschema-red/20260808_132132_202_cef035fa/RunMetadata.json
```

It failed after `4.875 s` with the same first and only blocking C1083 missing-
header error at line 3. The earlier 73.547-second run remains historical RED
evidence but is superseded by this frozen final snapshot.

### TypeSchema RED Independent Review Rejection

The frozen RED snapshot above is **not approved for GREEN implementation**.
An independent read-only review of SHA-256
`D5799DC913365A184CA197BC3A0EC61777EA72EB34783E914A1ADF5776AC5373`
returned the final verdict `NEEDS FIXES (2 Critical / 7 Important /
0 Minor)` after completing its positive-fixture and exact-error audit.
This rejection supersedes the preceding coverage description as readiness
evidence; the C1083 run remains only proof that the proposed header does not
exist yet.

The two Critical findings are architectural:

1. The test invented a second public owning `FAngelscriptValidatedTypeSchema`
   token and direct kind decoder. V1 permits only
   `FAngelscriptDecodedCacheRecordHandle`, created by the single declared-
   RecordId plus canonical-payload factory. SourceIndex and ModuleInterface
   must converge on that factory as part of Task 2B-2 rather than establish a
   parallel TypeSchema ownership or budget path.
2. Most malformed TypeSchema fixtures exercised only the producer writer or a
   test-only predicate. Such tests could remain green while the real shared
   decoder skipped local flag, reflection, relation, layout, property, method,
   behavior, and dependency validation. Every decoder-negative fixture must
   be structurally encoded, assigned its recomputed declared RecordId, and
   rejected through the public shared factory with exact error, stage, record
   kind, byte offset, unchanged sentinel output, and scratch-accounting
   assertions where applicable.

The confirmed Important corrections are: complete the mandatory local
matrices (including ordinary/statics reflection and zero-mask ordered
UFunction membership); add the three missing derived-hash/cross-field
precedence pairs and exact offsets; replace the generic local budget test with
allocator-authoritative TS-SCR-01..14 family probes; fix the metadata member
name and StableFunctionKey comparison compile blockers; exhaust raw enum gaps;
add every new-field one-byte truncation plus invalid optional/enum/boolean
decoder cases; and remove malformed-fixture use of a hash refresh helper whose
fail-closed `check` would fire before the decoder sees the intended error. Only
a deliberately self-consistent, field-locally-valid rehash used by a named
precedence test may refresh a malformed cross-field fixture.

The approved executable shape for failure-clears-output is
`TOptional<FAngelscriptDecodedCacheRecordHandle>&`: `TSharedRef` remains the
only owning handle, the factory resets the optional on entry/failure, and
success emplaces exactly one shared const reference. A nullable `TSharedPtr`
would create a second owning-handle form and is not V1. The existing public
`FAngelscriptValidatedSourceIndex` is therefore a transitional Task 2B-1
boundary, not an allowed graph or retained-record input. Because this change
has no legacy-compatibility requirement, Task 2B-2 will remove that public
owning role and make exact-fast-path eligibility consume the common record's
const SourceIndex view.

No TypeSchema production implementation may begin until the corrected suite
has a new clean RED and a fresh independent review reaches zero Critical and
zero Important findings. Task 2.4 therefore remains open.

### Unified Decoded-Record Boundary Follow-Up

The TypeSchema rejection triggered a separate read-only audit of the common
token boundary and the already-GREEN Task 2B-1 SourceIndex/ModuleInterface
implementation. Its accepted findings and migration acceptance list are
recorded in `decoded-record-boundary-audit.md`.

The follow-up confirmed that Task 2B-2 must do more than replace a TypeSchema
type name. It must remove the transitional public SourceIndex owning token and
mutable ModuleInterface decoder, retain nested captured offsets, add the shared-
Budget envelope overload, guard output-owned aliased input bytes from use-after-
free, delete token copy/move special members, and correct retained allocation
accounting. Current common string/array readers charge requested counts rather
than UE allocator slack, and `MaxTotalDecodedBytes` currently counts only the
input payload rather than the canonical token/DTO/offset capacities. The prior
Task 2B-1 approval did not cover this later all-record ownership model, so its
algorithms/goldens remain useful but its public decoder and budget expectations
are explicitly reopened for migration.

OpenSpec now maps TypeSchema captured offsets into TS-SCR-01..11, ModuleState
offsets into MS-SCR-01/02, and SourceIndex/ModuleInterface/FunctionBody/
DebugSidecar/ModuleSnapshot retained decode capacities into AR-SCR rows. It
also freezes a typed, allocation-free captured-offset query, the alias lifetime
guard, and separate TotalDecoded/Resident limit dimensions over each one
physical allocation. These are specification corrections only; their code and
tests remain pending.

### TypeSchema Behavior Matrix Stage Split

The corrected TypeSchema RED exposed an ambiguity in the original section
12.6 wording: its Cartesian product mixed fields that the immutable local
TypeSchema decoder owns with function declaration facts that only the
ModuleSnapshot graph can resolve from ModuleInterface. The normative matrix is
now explicitly split without reducing coverage. Local decode exhausts
`{BehaviorKind, TypeKind, cardinality, ReferenceKind, owner}` plus ordering,
flags, and local alias shape. Graph RED later crosses every locally admitted
row with exact function entity kind, owner, target existence, and ABI.

This correction prevents TypeSchema from creating a second function-
declaration authority or guessing from names/metadata, while retaining the
required all-entity-kind, missing-target, wrong-owner, and ABI-drift coverage.
Neither stage may substitute a generic smoke test for its half of the matrix.

### Unified Handle Implementation Preflight

A second read-only implementation preflight mapped the exact Runtime files,
functions and existing SourceInterface call sites for the common-token
migration. It found no non-test production consumer of the transitional
`FAngelscriptValidatedSourceIndex`, public SourceIndex decoder, mutable
ModuleInterface decoder, raw-DTO test decoder, or class-static eligibility
query. They can therefore be deleted directly in this development-phase break;
no compatibility wrapper is required or allowed.

The preflight additionally promoted four boundary corrections to normative
requirements: remove public session-budget `Reset()` because it can erase a
live token's conservative retained charge; add true scratch
`PromoteToRetained()` and peak combined-live accounting; charge the exact
single `MakeShared` token/controller allocation rather than only
`sizeof(Token)`; and separate whole-TU compile evidence from a behavioral RED
that needs a minimal real valid-path kernel. These corrections are recorded in
`decoded-record-boundary-audit.md`; production remains pending.

The revised TypeSchema RED was then frozen at SHA-256
`4DDC1A19C3E5777B259669242A11AF2D86C90276061832E309B0F3164317309C`
(`196186` bytes, `4532` lines, `36` CQTest methods). The author reports all
prior 2C/7I findings addressed and static forbidden-pattern/diff/whitespace
checks clean. No build or Automation result is claimed. A fresh independent
read-only review of that exact SHA is in progress; Task 2.4 remains open.

The follow-up coordinate design then froze SourceIndex `u16 0..89` and
ModuleInterface `u16 0..88` in
`source-interface-captured-offsets-v1.md`, including every P/S/T index role,
recursive CanonicalDataType pre-order ordinal, nested optional/reference/
dependency/metadata/parameter/slot routing, and exact eligibility wrong-kind
result. The latter is error 48, GraphOrOwnership, ModuleGraph stage 5, actual
supplied token kind, byte offset zero, false/empty output, unchanged Budget and
no allocation/accessor/offset lookup. Strict OpenSpec validation and both diff
checks pass after adding the 24th change document.

### Revised TypeSchema RED independent-review checkpoint

The independent exact-SHA review has now read all 4532 lines and checked the
snapshot against the five governing authorities. Its pre-final checkpoint is
`NOT APPROVED — at least 2 Critical / 7 Important`. Confirmed blockers include
incomplete exact diagnostic tuples for mandatory negatives; incomplete proof
of the sole handle/construction boundary; a writer-trace-derived rather than
independent field inventory; missing optional-tag and Property ordinal cases;
misclassified UFunction/Method/VFT ordinal fixtures; incomplete TS-SCR
allocation/failure-exit evidence; and multiple fixtures incorrectly labelled
valid. The reviewer is still producing the deduplicated, line-numbered final
report. No build, Automation run, production source, task checkbox, commit, or
approval is claimed by this checkpoint.

The same reviewer then completed deduplication and returned the final verdict
`NEEDS FIXES — 3 Critical / 9 Important / 0 Minor` against the unchanged SHA
`4DDC1A19C3E5777B259669242A11AF2D86C90276061832E309B0F3164317309C`.
In addition to the checkpoint findings, it proved that several inactive
KindPayload-arm decoder negatives are impossible under V1's sole TypeKind union
tag, and it expanded the important set to raw high-bit exhaustion, the full
property/layout matrix, missing deterministic precedence pairs, and typed-key
domain isolation. Exact line anchors, repair requirements, and confirmed
positives are recorded in `type-schema-red-review.md`; issue entries IC-016
through IC-027 are tracked in `implementation-issues.md`. No production source,
build, test, task closure, commit, or approval is claimed by this verdict.

During repair, IC-028 was added: exact TS-SCR budget-failure diagnostics and
unchanged allocation-attempt evidence require a narrow observed-event/field-
coordinate test-probe contract. Expected offsets and limits must remain owned
by the independent wire/allocator oracle rather than being returned by the
probe under test. This is a RED declaration requirement, not production or
behavioral evidence.

IC-028 review exposed IC-029: one probe-selected target per family/variant does
not exhaust the multiple allocator sites within strings, nested data types,
metadata, selected payload arms, and captured offsets. The normative repair in
`type-layout-authority-v1.md` section 11.1 adds a test-owned allocation-site
template table and forbids production helpers from returning expected sites,
stages, offsets, or limits. No revised RED approval or production evidence is
claimed by this design correction.

Allocation-site expansion then exposed IC-030: V1 Delegate/Funcdef callable
payload has no signature FString, only inline function key, ABI, and multicast
boolean. The TS-SCR09 authority now removes the nonexistent string site and
requires zero DTO string/container allocation for those arms while preserving
the real selected-arm offset charge. No Runtime field was added.

### Repaired TypeSchema RED candidate for fresh rereview

After closing the final Funcdef allowed-site residual, the repaired test-only
candidate is frozen at SHA-256
`63C265CCE5325302A7ABFF8D7D9C6AD47BD2EBEEFDB5DE1892D7ECA606BDBE92`:
308951 bytes, 6976 newline-counted lines, 46 CQTest methods, 66 test-owned
allocation-site templates, 50 semantic SiteKinds, and 106 exact-helper
references including its definition. Root independently repeated the hash,
size, method/delimiter/trailing-whitespace checks and forbidden self-oracle
scans. The full Property loop remains 2,621,440 common-factory cases.

The author changed only the untracked TypeSchema test, ran no build or test,
and made no commit. The candidate declares future Runtime observed-event/layout
test contracts and therefore has no whole-TU or behavioral RED evidence yet.
A fresh independent exact-SHA rereview is required before any production
declaration/stub implementation.

### Repaired TypeSchema RED exact-SHA rereview — rejected

Two independent read-only audits reverified SHA-256
`63C265CCE5325302A7ABFF8D7D9C6AD47BD2EBEEFDB5DE1892D7ECA606BDBE92`.
The full cross-document audit returned `3 Critical / 6 Important / 0 Minor`;
the focused handle/budget/TS-SCR audit returned `3 Critical / 7 Important /
0 Minor`. Neither reviewer edited files, built, ran Automation, wrote `Saved/`,
or committed. The candidate is **not approved** and no production declaration
or behavior work is authorized by this evidence.

The deduplicated findings are IC-031 through IC-042 in
`implementation-issues.md`. The dominant blockers are an incomplete public
captured-coordinate matrix; a circular semantic allocation observer and
unimplementable variant-filtered expected sites; missing canonical-payload
owned-byte charge; unreachable required templates and self-reported scratch
zero allocation; non-independent Resident/Temporary/Peak reconstruction;
missing reference exact/short limits; writer-trace-derived offsets; invalid or
multi-fault fixtures; incomplete property/relation/precedence rows; an
out-of-scope handle-copy probe; and cleanup tests that do not prove the target
allocation was reached.

The rereview also exposed a normative omission. `type-layout-authority-v1.md`
section 11/11.1 has now been corrected to include the sole token-owned
canonical-payload allocation in TS-SCR-01, require a semantic-blind generic
observer, freeze per-site `Required/StreamingZero/InvalidFixtureOnly`
dispositions and actual element-type slack boundaries, and require independent
chronology/lifetime/reference reconstruction plus distinct Total and Resident
one-short cases. This documentation change is design evidence only; the test
must receive a new SHA and fresh 0C/0I rereview.

Post-record checks on 2026-08-08:

```text
openspec validate refactor-as-incremental-function-cache --strict
Change 'refactor-as-incremental-function-cache' is valid

parent git diff --check: exit 0 (only existing LF->CRLF warnings)
plugin git diff --check: exit 0 (only existing LF->CRLF warnings)
```

No compile, Automation, PIE, package, launch, commit or production approval is
claimed by these document checks.

### Unified decoded-handle migration preflight

A fresh read-only plugin-wide `rg` audit found the transitional public
SourceIndex token, mutable ModuleInterface decode and exact-eligibility query
surface only in `AngelscriptCacheSemanticRecords.h/.cpp` and
`AngelscriptCacheSourceInterfaceTests.cpp`; no hidden consumer was found in the
rest of Runtime, Editor or Test. `AngelscriptCacheTypes.h` owns the public
session-Budget reset. Test migration has exactly 34 session-Budget reset call
sites: 10 in Archive Primitives and 24 in SourceInterface. Scratch reservation
release is deliberately excluded.

The exact file map and required transformations are recorded in
`decoded-record-boundary-audit.md`. Parent and plugin `git worktree list
--porcelain` independently confirm both isolated branches point at
`D:/Workspace/AngelscriptProject/.worktree/as-cache`; the main parent/plugin
branches remain separate worktrees. This is migration preparation and
isolation evidence, not RED/GREEN completion.

### TypeSchema captured-coordinate authority correction

Replacement-RED authoring exposed IC-043: the append-only TypeSchema field
numbers `0..38` had no exhaustive P/S/T consumption table. The wire authority
now freezes every range and removes the three concrete ambiguities:
PropertyMetadata is `{PropertyOrdinal,MetadataOrdinal,U}`;
BehaviorDeclaringOwner is `{BehaviorOrdinal,U,U}` and absent is unset; and
EnumEnumeratorMetadata is `{EnumeratorOrdinal,MetadataOrdinal,U}`. All unused
indices must be `U=MAX_uint32`; nested metadata array-count offsets remain
private decoder diagnostics rather than overloaded public coordinates.

This correction was written before the author resumed those RED rows. It is
design evidence only; the new test SHA must prove the complete `0..38` matrix
and receive fresh independent review.

Post-correction `openspec validate refactor-as-incremental-function-cache
--strict`, parent `git diff --check`, and plugin `git diff --check` all exited
zero; only the previously recorded LF-to-CRLF warnings were emitted.

### TypeSchema replacement RED — oracle-removal checkpoint

The first replacement-RED edit atomically removed the old family-level/circular
oracle definitions. The intermediate test snapshot is 6330 lines, 279989 bytes,
SHA-256 `CD951C5E922B168CB4423625268AD0D744B33BD38F2EB406B927EAF13AA071DC`.
Definitions removed include the top-level DTO capacity, family slack, site
template, site byte, event-derived exact-budget reconstruction and case
expansion helpers. Root mechanically confirmed their remaining references plus
three `SiteKindRaw` reads are confined to the still-unreplaced TS-SCR methods at
the end of the file. That dangling declaration RED is expected only between
atomic edit blocks; it is not a frozen candidate and was not built or run.

The next block must replace those methods with a test-owned wire inventory,
chronological expected plan and semantic-blind generic event comparison, then
reduce every old helper reference and production semantic-event read to zero.

### Unified decoded-handle implementation preflight — authority corrections

The read-only UE 5.8 and plugin source audit after the first TypeSchema
rereview found six implementation blockers, recorded as IC-044 through IC-049.
The final decoded token cannot be introduced as a temporary SourceIndex/
ModuleInterface-only variant: its intrusive controller charge depends on the
complete in-place layout of all seven `{DTO,captured offsets}` alternatives.
The sequence is therefore frozen as all seven storage declarations first,
then one final private-construction token and one common public handle.

Local UE 5.8 headers independently confirm that `MakeShared` uses
`SharedPointerInternals::NewIntrusiveReferenceController` and an in-place
`TIntrusiveReferenceController<T, ESPMode::ThreadSafe>`. The allocator request
uses the effective ordinary-new alignment from ModuleBoilerplate, not blindly
`alignof(FController)`. A test-only measurement hook must allocate and destroy
the exact controller type and measure the returned controller base pointer;
`GetAllocSize` must never be called on the token's interior object pointer.

The same preflight found that the existing split decoded/resident acquisitions
can half-charge a physical allocation; envelope payload copy has no mandatory
shared Budget and does not charge actual owned capacity; current SourceIndex
and ModuleInterface candidates discard most nested offsets; and codec,
validation and eligibility paths still use requested or fixed approximate
sizes. `record-wire-v1-remaining.md`, `implementation-plan.md` and
`decoded-record-boundary-audit.md` now freeze the atomic retained/temporary
acquisition APIs, combined-live peak, promotion rule, envelope charge,
exhaustive captured-offset storage and allocator-capacity rule. This is design
and implementation-order evidence only; no production code or build result is
claimed.

### TypeSchema replacement RED — second atomic checkpoint

The second replacement block removed every remaining reference to the six old
circular/family helpers and reduced `SiteKindRaw`, `FixtureVariant`, the three
production-reported entry-budget fields, `bProvenZeroAllocation` and
`ObservedScratchVariant` reads to zero. The replacement now contains a
test-owned wire scanner and inventory, raw-boundary and `{Field,P,S,T}`
coordinates, an independent reference sequence, static
`Required/StreamingZero/InvalidFixtureOnly` dispositions, 53 semantic sites
including canonical-payload/Enum-metadata/Typedef-subtype/combined-scratch,
and independently reconstructed Total/Resident/Temporary/Peak prefixes.

It also adds chronological event comparison, separate Total and Resident
one-short cases, reference exact/short limits, static streaming-zero approval,
target-reached cleanup guards, effective-new-alignment controller accounting,
and an exact-controller base-allocation measurement. This snapshot is not
frozen: the author is still adding the public TypeSchema `0..38` matrix,
all-fixture scanner assertions and relation/property/precedence closure. No
compile or Automation result is claimed before that edit receives a new SHA
and fresh independent review.

Status checks repeated on 2026-08-08:

```text
openspec validate refactor-as-incremental-function-cache --strict: exit 0
parent git diff --check: exit 0 (only existing LF->CRLF warnings)
plugin git diff --check: exit 0 (only existing LF->CRLF warnings)
task checklist: 8 complete / 51 open / 59 total
```

Parent and plugin worktree listings still place both feature branches only
under `D:/Workspace/AngelscriptProject/.worktree/as-cache`; the main checkout
and main plugin worktree remain separate and unchanged by this work.

### Shared validation result primitives — first production slice

The existing TypeSchema RED had already frozen diagnostic stage values and the
remaining-record authority had frozen append-only validation errors `44..64`.
`AngelscriptCacheTypes.h` now implements those declarations, adds `Stage` to
the result, preserves the existing three-argument constructor's third argument
as `ByteOffset` with `Stage=None`, and adds the distinctly named `AtStage`
factory. The exhaustive classifier maps the three new codec errors, sixteen
graph/ownership errors and two current-state ineligibility errors to their
frozen classes.

A new focused CQTest file,
`AngelscriptCacheValidationTests.cpp`, contains three methods that freeze all
numeric values, every appended classification, and the old-constructor versus
named-factory tuple behavior, including compile-time rejection of stage as the
old third positional argument and of an invented four-argument constructor.
Its current SHA-256 is
`598AC40E1F58B57ED6C8D0641ACE386E173648CE24F15E9B04CDFB8AE855D124`;
each appended error is checked through both the static classifier and actual
result construction.
Plugin `git diff --check` exits zero. No UBT or Automation result is claimed:
the replacement TypeSchema RED is still being authored and deliberately keeps
the whole test module at a declaration RED boundary until it is frozen and
reviewed.

### Atomic Budget, envelope and migrated-consumer checkpoint

`AngelscriptCacheTypes.h` now exposes only the atomic retained and temporary
decoded acquisitions, direct combined-live peak accounting and move-only
temporary promotion/release. The focused Budget RED has nine methods and is
frozen at SHA-256
`F67B564C64FDB37387F76AC45949BF20ACD98B677AF169D395AB2B884820FAF3`.
The current production header SHA-256 is
`FC8E0C61754077B0856E46FB29981E38538C3F1920E6F07975F3345675A3A71B`.
No public session reset or split decoded/resident acquisition remains in the
Runtime Cache directory.

The envelope now has a mandatory shared-Budget overload, charges the actual
owned payload-array capacity before allocation, builds into a local candidate,
and publishes only after physical/hash validation. Its production and focused
test SHA-256 values are respectively
`AAA11709B60C4F3E50E853E1B25AFB0D179E02AE75EE4E6078269D8F2D33DC79`
and `543AB2D562AAF0841A2C431207A31D41483E4A7264C716F18C6C5B0F01055292`.
The fixed 31-byte RecordId semantic header is stack-owned rather than a hidden
heap `TArray`.

All ten primitive-test and twenty-four SourceInterface session resets have been
replaced by fresh per-session Budgets except for the deliberately cumulative
two-read case, which retains one Budget and derives its exact single-read Total
from an independent measure run. SourceInterface no longer uses the old
temporary-only peak getter; it derives scratch as `PeakLive - final Resident`
and uses entry Resident plus standalone PeakLive for combined token/query
limits. Its frozen SHA-256 is
`C82C90E7BA2B072EEE76A55FD72147316B481D50C7DA52A634B67E1E4AC1ABEB`.
Static author review reports 0 Critical, 0 Important and 0 Minor. This is
migration evidence only; no current build or Automation result is claimed.

### TypeSchema replacement RED — frozen candidate

The complete replacement RED is frozen at SHA-256
`44432F811B66BB1BB2AF2E87B927CCD64525482132DA2E63FF87C97AF8F1124E`
(331959 bytes, 49 `TEST_METHOD`s). It contains exactly 53 static SiteKinds and
53 templates (`Required=41`, `StreamingZero=12`), the 39-row public field
coordinate matrix for fields `0..38`, independent raw-wire offsets, actual
per-element allocator boundaries, chronological allocation plans, independent
Total/Resident/Temporary/Peak/reference reconstruction, separate Total and
Resident one-short runs, reference exact/short runs, handle-copy accounting and
late physical/local/hash cleanup.

Author-side static review reported 0 Critical, 0 Important and one
formatting-only Minor. A different agent then completed a fresh read-only review
of the frozen SHA against the four authority documents and returned **3 Critical /
7 Important / 0 Minor**. The candidate is rejected. The findings are recorded as
IC-054 through IC-063 and detailed in `type-schema-red-review.md`; no TypeSchema
GREEN implementation claim is permitted before a repaired exact SHA receives a
new zero-Critical/zero-Important review.

### Canonical codec allocator-authoritative RED/GREEN edit

IC-052 adds a public primitive RED that independently calculates the default UE
allocator capacity for `TArray<TCHAR>` and
`TArray<FAngelscriptCachedDataType>`. It freezes exact success, Total one-short,
Resident one-short, empty-string zero allocation, output allocated size, full
counter invariance and `PayloadDecode` field offsets. The primitive test SHA-256
after this edit is
`DD554EE583DC4907B72A3050CC42D63C1383B1B7927E8DD0226C607E691B696D`.

The private canonical reader now calculates typed slack capacity before every
string/array growth, atomically consumes the exact capacity, calls `Reserve`
only after success, uses `PayloadDecode` for physical failures and
`LocalSemantic` for captured semantic failures. Its SHA-256 is
`915622B055288C8B29327CF6733B397CF64B78BAEE7F2CF8A70828FC8FB64DFA`.
This is a source-level GREEN edit only: the replacement TypeSchema RED still
keeps the test module at a declaration boundary, so no compile or Automation
result is claimed yet.

An independent read-only allocator review of this primitive slice returned
**0 Critical / 3 Important / 0 Minor**. Production capacity calculation and
Budget-before-Reserve ordering were statically confirmed, but the test does not
force an allocator-slack array count, does not exercise a second recursive
nonempty array site, and observes only final caller output rather than allocation
attempt chronology. The standalone trailing-data wrappers also still return
`Stage=None`. These gaps are IC-064 through IC-066; IC-052 is therefore only a
partial fix and no primitive GREEN test result is claimed.

After recording the two independent review results, IC-054 through IC-066 and
the decoded-candidate Temporary-to-Resident authority correction, the OpenSpec
record was revalidated:

```powershell
openspec validate refactor-as-incremental-function-cache --strict
git diff --check
git -C Plugins/Angelscript diff --check
```

All three commands exited `0`; OpenSpec reported
`Change 'refactor-as-incremental-function-cache' is valid`. The two diff checks
reported only existing LF-to-CRLF checkout warnings and no whitespace error.

### TypeSchema declaration-boundary RED build

After the TypeSchema replacement RED froze, the required whole-TU declaration
check was run through the repository wrapper:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label as-cache-typeschema-declaration-red -TimeoutMs 180000 -NoXGE
```

Result: expected RED, wrapper exit `1`, UBT process exit `6`. The first and only
reported compiler error is:

```text
AngelscriptCacheTypeSchemaTests.cpp(3,1): fatal error C1083:
cannot open include file 'Cache/AngelscriptCacheTypeSchema.h'
```

The build log and metadata are:

```text
Saved/Build/as-cache-typeschema-declaration-red/
  20260808_174803_998_d31b7e50/Build.log
  20260808_174803_998_d31b7e50/UBT.log
  20260808_174803_998_d31b7e50/RunMetadata.json
```

The Runtime unity containing the current Cache implementation compiled and the
Runtime library/DLL reached link before the Test declaration failure, but the
overall Editor build failed as intended. This is declaration RED evidence only,
not behavioral RED, GREEN, or a passing build. The next implementation slice
must add the complete seven-record DTO/coordinate/private-storage declarations
and the final common token header; a stub or TypeSchema-only owning wrapper is
explicitly insufficient.

### Decoded-candidate transaction implementation preflight

A separate read-only audit of the updated Temporary-to-Resident authority and UE
5.8 `MakeShared` implementation confirmed that the minimum viable implementation
is a Budget-private nested, move-only candidate transaction. It extends Total plus
Temporary atomically per physical site, releases only aggregate Temporary on
failure, promotes once before publication, and never escapes the synchronous
factory scope. The audit also confirmed the effective replacement-new alignment
formula and the need to measure the exact final seven-kind intrusive controller
from its allocation base rather than the token interior pointer.

The audit exposed IC-067 through IC-069: the current canonical reader hardcodes
retained charging, Budget thread affinity was implicit, and allocator prediction
cannot be corrected safely after allocation. Authority, tasks and the detailed
implementation recipe were updated in
`decoded-candidate-transaction-preflight.md`. No production implementation,
compile result or test result is claimed by this preflight.

After these record-only changes,
`openspec validate refactor-as-incremental-function-cache --strict` and parent
`git diff --check` both exited `0`; the diff check emitted only existing checkout
line-ending warnings.

### Canonical primitive allocator/stage repair and independent correction

IC-064 through IC-066 now have scoped production and RED changes: an actual typed
allocator slack count is discovered dynamically, a root plus child recursive
DataType produces two nonempty allocation sites, Total/Resident short runs stop at
the child before its allocation attempt while preserving the accepted root prefix,
and canonical string/DataType trailing bytes return `PayloadDecode` with the first
trailing offset. A fixed unit-test event buffer observes retained-budget attempt,
acceptance and physical allocation attempt without allocating itself.

The first wrapper build exposed a real ADL ambiguity in a same-named private probe
forwarder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label canonical-codec-ic064-066 -TimeoutMs 600000 -NoXGE
```

It failed with `C2668`; the private forwarder was renamed. The rerun compiled the
Runtime unity and linked both `UnrealEditor-AngelscriptRuntime.lib` and `.dll`, then
stopped only at the known missing `Cache/AngelscriptCacheTypeSchema.h` in the Test
unity:

```text
Saved/Build/canonical-codec-ic064-066-rerun/
  20260808_181601_122_a08e17e6/Build.log
  20260808_181601_122_a08e17e6/RunMetadata.json
```

Independent review then found IC-070 and IC-071: the buffer was recording outside
an observing test and its record function was declared publicly. Capture is now
default-off and controlled by a non-nestable RAII scope; unrelated unscoped decode
proves the prior event count remains unchanged. Only scope/read access remains in
the public unit-test header, while event recording is declared solely in the Runtime
private codec header.

A fresh wrapper run after that correction again compiled the Runtime unity and
linked its library/DLL, with the overall target still failing only at the sibling
TypeSchema declaration boundary:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label canonical-codec-ic070-071-review-fix -TimeoutMs 600000 -NoXGE
```

```text
Saved/Build/canonical-codec-ic070-071-review-fix/
  20260808_182112_172_2b2a35b5/Build.log
  20260808_182112_172_2b2a35b5/RunMetadata.json
```

Current scoped SHA-256 values are:

```text
Private/AngelscriptCacheCanonicalCodec.h
  7FF64D869B44BC51FB122C95FE51321A5EEB584335DBD903CCB9D5E3DEA00A9C
AngelscriptCacheSemanticRecords.h
  546C4A5556306464663DAC14EE82259889C4FBDAEDD0B34F97EFE7C57776F423
AngelscriptCacheSemanticRecords.cpp
  27A3E9D806FBBD11FDA0F6F9EBDBCD41CBEE25BC02CF05928BA6A937A5EB8DF2
AngelscriptCacheArchivePrimitiveTests.cpp
  B4AF2F7B625E8546199C2D2C5EADA6F8C3303C20E2D000CD3C11B3ACD060E235
```

The four files have zero trailing whitespace; plugin `git diff --check` exits
zero. Public-header scans find zero record/reset mutation declarations, seven
explicit test capture scopes and zero legacy reset calls. Primitive automation is
not yet claimed because its unity includes the still-missing TypeSchema header.

### Private decoded-candidate Budget transaction declaration slice

Three focused CQTest methods were added before production edits to freeze multiple
site extension, zero no-op, separate Total/live rejection, aggregate overflow,
failure release without Total refund, single promotion, existing scratch coexistence,
and move construction/assignment across Budgets. Because the same Test unity still
contains the missing TypeSchema header, this source RED could not be promoted to a
standalone behavioral RED.

`AngelscriptCacheTypes.h` now contains a Budget-private nested move-only candidate
transaction. Begin is counter-free, each nonzero extension preflights aggregate
overflow plus Total and combined-live limits before committing Total+Temporary,
failure/destruction releases only aggregate Temporary, and promotion reclassifies
the aggregate once without changing Total, combined live or Peak. Development
checks bind the Budget mutation thread and require zero active candidates at Budget
destruction. The test fixture friend exists only under
`WITH_ANGELSCRIPT_UNITTESTS`; the future sole decoded-record factory is the only
production friend.

The first wrapper build exposed IC-073: CQTest defines the fixture as `struct`, but
the friend forward used `class`. A first partial repair left `friend class` and
reproduced `C4099`; the final declaration uses guarded `struct` consistently.

```text
Saved/Build/decoded-candidate-budget-transaction/
  20260808_182612_054_ab8a5b3e/Build.log
Saved/Build/decoded-candidate-budget-transaction-rerun/
  20260808_182634_736_6a4d3502/Build.log
Saved/Build/decoded-candidate-budget-transaction-rerun2/
  20260808_182658_595_2bc331fd/Build.log
```

The final rerun compiled Runtime unities `11` and `27`, Budget-containing Test
unity declarations up to the later missing TypeSchema include, and linked
`UnrealEditor-AngelscriptRuntime.lib/.dll`. Overall wrapper exit remains `1` /
UBT `6` solely because `Cache/AngelscriptCacheTypeSchema.h` does not yet exist.
No Budget automation result is claimed. The canonical reader charge sink and final
all-record factory integration remain IC-067 work after TypeSchema RED approval.

### Independent pre-repair reviews after the declaration builds

The frozen four-file canonical allocator slice received a fresh read-only review.
Counting the already-open IC-067/IC-069 requirements, the result was:

```text
1 Critical / 5 Important / 1 Minor
```

The review confirmed the allocator-slack oracle, root/child reserve accounting,
root-prefix retention on a child shortfall, pre-existing-capacity reset and
`PayloadDecode` trailing stage. It rejected final approval because the reader still
lacks the candidate charge sink (IC-067), its event marker was separable from the
actual allocation (IC-074), production did not yet compare predicted and actual
allocator bytes (IC-069), the fixed observer lacked the frozen overflow protocol
(IC-075), the private mutation symbol remained exported under the test macro
(IC-071), observer destruction was not thread-bound (IC-076), and the two local
trailing cases omitted a direct malformed-class assertion (IC-066). No primitive
Automation result or approved SHA is claimed from this review.

The private decoded-candidate Budget transaction received a separate read-only
review with:

```text
0 Critical / 2 Important / 1 Minor
```

The review accepted the all-or-none per-site counter commit, zero-byte no-op,
monotonic Total semantics, Temporary-only failure release, one-shot promotion,
thread-affine mutation checks and coexistence with existing scratch reservations.
It rejected final approval because the transaction borrowed mutable Limits storage
(IC-077) and cross-Budget move-assignment could invert owner lifetime in non-check
builds (IC-078). Its Minor observation about an unconditional test friend was made
against a pre-guard snapshot; the current source has both the forward declaration
and friend under `WITH_ANGELSCRIPT_UNITTESTS`, but that fact still needs the next
frozen build/review evidence. No Budget Automation result is claimed.

The repaired candidate source slice is now frozen for build and independent review:

```text
AngelscriptCacheTypes.h
  211ED5764BC6F3FB2B50D9F810C1846C6E1D32DE15B92D68DAF47F18E1D00B96
AngelscriptCacheBudgetTests.cpp
  D165B2239971582815B0812C2E3BCD145E379D633E8E11C6C5828B316932757F
```

The transaction owns value snapshots of both decoded limits, move-assignment is
deleted while move construction remains, and moved-from/promotion/release paths
clear the snapshots. Focused source cases use a temporary Limits argument, mutate a
named Limits object after Begin, require `!is_move_assignable`, and verify move-
construction plus promotion/destruction exactly once. A namespace-scope non-friend
detection helper requires the private Begin surface to remain inaccessible. Static
scans find no stored Limits pointer or move-assignment definition. Build, Automation
and the new independent review are still pending and therefore no GREEN is claimed.

After recording IC-074 through IC-078 and the updated transaction authority, strict
OpenSpec validation passed:

```powershell
openspec validate refactor-as-incremental-function-cache --strict --no-interactive
```

```text
Change 'refactor-as-incremental-function-cache' is valid
```

### Repaired TypeSchema RED candidate AA4808

The TypeSchema RED author froze one replacement candidate after addressing the
IC-054 through IC-063 rejection set:

```text
AngelscriptCacheTypeSchemaTests.cpp
  SHA-256: AA4808D0EAB60932C8BAD0A1C2A9D3A0843629041B3D14933B76989D8ACBFFF2
  Bytes: 361655
  Lines: 8411
  Unique TEST_METHOD: 51
  SiteKind: 53 plus Count sentinel
  Fixed templates: 53 (Required 41, StreamingZero 12)
  Streaming checkpoint rows: 12
```

The author-side static audit reports candidate-Temporary allocation events before
publication, one independent success promotion, failure Temporary release with
monotonic Total, a shared expanded allocator-slack case table, a representable late
presence fault, independent scanner coordinates, single-axis ordinal mutations with
recomputed hashes, explicit base/dependency closure, exact reference-bearing sets,
per-occurrence prefix shorts, Count/frequency/disposition closure, all twelve
semantic-blind streaming checkpoints and the complete producer tuple. Its forbidden
scan reported zero matches for the nine rejected escape patterns and duplicate test
names. No build, Automation or production implementation was run or claimed. A new
independent reviewer is auditing the exact SHA; only 0 Critical / 0 Important may
open the TypeSchema GREEN gate.

### Candidate transaction independent approval and canonical repair build

The frozen candidate transaction SHA pair received a new independent read-only
review with exact hash agreement and:

```text
0 Critical / 0 Important / 0 Minor
```

The reviewer accepted IC-053, IC-068, IC-072, IC-073, IC-077 and IC-078: limit
snapshots are owned values, move-assignment is deleted, move construction transfers
one active candidate without double accounting, Total remains monotonic, failure
releases only Temporary, promotion is one-shot, owner-thread and active-count
invariants are coherent, the test friend is compiled out of non-test builds and the
namespace-scope SFINAE detector has no friend authority. The remaining integration
constraint is intentional: the raw Budget owner is a synchronous lexical borrow and
must never enter a handle or async task.

The canonical repair is frozen for a separate independent review at:

```text
Private/AngelscriptCacheCanonicalCodec.h
  1263BBB7505B049932BFF3E094AAB41BCDAB6AEC82A94924B9CA6BD4E2CE1A4E
AngelscriptCacheSemanticRecords.h
  C6407E624A539244525931EFD7D8BECFA997533836196287E2C872A8F9A3438A
AngelscriptCacheSemanticRecords.cpp
  25FFA8A83EC808153A6648AE71A624A9744EF05B18F9BC78A28F4FB1FF04FF0B
AngelscriptCacheArchivePrimitiveTests.cpp
  6B8C60BDB6BE053401E73918C407C1CB2E0CD6481EDF6ED9DB3722D2CE861CB3
```

It now uses one instrumented string/typed-array `Reserve`, records allocation
success with actual bytes, fails closed on predicted/actual mismatch without Budget
correction, accepts a caller-owned fixed event view with explicit overflow, binds
the capture scope to its construction thread, removes the record mutation DLL
export, and asserts the complete trailing tuple. IC-067 remains intentionally open
at the helper's single retained-charge seam.

The following fresh wrapper build verified the repaired Runtime declaration and
link paths:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label cache-canonical-candidate-review-fixes -TimeoutMs 600000 -NoXGE
```

```text
Saved/Build/cache-canonical-candidate-review-fixes/
  20260808_185724_003_0216e3fb/Build.log
  20260808_185724_003_0216e3fb/UBT.log
  20260808_185724_003_0216e3fb/RunMetadata.json
```

Runtime unities `11` and `27` compiled and
`UnrealEditor-AngelscriptRuntime.lib/.dll` linked. Overall exit remained wrapper `1`
/ UBT `6` solely at the intentional TypeSchema RED gate:

```text
AngelscriptCacheTypeSchemaTests.cpp(3,1): fatal error C1083:
Cache/AngelscriptCacheTypeSchema.h: No such file or directory
```

Primitive, Budget and TypeSchema tests share `Module.AngelscriptTest.18.cpp`; the
first two appear before the missing TypeSchema include and emitted no earlier
diagnostic, but the fatal include prevents a complete Test object and no Test GREEN
or Automation result is claimed.

The exact four-file canonical SHA set then received a new independent read-only
review with exact hash agreement:

```text
0 Critical / 0 Important / 1 Minor
```

The scoped implementation is approved at 0C/0I, with IC-067 explicitly excluded as
the next all-record integration seam. The reviewer confirmed one physical Reserve,
the shared string/typed-array helper, Budget-before-allocation chronology, actual-
byte mismatch fail-closed behavior without post-allocation correction, no target
allocation on shortfall, no public/exported mutation authority, non-test hook
elision, valid null/zero/nesting/thread guards and complete trailing tuples. The
sole Minor, recorded as IC-079, is missing explicit boundary fixtures for zero-
capacity, invalid positive-null, nested and wrong-thread capture misuse; the current
two-slot/four-event case already proves overflow without growth. No dynamic GREEN is
claimed until those cases and focused Automation run after the TypeSchema gate.

### TypeSchema AA4808 independent rejection

The new reviewer confirmed the exact SHA and measured 361,655 bytes, 8,410 LF
terminators with a final newline, 51 unique tests, 53 sites plus Count, 41 Required,
12 StreamingZero and twelve streaming checkpoints. The independent result was:

```text
NEEDS FIXES — 3 Critical / 6 Important / 1 Minor
```

The three Critical findings are: the selected `Enum + None` later presence state is
legal and therefore cannot prove IC-056 precedence; the shared expanded-case loop
still has only unlimited success rather than exact Total/live success; and typed
wrong-record-kind queries use default `Field=Invalid` coordinates rather than valid
coordinates from the six other kinds. The Important findings retain impossible
Typedef/dependency Required fixtures, derive exact reference occurrences from the
fixture DTO rather than a test-owned authority table, permit a Runtime-owned growing
TypeSchema probe, invent an unfrozen public `InjectedTestFailure`, call the valid-
fixture hash finalizer on malformed ordinals, and leave two property replay
fingerprints stale. The line-count convention is the sole Minor. Existing accepted
directions include candidate Temporary/promotion semantics, independent scanner
offsets, Count/frequency/disposition, twelve streaming checkpoints and the full
inactive-arm producer tuple. IC-080..IC-085 record the distinct new findings; a new
test-only repair has started and no GREEN claim is made.

### IC-079 canonical boundary-test repair

Only `AngelscriptCacheArchivePrimitiveTests.cpp` changed after canonical production
approval, to SHA:

```text
10921140226A71031E2FAFED6BB0244FA5ACAAD05428500A9EDAB3DB19AC8938
```

The overflow fixture now uses one slot and requires successful decode, count one,
overflow true and a preserved BudgetAttempt. New zero-capacity and positive-size/
null-data views prove count saturation, explicit overflow, no storage write and no
decode interruption. No reliable C++ `checkf` death-test facility exists in the
current CQTest layer, so nested/wrong-thread fatal invariants remain source-level
evidence rather than weakened recoverable behavior. The three approved production
SHAs did not change. Build and Automation remain pending while the TypeSchema test
file is under repair.

### TypeSchema repair-preflight authority correction

Read-only repair preflight found that the V1 semantic and allocation authorities
could not both be implemented. A legal Typedef is an unqualified primitive alias,
so it cannot have a successful subtype-array allocation; TS-SCR-09 nevertheless
called that storage Required. IC-086 corrects it to one hostile-input
`InvalidFixtureOnly` physical site plus a separate legal zero-event validation
checkpoint. Preflight also found TS-SCR-11's "all dependency kinds" success wording
contradicted the exact TypeSchema-derived closure. IC-087 limits Required success to
`Inheritance`, `ValueLayout`, `Declaration`, `Signature` and `EnvironmentAbi`; other
common kinds remain invalid-extra semantic coverage. Both authority attachments were
updated before the next RED edit, as required when documentation conflicts with the
plugin architecture. This is design correction only, not a test or production GREEN.

### Task 2B-2 progress checkpoint split

The broad 2.4/2.5/2.5a gates hid completed evidence behind three unchecked mega-
items. Seven explicitly bounded execution checkpoints were added without weakening
or replacing the parent acceptance criteria. The mechanical ledger changed from
`8/59` to `12/66`: four new completed rows represent authority/rejection capture,
the exact repaired TypeSchema candidate plus independent-review launch, the
independently approved candidate transaction source slice, and the canonical
allocator repair plus Runtime relink. Three new open rows separately expose
TypeSchema approval, canonical approval/Automation and the unified publication
boundary.

After this split and all current record updates:

```text
openspec validate refactor-as-incremental-function-cache --strict --no-interactive
  PASS: Change 'refactor-as-incremental-function-cache' is valid

parent git diff --check
  exit 0 (line-ending conversion warnings only)

plugin git diff --check
  exit 0 (line-ending conversion warnings only)
```

### IC-067 explicit charge sink RED and compile/link GREEN

The ambient canonical allocation scope was first replaced in the Primitive RED by
an explicit per-call caller-owned capture view. The exact wrapper command was:

```powershell
$tu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheArchivePrimitiveTests.cpp').Path
& .\Tools\RunBuild.ps1 -Label ic067-explicit-capture-red `
  -TimeoutMs 600000 -NoXGE `
  -ExtraArgs @("-SingleFile=$tu", '-NoHotReloadFromIDE')
```

It failed as intended only because
`FAllocationEventCaptureView` and the two same-path `WithAllocationCaptureForTests`
facades did not exist:

```text
Saved/Build/ic067-explicit-capture-red/20260808_194302_866_3841ad31/
ProcessExitCode 6 / FinalExitCode 1
```

The GREEN introduced a private, constructor-required `FDecodedChargeSink` stored by
value in `FReader`. It contains only context/function pointers (plus an explicitly
passed observer in unit-test builds); retained and future candidate behavior are
adapters outside the semantic-blind codec. The old `thread_local` ambient observer
and scoped mutation API were removed. Explicit capture uses caller-owned fixed
storage, resets count/overflow for that call, saturates with visible overflow and
does not change decode behavior. A second caller view proves events cannot route to
an earlier buffer.

The first Runtime compile exposed IC-092, an ambiguity caused only by a broad private
namespace import:

```text
Saved/Build/ic067-semantic-records-tu/20260808_194615_645_e5fc4ca3/
ProcessExitCode 6 / FinalExitCode 1
```

After replacing it with exact type aliases, all three independent TUs passed:

```text
Saved/Build/ic067-semantic-records-tu-fix1/20260808_194640_615_aa47e2a7/
Saved/Build/ic067-primitive-tu-green/20260808_194651_770_dd40f521/
Saved/Build/ic067-budget-tu-green/20260808_194708_556_95f30fed/
ProcessExitCode 0 / FinalExitCode 0 for each
```

The Runtime module then rebuilt and linked both artifacts:

```text
Saved/Build/ic067-runtime-module-link/20260808_194741_485_59d86ad0/
[1/3] Compile Module.AngelscriptRuntime.27.cpp
[2/3] Link UnrealEditor-AngelscriptRuntime.lib
[3/3] Link UnrealEditor-AngelscriptRuntime.dll
ProcessExitCode 0 / FinalExitCode 0
```

Static audit at this checkpoint:

```text
canonical header TryConsumeRetainedDecoded matches: 0
ambient GCanonicalAllocationProbe/thread_local/scoped/RecordAllocationEvent matches: 0
canonical reader physical Reserve sites: 1
```

These are compile/link facts, not Automation GREEN. Primitive/Budget Automation and
the candidate adapter remain open until the unified decoded-record declaration gate
permits a complete Test module.

### IC-067 retained-side exact-SHA independent source approval

A separate read-only reviewer recomputed and reviewed the exact four-file set:

```text
AngelscriptCacheCanonicalCodec.h
  089424C6B089E040D5006E850BD63E374905A788968D51CAEF60F8B954FB2514
AngelscriptCacheSemanticRecords.h
  6E7989D6363B225406985687448978B18AD7AA8F5EBDA3A5E5F6F96A4A093A10
AngelscriptCacheSemanticRecords.cpp
  C15BD094CEC4D6D910DEC3575E85C8912928942951AB482D20E202CA2DBFBC05
AngelscriptCacheArchivePrimitiveTests.cpp
  41A810366545AC0170C8C225CAC7C88F991DCDC9E701BD16A1452AB01364D002
```

Verdict: **0 Critical / 0 Important / 0 Minor**. The reviewer made no edit, build,
Automation run, OpenSpec/Saved write or commit. It independently confirmed:

- the sink is constructor-required, stored by value and consists of a context plus
  bare function pointer; no `TFunction`, lambda erasure, TLS or global routing exists;
- the retained adapter is outside the canonical codec and every current reader site
  binds it explicitly, while the private codec contains no retained semantic call;
- there is exactly one physical `Reserve`, after allocator prediction and successful
  charge, with predicted-versus-actual fail-closed `Overflow` and no post-allocation
  budget correction;
- string/DataType public and captured facades call the same internal decoder;
- fixed caller storage safely covers ordinary inert calls, independent callers,
  saturation, zero capacity and positive-length null storage; and
- test observer types, members, adapters and facades are all excluded when
  `WITH_ANGELSCRIPT_UNITTESTS` is false, with synchronous non-escaping lifetimes.

This approves the retained-side source slice only. Candidate binding in the sole
seven-kind factory, final promotion/publication and focused Primitive/Budget
Automation remain open; no parent task is closed by this static review alone.

### Second repaired TypeSchema RED candidate

The author froze the second repair at:

```text
SHA-256: 12E890CA7C905D01839A5FE92DDAEBC59D672CC43836E880A975B83FF86090A1
bytes: 383981
LF terminators/logical lines: 8930 / 8930
final LF: yes
TEST_METHOD: 53 unique
TS-SCR: 53 total / 40 Required / 12 StreamingZero / 1 InvalidFixtureOnly
reference authority: 78 unique family/variant rows
TypeSchema Required dependency variants: 5
```

The author-side audit reported that the repair removed all `InjectedTestFailure` and
optional-style LayoutInput target uses, uses caller-owned fixed TypeSchema chronology,
makes Typedef subtype storage hostile-input-only, samples representative allocator
occurrences, replaces the DTO-derived reference oracle and explicitly includes the
decoded-record boundary. These are candidate claims only; the independent result
below supersedes the optional-target and performance claims.

### TypeSchema `12E890...` independent rereview — rejected

A fresh independent, read-only review reproduced the frozen identity exactly:

```text
SHA-256: 12E890CA7C905D01839A5FE92DDAEBC59D672CC43836E880A975B83FF86090A1
bytes: 383981
LF terminators/logical lines: 8930 / 8930
final LF: yes
TEST_METHOD: 53 unique / 0 duplicates
TS-SCR: 53 total / 40 Required / 12 StreamingZero / 1 InvalidFixtureOnly
reference authority: 78 unique rows / 0 duplicates
TypeSchema Required dependency variants: exact five
```

Verdict: **NEEDS FIXES — 1 Critical / 2 Important / 1 Minor**. The review made no
source/OpenSpec edit, build, test or `Saved/` write.

1. Critical / IC-088: `LayoutInputRolePresenceAndTargetMatrixIsComplete` still calls
   `Input.Target.Reset()` and models the direct required Target as an optional
   presence bit. Target must remain a direct stable reference; only Boundary and
   Alignment participate in the presence matrix, with direct zero-key/kind/ExpectedAbi
   negatives and a complete forbidden optional-access scan.
2. Important / IC-086: the one InvalidFixtureOnly hostile Typedef subtype row proves
   semantic rejection but not its exact allocation event, capacity, Total/live one-
   short behavior, ByteOffset or cleanup. It needs a dedicated physical hostile-
   fixture budget/chronology test and must never close Required coverage.
3. Important / IC-089: the new fixed filtered chronology view is caller-owned, but
   its indexed accessor linearly rescans for every complete-comparison element,
   restoring O(E^2). Replace the complete comparison with one forward scan and freeze
   representative fixture/target/per-SiteKind counts.
4. Minor: Required-coverage diagnostics still say `unlimited-common-factory`; the
   implemented gate is exact Total/live common-factory success.

No TypeSchema production GREEN, full Test build or Automation result is claimed. A
third exact-SHA repair and fresh independent `0 Critical / 0 Important` review remain
the gate.

### TypeSchema declaration/file-map preflight

A separate read-only inventory froze the exact TypeSchema declaration surface and
recommended the dependency direction:

```text
AngelscriptCacheSemanticRecords.h
  -> AngelscriptCacheTypeSchema.h
  -> AngelscriptCacheRemainingRecordTypes.h
  -> AngelscriptCacheDecodedRecord.h
```

TypeSchema owns only its enums, DTOs, layout/resolver contracts, coordinate and
archive/writer-trace surface. The decoded-record header owns the final complete seven-
alternative token and includes TypeSchema; TypeSchema must not include or define that
token. A temporary TypeSchema-only decoded class is forbidden because final record
size, captured-offset storage, `TVariant`, controller charge and `MakeShared` probe
depend on all seven complete alternatives.

This audit also exposed IC-093: the current RED wraps public `TryDecode` calls in a
scoped TypeSchema allocation probe even though neither call nor scope supplies an
explicit factory dependency. That contract can only work through forbidden ambient
TLS/global routing. The RED must instead call a unit-test-only explicit
`FAngelscriptDecodedCacheRecordTestAccess::TryDecodeWithProbe` façade which injects
the caller-owned probe into the same private internal factory. The façade may not
decode, validate, own or publish independently. This new finding is included in the
third-candidate repair and is not a production-GREEN implementation.

### Budget per-instance thread-affinity characterization

The Cache source baseline gained one small Budget test, bringing current source
definitions from 124 to 125. It proves that a fresh Budget is unbound, const reads do
not claim ownership, the first mutation (including zero bytes) binds to the caller,
and a separately constructed worker Budget binds to its worker without changing the
main Budget. It uses the existing Test friend and adds no production/test API.

The first single-file wrapper exposed IC-094, an unavailable CQTest matcher:

```text
Tools/RunBuild.ps1 -Label cache-budget-thread-affinity-tu ...
Saved/Build/cache-budget-thread-affinity-tu/20260808_200541_099_f20c1eb4/
AngelscriptCacheBudgetTests.cpp(782,3): error C2039: IsNotEqual
ProcessExitCode 6 / FinalExitCode 1
```

After replacing it with the existing boolean matcher, the same TU compiled:

```text
Tools/RunBuild.ps1 -Label cache-budget-thread-affinity-tu-fix1 ...
Saved/Build/cache-budget-thread-affinity-tu-fix1/20260808_200556_561_5574171d/
[1/1] Compile [x64] AngelscriptCacheBudgetTests.cpp
ProcessExitCode 0 / FinalExitCode 0
```

This is compile evidence only. The focused Budget Automation still waits for the
TypeSchema header gate so the complete Test module can link the new method.

### Independent monotonic Budget buckets — 2026-08-08

The Budget characterization shard now separately freezes the three non-decoded
monotonic buckets: stored bytes, decompressed bytes, and references/relocations.
Each bucket reaches its exact limit, accepts a zero-byte operation while full,
rejects a one-byte extension atomically, rejects a `MAX_uint64` arithmetic
overflow atomically, and leaves every unrelated counter unchanged. This adds no
production or test-only interface.

The repository-wrapper single-TU check passed:

```text
Tools/RunBuild.ps1 -Label cache-budget-independent-monotonic-tu ...
Saved/Build/cache-budget-independent-monotonic-tu/20260808_203041_866_8987c8bf/
[1/1] Compile [x64] AngelscriptCacheBudgetTests.cpp
ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 127 `TEST_METHOD` definitions, including 15 in
the Budget shard. Focused Automation remains pending the TypeSchema production
header gate; this evidence is compilation only.

The next Budget ownership case holds two decoded-candidate transactions open on the
same session Budget, promotes one and rolls the other back. It proves that promotion
reclassifies only the owning transaction's Temporary bytes, rollback releases only
its own live bytes, neither operation double-charges or refunds monotonic Total, and
the historical combined-live peak remains exact. The repository-wrapper single-TU
check passed:

```text
Tools/RunBuild.ps1 -Label cache-budget-overlapping-candidates-tu ...
Saved/Build/cache-budget-overlapping-candidates-tu/20260808_204259_355_6d318656/
[1/1] Compile [x64] AngelscriptCacheBudgetTests.cpp
ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 128 methods, including 16 Budget methods. This is
again compile evidence rather than an Automation-pass claim.

### Remaining-record declaration inventory and newly exposed RED gate

A read-only inventory extracted the exact wire-ordered ModuleState, FunctionBody,
DebugSidecar and ModuleSnapshot DTO/nested-enum surface, plus existing SourceIndex and
ModuleInterface coordinate authorities and physical-reader migration points. It made
no edit, build/test, `Saved` write or commit.

Confirmed complete authorities:

- SourceIndex captured enum `0..89`, typed `uint16`, with P/S/T rules through
  discovery options, mounts/options, providers, hooks, files, inputs, edges and
  ineligible scopes;
- ModuleInterface captured enum `0..88`, including declaration DataType preorder on
  Secondary, parameter DataType preorder on Tertiary, optional tag/value and nested
  metadata/slot rules;
- remaining record schema versions are all 1, and the wire/nested DTO field order is
  available for ModuleState, FunctionBody, DebugSidecar and ModuleSnapshot.

The inventory found IC-095: no repository source freezes the four remaining record
captured-field numeric domains or P/S/T rules despite the remaining-wire requirement
that corrected RED do so. Therefore final RemainingRecordTypes/DecodedRecord
declarations may not be claimed GREEN from guessed coordinates. A dedicated small RED
and normative four-table attachment are now task 2.4d.

It also found IC-096: FunctionBody member names conflict between normative wire and a
plan sketch, and several nested DTO public member/default shapes are not tested. The
selected RED direction is normative `FunctionSourceDigest`/`FunctionInputDigest`,
exact member-type/order traits, no invented defaults, `u64` byte payload encoding and
no manifest-only ModuleSnapshotLink in the record header.

Existing migration sites remain identified in `AngelscriptCacheSemanticRecords.cpp`:
SourceIndex readers around `2847..3008`, ModuleInterface/common nested readers around
`418..788`, `3387`, `3510` and `4013..4042`, and transitional public owners/wrappers
around `4801..4951`. These are file-map facts, not implementation claims.

### TypeSchema third-candidate authority preflight

SHA `1A806E00...28CAF3` (408,170 bytes, 9,467 LF logical lines, 54
unique methods) statically closes the prior direct-Target, hostile-Typedef,
explicit-probe and forward-chronology findings. It was not built or run because an
independent read-only preflight found IC-097 Important first: its 42/73 bounded
set is still selected after cartesian natural-candidate generation, so the literal
counts are post-hoc rather than source-explicit authority.

The next RED must freeze 45 named fixture rows and 73 named target rows, retain a
named 53-SiteKind coverage partition, eliminate runtime first-match/dedup selection,
and execute each fixture's full plan/chronology once. No TypeSchema GREEN,
compilation, Automation or approval is claimed for `1A806E...`.

### Canonical-string allocation-alias preflight

The primitive shard gained a two-direction test whose input view points into the
output object's own allocation. Both serialize and deserialize must return
`AliasedInputOutput`, clear output and, for decode, leave every Budget counter zero.
The production fix moved the archive address-range implementation to the shared
Runtime Private `AngelscriptCacheMemoryView.h` and performs overlap classification
before output mutation or reader/Budget work.

The exact single-TU wrapper evidence is:

```text
cache-canonical-string-alias-semantic-tu
  Saved/Build/cache-canonical-string-alias-semantic-tu/20260808_204855_203_9bf699cc/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-memory-view-archive-tu
  Saved/Build/cache-memory-view-archive-tu/20260808_204907_197_e790e732/
  failed: the initial extraction left two qualified references to the old private
  FAddressRange/TryGetViewRange names; ProcessExitCode 6 / FinalExitCode 1

cache-memory-view-archive-tu-fix1
  Saved/Build/cache-memory-view-archive-tu-fix1/20260808_204927_082_41f3a3af/
  [1/1] Compile [x64] AngelscriptCacheArchive.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-canonical-string-alias-test-tu
  Saved/Build/cache-canonical-string-alias-test-tu/20260808_204934_958_9a10d0b6/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The initial Archive failure was an extraction name-resolution error, not an alias
behavior result; importing the shared type/function names fixed it. The Cache source
baseline is now 129 methods, including 7 primitive methods. Focused Automation and
Runtime link evidence remain pending the TypeSchema header gate.

The same read-only gap audit recorded IC-098, IC-100 and IC-101 for late-failure
candidate ownership, allocator-authoritative eligibility result charging and removal
of reset/read global probes. Those are pending RED/implementation work rather than
passing claims.

The primitive late-failure ownership RED now covers an allocated canonical string
and a nested CanonicalDataType, each with trailing data after complete physical
decode. Both cases seed existing Retained and Temporary ownership and require empty
output, monotonic Total including accepted candidate charge, Resident/Temporary
restored exactly to the seeds, and a preserved historical peak. Its source compiles:

```text
Tools/RunBuild.ps1 -Label cache-primitive-late-failure-red-tu ...
Saved/Build/cache-primitive-late-failure-red-tu/20260808_205158_323_da41002f/
[1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
ProcessExitCode 0 / FinalExitCode 0
```

This is an intentional behavioral RED: current direct retained charge sinks cannot
satisfy the live-ownership assertions. It has not been executed while the complete
Test module is blocked, and no GREEN claim is made. The Cache source baseline is now
130 methods, including 8 primitive methods.

### Eligibility caller-owned bounded observation — 2026-08-08

The eligibility capacity seam no longer uses a process-global atomic reset/read
probe. The production entry and test-only facade call the same private query body;
the production call supplies no observer, while the test facade receives an
explicit caller-owned `TArrayView` over fixed POD event storage plus caller-owned
count/overflow fields. Observation cannot allocate and a full view only sets the
overflow flag.

The pre-existing multi-file allocator-capacity test now reads the primary and
auxiliary events from its own two-slot capture. A new test concurrently executes
zero-, one- and exact-two-slot captures and compares each with an unobserved
production call. It freezes identical success tuple, output scope, diagnostic and
all query-Budget counters, plus `0/overflow`, `1/overflow` and `2/no-overflow`
capture behavior. The old eligibility reset/read/global names have zero Runtime or
Cache-test references.

Repository-wrapper single-TU evidence:

```text
cache-eligibility-caller-capture-runtime-tu
  Saved/Build/cache-eligibility-caller-capture-runtime-tu/20260808_205857_582_c0fd5d98/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-eligibility-caller-capture-test-tu
  Saved/Build/cache-eligibility-caller-capture-test-tu/20260808_205903_869_974d562b/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-eligibility-caller-capture-concurrent-test-tu
  Saved/Build/cache-eligibility-caller-capture-concurrent-test-tu/20260808_210203_921_bbe0fa64/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

This is source-compilation evidence, not focused Automation or Shipping symbol
evidence. IC-101 remains partially open because the separate whole-record copy
counter still uses global state. Including the seven newly added remaining-record
coordinate RED methods, the current Cache source baseline is 138 definitions: 25
SourceInterface methods and 7 RemainingRecordCoordinates methods.

### Remaining-record coordinate/DTO declaration RED — 2026-08-08

The dedicated seven-method RED and its normative four-record coordinate attachment
are now present. The repository wrapper reaches exactly the intended first missing
production declaration and no test-local substitute type:

```text
Tools/RunBuild.ps1 -Label cache-remaining-coordinate-red-tu ...
Saved/Build/cache-remaining-coordinate-red-tu/20260808_210337_903_0eb9aa51/
[1/1] Compile [x64] AngelscriptCacheRemainingRecordCoordinateTests.cpp
fatal error C1083: cannot open include file:
  Cache/AngelscriptCacheRemainingRecordTypes.h
ProcessExitCode 6 / FinalExitCode 1
```

This is the expected compile RED, not production failure evidence and not GREEN.
The attachment SHA is
`96B86A359291A5947AD33E4DBF787613F67B792450C2B7D8475FD01DD63FD109`;
the test-TU SHA is
`AFA0DBDE0BC07A700777BDF4118073299EED41783891F01243BD5831D634A4F7`.
An independent exact-SHA review is active; task 2.4d remains unchecked until any
Critical/Important findings are repaired and the final SHA is re-reviewed.

### Eligibility published-result allocator ownership — 2026-08-08

The SourceInterface shard adds a RED whose one matching scope is selected so both
the result `TArray` and its diagnostic `FString` receive allocator slack beyond the
requested element/character counts. It compares Budget retained bytes with the
actual `GetAllocatedSize()` sum, freezes exact Total/combined-live success, and
requires each one-byte-short limit to fail with an allocation-free, empty output.
The test source compiled before the production change:

```text
cache-eligibility-result-capacity-red-tu
  Saved/Build/cache-eligibility-result-capacity-red-tu/20260808_210857_558_1278b483/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

Production now predicts the exact reserved capacity for the result array and every
owned diagnostic string, charges their sum as a Temporary decoded candidate while
query scratch remains live, constructs the result without intermediate growth,
checks the actual owned-byte sum and promotes exactly once. Any prediction mismatch
empties the output and releases only live Temporary ownership; monotonic Total is
not refunded. `FAngelscriptCacheExactFastPathEligibility::Reset()` now calls
`Empty()` so failure also releases a caller's stale output capacity.

Post-change source compilation:

```text
cache-eligibility-result-capacity-runtime-tu
  Saved/Build/cache-eligibility-result-capacity-runtime-tu/20260808_211003_501_50cba30d/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-eligibility-result-capacity-green-tu
  Saved/Build/cache-eligibility-result-capacity-green-tu/20260808_211008_732_56bf33ae/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

This remains TU compilation rather than behavioral Automation evidence. The Cache
source baseline is now 139 methods, including 26 SourceInterface methods.

### Removal of the SourceIndex process-global copy counter — 2026-08-08

The remaining IC-101 ambient state has been removed. `FAngelscriptCachedSourceIndex`
again uses its ordinary defaulted copy operations in every build; Runtime no longer
changes DTO copy semantics under `WITH_ANGELSCRIPT_UNITTESTS`, includes `<atomic>`
for this purpose, or exports reset/read copy-counter methods. The two old assertions
were replaced with production-contract evidence: the validated owner is non-copyable,
nothrow movable and exposes only a const record reference.

The new move test executes move construction and move assignment over an already
valid destination with a distinct SourceSnapshot. It proves authority replacement,
moved-from invalidation, successful query through the new owner, moved-from
`InvalidPresence`, released output capacity and zero Budget mutation.

```text
cache-remove-global-copy-counter-runtime-tu
  Saved/Build/cache-remove-global-copy-counter-runtime-tu/20260808_211333_161_5c065bfd/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-validated-token-move-test-tu
  Saved/Build/cache-validated-token-move-test-tu/20260808_211338_766_8b0e5e4e/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

This raises the Cache source baseline to 140 methods, including 27 SourceInterface
methods. IC-101 still needs focused Automation and a final non-test/Shipping symbol
scan before closure.

### Candidate-owned semantic reader charges — 2026-08-08

Canonical string, canonical DataType, SourceIndex and ModuleInterface allocation
charges now enter one aggregate decoded-candidate transaction as Temporary. Their
normal physical reader remains unchanged and receives a semantic-blind charge sink;
only after trailing-data and local/derived-hash validation succeeds does the caller
perform one promotion. Every failure path destroys the candidate, returns live
Resident/Temporary ownership to the caller's baseline and preserves monotonic Total
plus historical peak.

The SourceInterface shard adds one test covering SourceIndex and ModuleInterface
late derived-hash failures with independent retained and temporary seed ownership.
It requires exact error/RecordKind, invalid/empty output, Total growth, exact seed
restoration, a higher historical peak, and seed-reservation release without Total
refund. The earlier primitive trailing-data test exercises the same ownership rule
for allocated string and nested DataType.

```text
cache-candidate-charge-sink-runtime-tu
  Saved/Build/cache-candidate-charge-sink-runtime-tu/20260808_211711_683_69fe1dbb/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-candidate-charge-sink-primitive-tu
  Saved/Build/cache-candidate-charge-sink-primitive-tu/20260808_211723_280_1821a7a6/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-candidate-charge-sink-source-tu
  Saved/Build/cache-candidate-charge-sink-source-tu/20260808_211734_270_ee957d13/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-late-record-candidate-rollback-test-tu
  Saved/Build/cache-late-record-candidate-rollback-test-tu/20260808_211848_399_eeb4576c/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

This remains compile evidence while the complete Test module is gated. The Cache
source baseline is now 141 methods, including 28 SourceInterface methods. The
seven-kind decoded factory and final promotion/publication boundary remain task
2.5a.4 work.

### TypeSchema explicit-authority candidate review — 2026-08-08

The exact candidate `A91BC8D...2F0F48` (445,337 bytes, 10,210 LF, 54 unique
methods) was independently rejected at `2 Critical / 1 Important / 0 Minor` despite
successfully freezing named 53-site, 45-fixture and 73-target row counts and O(E+T)
target indexing. Its 38 slack fixtures still stored ranges and selected the first
allocator boundary through formulas; CanonicalPayload searched and reserialized;
hostile Typedef still discovered a boundary and inferred its plan position; and a
separate relocation test retained TSet/natural Family×Variant enumeration. The next
candidate must store literal resolved physical cardinalities/targets and use only
direct verification. No build, Automation or TypeSchema approval is claimed.

### Remaining-record independent RED review — 2026-08-08

The exact-SHA review of `96B86A...FD109` / `AFA0DB...34A4F7` returned
`0 Critical / 4 Important / 0 Minor`; the candidate is rejected and task 2.4d stays
open. Required repairs are: freeze exact DTO/coordinate member arity and declaration
order (including pointer-free/no extra members), cover wrong-kind/Invalid/
unpublished/set-zero/unused-and-OOB axes for all four coordinate types, replace the
caller-supplied optional-applicability boolean with a field-specific contract
matrix containing absent and present pairs, and prove independent DataType roots
restart preorder ordinal zero without cross-root leakage. No production header may
be implemented from the rejected candidate.
### RecordId domain separation and derived-output atomic reset — 2026-08-08

Two additional pure contract cases close high-value gaps without adding an
interface. The envelope shard builds empty and non-empty payload IDs for all seven
record kinds, proves every pair has a distinct full domain-separated hash, and
freezes cross-kind ordering by numeric Kind before hash ordering. Same-kind IDs then
prove the complete 256-bit ContentHash controls ordering.

The SourceInterface shard preloads every derived output with nonzero sentinels and
injects a precise Invalid declaration/provider enum. It requires
`ComputeDeclarationHashes` to clear both hashes atomically and requires
`ComputeSourceSnapshot`/`ComputeModuleInterfaceAbi` to clear their outputs on the
same exact `UnknownEnumValue` failure.

```text
cache-recordid-all-kind-domain-test-tu
  Saved/Build/cache-recordid-all-kind-domain-test-tu/20260808_212012_319_71371c74/
  [1/1] Compile [x64] AngelscriptCacheArchiveEnvelopeTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-derived-output-atomic-reset-test-tu
  Saved/Build/cache-derived-output-atomic-reset-test-tu/20260808_212101_092_dbcd148e/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 143 methods: 16 Envelope and 29 SourceInterface.
These are compiled source contracts; focused Automation still waits for the
declaration RED gates.

### Concurrent canonical capture isolation and rollback expectation repair

A new primitive case concurrently decodes an allocated canonical string and a
nested DataType on worker threads, each with its own Budget and fixed caller-owned
event array. The string capture contains only `StringCharacters` events, the type
capture only `TypedArrayElements`; both return exact values, promoted retained bytes
and zero Temporary ownership without cross-events or overflow.

Moving the current readers to aggregate candidates also changed the correct
one-short nested-array expectation: the first accepted allocation remains in
monotonic Total and historical peak, but Resident and Temporary both return to zero
when the later allocation is rejected. The older partial-retained assertions were
updated accordingly.

```text
cache-concurrent-canonical-capture-test-tu
  Saved/Build/cache-concurrent-canonical-capture-test-tu/20260808_212332_041_c8c59dc9/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-candidate-rollback-expectations-test-tu
  Saved/Build/cache-candidate-rollback-expectations-test-tu/20260808_212421_961_2bbf714f/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 144 methods, including 9 primitive methods.

### Progressive OpenSpec and scoped diff integrity check

```text
openspec validate refactor-as-incremental-function-cache --strict
  Change 'refactor-as-incremental-function-cache' is valid

openspec diff-check refactor-as-incremental-function-cache
  error: unknown command 'diff-check'

git diff --check
git -C Plugins/Angelscript diff --check
  no whitespace errors
```

The unsupported CLI assumption is IC-102. Parent Git emitted LF/CRLF checkout
warnings for existing tracked worktree files, but neither scoped diff check emitted
a whitespace defect.

### Runtime module link after candidate/eligibility integration

The repository wrapper can build only `AngelscriptRuntime`, avoiding the intentionally
missing Test-module declaration RED headers while still compiling unity consumers
and linking the actual Runtime library/DLL:

```text
Tools/RunBuild.ps1 -Label cache-candidate-runtime-module-link \
  -ExtraArgs @('-Module=AngelscriptRuntime', '-NoHotReloadFromIDE')
Saved/Build/cache-candidate-runtime-module-link/20260808_212601_526_3ebd3873/
[1/4] Compile Module.AngelscriptRuntime.27.cpp
[2/4] Compile Module.AngelscriptRuntime.11.cpp
[3/4] Link UnrealEditor-AngelscriptRuntime.lib
[4/4] Link UnrealEditor-AngelscriptRuntime.dll
ProcessExitCode 0 / FinalExitCode 0
```

This upgrades the candidate/eligibility evidence from isolated Runtime TU
compilation to Development Editor Runtime-module link success. It still does not
execute the focused behavioral tests.

### Eligibility dual-slack guard and repaired remaining-record RED — 2026-08-08

The allocator-authoritative eligibility result test now selects both a diagnostic
`FString` length and a matching-scope count whose Unreal reserve capacities exceed
their logical lengths. It has explicit assertion-following early returns so a
future allocator-policy change cannot make the fixture continue into unsafe array
construction after the contract failure. The source recompiles through the wrapper:

```text
cache-eligibility-result-dual-slack-test-tu
  Saved/Build/cache-eligibility-result-dual-slack-test-tu/20260808_212913_428_cd491965/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The repaired remaining-record authority is frozen at
`C5843B0F...C1047D9B` (normative attachment) and
`FC152683...38F857F` (test TU, 9 methods). Its wrapper compile is the intended RED:

```text
cache-remaining-coordinate-frozen-red2-tu
  Saved/Build/cache-remaining-coordinate-frozen-red2-tu/20260808_212947_811_f12da1d7/
  [1/1] Compile [x64] AngelscriptCacheRemainingRecordCoordinateTests.cpp
  fatal error C1083: cannot open include file:
    Cache/AngelscriptCacheRemainingRecordTypes.h
  ProcessExitCode 6 / FinalExitCode 1
```

No production substitute declaration exists, and compilation reaches no secondary
error. The source baseline is now 146 methods. This remains source RED evidence,
not an Automation pass; exact-SHA independent review is in progress before the
declaration GREEN gate opens.

### Envelope aliasing includes unused allocation capacity — 2026-08-08

The envelope contract now constructs valid non-empty input views wholly inside the
unused capacity, but outside the logical elements, of the serializer output and
deserializer payload output. Both paths must reject `AliasedInputOutput`, atomically
clear the output and leave every decoded/live Budget counter zero before `Reset()`
can invalidate the input memory. This specifically guards against comparing a view
only with `Num()` instead of the complete owned allocation.

```text
cache-envelope-capacity-alias-test-tu
  Saved/Build/cache-envelope-capacity-alias-test-tu/20260808_213244_913_0613112f/
  [1/1] Compile [x64] AngelscriptCacheArchiveEnvelopeTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 147 methods, including 17 envelope methods. This
is a compiled source contract; focused behavioral Automation remains gated by the
intentionally absent final record declaration headers.

The same allocation-capacity boundary is now frozen independently for canonical
string serialization (`FStringView` into unused `TArray<uint8>` capacity) and
deserialization (canonical bytes inside unused `FString` character capacity). Both
paths return `AliasedInputOutput`, clear their output and leave all live/decoded
Budget counters at zero:

```text
cache-canonical-capacity-alias-test-tu
  Saved/Build/cache-canonical-capacity-alias-test-tu/20260808_213435_986_00623058/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 148 methods, including 10 primitive methods.

The shared address-range preflight is additionally exercised with a deliberately
non-dereferenceable view whose `pointer + size` would wrap `UPTRINT`. Serializer and
deserializer both reject it as `InvalidArrayView`, clear output and leave Budget
untouched before inspecting a byte:

```text
cache-envelope-address-overflow-test-tu
  Saved/Build/cache-envelope-address-overflow-test-tu/20260808_213547_270_c5c3c064/
  [1/1] Compile [x64] AngelscriptCacheArchiveEnvelopeTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 149 methods, including 18 envelope methods.

### Canonical DataType recursively guards previous output allocations — 2026-08-08

The new primitive case stores a valid canonical DataType byte stream inside unused
capacity of both the root `OrderedSubTypes` array and a child's nested
`OrderedSubTypes` array. The first test compile exposed only a missing private
fixture qualifier; after that correction the RED source compiled. Production now
uses the shared allocation-range implementation for any `TArray<Element,
Allocator>` and recursively checks the actual previous DataType graph before
clearing output.

```text
cache-datatype-recursive-alias-red-tu
  AngelscriptCacheArchivePrimitiveTests.cpp(744): MakeInt32Type not found
  ProcessExitCode 6 / FinalExitCode 1

cache-datatype-recursive-alias-red-tu-fix1
  Saved/Build/cache-datatype-recursive-alias-red-tu-fix1/20260808_214011_755_2c3cca1e/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-datatype-recursive-alias-runtime-tu
  AngelscriptCacheMemoryView.h: no TryGetAllocationRange overload for
    TArray<FAngelscriptCachedDataType>
  ProcessExitCode 6 / FinalExitCode 1

cache-datatype-recursive-alias-runtime-tu-fix1
  Saved/Build/cache-datatype-recursive-alias-runtime-tu-fix1/20260808_214119_714_1520cfaf/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-datatype-recursive-alias-green-tu
  Saved/Build/cache-datatype-recursive-alias-green-tu/20260808_214128_845_23e04795/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-datatype-recursive-alias-runtime-link
  Saved/Build/cache-datatype-recursive-alias-runtime-link/20260808_214153_834_7bfa3fd5/
  Runtime compile + lib/DLL link, ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 150 methods, including 11 primitive methods.
Behavioral Automation is still pending because the complete Test module is
intentionally held RED by missing final record headers.

The first candidate/eligibility exact-SHA review was deliberately discarded when
its mid-review rehash detected the two files changed for this slice. It produced no
approval or usable findings; a new freeze/review is required after the source stops
moving.

### Remaining-record repaired RED exact-SHA review — 2026-08-08

The independent review revalidated both frozen hashes before and after inspection,
made no edits and performed no build. It rejected
`C5843B0F...C1047D9B` / `FC152683...38F857F` at
`0 Critical / 3 Important / 1 Minor`:

1. exact structured-binding arity and a separate named-member type list do not bind
   a repeated-type declaration position to a specific name; two `FString`, `uint32`
   or `FAngelscriptCachedModuleRecordLink` members can still swap wire positions;
2. the one-argument lookup surface is present, but a forbidden additional
   `FindCapturedOffset(Coordinate, bool)` overload is not mechanically rejected;
3. optional authority is keyed only by field family, so mixed present/absent rows
   and DataType nodes plus one-hot cross-family rejection are not expressible;
4. `remaining-record-declaration-inventory.md` still says the four coordinate
   tables have no authority, contrary to the new normative attachment.

The enum/table counts, P/S/T partitions, declaration-first failure matrices,
root-specific preorder bounds, recursive pointer rejection, digest names and
manifest-link exclusion all passed review. The RED has been returned for a fourth
repair. No remaining-record declaration GREEN or approval is claimed.

### TypeSchema fourth literal-authority candidate — 2026-08-08

The repaired TypeSchema RED is frozen at
`548D029EA94A9C3F20FBB035B0DF0CB5974AB46E0A19C0D5E3A35949BB71B9F1`
(447,211 bytes, 10,244 LF lines, 54 methods). The author-side read-only checks report:

- 53 explicit sites partitioned 40 Required / 12 StreamingZero / 1
  InvalidFixtureOnly;
- 45 explicit representative fixtures (3 shape / 4 occurrence / 38 slack) and 73
  unique targets;
- literal final cardinality/request/padding values for every slack fixture, with one
  official serialization per fixture and no runtime selection;
- hostile Typedef `RequestedSubTypes=2`, occurrence 6 and direct target/successor
  coordinates;
- 78 explicit relocation rows (63 reference-bearing / 15 None), compile-time unique
  and processed linearly;
- zero remaining search, min/max, first-match, TSet, natural variant enumeration,
  `continue` or extra authority-serialization patterns.

`clang-format --dry-run` returned 0 and no parse-like diagnostic was found. No build
or Automation has run, and this is not self-approval. Fresh independent exact-SHA
review remains the declaration gate.

### Remaining-record fourth exact-occurrence candidate — 2026-08-08

The repaired three-file RED is frozen at:

- coordinate authority: `B65D52F3...4117BFDE` (542 lines);
- declaration inventory: `181544F5...4EF363E` (292 lines);
- test TU: `55A7BB81...23B55A8F` (2,352 lines, 11 methods).

It now maps unique aggregate-position sentinels back through every named member of
all 15 DTOs, rejects a caller Boolean lookup overload for each coordinate type, and
models optional applicability as exact `{family, Primary, Secondary/root-node}`
occurrences. Seven repeatable families each carry distinct present/absent rows;
Global and HardValue DataType roots use distinct row/node identities; every
controlled field runs own, same-family-other and each unrelated one-hot tag, while
presence fields remain queryable in every state. The declaration inventory now
recognizes the four normative coordinate authorities.

The wrapper reproduces the intended declaration RED with no secondary diagnostic:

```text
cache-remaining-coordinate-frozen-red3-tu
  Saved/Build/cache-remaining-coordinate-frozen-red3-tu/20260808_215209_858_6f3b69f7/
  fatal error C1083: cannot open include file:
    Cache/AngelscriptCacheRemainingRecordTypes.h
  ProcessExitCode 6 / FinalExitCode 1
```

The Cache source baseline is now 152 methods. This is not approval or a passing
test count; independent exact-SHA 0C/0I review is still required.

### Candidate/eligibility review closure slice — 2026-08-08

The fresh seven-file exact-SHA review completed with `0 Critical / 3 Important /
2 Minor`. It approved candidate rollback/promotion, shared private charge routing,
actual eligibility result ownership, caller-owned observers, alias-capacity ranges
and non-test guards, but rejected three remaining points. All three were converted
to focused source contracts and production/test corrections:

1. previous DataType output scanning is bounded by the caller limit capped at depth
   64 and cumulative `MaxArrayElements`, with one checked input range and local
   ownership preserving any aliased input allocation;
2. eligibility scratch starts at zero and includes only actual allocator reserve
   capacities, with no ownerless 256-byte estimate;
3. string and two-allocation recursive DataType observation now compare the full
   result tuple, output and all Budget getters across absent/zero/undersized/exact
   captures.

Repository-wrapper compile evidence:

```text
cache-bounded-datatype-alias-runtime-tu
  Saved/Build/cache-bounded-datatype-alias-runtime-tu/20260808_220602_848_ea9305a3/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-bounded-datatype-alias-primitive-tu
  Saved/Build/cache-bounded-datatype-alias-primitive-tu/20260808_220614_681_057f6c89/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-eligibility-no-phantom-scratch-tu
  Saved/Build/cache-eligibility-no-phantom-scratch-tu/20260808_220633_242_428fb9f2/
  [1/1] Compile [x64] AngelscriptCacheSourceInterfaceTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The first observer-equivalence TU failed only because CQTest's assertion macro uses
a no-value early return inside value-returning fixture lambdas:

```text
cache-canonical-observer-parity-tu
  Saved/Build/cache-canonical-observer-parity-tu/20260808_220852_228_7ab78514/
  C3487/C2562: inconsistent void/value lambda return
  ProcessExitCode 6 / FinalExitCode 1
```

Moving the impossible fixture-seed report to `TestRunner->AddError`, without
changing the parity assertions, produced the focused compile GREEN:

```text
cache-canonical-observer-parity-tu-fix1
  Saved/Build/cache-canonical-observer-parity-tu-fix1/20260808_220917_464_952f02a5/
  [1/1] Compile [x64] AngelscriptCacheArchivePrimitiveTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The Cache source baseline is now 154 methods, including 13 primitive methods. These
are compiled source contracts, not executed Automation results.

### TypeSchema declaration-first RED approved — 2026-08-08

The fourth exact-SHA independent review found one hidden compile problem: two
filtered overflow-checkpoint views were accessed with `operator[]` even though the
restricted view intentionally exposes only constant lookup. Both sites were changed
to `FindAtForConstantLookup(0)` after their exact-count assertions.

The repaired source is frozen at:

```text
SHA-256  60BE380E68EE0E6083F153C69FAD59952C51C84CF9C0A43FBAAE325EEF3C4EB0
Bytes    447273
LF       10246
Methods  54, all unique
```

A fresh independent read-only review checked the SHA at start, middle and end and
returned **0 Critical / 0 Important / 0 Minor — approved**. The 53 sites, 45
fixtures, 73 targets, 78 relocation-authority rows, five dependency variants,
captured coordinates, hostile Typedef, candidate chronology and caller-owned probe
gates all remained intact. This approval opens TypeSchema production declaration
work; it does not claim the intentionally absent header, build or Automation is
already GREEN.

### Remaining-record fourth RED review — 2026-08-08

The three frozen files remained byte-identical throughout independent review, but
the candidate was rejected at **0 Critical / 2 Important / 0 Minor**:

1. each two-dimensional optional family changed Primary and Secondary together, so
   an implementation ignoring either one axis could still pass; the fifth repair
   must freeze same-Primary/different-Secondary and different-Primary/same-Secondary
   one-hot cases independently;
2. the Boolean-overload negative concept covered only a const receiver plus const
   coordinate lvalue, so mutable-lvalue, rvalue and non-const receiver overloads
   were not mechanically forbidden.

All DTO member-position sentinels, enum/count tables, coordinate ranges, root-local
DataType preorder, pointer-free owning traits, exact digest names and record-only
ModuleSnapshot shape passed. The production header remains intentionally absent. A
fifth RED repair is in progress and will require a new exact-SHA independent 0C/0I
review before declaration GREEN.

The fifth author candidate is now frozen without creating the production header:

```text
remaining-record-captured-offsets-v1.md
  SHA-256 8A0F30ACB8A4FBD226F5ADBAA69BB9C302C7A2EB9AAA2AD5A705B38E097F7EA3
  25247 bytes / 552 LF
remaining-record-declaration-inventory.md
  SHA-256 181544F584EE359644C6252E6E3F05685EA89541B7AFAFCF1B29C05D04EF363E
  10176 bytes / 292 LF
AngelscriptCacheRemainingRecordCoordinateTests.cpp
  SHA-256 9A91DB079C0E698BB99A6813D8C7587E01E61AE82E5FD035342EB0A90949F67F
  117362 bytes / 2493 LF / 11 methods
```

It adds A=`{0,0}`, B=`{0,1}`, C=`{1,0}` authority for each of the
three two-axis families and six Boolean-overload negative call shapes for each of
the four coordinate types. Author static checks report 9/9 exact two-axis identity
rows, three matrices, 24 prohibited Boolean call forms, 18 optional representatives,
zero trailing whitespace/NUL and balanced raw braces. This is not self-approval;
fresh exact-SHA independent review is in progress.

The independent reviewer rehashed all three fifth-candidate files at start, middle
and end and returned **APPROVED — 0 Critical / 0 Important / 0 Minor**. It confirmed
all nine A/B/C two-axis identities, three complete axis-isolation matrices, 24
Boolean-overload negative call shapes, the 89/28/12/25 captured-field ranges,
P/S/T failure coverage, four independent DataType roots, all 15 DTOs/72 named
member positions, recursive pointer-free ownership, exact FunctionBody digest names
and six-member record-only ModuleSnapshot shape. This exact candidate is now the
remaining-record production-header authority; it does not claim that header,
decoder, factory build or Automation is already GREEN.

### Remaining-record production declaration boundary — 2026-08-08

The independently approved declaration authority was implemented in
`Cache/AngelscriptCacheRemainingRecordTypes.h` without changing the three frozen
RED files. Static declaration checks found all thirteen enums with the expected
underlying types and continuous ranges:

```text
uint8 persisted/support enums  9
uint16 captured-field enums    4 (89 / 28 / 12 / 25 values)
coordinate aggregates          4
wire-ordered owning DTOs       15
exported aggregate structs     19 total
SHA-256                         2832DFDD01890B01473D8C9370CB167FF5386562C9D69275D9A8808374978FB0
Bytes / LF                     12055 / 437
trailing whitespace / NUL      0 / 0
```

The required repository-wrapper command was:

```powershell
$tu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheRemainingRecordCoordinateTests.cpp').Path
& .\Tools\RunBuild.ps1 -Label cache-remaining-record-header-green-tu `
  -TimeoutMs 600000 -NoXGE `
  -ExtraArgs @("-SingleFile=$tu", '-NoHotReloadFromIDE')
```

It proved that the former first RED blocker moved from the remaining declaration
header to the separately owned shared decoded-record boundary:

```text
Saved/Build/cache-remaining-record-header-green-tu/20260808_222906_937_bd23bdea/
AngelscriptCacheRemainingRecordCoordinateTests.cpp(2,1): fatal error C1083
  Cache/AngelscriptCacheDecodedRecord.h: No such file or directory
ProcessExitCode 6 / FinalExitCode 1
```

No decoded-record substitute or test-only lookup implementation was introduced.
Because preprocessing stops at the second include, this is declaration progress and
an exact integration boundary, not a focused-TU compile GREEN or Automation result.

An independent static comparison of the header declarations against the frozen test
source found all nine `uint8` enum name/value maps exact, all four captured-field
enums continuous through `88/27/11/24`, all nineteen approved exported aggregate
names present, and zero missing required member-name sentinels. Post-record update:

```text
openspec validate refactor-as-incremental-function-cache --strict --no-interactive
Change 'refactor-as-incremental-function-cache' is valid
```

### Remaining-record complete TU compile repair — 2026-08-08

Once the shared decoded-record header existed, the same repository-wrapper compile
reached the complete remaining-coordinate test body. Its first run failed only on
the project warnings-as-errors name-shadowing rule:

```text
cache-remaining-record-shared-boundary-tu2
  Saved/Build/cache-remaining-record-shared-boundary-tu2/20260808_223706_140_775f379d/
  C4458: local DebugSidecarFields hides the class-level authority table
  ProcessExitCode 6 / FinalExitCode 1
```

The local variable alone was renamed to `FunctionDebugSidecarFields`. No assertion,
field value, occurrence identity or normative attachment changed. The identical
single-file wrapper command then compiled GREEN:

```text
cache-remaining-record-shared-boundary-tu3
  Saved/Build/cache-remaining-record-shared-boundary-tu3/20260808_223739_408_99d2ad1a/
  [1/1] Compile [x64] AngelscriptCacheRemainingRecordCoordinateTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The compile-repaired source candidate is
`77C56BC6D8264A7BC93EF4BF7830CDBE36BCB383CC6ECF8C7339F23E0655CEE0`
(117,378 bytes / 2,493 LF / 11 methods / final LF). Because the previous approval
was exact-SHA, checkpoint 2.4d is reopened until a fresh independent rereview of
this candidate returns zero Critical and zero Important.

Fresh exact-SHA rereview subsequently approved the repaired candidate at **0C / 0I /
0M**. The reviewer rehashed `77C56BC...5CEE0` at start, middle and end, verified no
drift, and proved that replacing exactly the two local
`FunctionDebugSidecarFields` occurrences with the former name reconstructs the
previously approved `9A91DB07...49F67F` byte stream. All A/B/C two-axis matrices,
24 prohibited Boolean call forms, 89/28/12/25 enum ranges, P/S/T rules, four
DataType roots, 15 DTO/72 member positions, owned value semantics, digest names and
six-member ModuleSnapshot shape remain unchanged. Checkpoint 2.4d is therefore
closed on the compile-GREEN repaired SHA.

### Shared decoded-record declaration independent review — 2026-08-08

A read-only review compared the stable production headers against
`record-wire-v1-remaining.md`, `source-interface-captured-offsets-v1.md` and the
approved Remaining-record declarations. Result: **3 Critical / 2 Important / 0
Minor; not approved for complete seven-kind factory GREEN**.

The three Critical findings are structural rather than formatting defects:

1. the token's `TUniquePtr` storage is a forbidden second persistent heap
   allocation and excludes actual storage from controller-size measurement;
2. the variant alternatives are bare DTOs instead of seven per-kind aggregates
   that each own their complete decoder-captured offset table; and
3. SourceIndex/ModuleInterface publish two-value placeholder field enums instead
   of their approved 90/89-value coordinate authorities.

The Important migration finding is that the existing public SourceIndex and
ModuleInterface owning decoders still compete with the declared sole factory.
They may remain only while consumers are actively migrated and must be deleted
before the sole-boundary task can close. The second Important item is the expected
exact-SHA rereview gate for the IC-118 test-only rename.

The reviewed production headers stayed byte-stable throughout the review. The
next implementation step is therefore a declaration-shape correction, not a
partial decoder implementation or token-size freeze.

### TypeSchema complete-TU syntax repair frontier — 2026-08-08

The first complete TypeSchema compile made the distinction between source review
and project compilation explicit. Compile-only test repairs preserved all 54 test
methods and every authority row while correcting constexpr placement, case scope,
CQTest context dispatch, a value-returning fixture lambda, two unmatched
parentheses and three restricted-view lookups. The TU-local assertion dispatcher
retains the original matcher and early return, records the existing second context
only on failure, is a single safe statement in both forms and is undefined before
the end of the file.

Repository-wrapper evidence:

```text
cache-typeschema-production-declaration-tu5
  Saved/Build/cache-typeschema-production-declaration-tu5/20260808_224537_593_b55f6465/
  all prior test parser/macro errors absent
  first remaining error: FAngelscriptCacheStableReference lacks operator==
  test instantiation: TArray::Contains at line 6743
  ProcessExitCode 6 / FinalExitCode 1
```

The new candidate is
`431F0B494C3ADB738C08D815E59983D353E89C72BEDCCD673BA2677A0E393DF0`
(448,518 bytes / 10,282 LF / 54 methods / final LF). It has advanced from test
syntax into a real production declaration RED, but exact-SHA approval does not
transfer from `60BE380E...4EB0`; checkpoint 2.4c is reopened for fresh review.

Two narrowly scoped production value comparisons closed the remaining declaration
compile frontier:

```text
cache-typeschema-production-declaration-tu6
  Saved/Build/cache-typeschema-production-declaration-tu6/20260808_224651_938_e76a2820/
  first error: FAngelscriptCacheSemanticDependency lacks operator==
  ProcessExitCode 6 / FinalExitCode 1

cache-typeschema-production-declaration-tu7
  Saved/Build/cache-typeschema-production-declaration-tu7/20260808_224717_175_0cf54459/
  [1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

`FAngelscriptCacheStableReference` equality is same-type and exact over Kind,
StableKey and ExpectedAbi. `FAngelscriptCacheSemanticDependency` additionally
compares dependency Kind plus exact optional presence/value. TU7 is complete
single-file compilation evidence only; production codec/link and Automation remain
open, and the candidate still requires fresh exact-SHA source approval.

Independent review preserved every 53/45/73/78/5 authority and all 652 dispatcher
assertions but found one Unity preprocessor-state leak: the local macro was removed
without restoring CQTest's upstream `ASSERT_THAT`. The test now uses
`push_macro/pop_macro` and a post-restore compile guard. The new exact candidate is
`F0BDD6169DE49443874F53BC4E42A5AB16E03D355044603297092B2A71C10F47`
(448,700 bytes / 10,288 LF / 54 methods / final LF).

```text
cache-typeschema-unity-macro-restore-tu12
  Saved/Build/cache-typeschema-unity-macro-restore-tu12/20260808_230421_737_ca81f505/
  [1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The push/pop repair changes only macro lifetime around this source. Exact-SHA review
must still approve the new byte stream before checkpoint 2.4c recloses.

Fresh exact-SHA rereview approved `F0BDD616...10F47` at **0C / 0I / 0M**. The
reviewer proved by exact reverse transformation that the only difference from the
previous compile-repaired source is the 182-byte/6-LF macro lifetime fix, verified
592 single-argument and 60 contextual assertions, and reconfirmed every
53/45/73/78/5 authority partition. TU12 plus the post-pop compile guard closes the
Unity macro finding and reopens production TypeSchema/decoded-factory GREEN work.

### C++-private decoded-token repair compile contracts — 2026-08-08

The namespace-scope implementation-detail variant was moved into the token's true
C++ `private:` section. A precisely friended, empty codec bridge is the only
non-member allowed to name the nested TypeSchema offset storage. The declaration
and private-header compile frontiers both pass:

```text
cache-typeschema-private-token-declaration-tu10
  Saved/Build/cache-typeschema-private-token-declaration-tu10/20260808_230242_455_0741848b/
  [1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-decoded-record-private-compile-contract-tu11
  Saved/Build/cache-decoded-record-private-compile-contract-tu11/20260808_230329_220_4c7b84d9/
  [1/1] Compile [x64] AngelscriptCacheDecodedRecordDeclarationTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The new one-method compile-contract source is SHA-256
`0836FD58BCBCEDFEB8DA31A8377C289247358F908A7BA958AEEF376833D944FD`
(1,673 bytes / 52 LF / final LF). Its negative requirements prove external code
cannot name the private variant, TypeSchema offset storage or SourceIndex
alternative; it also verifies the codec bridge is empty and the token remains
non-default/copy/move constructible. This is compile evidence, not Automation.

Fresh independent rereview approved the private-shape repair source set at **0C /
0I / 0M**. The reviewer rehashed both headers at start, middle and end, confirmed
the only codec access is the exact empty friend bridge, found no pimpl/second
variant/second owner/stale deleted-header reference, and validated TU10/TU11. This
approves the final token declaration architecture without claiming its not-yet-
implemented codec/factory is linked or behaviorally GREEN.

### Decoded-token accessor implementation frontier — 2026-08-08

The first real `AngelscriptCacheDecodedRecord.cpp` production slice implements the
constructor/destructor, seven typed const getters and seven exact P/S/T coordinate
lookups against the approved private by-value variant. TypeSchema uses stack-only
views over its twelve frozen offset groups and stops on the first match; every
wrong-kind lookup is null/unset and no lookup allocates.

```text
cache-decoded-record-accessor-tu13-fix1
  Saved/Build/cache-decoded-record-accessor-tu13-fix1/20260808_232017_351_060c690c/
  [1/1] Compile [x64] AngelscriptCacheDecodedRecord.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

Source SHA-256 is
`1EC8330F81068CB64CEB1BC59CD06AF5F029C16F9A0FF389C2C9B878703A25E2`
(5,940 bytes / 176 LF / final LF). The factory/controller/decoder/publication and
graph functions remain open, so this is compile evidence only.

### TypeSchema pure-producer implementation frontier — 2026-08-08

`Cache/AngelscriptCacheTypeSchema.cpp` now has the first production producer
implementation for the frozen V1 surface:

- versioned primitive/ObjectHandle layout constants;
- full-width dependency and canonical UTF-8 metadata comparators;
- canonical LayoutInput, storage-layout, property-layout, enum-authority and final
  type-layout hash streams using `FAngelscriptArtifactCanonicalWriter`;
- non-mutating canonicalization of set-like metadata/dependencies and stable
  relation/layout-input kind sections before TypeSchema payload emission;
- inactive-arm, common value and derived-hash fail-closed producer checks with
  atomic empty output; and
- one canonical wire writer plus a `WITH_ANGELSCRIPT_UNITTESTS`-guarded bounded
  physical trace over the completed bytes. The trace owns no DTO decoder,
  publication path, Budget, probe or global state.

The first real TU compile found and rejected an invalid test-field enum use:

```text
typeschema-producer-green-tu1b
  Saved/Build/typeschema-producer-green-tu1b/20260808_232206_119_d1591bfc/
  AngelscriptCacheTypeSchema.cpp(524): C2838/C2664
  ProcessExitCode 6 / FinalExitCode 1
```

After repair and producer/trace completion, both required repository-wrapper
SingleFile frontiers compile:

```text
typeschema-producer-final-tu5
  Saved/Build/typeschema-producer-final-tu5/20260808_233133_329_eec67dba/
  [1/1] Compile [x64] AngelscriptCacheTypeSchema.cpp
  ProcessExitCode 0 / FinalExitCode 0

typeschema-producer-test-tu2
  Saved/Build/typeschema-producer-test-tu2/20260808_232752_965_6f77aa45/
  [1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The producer source candidate is SHA-256
`DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`
(56,909 bytes / 1,702 LF / final LF). This is a compile frontier only. The payload,
hash and exact trace goldens still require focused Automation after the sibling
decoded factory is linkable; no decoder, token publication, probe or graph behavior
is claimed by this slice.

### Sole decoded-record factory kernel compile frontier — 2026-08-08

`Cache/AngelscriptCacheDecodedRecord.cpp` now implements the first common factory
kernel around the final seven-alternative private token shape. It preserves an old
output handle while validating/copying a potentially aliased input view, resets the
caller output atomically, validates the RecordId and payload limit before decoded
allocation, owns one private candidate transaction, charges the final intrusive
controller and token-owned canonical-payload capacity before allocation, verifies
the payload allocator result, selects the exact active variant and promotes once
before publication. The public path passes no observer; the guarded test façade
forwards an explicit caller-owned fixed probe into the same private function.

The kernel does not call the transitional public SourceIndex/ModuleInterface
deserializers. Only the TypeSchema private bridge call is present; that bridge and
the six other private codec integrations still have to link and pass behavior, so
this result does not close the sole-factory or unified boundary tasks.

```text
cache-decoded-factory-kernel-tu14
  Saved/Build/cache-decoded-factory-kernel-tu14/20260808_233828_342_541d6eb1/
  [1/1] Compile [x64] AngelscriptCacheDecodedRecord.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

Source SHA-256 is
`53BE02F60D7EDC9123402D66ECF417569A5F328A105E808FFD07B2455EC04EC4`
(20,112 bytes / 629 LF / final LF). Plugin `git diff --check` passes apart from
pre-existing line-ending warnings in tracked Build/validation files. A focused
source scan reports zero legacy `DeserializeSourceIndex`/
`DeserializeModuleInterface`, `MakeShareable`, direct token `new`, `thread_local`
or ambient/global probe references in the factory source.

### TypeSchema producer independent exact-SHA review — 2026-08-08

An independent read-only review recomputed producer SHA
`DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`
(56,909 bytes / 1,702 LF) at start, middle and end and audited TU5/TU2 metadata.
The five canonical domain strings/field streams, TypeSchema wire order,
non-mutating set canonicalization, stored-derived-hash order, single-writer physical
trace bounds and atomic clearing for currently detected producer failures were
confirmed. No decoder, probe, graph or publication path leaked into the producer.

The source verdict is **0 Critical / 1 Important / 0 Minor**, so this SHA is not
approved. IC-138 records the substantive gap: normal serialization checks hashes
but not the complete local semantic matrix and can emit a self-consistent duplicate/
conflicting LayoutInput or other illegal enum/flag/ordinal shape. The review also
identified IC-139 as a test-evidence gap: independent fixed expected hex is present
for only three of the five hash domains; LayoutInputHash and EnumAuthorityHash need
literal vectors. A mistakenly requested, nonexistent golden attachment name is not
treated as a source defect or a reason to create duplicate authority.

TU5 and TU2 remain valid compile-frontier evidence, but they do not override the
review findings and no producer/TypeSchema behavioral GREEN is claimed.

### Task 2.7 Manifest/Pack repaired declaration RED freeze — 2026-08-08

The first independently reviewed Manifest/Pack candidate was rejected at
**3 Critical / 4 Important / 0 Minor**. The repaired author candidate closes the
seven findings in source and authority but remains explicitly pending fresh
exact-SHA independent rereview; this is not a `0C/0I` disposition, a complete-TU
compile, a Runtime implementation, or an Automation pass.

Frozen files:

| File | SHA-256 | Exact shape |
| --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheManifestPackTests.cpp` | `E763DD3285BD257CBBC7F9E08EE9B3C33893F8C3FFC732DBACF984FD680EB92E` | 129,043 bytes / 2,833 LF / 26 methods / final LF |
| `manifest-pack-wire-v1.md` | `E36722A99A05D2AE2C4452F01016E6FD6243A8EDCAD34C232A36F182C37E1779` | 35,208 bytes / 814 LF / final LF |
| `manifest-pack-red-test-authority.md` | `913DF562A0958DC3BE60DDA258571A8A06114CD7403DB48AA92855CC9847B7E0` | 9,056 bytes / 127 LF / final LF |
| `unit-test-coverage-matrix.md` | `C71064D5D9E5AC84EDFC90BFC0FB8E6189457B1CD689A20978666BDECD73FF11` | 11,316 bytes / 134 LF / final LF |

The actual Cache-directory source scan is `181` `TEST_METHOD` definitions;
Manifest/Pack owns `26`. The repaired evidence includes explicit
`TArray(MakeArrayView(native))`, TypeSchema and seven-kind exact reachability,
independent manifest/decoded SourceSnapshot, visited==manifest and exactly-once
per-root graph calls, all seven missing/wrong/unreachable target kinds, one
retained+temporary combined-live Budget and raw-buffer lifetime, decompression
under/over and None/Zlib size failures, exact/one-short MaxCanonical, complete
later range combinations, zero root/location keys, wrong/missing roots and all
six PackId/offset/stored/raw/codec/checksum location dimensions, a real
completion-ordinal aggregation seam for forced-serial/forward/reverse/seeded,
and successful record/generation prepopulation before atomic failure clearing.

Required repository-wrapper RED evidence:

```text
cache-manifest-pack-repaired-red-tu
  Saved/Build/cache-manifest-pack-repaired-red-tu/20260808_234148_544_45e29957/
  [1/1] Compile [x64] AngelscriptCacheManifestPackTests.cpp
  ProcessExitCode 6 / FinalExitCode 1
  fatal/error diagnostics: 1 / 1
  only diagnostic: source (1,1) cannot open
    Cache/AngelscriptCacheManifestPack.h
```

The command used the absolute `-SingleFile` path, `-NoHotReloadFromIDE`, the
repository wrapper, and no Runtime substitution header. The missing production
declaration is therefore the intended first RED frontier; no later C++
diagnostic or GREEN behavior is claimed.

### IC-138/IC-139 normal TypeSchema producer RED — 2026-08-09

The existing TypeSchema CQTest TU now contains a normal `SerializeTypeSchema`
producer matrix for duplicate/conflicting LayoutInput singletons, relation form and
ordinal rules, immutable layout size/alignment/boundary/replay, property storage/
access/flags/replication/ordinal/offset, method/VFT/behavior kind/ordinal/owner,
TypeSemanticFlags, reflection/statics/optional/UFunction, enum ordinal/name, and
locally derivable dependency coverage. Every case presets output bytes, requires the
exact producer tuple with `Stage=None` and offset zero, and compares guarded physical
wire snapshots before/after the call so the caller DTO remains wire-semantically
unchanged. The same TU adds independent literal LayoutInputHash and EnumAuthorityHash
vectors plus one-field mutation literals.

The repository-wrapper test SingleFile compile is clean:

```text
ic138-producer-red-test-tu
  Saved/Build/ic138-producer-red-test-tu/20260809_000333_595_2349ae33/
  [1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

A pre-GREEN full link was attempted so compile-only evidence would not be mistaken
for behavioral RED. It could not reach Automation because two already recorded,
separately owned implementation frontiers remain open:

```text
ic138-producer-red-link
  Saved/Build/ic138-producer-red-link/20260809_000350_244_1ad1e48d/
  ProcessExitCode 6 / FinalExitCode 1
  AngelscriptCacheManifestPackTests.cpp(1,1): missing
    Cache/AngelscriptCacheManifestPack.h
  UnrealEditor-AngelscriptRuntime.dll: unresolved
    FDecodedRecordCodecBridge::TryDecodeTypeSchema
```

This is a compiled RED test frontier, not an Automation failure or producer GREEN.

Fresh independent start/middle/end exact-SHA review approved this declaration-first
RED at **0 Critical / 0 Important / 0 Minor**. The review independently decoded all
five complete pack/manifest literals, recomputed the direct-payload BLAKE3,
domain-separated semantic hash, Zlib bytes, PackIds and GenerationIds, and found no
test-local semantic decoder, reachability traversal, publication path or scheduling
oracle. It also rechecked that the intentional missing-header diagnostic is the sole
compile diagnostic in Build.log, UBT.log and structured UBT.json. IC-128 through
IC-134 are therefore closed for the frozen RED source/authority boundary, and task
2.7 advances. This approval does not claim the production header, task 2.8/2.9,
complete-TU compilation, Automation or packaging.

### Factory nested-observer and injected-fault lifecycle repair — 2026-08-08

Fresh independent review of the first common-factory kernel reported two Critical
findings: the canonical reader received an empty allocation observer, and the
declared injection/checkpoint configuration was never consumed. IC-140 and IC-141
record the findings and the deliberately partial repair status.

The factory now begins/resets one caller-owned probe per decode, records the final
controller, owned canonical payload and all canonical-reader allocation successes
in one ordinal space, forwards nested candidate Budget rejections, preserves exact
field offsets for deferred local/hash failures, supports immediate physical failure
after the chosen successful allocation, and closes call-local live observation on
every return. `FDecodedAllocationObserverForTests` gained a guarded post-success
decision callback; the normal production path still constructs no observer and
publishes no test state.

Repository-wrapper compile evidence:

```text
cache-decoded-factory-observer-tu15
  Saved/Build/cache-decoded-factory-observer-tu15/20260808_235612_351_d4f02462/
  [1/1] Compile [x64] AngelscriptCacheDecodedRecord.cpp
  ProcessExitCode 0 / FinalExitCode 0

cache-canonical-observer-compat-tu
  Saved/Build/cache-canonical-observer-compat-tu/20260808_235625_855_c63efc7a/
  [1/1] Compile [x64] AngelscriptCacheSemanticRecords.cpp
  ProcessExitCode 0 / FinalExitCode 0
```

The exact compiled factory source SHA-256 is
`66231C6614B6A858E772399D8D61704C4D608070F4B07D9118FB9367BFCA1292`
(25,964 bytes / 811 LF / final LF). Supporting guarded declarations are:

- canonical codec header `CF51724E0EB63A9E8967EE52F9241B6C7D6D1D5E9DFEB6757B06E051192D9755`;
- TypeSchema header `CE9BF77DE6C4AD969ADC7E3F8754FBBE78C7ADDAEA15D1F9E9EB818C3426FDD7`;
- semantic-record header `83778A500B0D22FFE4988AC0727641C39D58E5873B5EFA1284437D8EA21FF2F2`.

This is compile-frontier evidence only. The TypeSchema bridge still has to perform
the twelve validation checkpoints and consume the deferred local/hash targets; the
seven-kind link, exact fault matrix, focused Automation and independent rereview
remain open. No task checkbox is advanced by these two SingleFile compiles.
