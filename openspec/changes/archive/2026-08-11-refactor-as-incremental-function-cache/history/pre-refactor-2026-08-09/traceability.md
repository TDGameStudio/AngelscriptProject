# Requirement Traceability

This matrix maps every normative requirement in the change to its implementation task group and mandatory evidence. It is a planning artifact; no row is complete until the referenced tests/reports exist.

Task 2B-3 evidence below is byte-for-byte against
`manifest-pack-wire-v1.md`; Task Group 3 evidence is state-machine/fault-
injection evidence against `store-publication-v1.md`. Store control-plane
errors remain separate from archive validation throughout this matrix.

## `as-script-artifact-identity`

| Requirement | Tasks | Required evidence |
|---|---|---|
| Persisted script entities have deterministic full-width identities | 1.2–1.3 | `Cache.Identity.EntityKeysIgnoreProcessAndEnumerationState` and source-line stability |
| Module identity uses canonical logical source coordinates | 1.2–1.3, 4.1–4.2 | project relocation and case-collision tests |
| Every type and callable kind has a canonical owner | 1.2–1.3 | overload/synthetic ownership golden vectors |
| Pre-compile function input is independent from logical identity | 1.4, 4.4, 4.6–4.8 | body/dependency digest matrix and compiler-call counters across every invocation kind |
| Compiled execution and debug content are validated separately | 1.4, 2.1–2.4, 4.4, 4.8 | formatting/debug split and corrupt execution/VM-metadata rejection |
| Debug absence is a shared profile-specific identity coordinate | 2.4–2.5, sibling StaticJIT identity task | one common `function-debug-absent` API, full ProfileKey Editor/Shipping goldens, empty-payload distinction and sibling consumption without a second algorithm |
| Compatibility, compilation context, and environment symbols are distinct | 1.4, 4.3–4.5 | Editor/Game profile, both initialization paths and referenced/unrelated binding tests |
| Full 256-bit hashes are authoritative | 1.2–1.3, 2.4 | display-GUID collision and conflicting metadata rejection |
| Numeric FunctionId remains current-engine state | 4.11 | active-only hot-reload route rebuild, temporary-module exclusion and two-engine isolation |
| StaticJIT consumes identity without owning Cache V2 | 1.5, 5.9 | cache-side compatibility bridge miss/absence/mismatch VM fallback with unchanged Cache state; external-provider parity remains sibling-owned |

## `as-incremental-script-cache`

| Requirement | Tasks | Required evidence |
|---|---|---|
| Cache V2 is logically segmented and physically packed | 2.1–2.9, 3.3 | record/archive goldens plus `UEASCV2M`/`UEASCV2P` schema-1 byte goldens; 33-byte RecordId, 65-byte root, 122-byte location, 32-byte pack header and 96-byte index; semantic-payload-not-envelope pack storage; exact SourceIndex/ModuleSnapshot reachability, allowed pack-only historical extras, no-one-file-per-function inspection, and same RecordIds with different complete physical PackIds |
| Exact restore records contain reconstructible semantic descriptors | 2.2–2.6, 4.8–4.10 | `record-wire-v1.md` common/SourceIndex/ModuleInterface goldens, public identity-only ImportKey versus non-key ABI/slot validation, local owner/TypeKind matrix, layered type-spelling/DeclaredType producer+resolver equality, independently approved ModuleState and combined TypeSchema/`type-layout-authority-v1.md` before 2B-2 RED, pointer-free Property storage and BaseType/CodeRoot/StructHeader witnesses, present-zero boundary versus absence, immutable offset/tail replay, linked-layout-before-current and external-single-witness current-layout tests, cold exact hit with no selected-module live resolver entries/calls, immutable missing-local-child failure, prospective validated-local-layout view for an environment template nested over a local value, primitive/ObjectHandle/profile skip routes, raw eligible CodeRoot memo reused with root/derived stored consumption masks, Typedef/Funcdef exact descriptors, `record-wire-v1-remaining.md` type/property/relation/slot/reflection/global/value/lifecycle goldens, derived-hash recomputation, legacy-field comparison and no-parse declaration/reflection equality |
| Record links are keyed and graph ownership is validated | 2.2–2.9, 4.8–4.10 | redundant module-key links, exact schema/body/global/enum/initializer coverage, duplicate/cross-owner/wrong-kind/missing-record/Forbidden-link failures, per-module atomic graph output, then 2B-3 exact reachable manifest roots |
| ModuleState exclusively owns V1 global initializer execution | 2.4–2.6, 4.4–4.5, 4.9 | independently approved exhaustive init/value-width/cleanup/hard-value/initializer/post-init matrix; ProfileKey, canonical scalar bits, one initializer per VmInitializer global, 0/1 module initializer, same-module post-init, every-local-enum authority, local Deserialize with zero codec calls, reachable step-1 exactly-once initializer summary, reverse rollback and whole-state hit/miss matrix |
| Declaration ABI and embedded content dependencies are distinct | 2.2–2.5, 4.4–4.8 | ExpectedAbi/content presence matrix, default-expression interface mutation, unchanged-call-ABI callee edit reuse, folded resolved-value invalidation and missing/forbidden ABI failures |
| Debug sidecar absence has a canonical content coordinate | 2.4–2.5, 4.8 | shared full-ProfileKey debug-absent goldens, no zero/empty sentinel, typed exact logical sections, source-summary equality and present/cross-function/profile sidecar validation |
| VM-private bytes remain opaque behind a validated seam | 2.4–2.5, 4.8 | five private record-specific decoder paths prove zero codec calls while the sole public common factory dispatches them; `UEASOPQ1` fixture codecs receive Limits plus the shared budget and return validated hash, complete-coordinate relocation subset, Debug V1 zero relocations, exact debug sources and `{ReferenceKind, StableKey}`-ordered owned name/string bytes; immutable token reachability invokes each initializer/body/body-owned-sidecar exactly once, stores summaries in the validated graph, ignores unrelated records, and source scan proves common graph never parses VM payloads |
| Validation is versioned, cumulative, and distinguishes corruption from ineligibility | 2.2–2.9, 3.5–3.6, 4.8 | preserved errors `0..43`, exact remaining-record errors `44..64`, manifest/pack-only errors `65..71`, append-only stages and old-constructor ByteOffset compatibility, exhaustive `Classify(Error)`, codec-entry established RecordKind with serializer offset `0` and decoder captured enclosing-field offsets, physical trailing-data before semantics, exact TypeSchema top-level field-local order followed by cross-field pairing/coverage/layout replay, unique LayoutInputHash → property StorageLayoutHash/PropertyLayoutFingerprint → EnumAuthorityHash → final TypeLayoutHash order with exact-ByteOffset paired winners, factory-only immutable RecordId-recomputing/dispatching SourceIndex+record tokens, token-only query with explicit Limits+Budget and no whole-record copy/re-prepare, independent schema axes, mandatory envelope budget overload plus one caller-owned manifest/pack/child/graph/query/codec budget, allocator-authoritative `TS-SCR-01..22` exact-limit/one-byte-short/lifetime/promotion evidence, monotonic persistent counters plus allocation-before-reserve live-resident RAII scratch released on every exit, null-context/zero-selection failure, fixed source→profile→eligible dependency missing→ABI→content→eligible numeric-layout order through separate required current resolvers with graph/profile-closed local skips, counter-proved non-O(n²) indexes, `MaxGenerationPacks` rejection before pack access, local→reachable-codec→manifest-graph→current typed precedence, and independent store-error/nested-archive-result evidence |
| Invocation kind maps deterministically to shared identity | 2.4–2.5, 4.6–4.8 | every invocation matrix row; generated default destructor proves `EntityKind::Destructor=35 + Generated` without adding or renumbering Task 1 identity values |
| Module activation is atomic | 4.8–4.10, 5.1–5.3 | missing-record rollback, VM adapter rejection, successful complete restore and post-ClassGenerator immutable DTO |
| Exact source snapshots bypass preprocess parse and compile | 2.2–2.3, 4.1–4.2, 4.12 | six public fail-closed typed source-key builder/domain full-hash goldens, Game/Plugin/Memory inventory, raw BLAKE3-256, required `FTextChar::GetCodepoint` + per-code-point `ToLower` collision vectors for ASCII/BMP/true supplementary-plane traversal with unchanged identity bytes, exact graph-reference phase order Mount→Hook→File→Input→Edge→Ineligible before authority conflicts, competing full-256-bit duplicate groups proving the smallest second wire occurrence, bidirectional capability/reason and edge-ordinal matrices, complete no-dangling typed source graph with unique GeneratedSourceKey authority, Files-only ModuleKey mapping, pure base-to-dependent Hook transitive closure with detached-chain/two-module isolation, forged self/multi-node cycle `DerivedHashMismatch` before query, and exact warm counters all zero; production CompatibilityKey assembly/isolation remains explicitly deferred to the first authoritative assembler and is not current 2B-1 evidence |
| Changed modules retain unchanged function bodies | 4.4–4.8, 4.12 | one-body edit compiles exactly one invocation; factory/public-single coverage remains correct |
| Type schemas invalidate structural dependency closure | 4.4–4.5, 4.10 | property/inheritance/dependent-module matrix |
| Globals and initializer order are one module-state cache unit | 4.4–4.5, 4.9 | global initializer and hard-value dependency matrix |
| Invalidation uses typed semantic dependencies | 4.1–4.5 | full mutation matrix with exact stable keys/reasons |
| Cache V2 is a Saved-only immutable generation store | 3.1–3.3, 5.1–5.2 | exact default/override/canonical-containment paths, lower-case full-hash namespaces/finals, 80-byte pointer goldens, empty first start, immutable collision/reuse and supported-platform atomicity tests |
| Generation publication is atomic and recoverable | 3.2–3.6 | same-directory temp grammar, flush/reopen/no-replace/directory-sync, every frozen fault/cancellation/commit point, generic delete-then-move rejection, namespace lock/rebase/concurrent writer evidence, immutable-handle pinning and exact Current→Previous→cold-Pending fallback |
| Cache preparation is bounded parallel and deterministic | 3.8, 5.2–5.3, 5.9 | serial/random scheduling byte equality, explicit per-engine mutation gate, immutable DTO and multi-engine isolation |
| AngelScript engine mutation is serialized per engine | 5.1–5.3 | startup/runtime owner transition, explicit-token reentrancy, lock order, reload/shutdown/provider race and two-engine non-blocking tests |
| Loose source is authoritative over stale cache | 3.6, 5.1–5.2, 5.7 | fresh failure versus hot-reload last-good tests |
| Editor and PIE continuously maintain Cache V2 | 5.1–5.4, 7.3 | async Current/Pending transitions and real PIE behavior |
| Shutdown performs a bounded flush without late compilation | 5.5 | complete-before-timeout and timeout cancellation tests |
| Packaged runtime reload is configurable and code-only | 5.6–5.7 | Disabled/Manual/Automatic and RequiresRestart state machine |
| Runtime reload and cache controls are exposed through stable APIs | 5.6–5.8 | reflection, console and completion delegate tests |
| Cache settings have safe deterministic defaults | 5.6 | reflected default-value tests |
| Cache data is validated before allocation and engine mutation | 2.4–2.9, 3.1–3.6 | malformed record/manifest/pack/pointer/root matrix, canonical Zlib recompress equality, whole-file ID/location checks, every configured budget before allocation/open, and separate store versus archive error assertions |
| Legacy PrecompiledScript cache has no production path | 6.1–6.2 | legacy rejection and production reference scan |
| Diagnostics prove incremental behavior with stable identifiers | 5.8, 7.4–7.6 | deterministic JSON and package reports |
| Unreachable content is reclaimed outside startup | 3.7 | all physically valid pointer slots as roots, no-startup-compaction, two-phase rewrite/switch then re-lock/remark/sweep, intervening publication, pinned-reader DeleteDeferred and later-sweep tests |

The Task 2B-1 rows above are complete. The intervening `0 Critical / 4
Important / 3 Minor` and later allocator-capacity rereviews are retained as
historical findings in `verification.md`; all common-contract findings now have
genuine RED/GREEN evidence, full focused regressions, fresh enabled/disabled
105-action builds, and a final independent **APPROVED — 0 Critical / 0
Important / 0 Minor** review. Tasks 2.2 and 2.3 are checked. Task 2B-2 remains
blocked only on fresh approval of the reconciled combined TypeSchema/layout
authority; ModuleState is already independently approved. Future production CompatibilityKey assembly remains an
explicit downstream task rather than a Task 2B-1 completion claim.

## `as-cooked-packaging-runtime`

| Requirement operation | Tasks | Required evidence |
|---|---|---|
| MODIFIED: AngelScript Caches Are Staged | 6.3–6.4 | staged loose Script/`Binds.Cache` and legacy/baseline absence |
| REMOVED: Packaging Tooling With Precompiled Pre-Step | 6.2, 6.4 | no generation parameter/process/command and source scan classification |
| ADDED: Packaging tooling does not pre-generate script cache data | 6.3–6.4 | Development/Shipping package metadata and archive inspection |
| ADDED: Packaged runtime creates and updates Cache V2 from loose source | 5.2, 5.7, 6.3–6.5, 7.4–7.5 | typed startup result, default nonzero unattended invalid-source exit independent of legacy flag, first-launch and structural cold-start reports |
| ADDED: Real packages receive deterministic multi-launch cache verification | 6.5–6.6, 7.4–7.5 | separate Development and Shipping `CachePackage` summaries |

## Final Gates

- `Tools\RunTestSuite.ps1 -Suite Cache` covers focused unit/runtime integration.
- `Angelscript.TestModule.Cache.PIE` supplies actual Editor PIE lifecycle evidence.
- `Tools\RunTestSuite.ps1 -Suite CachePackage` supplies actual Development/Shipping executable evidence.
- `Tools\RunTestSuite.ps1 -Suite All` checks repository-wide regressions but intentionally does not rebuild packages.
- The Runtime `PublicDefinitions` single-owner UBT gate still requires fresh E1/E0 definitions-header verification; Shipping compile/package remains a final gate, not evidence supplied by this record-only pass.
- `verification.md` records exact counts, command exits, report paths, benchmark paths, legacy reference classification and any remaining limitations before completion is claimed.
