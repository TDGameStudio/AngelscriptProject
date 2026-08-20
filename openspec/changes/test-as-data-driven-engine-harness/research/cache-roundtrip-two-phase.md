# Cache V2 two-phase engines (authored and generated AS)

Layer 1 AngelScript (checked-in fixtures **and** generated products) is a Cache V2 input, same as it is a VM / StaticJIT generate / Runtime JIT input. The harness does **not** invent a third AS pile for cache. `Angelscript.TestModule.Cache.*` CQTest stays the owner of store, incremental generation, ExactStartup internals, and corruption cases.

## Two engines, one leaf

`cache-roundtrip` is not one `Create()`. It is producer then consumer, matching `AngelscriptCacheFreshEngineRestoreTests` / `AngelscriptCacheExactWarmStartupTests` (`FAngelscriptTestFixture` IsolatedFull, destroy producer before consumer).

```text
materialize AS → temp Script/   (authored copy or generated product text)
        │
        ▼
Phase 1  Producer isolated Full engine
         compile from disk Script/
         persist Cache V2 under CacheV2RootOverride
         destroy engine (no live asIScriptModule / descriptor pointers)
        │
        ▼
Phase 2  Consumer isolated Full engine
         same cache root + same source identity
         restore ExactStartup / existing helper
         executeInt / executeBool on restored modules
         destroy engine
```

Execute observations run **only** on the consumer. Restore success SHALL NOT be “compile the `.as` again and it still works”.

JSON still does not embed `FAngelscriptEngineConfig`. Cases MAY set optional `cacheRoot` so both engines use a custom Cache V2 folder. Default remains `{ProjectSavedDir}/Automation/DataDriven/<leaf>/CacheV2`.

## Custom cache folder

Authors need an isolated, inspectable Cache V2 directory (two cases that must not share packs, or a golden that points at a known Automation subfolder).

| Catalog `cacheRoot` | Resolved `CacheV2RootOverride` |
|---|---|
| omitted | `{ProjectSavedDir}/Automation/DataDriven/<leafId>/CacheV2` |
| relative `OptionalEmptyCustom` | `{ProjectSavedDir}/Automation/DataDriven/CacheRoots/OptionalEmptyCustom/` |
| absolute under `Saved/Automation/` | that normalized path |
| `..`, empty, outside `Saved/Automation/`, Fixtures, host `Script/`, production cache | catalog validation fails |

Producer and consumer SHALL use the **same resolved path**. `cacheRoot` on a non-`cache-roundtrip` case SHALL fail validation. This is a path overlay, not a config blob.

## Config: shared vs phase-specific

`FAngelscriptTestEngine::Create` already forces `bSkipInitialCompile = true` and sets `bDisableCacheV2Persistence` unless `CacheV2RootOverride` is set. Cache leaves **must** set the override so producer can persist.

| Setting | Producer | Consumer | Why |
|---|---|---|---|
| Engine | `FAngelscriptTestEngine::Create` isolated Full | **New** `Create`, not `GetSharedEngine` | Bind DBs independent; no shared-engine cache pollution |
| `CacheV2RootOverride` | resolved `cacheRoot` or per-leaf default | **Same path** | Consumer must open the generation the producer published |
| `GetProjectDir` | temp project root with `Script/` | **Same root** | Source identity / ExactStartup match; not host `Script/` |
| Disk AS | fixture copy or generated product text under `Script/` | same files still present (identity), not re-parsed as oracle | Cache V2 keys off source snapshot |
| `bDisableCacheV2Persistence` | `false` | `true` on consumer (no second publication) | Producer writes; consumer restore-only, same idea as ExactWarm “no publication” |
| `bForceSerialCacheV2Preparation` | `true` in tests | `true` | Avoid threaded prepare in Automation workers |
| Coordinator | `VMOnly` | `VMOnly` | This profile is cache, not Runtime JIT / StaticJIT generate |
| Purpose | ordinary Full (not `StaticJITGeneration`) | ordinary Full | Cache restore is not JIT generate |

Compatibility / context / profile **identity keys** for the cache store are harness-owned constants for DataDriven leaves (or reused from existing cache test helpers). They SHALL be identical on producer capture and consumer restore. Catalogs SHALL NOT embed those blobs.

Reuse existing capture/publish/ExactStartup helpers at apply time. Do not add a production cache API.

## Generated products

`vm` leaves may stay memory-mount. `cache-roundtrip` SHALL materialize the generated AngelScript to the temp `Script/` **before** the producer, the same disk trick as `typed-ast-generate`. Do not check in `Fixtures/Generated/**`.

Wave A goldens:

- Authored: `syntax.optional-empty.cache` (already task 6).
- Generated: one explicit `integral-bitwise` `int8` `mutable_lvalue` `cache-roundtrip` case. Not a cartesian of every type.

Same `executeInt` oracles as the matching `vm` leaf. Dump numbered generated source if producer compile or consumer execute fails.

## Out of this profile

Incremental function-body cache, pack corruption, ClassGraph restore, packaged reload, Cache×StaticJIT isolation internals — remain `Angelscript.TestModule.Cache.*`. Corpus leaves only prove: this AS survives persist + **fresh engine** restore + execute.
