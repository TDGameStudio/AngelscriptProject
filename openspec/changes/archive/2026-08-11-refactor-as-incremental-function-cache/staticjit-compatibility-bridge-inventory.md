# StaticJIT compatibility bridge inventory after Cache V2 cutover

Date: 2026-08-11

## Boundary

Cache V2 no longer selects, reads, writes or generates `PrecompiledScript*.Cache`
during Engine startup, packaging or runtime reload. `DataGuid`, generated numeric
IDs and legacy pointer/reference relocation are not Cache V2 validity coordinates.
The only Cache-owned native-routing identity is the full stable function key plus
graph-verified content/profile, resolved to a current Engine function/FunctionId in
an immutable transient route snapshot.

The symbols below remain temporarily because sibling OpenSpec
`refactor-as-static-jit-external-module` has not yet replaced the generated AOT
transport. They are compatibility consumers, not a second cache authority. Their
removal belongs to the sibling change after provider parity.

## Retained bridge inventory

| File/surface | Retained symbols or data | Exact current use | Why retained / later owner |
|---|---|---|---|
| `StaticJIT/AngelscriptStaticJIT.h/.cpp` | `FJITDatabase`, `FAngelscriptStaticJIT`, generated function/global/type/property reference emit, `GenerateStaticJITAotArtifactsForDiagnostics` | Registers and emits the existing generated `.jit.cpp/.jit.hpp` transport and the AOT test fixture. It is never consulted to validate a Cache V2 generation. | Sibling Provider/catalog implementation replaces generated numeric registration and content-specific dispatch. |
| `StaticJIT/StaticJITHeader.h/.cpp` | `FStaticJITCompiledInfo::PrecompiledDataGuid`, generated registration helpers | Carries the current generated binary's legacy AOT pairing and publishes generated entries into `FJITDatabase`. | Sibling Provider ABI/catalog and project-module scaffold own replacement. |
| `StaticJIT/PrecompiledData.h/.cpp` | archive DTOs, `DataGuid`, `CreateFunctionId`, `MapFunctionId`, `GetIdForFunction`, reference relocation, `Save`/`Load` | Used only by explicit StaticJIT diagnostics/AOT generation and their tests. Production Engine startup has no load/save/generate caller. | Sibling AOT transport cutover; do not reuse these fields in Cache V2. |
| `StaticJIT/StaticJITDiagnostics.h/.cpp` | explicit cache load, `bUseStaticJITCompatibilityData` guard, legacy ID/Guid snapshot | Developer/test diagnostics for the retained AOT fixture. It must be called explicitly; the private Engine flag defaults false and has no process/config selection path. | Sibling diagnostics migrate to Provider catalog/stable-key reports. |
| `Core/AngelscriptEngine.h/.cpp` compile stages | `PrecompiledData` pointer and `bUseStaticJITCompatibilityData` | Two compile-stage branches remain reachable only while `StaticJITDiagnostics::CompileLoadedPrecompiledData` owns the temporary guard. Normal initial compile, hot reload, packaged reload and Cache V2 restore never set it. | Delete with sibling diagnostics transport. |
| `Core/AngelscriptEngine.h/.cpp`, `StaticJIT/StaticJITBinds.cpp` | `bCollectStaticJITCompatibilityBinds`, `IsCollectingStaticJITCompatibilityBinds` | Explicit isolated-engine switch for collecting NativeForms required by current StaticJIT tests/tooling. It does not create a cache archive and is not parsed from the process command line. | Rename/remove when sibling provider owns native-form catalog construction. |
| `ClassGenerator/*`, compilation events/context | `bLoadedPrecompiledCode`, module-local `PrecompiledData` pointer | Observes the explicit diagnostics bridge while it still materializes a module. Cache V2 restore has its own adapter and does not claim this legacy bit. | Remove/rename with the bridge compile path. |
| `Dump/AngelscriptStateDump*` and `AngelscriptStateSnapshot.cpp` | compatibility flags, `PrecompiledData.csv`, `FJITDatabase` tables | External observation of the remaining bridge. Fields are labelled `StaticJITCompatibility`; old production selection flag names were removed. | Keep observable until sibling cutover, then replace with Provider/stable-route tables. |
| `AngelscriptTest/StaticJIT/AOT/*`, `AngelscriptPrecompiledDataArchiveTests.cpp`, NativeForms tests | fixed Guid/cache fixture and explicit compatibility switches | Test-only generation, archive and generated-entry verification. These artifacts are not packaged startup caches. | Migrate in sibling acceptance; current missing local matched pair is IC-404. |

## Removed production paths

- `FAngelscriptEngineConfig` no longer contains `bGeneratePrecompiledData`,
  `bIgnorePrecompiledData` or `bSkipStaticJITCodeGen`.
- `FAngelscriptEngine` no longer contains `bUsePrecompiledData` or
  `bUsedPrecompiledDataForPreprocessor` and no longer exposes
  `IsGeneratingPrecompiledData`.
- `FromCurrentProcess` no longer parses `-as-generate-precompiled-data`,
  `-as-ignore-precompiled-data` or `-as-skip-static-jit-codegen`.
- `Initialize` never probes configuration-specific or generic
  `PrecompiledScript*.Cache`, never compares its `DataGuid`, never saves one and
  never requests the cache-generation forced exit.
- `InitialCompile` always obtains module inputs from authoritative source/Cache V2
  paths; HotReload and packaged Runtime reload no longer have an old-preprocessor
  disable branch.
- `Tools/RunPackage.ps1` has no pre-generation parameter/process and
  `Config/DefaultGame.ini` stages `../Script` as loose NonUFS.

## Rejection and debug behavior

`Cache/AngelscriptCacheLegacyCutover.*` checks only the fixed filenames through an
existence predicate. It never opens or hashes their payload. A found file produces
the stable `[CacheV2][LegacyRejected]` diagnostic and source compilation continues.
`Binds.Cache` is reported independently as accepted. The offline Python dump tool
does not decode old archives; C++ owns this live startup diagnostic because it has
the authoritative source-root inventory.

Focused evidence:

- LegacyCutover `4/4`: `Saved/Tests/cache-v72-legacy-production-cutover-test1/
  20260811_071242_351_7486152a`.
- StaticJIT NativeForms `2/2`: `Saved/Tests/
  cache-v72-staticjit-nativeforms-regression1/
  20260811_071320_880_b9a79b58`.
- Engine isolation `14/14`: `Saved/Tests/
  cache-v72-engine-isolation-regression1/
  20260811_071404_507_e257a14d`.
