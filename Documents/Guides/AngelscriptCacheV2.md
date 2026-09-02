# AngelScript Cache V2 Operations and Troubleshooting

This guide describes the implemented incremental Cache V2 contract for Editor, PIE, Development, Shipping, and StaticJIT routing. The Chinese guide, maintained first for this repository, is `Documents/Guides/AngelscriptCacheV2_ZH.md`. Design rationale and the complete change-classification model live in `openspec/changes/refactor-as-incremental-function-cache/cache-v2-flow-and-change-classification.md`. Cache test-suite structure problems are reviewed in `Documents/Guides/CacheV2TestReview_20260813.md`. A Chinese walkthrough (plain-language overview, process cases including a failed startup recompile, force-recompile commands, and how to measure cold vs warm startup) is in `Documents/Knowledges/ZH/RT_CacheV2.md`.

> **Current product status (2026-08-24):** Cache V2 is a retained experimental feature and is disabled by default pending a possible redesign. A default Engine does not attempt ExactStartup/cross-Engine restore, compile or Hot Reload capture, or shutdown persistence; it compiles authoritative `.as` source directly. The Pack, restore, incremental, and Runtime-reload sections below describe the explicitly enabled prototype and are not canonical-compiler cutover prerequisites.

## Purpose and authority

When explicitly enabled, Cache V2 persists previously validated AngelScript compilation artifacts as content-addressed records. A first launch with no valid generation compiles the authoritative source normally and publishes a cache. A later exact launch restores it; a changed launch reuses only records whose identities and current dependency fingerprints still match. With product defaults, all Cache restore/capture/persistence steps are bypassed.

Loose `.as` source remains the correctness authority. Corrupt bytes, incompatible schema/profile/context, source mismatch, or failed dependency validation becomes a typed miss or startup failure. The loader never runs a stale generation for different source merely to keep the process alive.

The principal benefit is Engine initialization and Editor/PIE or packaged-process script loading. Successful Editor reload and optional packaged runtime reload also maintain the cache. Shutdown only performs a bounded flush of already frozen publications—five seconds by default—and never discovers, preprocesses, parses, or compiles new work.

## Logical records and physical Packs

One `.as` file is neither a permanently indivisible cache unit nor expanded into one physical file per function. Logical records are independently content-addressed, then grouped into immutable Packs:

| Record | Authority | Typical invalidation |
| --- | --- | --- |
| `SourceIndex` | mounts, providers, files, includes/generated inputs | raw source or preprocessing input changes |
| `ModuleInterface` | declarations, imports, function/type/global/property contract | signature, owner, trait, or import-route change |
| `TypeSchema` | inheritance, properties, layout, method/VFT, reflection, enum authority | structural, layout, reflection, interface, or enum change |
| `ModuleState` | globals, constants, initializers, solved order | global/constant/initializer/order change |
| `FunctionBody` | stable function identity, input digest, VM execution, actual dependencies | body, call ABI, or dependency fingerprint change |
| `DebugSidecar` | line/source mapping | line mapping or debug-profile change; may be omitted in Shipping |
| `ModuleSnapshot` | complete record set needed to restore one module | any required record or assembly relationship changes |
| `ASTBodySidecar` (kind 8) | pointer-free sealed canonical AST body for retain-policy restore | function-body rebuild, type/decl remap failure, or verifier-invalid fragment |

`ASTBodySidecar` never replaces `FunctionBody` and is never written into `SaveByteCode`. Discard-policy restore loads VM state and ignores sidecars. Retain-policy ExactStartup restore republishes one complete verified module AST without preprocess/parse/Sema/Bytecode CodeGen. There is no `TypedHIRSidecar` record kind.

Records can therefore be reused independently while module restoration and activation remain atomic. A partially old and partially new module is never exposed to the Engine.

## Change classification

A raw-byte change first misses the exact `SourceIndex` fast path. The normal preprocessor, parser, declaration, and semantic/layout authorities then classify the real impact; no filename or regular-expression heuristic decides whether a change is structural.

- A body-only edit retains `StableFunctionKey` and changes that function's source/input/content digest. Unrelated functions, types, and module state remain reusable.
- A parameter, return, qualifier, owner, or function-kind edit changes stable identity or declaration ABI. It invalidates the interface, owning type method declaration, and actual caller closure.
- A property, base, interface, method/VFT, reflection, or enum edit invalidates the associated `TypeSchema` and structural dependency closure. Functions that actually access the changed layout miss through their dependency digests.
- A global, constant, initializer, or initialization-order edit invalidates the atomic `ModuleState`; hard-value consumers miss through their persisted actual dependencies.
- Comments, spaces, or line breaks change the raw source hash and therefore cause preprocess/parse work. If canonical semantics are unchanged, execution bodies, type schema, and module state can still hit; only the debug sidecar may need new line mapping.
- Presentation-only `UFUNCTION` metadata usually preserves logical function identity while rebuilding declaration/type reflection. RPC, event, virtual-dispatch, or other call-semantic flags also invalidate the affected execution and route closure.

The compiler captures actual type, property, global, operator, hard-value, and optional embedded-content dependencies on a miss. A later launch can therefore reject an unchanged caller whose real ABI/layout/value input changed before invoking its function compiler.

## Stable function routing and StaticJIT

Cache V2 never persists process-local numeric FunctionIds. A domain-separated BLAKE3-256 `StableFunctionKey` represents logical identity from stable module/owner, namespace, function kind, and canonical declaration/traits. A normal body edit keeps the key; signature, owner, qualifier, rename, or function-kind changes create a new key.

Every Engine rebuilds `StableFunctionKey -> current Engine FunctionId` after restore or compile. A StaticJIT provider selects a Native entry by stable key, execution-content hash, profile, and ABI. A missing, removed, or mismatched provider falls back to VM for that route; it cannot make an invalid Cache generation valid.

UE Live Coding can refresh Native provider code and entry addresses compiled into an external Editor module. It does not own `.as` freshness, Cache generations, the `Current` pointer, or script hot-reload correctness.

## Lifecycle policy

In non-PIE Editor, a successful initial compile or hot reload freezes a pointer-free DTO and schedules asynchronous Store preparation. A structural update becomes `Current` only after module swap, ClassGenerator, reflection, and reinstancing succeed. Failure keeps the active modules and prior `Current` unchanged.

During PIE, safe body-only updates may track the active Engine in `Current`. A structural result that is valid for a fresh Engine but cannot replace existing PIE instances keeps active `Current` unchanged and publishes the source-correct candidate as `PendingColdStart`. A later full/cold transaction after PIE must succeed before promotion.

Development and Shipping packages retain loose `.as` source and require no pre-generated cache baseline. The first launch compiles and publishes `Current`; an unchanged later launch can restore exactly. Packaged runtime reload defaults to `Disabled`. Explicit `Manual` or `Automatic` requests run at a game-thread safe point: code-only changes can apply, while signature/class/layout changes report `RequiresRestart` and do not mutate live structure.

## Store layout and publication

The default base root is `Saved/Angelscript/CacheV2`. Compatibility and Context hashes isolate namespaces:

```text
Saved/Angelscript/CacheV2/
  <CompatibilityHash>/
    <ContextHash>/
      Current.ascurrent
      Previous.ascurrent
      PendingColdStart.ascurrent
      Generations/<GenerationId>.asmanifest
      Packs/<PackId>.aspack
```

Packs and Manifests are immutable and content-addressed. Small pointer files are atomically replaced. A normal publication moves the prior `Current` to `Previous`. A crash before pointer replacement preserves old `Current`; an uncertain post-replacement result is resolved by rereading the pointer. All valid `Current`, `Previous`, and `PendingColdStart` slots are compaction retention roots.

## Settings and process overrides

`UAngelscriptCacheSettings`, shown under Project Settings as **AngelScript Incremental Cache**, provides:

| Setting | Default | Meaning |
| --- | ---: | --- |
| `bEnableCacheV2` | `false` | experimental opt-in; produce and consume Cache V2 only when explicitly enabled |
| `ShutdownFlushTimeoutSeconds` | `5.0` | maximum bounded shutdown wait |
| `PackTargetMiB` | `64` | canonical raw-byte target per immutable Pack, range 1..256 MiB |
| `bEnableParallelPreparation` | `true` | compress immutable records and build independent Packs concurrently |
| `MaxPreparationWorkerCount` | `4` | Cache-only worker ceiling, range 1..64 |
| `bEnableDecisionTrace` | `false` | bounded pointer-free decision journal |
| `DecisionTraceCapacity` | `1024` | retained event capacity, range 1..65536 |
| `PackagedRuntimeReloadMode` | `Disabled` | packaged Disabled/Manual/Automatic policy |

Diagnostic and benchmark process overrides are:

```text
-as-cache-root=<absolute-directory>
-as-cache-report=<absolute-json-path>
-as-cache-trace
-as-cache-trace-capacity=<1..65536>
-as-cache-pack-target-mib=<1..256>
-as-cache-preparation-workers=<1..64>
-as-cache-force-serial-preparation
```

The normal production writer uses a 64 MiB target and at most four bounded workers. Workers only touch immutable DTOs, compression, and independent Pack assembly. Declarations, type/layout materialization, globals/initializers, module swap, ClassGenerator, stable routes, and generation selection remain serialized by the per-Engine mutation gate. Forced-serial and bounded-parallel preparation must emit byte-identical Packs, Manifests, RecordIds, and GenerationIds.

The process overrides above configure diagnostics, paths, or writer behavior; they do not implicitly enable Cache V2. Enable `bEnableCacheV2` in Project Settings before using the prototype. Focused Cache automation uses a per-Engine override so the product default remains untouched.

## Runtime diagnostics

The console surface operates on the current Engine and returns typed outcomes:

```text
as.Cache.Status
as.Cache.Status Json=Diagnostics/cache-status.json
as.Cache.Flush Timeout=5
as.Cache.Verify Generation=Current Deep=1
as.Cache.Verify Generation=Previous Deep=0
as.Cache.Compact Timeout=5
as.Cache.ForceClean
as.Cache.ForceClean Module=<canonical-name-or-stable-module-key>
as.ReloadScripts
as.Cache.Trace Enable Capacity=4096
as.Cache.Trace Dump Json=Diagnostics/cache-trace.json
as.Cache.Trace Clear
as.Cache.Trace Disable
as.Cache.Explain Transaction=<ordinal> Module=<64-hex-key>
```

`Json=` paths must remain beneath Project `Saved`. `Status` and `-as-cache-report` expose the same pointer-free schema-4 session document, so separate Editor/game processes can be correlated by stable coordinates. Blueprint exposes **Get AngelScript Cache Status JSON**. C++ has typed capture, JSON, flush, verify, compact, force-clean, and explain APIs in `AngelscriptCacheDiagnostics.h`.

`as.Cache.ForceClean` is the force recompile for both Cache and the live AngelScript modules: selected modules (or all active modules) take `FullReload` with function Hits disabled. It does not delete on-disk packs; use `Compact` to reclaim files. `as.ReloadScripts` queues one packaged loose-source reload and still allows Hits; in the Editor it returns `Disabled`. `Flush` / `Verify` / `Status` / `Explain` / `Trace` do not compile. There is no `as.RecompileAll`, and none of these commands rebuild C++ / UHT / StaticJIT.

If startup SourceIndex misses and the resulting compile fails, the different-source disk `Current` is not activated. The Editor shows a compile-error modal and retries via FullReload after save; packaged / unattended / commandlet hosts exit with status 3. A `FatalPartialRestore` refuses compile fallback. A hot-reload failure after modules are already live keeps last-good in memory. See `RT_CacheV2.md` sections 7–8.

## Read-only Python inspection

The dependency-free dump tool never starts Unreal or modifies the inspected Store:

```powershell
python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --generation Current

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json `
    --session-report Saved/Diagnostics/cache-session.json

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --diff Previous Current

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --explain <stable-key>
```

It validates pointers, Manifests, Packs, BLAKE3 identities, indexes, codecs, checksums, RecordIds, and supported public payload schemas. It reports module/type/function/global/reuse data, but it remains a physical-integrity and observation tool. Runtime remains authoritative for current ABI, dependency graph, relocation, budgets, and Engine materialization.

## Verification and benchmark entry points

Use repository wrappers:

```powershell
Tools\RunCacheV2DumpTests.ps1
Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache
Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development
Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Shipping

Tools\RunAngelscriptCacheBenchmark.ps1 `
    -ArchiveRoot <archive-root> `
    -Configuration Development `
    -WarmupRuns 1 -MeasuredRuns 3

Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic `
    -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4
```

The package benchmark uses a disposable source fixture and isolated cache roots. It covers cold, exact warm, body, type, module state, diagnostic overhead, and 4/16/64 MiB serial/parallel policies. `totalMs` is whole-process wall time, not `InitialCompile` alone. Time is observational until a representative baseline supports a threshold; semantic parity, process exit, report/dump correlation, and deterministic bytes are hard assertions.

A single-launch comparison does not need the full matrix: pass `-as-cache-report` / `-as-cache-trace` and read schema-4 `functionReuse` counts plus `StartupSelection` / `StartupRestore` `elapsedMicroseconds`. Engine `FAngelscriptScopeTimer` lines (`script compilation total`) and Insights `Angelscript.Compile.Initial` are closer to compile cost; those compile timers are absent on a whole-generation ExactStartup hit. The session JSON has no per-stage preprocess/parse/function split, and Editor startup has no automated A/B. The smallest local contrast is one empty-root (or ForceClean then relaunch) report versus one unchanged-source report. See `RT_CacheV2.md` section 9.

The 2026-08-12 V7.7 Development sample contains 38 staged sources and one
32.7 KiB Pack. Cold median was 11093 ms and unchanged warm was 14055 ms. The
warm report restored 18 functions but still compiled four misses and classified
four functions as typed `NotCacheable`; this sample therefore **does not prove a
startup speedup** and must not be advertised as one. All 4/16/64 MiB policies
formed one Pack; parallel medians were +0.40%, +1.45%, and +0.60% versus serial,
which proves parity but cannot demonstrate worker benefit. A representative
larger project corpus and finer stage timings are prerequisites for performance
tuning. The 64 MiB/four-worker policy is a conservative default, not an optimum
selected by this sample. Summary and Verbose process medians were respectively
0.07% and 0.22% above Disabled in three measured runs and remain observations.

## Troubleshooting order

1. Retain the process log and capture a session report with `-as-cache-report=<absolute-json>` or `as.Cache.Status Json=...`.
2. Run `as.Cache.Verify Generation=Current Deep=1`; deep mode decompresses and decodes reachable records in addition to Store boundaries.
3. Correlate the live report with Python `--session-report`, then use `--diff Previous Current` to identify changed semantic records.
4. For miss/fallback causality, opt in before startup with `-as-cache-trace`, then dump the bounded journal or query it through `as.Cache.Explain`. Leave tracing disabled during normal operation.
5. Use `as.Cache.ForceClean` to compare an authoritative clean compile with cached behavior. Do not hand-edit pointer, Manifest, or Pack files.
6. A compatibility/context/profile, source snapshot, UUID/GenerationId, or stable-key mismatch should miss and publish a new generation. There is intentionally no legacy-cache reader or migration tool during plugin development. To force a complete rebuild, stop participating processes and remove only the exact project `Saved/Angelscript/CacheV2` directory; source is unaffected.
