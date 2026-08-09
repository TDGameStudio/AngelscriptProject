## 1. Evidence And Stable Artifact Identity

- [ ] 1.1 <!-- Non-TDD --> Recheck and record the current `PrecompiledScript.Cache` fields, FunctionId/DataGuid pairing, module restore stages, builder compile seams, dependency edges, package staging, and affected legacy tests before source edits.
- [ ] 1.2 <!-- TDD --> Add `Angelscript.TestModule.Cache.Identity` failures for module/type/function/global/property key determinism, path relocation, case-collision rejection, overload/synthetic ownership, full-hash collision behavior, and two-engine FunctionId isolation.
- [ ] 1.3 <!-- TDD --> Implement `FAngelscriptHash256`, domain-separated BLAKE3 canonical encoding, stable module/type/function/global/property key types, display-only GUID conversion, and golden vectors.
- [ ] 1.4 <!-- TDD --> Add failures and implement `FunctionInputDigest`, execution/debug `FunctionContentHash`, `CompatibilityKey`, `ContextKey`, and `ArtifactProfileKey` separation.
- [ ] 1.5 <!-- TDD --> Add failures and implement `FAngelscriptEnvironmentSymbolCatalog` with per-symbol ABI fingerprints and exact dependency capture so unrelated binding changes remain hits.
- [ ] 1.6 <!-- TDD --> Implement engine-owned stable-key-to-current-function/FunctionId routing and prove hot-reload rebuild plus multi-engine isolation.
- [ ] 1.7 <!-- Non-TDD --> Publish deterministic identity/profile golden vectors and update the sibling StaticJIT OpenSpec contract without coupling it to Cache V2 storage.

## 2. Cache V2 Records And Validated Archive

- [ ] 2.1 <!-- TDD --> Add byte-exact archive failures for `SourceIndex`, `ModuleInterface`, `TypeSchema`, `ModuleState`, `FunctionBody`, `DebugSidecar`, `ModuleSnapshot`, generation manifest, pack index, and stable references.
- [ ] 2.2 <!-- TDD --> Implement versioned explicit-field Cache V2 record types and serializers without raw struct dumps, native pointers, UObjects, FName indices, or numeric FunctionIds.
- [ ] 2.3 <!-- TDD --> Add and implement canonical stable-reference serialization/resolution for script and environment functions, types, globals, properties, imports, names, and strings.
- [ ] 2.4 <!-- TDD --> Add corruption/budget failures for magic/schema/profile, overflow, counts, offsets, codecs, stored/raw sizes, checksums, duplicate/conflicting keys, dependency kinds, canonical order, root containment, and memory limits.
- [ ] 2.5 <!-- TDD --> Adapt current precompiled module/function data into Cache V2 comparison fixtures while keeping the adapter test-only and excluding legacy identity from new records.
- [ ] 2.6 <!-- Non-TDD --> Move script-cache ownership and generic retained helpers out of `StaticJIT/` into the new Runtime `Core/Artifacts` and `Cache` boundaries without removing the old production path yet.

## 3. Content-Addressed Pack And Generation Store

- [ ] 3.1 <!-- TDD --> Add temporary-store failures for empty first start, Current/Previous/Pending selection, immutable read sessions, content reuse, and distinct compatibility/context namespaces.
- [ ] 3.2 <!-- TDD --> Implement Saved-only store discovery under `Saved/Angelscript/CacheV2/<CompatibilityKey>/<ContextKey>/` and validated immutable generation read sessions.
- [ ] 3.3 <!-- TDD --> Implement deterministic aggregated pack construction with canonical full-key ordering, 64 MiB target policy, large-record handling, per-record `None`/`Zlib` metadata, and uncompressed-content identity.
- [ ] 3.4 <!-- TDD --> Add injected crash-point failures and implement temporary pack/manifest writes, flush/validation, immutable rename, and atomic Previous/Current replacement.
- [ ] 3.5 <!-- TDD --> Add concurrent-writer failures and implement store-path `FSystemWideCriticalSection`, Current reread/rebase, cancellation, and reader isolation.
- [ ] 3.6 <!-- TDD --> Add Current corruption and source-snapshot-aware Previous/Pending fallback tests without authorizing different-source stale execution.
- [ ] 3.7 <!-- TDD --> Add explicit reachability/compaction failures and implement Current/Previous/Pending pack retention plus non-startup compaction.
- [ ] 3.8 <!-- TDD --> Prove forced-serial and randomized bounded-parallel preparation emit byte-identical manifests, packs, and generation IDs.

## 4. Source Planning, Compiler Reuse, And Module Assembly

- [ ] 4.1 <!-- TDD --> Add source-inventory failures for path normalization, addition/deletion, raw hash, include/preprocessor closure, exact snapshot, and formatting-only changes.
- [ ] 4.2 <!-- TDD --> Implement parallel SourceIndex discovery/hash and deterministic source-to-module planning with an exact-snapshot fast path.
- [ ] 4.3 <!-- TDD --> Add the complete mutation matrix for body, signature/owner/trait, class/property/inheritance/metadata, enum/delegate/interface, global/initializer, import, options, debug, and environment ABI changes.
- [ ] 4.4 <!-- TDD --> Implement typed invalidation planning from existing normal/hard/structural module dependencies and per-record semantic dependencies.
- [ ] 4.5 <!-- TDD --> Add maintained-AngelScript-fork failures for ordinary functions, methods, constructors/destructors, factories, generated defaults, and `__InitDefaults` cache lookup/capture.
- [ ] 4.6 <!-- TDD --> Implement the per-builder function artifact hook, pre-compiler `FunctionInputDigest` query, validated FunctionBody attachment, compile-miss path, and post-compile capture without changing `.as` syntax.
- [ ] 4.7 <!-- TDD --> Add ModuleState failures for global values, initializer dependency order, post-init, and hard-value closure; implement module-atomic global restore/rebuild.
- [ ] 4.8 <!-- TDD --> Add TypeSchema and complete ModuleSnapshot assembly failures; implement declaration-first stable-reference restore and module-atomic activation.
- [ ] 4.9 <!-- TDD --> Prove exact warm restore invokes zero preprocess/parse/compiler calls and a controlled one-body edit invokes exactly one function compiler while TypeSchema/ModuleState remain hits.

## 5. Engine, Editor, PIE, And Runtime Lifecycle

- [ ] 5.1 <!-- TDD --> Add lifecycle failures for no-cache initial compile, warm restore, failed fresh startup, failed hot reload, failed ClassGenerator, async publication, cancellation, and two-engine state.
- [ ] 5.2 <!-- TDD --> Make `FAngelscriptCacheService` engine-owned and integrate source selection, restore planning, successful compile capture, and module/ClassGenerator completion into the existing `FAngelscriptEngine` transaction.
- [ ] 5.3 <!-- TDD --> Implement asynchronous post-success generation preparation/publication while keeping active engine mutation and final selection on the owning safe point.
- [ ] 5.4 <!-- TDD --> Add Editor/PIE failures and implement Current alignment, code-only publish, structural `PendingColdStart`, post-PIE full-reload promotion, and last-good behavior.
- [ ] 5.5 <!-- TDD --> Add shutdown timing/cancellation failures and implement Cache flush before AS engine release with 5-second default timeout and no shutdown compilation.
- [ ] 5.6 <!-- TDD --> Add settings/API reflection failures and implement `UAngelscriptCacheSettings` plus reload mode/request/outcome/result types, `UAngelscriptSubsystem::RequestRuntimeReload()`, and completion delegate.
- [ ] 5.7 <!-- TDD --> Add packaged runtime policy failures and implement Disabled/Manual/Automatic scanning, code-only safe-point reload, `RequiresRestart` structural guard, busy/shutdown cancellation, and source-authoritative failure.
- [ ] 5.8 <!-- TDD --> Add diagnostics failures and implement status/flush/verify/compact/reload console commands, `-as-cache-root`, `-as-cache-report`, stable JSON schema, counters, reasons, and stage timings.
- [ ] 5.9 <!-- TDD --> Prove StaticJIT provider absence/removal/content/profile/ABI mismatch changes only Native/VM routing and never invalidates a valid AS Cache generation.

## 6. Legacy Removal And Packaging

- [ ] 6.1 <!-- TDD --> Add a legacy-rejection failure proving `PrecompiledScript.Cache` and `DataGuid` cannot satisfy Cache V2 while `Binds.Cache` remains valid.
- [ ] 6.2 <!-- Non-TDD --> Remove the old script-cache reader/writer, random DataGuid, old-pointer/FunctionId maps, forced-exit generation flags/commands, production StaticJIT ownership, and legacy-only tests after Cache V2 parity passes.
- [ ] 6.3 <!-- TDD --> Add packaging preflight failures and change `Script` staging from UFS to loose NonUFS while preserving `Binds.Cache` and rejecting staged legacy cache/baseline artifacts.
- [ ] 6.4 <!-- Non-TDD --> Remove `RunPackage.ps1` cache pre-generation parameters/process and retain only BuildCookRun plus staged-output validation.
- [ ] 6.5 <!-- TDD --> Add `RunAngelscriptCachePackageSmoke.ps1` tests/helpers for disposable archive fixtures, isolated cache/report roots, executable discovery, process timeout/exit handling, and cold/warm/edit/error/structural report assertions.
- [ ] 6.6 <!-- Non-TDD --> Add `Cache` and separate heavy `CachePackage` suite definitions plus a typed `PackageSmoke` entry for Development and Shipping; keep package builds out of normal `All`.

## 7. Final Real-Environment Verification And Documentation

- [ ] 7.1 <!-- Non-TDD --> Run the complete `Angelscript.TestModule.Cache` unit/runtime integration prefix and record counts, reports, and zero failure/skip/timeout evidence.
- [ ] 7.2 <!-- Non-TDD --> Run affected HotReload and StaticJIT prefixes and record compatibility evidence.
- [ ] 7.3 <!-- TDD --> Add and run real PIE cache lifecycle coverage for cold/warm sessions, live body edit, structural defer/promote, compile failure, active instance behavior, and PIE cleanup.
- [ ] 7.4 <!-- Non-TDD --> Build and run the real Development package multi-launch matrix: staged files, cold, unchanged warm, one-body edit, invalid source, restored last-good, and structural cold start.
- [ ] 7.5 <!-- Non-TDD --> Build and run the identical real Shipping package multi-launch matrix and record executable exits plus structured cache reports.
- [ ] 7.6 <!-- Non-TDD --> Capture cold/warm/body/type/global and serial/parallel benchmark rows with machine/profile/commit, at least one warmup and three measured runs, median/min/max, counters, and bytes.
- [ ] 7.7 <!-- Non-TDD --> Update Chinese cache/build/test/package guidance first, then English plugin README/guides and architecture facts, including loose-source/security and packaged structural-restart limits.
- [ ] 7.8 <!-- Non-TDD --> Run the canonical build, Cache suite, affected suites, configured All suite, CachePackage suite, strict OpenSpec validation, legacy reference classification, and `git diff --check`; record exact artifacts in `verification.md`.
