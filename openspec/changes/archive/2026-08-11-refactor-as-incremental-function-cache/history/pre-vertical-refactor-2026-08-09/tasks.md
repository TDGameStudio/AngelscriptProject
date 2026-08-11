# Cache V2 Executable Tasks

This is the current checklist. Every checkbox is a bounded dependency/backlog
slice, not an equal-sized progress unit or automatically assignable handoff. Before
assignment, the primary agent materializes the next slice as the single `Current
ready packet` in `implementation-plan.md`, with owned/forbidden files, frozen
inputs, prerequisites, exact applicable commands, evidence and review gate. Current
progress is reported by milestone and evidence state in `status.md`, never by a
global completed/total ratio. Historical checkbox wording is preserved in
`history/pre-refactor-2026-08-09/tasks.md`.

## R. OpenSpec execution reset

- [x] R1 <!-- Non-TDD --> Complete the OpenSpec-only execution reset: preserve and hash the historical records, publish the current plan/status/tasks/lessons/issues/verification/traceability set, pass strict OpenSpec and link/task/archive/diff validation, and prove the non-OpenSpec source manifest is byte-identical to the recorded baseline.

## A. Accepted identity and common archive baseline

- [x] A1 <!-- TDD --> Freeze and implement full-width domain-separated stable module/type/function/global/property identities plus display-only GUID conversion and relocation/collision goldens.
- [x] A2 <!-- TDD --> Freeze and implement separated source/input/content/profile digests shared with the sibling StaticJIT contract without giving StaticJIT Cache storage authority.
- [x] A3 <!-- TDD --> Close the checked record envelope, canonical writer/reader primitives, exhaustive archive result classification and common Budget foundation.
- [x] A4 <!-- TDD --> Close SourceIndex and ModuleInterface Task 2B-1 validation, graph/reference precedence, eligibility and immutable token baseline; revalidation after common-factory migration remains B12.
- [x] A5 <!-- TDD / authority --> Approve the TypeSchema declaration-first RED, remaining-record coordinate/C++ shape RED, candidate Budget and canonical allocator retained-side boundaries.
- [x] A6 <!-- TDD / authority --> Approve the 26-method Manifest/Pack declaration-first RED, frozen wire and RED authority; production remains C2 onward.

## B. Sole seven-kind decoder, ownership and module graph

- [x] B1 <!-- TDD / exact-SHA review --> Audit IC-138/139 paused TypeSchema tests against the frozen authority, compile the complete test TU, freeze its exact SHA/shape, and obtain fresh independent approval before treating it as RED authority.
- [x] B2 <!-- TDD / RED --> Add a normal TypeSchema producer RED for all canonical-local semantic obligations, exact layout/enum hashes and legal resolver independence; crashes, checks, missing headers and unresolved symbols do not satisfy this task.
- [ ] B3 <!-- TDD / GREEN --> Implement the producer local validator on the production path and pass focused producer behavior, keeping test construction from becoming a second semantic owner.
- [ ] B4 <!-- TDD / exact-SHA review --> Finish IC-140/141 factory/allocation candidate review, behavior tests, disabled/enabled seam equivalence and Shipping symbol/size scan without editing the review candidate during review.
- [x] B5 <!-- TDD --> Implement TypeSchema physical decoding, all captured field offsets and trailing-data precedence into a local unpublished candidate.
- [ ] B6 <!-- TDD --> Implement TypeSchema field-local and cross-field semantic validation, all twelve checkpoints, local-child closure and fail-before-current-resolver ordering.
- [ ] B7 <!-- TDD / reviewed safety boundary --> Implement TypeSchema layout-input/property/enum/final hash validation, prospective local-layout view, eligible current-layout memoization and stored consumption masks with exact error precedence.
- [ ] B8 <!-- TDD --> Migrate SourceIndex and ModuleInterface decode consumers into the sole common factory, remove transitional ownership/wrappers, and prove no copy, reprepare or double Budget charge.
- [ ] B9 <!-- TDD --> Implement private wire/local/hash decoders for ModuleState, FunctionBody, DebugSidecar and ModuleSnapshot, with the frozen DTOs, offsets, opaque boundaries and debug-absent identity.
- [ ] B10 <!-- TDD / reviewed safety boundary --> Close seven-kind RecordId-recomputing dispatch, one candidate/controller/payload allocation chronology, one-shot promotion, all failure releases and immutable shared-const publication.
- [ ] B11 <!-- TDD / reviewed graph boundary --> Implement the single `ValidateModuleSnapshotGraph` traversal, reachable-only handle retention, compact ordinal indexes, exactly-once opaque validation, resolver ordering and atomic empty output.
- [ ] B12 <!-- Verification --> Run complete record/factory/graph and common-archive regressions, concurrency/fault/capacity tests and non-test symbol/size scans; record exact counts/logs and update milestone B only at the achieved evidence level.

## C. Deterministic Pack and Manifest data plane

- [x] C1 <!-- TDD / authority --> Freeze and independently approve the 26-method missing-declaration RED, `manifest-pack-wire-v1.md` and `manifest-pack-red-test-authority.md`.
- [ ] C2 <!-- TDD --> Implement deterministic aggregate Pack declarations and semantic-payload/index construction without filesystem or live-engine dependencies.
- [ ] C3 <!-- TDD --> Implement Manifest declarations, exact SourceIndex/ModuleSnapshot roots and record-to-pack locations with frozen sizes/order/identity rules.
- [ ] C4 <!-- TDD --> Implement checked None/Zlib storage, canonical Zlib recompression, checksum/range/overlap validation and one cumulative monotonic read Budget.
- [ ] C5 <!-- TDD --> Prove serial, forward, reverse and seeded-random construction yields identical payloads, indexes, stored bytes, PackIds and GenerationIds.
- [ ] C6 <!-- TDD / depends B11 --> Implement exact Manifest reachability through the sole record factory and module graph; enforce `MaxGenerationPacks` before lookup/open and frozen stage/error precedence.
- [ ] C7 <!-- TDD --> Build and validate a complete immutable in-memory generation while keeping paths, pointers, locking and engine mutation out of this layer.
- [ ] C8 <!-- Verification --> Run Archive/PackFormat/Manifest GREEN plus affected factory/graph regressions and record exact artifacts.

## D. Content-addressed immutable Store

- [ ] D1 <!-- TDD / RED --> Freeze canonical root/containment/name, 80-byte pointer, injected atomic-capability and store error/stage/commit-state failures.
- [ ] D2 <!-- TDD --> Implement Saved-only namespaces, exact `-as-cache-root` replacement, strict recognized temp names and platform capability abstraction.
- [ ] D3 <!-- TDD --> Implement write/flush/close/reopen/no-replace/directory-sync/final-reopen publication for immutable Pack and Manifest files.
- [ ] D4 <!-- TDD / reviewed atomic boundary --> Implement ordered namespace locking, cancellable polling, under-lock reread/rebase and true old-or-new Current/Previous/Pending publication.
- [ ] D5 <!-- TDD --> Implement immutable read sessions that pin one Manifest and every distinct Pack while sharing one Budget across slot fallback.
- [ ] D6 <!-- TDD --> Implement explicit two-phase compaction with source/profile revalidation, intervening-publication remark and deferred pinned-file deletion; never compact on startup.
- [ ] D7 <!-- Verification --> Prove all fault/cancel/indeterminate boundaries, immutable corruption/collision handling and serial/parallel/concurrent-publisher determinism with focused Store GREEN.

## E. Source planning, compiler reuse and atomic module assembly

- [ ] E1 <!-- TDD --> Freeze source inventory behavior for Game/Plugin/Memory mounts, raw bytes, stable provider/hook fingerprints, paths/collisions, additions/deletions and per-scope exact-fast-path ineligibility.
- [ ] E2 <!-- TDD --> Implement production SourceIndex discovery/hashing and exact-snapshot planning with pointer-free immutable worker DTOs.
- [ ] E3 <!-- TDD --> Capture a per-engine environment symbol catalog after binds/type registration and prove referenced-only ABI invalidation and multi-engine isolation.
- [ ] E4 <!-- TDD --> Freeze body/signature/type/global/import/options/debug/environment mutation results and typed dependency reasons.
- [ ] E5 <!-- TDD --> Implement deterministic minimum-complete invalidation closure from module and record dependencies.
- [ ] E6 <!-- TDD --> Add the maintained-fork kind-tagged compile descriptor for every ordinary/generated/factory/public-single/lambda family and explicit NotCacheable coordinates.
- [ ] E7 <!-- TDD --> Implement compiler hit/miss attachment, persisted actual-dependency resolution and successful miss capture without a duplicate semantic pass.
- [ ] E8 <!-- TDD / reviewed VM boundary --> Implement the pointer-free function artifact codec and full opcode/reference/stack/local/cleanup/debug attachment validation before engine mutation.
- [ ] E9 <!-- TDD --> Implement module-atomic globals, constants, initializer dependency order and post-init restore/rebuild from one ModuleState.
- [ ] E10 <!-- TDD / integration --> Implement declaration-first TypeSchema/ModuleSnapshot assembly and active stable routes; prove exact warm restore has zero preprocess/parse/compiler calls and one isolated body edit invokes only the correct compiler closure.

## F. Engine, Editor, PIE, runtime reload and StaticJIT isolation

- [ ] F1 <!-- TDD / RED --> Freeze no-cache, warm, failed-start, failed-reload/ClassGenerator, asynchronous publication, cancellation and two-engine lifecycle behavior.
- [ ] F2 <!-- TDD / reviewed concurrency boundary --> Add one engine-owned Cache service and one reentrancy-defined mutation gate with explicit owner transition and lock order.
- [ ] F3 <!-- TDD --> Freeze and implement the pointer-free successful-publication DTO boundary; keep active Current and cold-start candidate distinct for partially handled PIE work.
- [ ] F4 <!-- TDD / real PIE after focused GREEN --> Implement Editor and PIE Current alignment, code-only publish, structural PendingColdStart, post-PIE promotion and last-good active behavior.
- [ ] F5 <!-- TDD --> Implement bounded shutdown flush before AS data release, with five-second default and no late discovery/preprocess/compile.
- [ ] F6 <!-- TDD --> Implement settings, C++/Blueprint reload APIs, completion delegate and status/flush/verify/compact/reload console commands plus deterministic reports.
- [ ] F7 <!-- TDD --> Implement packaged Disabled/Manual/Automatic safe-point reload, default Disabled, typed startup failure and structural `RequiresRestart`.
- [ ] F8 <!-- TDD / sibling contract --> Prove StaticJIT provider absence/removal/key/content/profile/ABI mismatch changes only Native/VM routing; Live Coding refresh never owns Cache validity.

## G. Direct legacy cutover, packaging and final acceptance

- [ ] G1 <!-- TDD --> Prove `PrecompiledScript.Cache`, DataGuid and old relocation data cannot satisfy Cache V2 while `Binds.Cache` remains supported.
- [ ] G2 <!-- Non-TDD / after parity --> Remove the legacy reader/writer, cache-correctness DataGuid, persisted pointer/FunctionId relocation, forced-exit cache generation and cache-only tooling; inventory retained StaticJIT numeric transport separately.
- [ ] G3 <!-- TDD --> Change `Script/` staging to loose NonUFS, remove package cache pre-generation and reject staged legacy/baseline cache artifacts.
- [ ] G4 <!-- TDD / tooling --> Add isolated Cache package-smoke helpers, Development/Shipping suite entries, timeouts/exits and structured cold/warm/edit/error assertions; keep heavy packages out of normal `All`.
- [ ] G5 <!-- Verification --> Run the complete Cache prefix and affected HotReload/StaticJIT prefixes with discovered/executed/pass/skip/timeout evidence.
- [ ] G6 <!-- Real acceptance --> Run real PIE cold/warm, live body edit, structural defer/promote, invalid source, active instance and cleanup scenarios.
- [ ] G7 <!-- Real acceptance / last --> Run real Development and Shipping multi-launch matrices for staged source, cold generation, unchanged warm reuse, body edit, invalid/restored source and structural cold start.
- [ ] G8 <!-- Final verification --> Capture cold/warm/body/type/global and serial/parallel benchmarks; update Chinese guidance first; run canonical build, configured suites, strict OpenSpec, legacy-reference classification and diff checks with exact evidence.

## Legacy task mapping

| Historical IDs | Current execution area | Preservation note |
|---|---|---|
| `1.1–1.5` | A1–A2 | Stable identity foundation remains accepted. |
| `2.1–2.3` | A3–A4 | Common archive baseline remains accepted, subject to B8/B12 migration regression. |
| `2.4–2.5a.4` | A5 and B1–B12 | Former mega-gates are decomposed by producer, decoder layer, ownership, graph and evidence. |
| `2.6` | E8/E10 test adaptation | Legacy data may be a fixture only, never identity or production fallback. |
| `2.7–2.9` | A6 and C1–C8 | RED authority is accepted; all production Pack/Manifest work remains open. |
| `2.10` | B/E/G ownership cutover | Generic Cache ownership moves out of StaticJIT without premature provider-transport deletion. |
| `3.1–3.8` | D1–D7 | Store is still unimplemented. |
| `4.1–4.12` | E1–E10 | Source/compiler/assembly remains downstream. |
| `5.1–5.9` | F1–F8 | Lifecycle and sibling routing remain downstream. |
| `6.1–6.6` | G1–G4 | Direct cutover/package setup remains after parity. |
| `7.1–7.8` | G5–G8 | Real PIE and Development/Shipping acceptance remains last. |
