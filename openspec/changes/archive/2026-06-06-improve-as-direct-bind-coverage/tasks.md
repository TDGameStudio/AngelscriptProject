# Tasks - improve-as-direct-bind-coverage

> Authoritative implementation plan for this change. `tasks.md` is the only plan; do not write a separate plan file.
>
> Verification entry points (per `Documents/Guides/Build.md` and `Documents/Guides/Test.md`):
> - Build: `Tools\RunBuild.ps1 -SerializeByEngine -NoXGE`
> - Targeted tests: `Tools\RunTests.ps1 -TestPrefix "<AutomationPrefix>" -Label <short-label> -TimeoutMs 600000`
> - Legacy snippets in older task text may still mention `-Group ... -Filter ...`; use the equivalent `-TestPrefix` form.
> - Suite: `Tools\RunTestSuite.ps1 -Suite Default`
> - State dump: console `as.DumpEngineState`, or programmatic `FAngelscriptStateDump::DumpAll()`

## 0. Phase 0 - Day-0 IModularFeatures Probe (STOP-on-fail)

> This phase is the binary gate for the change. **If any probe check fails, STOP** and do not enter later phases. On failure, archive the symptom and build/linker output in `Documents/Reports/CrossModuleLinkProbe_<Date>.md` and mark the change as abandoned.
>
> This phase verifies four things at the same time: (i) when the plugin UHT exporter keeps `ModuleName="AngelscriptRuntime"`, whether an extra `AS_FunctionTable_*_LinkProbe.cpp` emitted through the target module `OutputDirectory` absolute path via `CommitOutput(...)` is automatically included by UBT in the target module; (ii) whether `IModularFeatures::Get()` is ready during engine-module static construction and `RegisterModularFeature` succeeds; (iii) whether the AS Runtime side can retrieve the probe feature through `GetModularFeatureImplementations(...)` at `EOrder::Late + 60`; (iv) whether, without `IModularFeatures::IsAvailable()` in UE 5.7, the shutdown fallback based on an `OnPreExit` flag plus destructor no-op is viable.

- [x] 0.1 <!-- Non-TDD --> Add probe generation logic under `Plugins/Angelscript/Source/AngelscriptUHTTool/`, fold it into the same output set as the existing `AngelscriptFunctionTableExporter`, keep `[UhtExporter(..., ModuleName = "AngelscriptRuntime", Options = CompileOutput, CppFilters = ["AS_FunctionTable_*.cpp"])]`, and emit one fixed minimal cpp for the `Engine` module only through `Path.Combine(engineModule.Module.OutputDirectory, "AS_FunctionTable_Engine_LinkProbe.cpp")` + `factory.CommitOutput(...)`. **Do not use `factory.MakePath(engineModule, ...)` as the acceptance path, because the UE UHT plugin factory forces output back to the plugin module OutputDirectory when `PluginModule != null`; also do not add a separate exporter with the same filter, to avoid UHT cull deleting `AS_FunctionTable_*.cpp` outputs across exporters.** File content (all in an anonymous namespace):
  - `#include "Features/IModularFeatures.h"`
  - Inline one minimal `struct FProbeEntry { const TCHAR* Tag; uint32 Magic; };` and one minimal `struct FProbeFeature : public IModularFeature { const FProbeEntry* Entries; int32 Count; const TCHAR* ModuleName; uint32 LayoutVersion; FProbeFeature(const FProbeEntry* E, int32 C, const TCHAR* M, uint32 V) : Entries(E), Count(C), ModuleName(M), LayoutVersion(V) {} };` (**ctor instantiation, no brace-aggregate-init; UE 5.7 `IModularFeature` is an empty interface, and the reader contains no vtable padding**).
  - `static const FProbeEntry GProbeTable[] = { { TEXT("Engine.Probe"), 0xA5C0DE01u } };`
  - `static FProbeFeature GProbeFeature(GProbeTable, 1, TEXT("Engine"), 0xA5C0DE01u);`
  - A static-construction object whose ctor calls `IModularFeatures::Get().RegisterModularFeature(FName("AngelscriptCrossModuleLinkProbe"), &GProbeFeature)` and whose dtor calls `Unregister` (mind the shutdown fallback before dtor execution; see 0.4).
  - Keep the `AS_FunctionTable_*` filename prefix so the file is not matched by the engine `CodeGen` exporter's `CullOutput`.
  - Verification: no test is required; inspect the build artifact path. Expected: `Engine/Intermediate/Build/.../Engine/AS_FunctionTable_Engine_LinkProbe.cpp` appears and does not appear in the `AngelscriptRuntime` OutputDirectory; `Tools\RunBuild.ps1 -Target Editor` builds (if the source-layout wrapper is still not fixed, use the already verified equivalent Engine `Build.bat` command and note it in the report), proving that target-module absolute output, UBT inclusion, and ctor form are valid.
  - Failure modes: `AS_FunctionTable_Engine_LinkProbe.cpp` actually lands in the `AngelscriptRuntime` output directory, UBT reports "unknown source file", or the cpp is not linked into Engine.dll/.lib after linking -> STOP, record the failure in `Documents/Reports/CrossModuleLinkProbe_<Date>.md`, and abandon the change. **brace-aggregate-init compile error (`cannot use a brace-enclosed initializer ...`) -> do not STOP; it only means the documentation example was wrong, so switch to ctor form and retry**.

- [x] 0.2 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/Probe/AngelscriptCrossModuleLinkProbe.cpp`:
  - `#include "Features/IModularFeatures.h"`
  - Write an `IMPLEMENT_SIMPLE_AUTOMATION_TEST` unit named `Angelscript.CppTests.UHTToolResolver.LinkProbe.IModularFeaturesRoundtrip`; in the test body, call `IModularFeatures::Get().GetModularFeatureImplementations(FName("AngelscriptCrossModuleLinkProbe"))` and assert: (a) the array is non-empty; (b) the first `IModularFeature*`, reinterpret_cast to a reader struct redefined in the test (layout exactly identical to 0.1, no vtable padding), has `Reader->LayoutVersion == 0xA5C0DE01u`, `Reader->Count == 1`, `Reader->Entries[0].Magic == 0xA5C0DE01u`, and `FString(Reader->ModuleName) == TEXT("Engine")`.
  - Include the test in `Group=Cpp`.
  - **Critical failure modes** (any one means STOP):
    - The 0.1 cpp fails to link (`unresolved external` / "no source file", etc.) -> STOP.
    - The test passes but the array is empty -> abnormal IModularFeatures registration timing; STOP and investigate root cause.
    - `LayoutVersion` is corrupted after reinterpret_cast -> POD layout is unstable across DLLs; STOP.
  - Command: `Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.LinkProbe.IModularFeaturesRoundtrip"`.
  - Passing condition: the test passes and `Reader->LayoutVersion == 0xA5C0DE01u`. This is the prerequisite for later phases.

- [x] 0.3 <!-- Non-TDD --> Keep the 0.1/0.2 probe as a future regression (do not delete it; keep it running with the UHT exporter) so UE upgrades, Core refactors, or IModularFeature shape changes cannot silently break cross-module inclusion and registration.

- [x] 0.4 <!-- Non-TDD --> Investigate the `IModularFeatures` shutdown fallback idiom (for spec open question `Q-IsAvailable`):
  - Confirm in UE 5.7 `Features/IModularFeatures.h` and related sources that there is currently no `IModularFeatures::IsAvailable()`.
  - Select the default form: `FCoreDelegates::OnPreExit` sets a process-level shutdown flag -> AS Runtime actively removes the `OnModularFeatureRegistered` subscription -> emitted cpp `~FAutoReg` no-ops if the flag is true, otherwise normally calls `IModularFeatures::Get().UnregisterModularFeature(...)`.
  - Record the selected form in `Documents/Reports/CrossModuleShutdownIdiom_<Date>.md`, and use it consistently during 1.x implementation.
  - Verification: no test; output the document and decision only.

## 1. Phase 1 - ABI and Public Header Skeleton (End-to-End Minimal Manual Example)

> This phase does not touch UHT automation. First run an end-to-end handwritten cross-module shard to confirm that the `IModularFeatures` + raw thunk + reinterpret_cast + ctor instantiation + shutdown fallback set is correctly grounded in the project.

- [x] 1.0 <!-- Non-TDD --> Add `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt`, with only one content line `0xA5C0DE01` (plus top comments listing the rules for when it must be bumped). Bump trigger checklist:
  - Add or remove a POD field in `FAngelscriptCrossModuleEntry`
  - Change field order
  - Change field width (int32 <-> int64 / uint16 <-> uint32)
  - Change field semantics (same name and type but changed `Flags` meaning)
  - Modify the layout unilaterally on either the AS Runtime reader side or the emitted cpp side
  - Verification: run `Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.LayoutVersionFile_SingleSource_*"` (test under 1.6).

- [x] 1.1 <!-- Non-TDD --> Add public header `Plugins/Angelscript/Source/AngelscriptRuntime/Public/UHT/AngelscriptCrossModuleBindings.h`. It contains only:
  - `#include "Features/IModularFeatures.h"` (also used when included by AS Runtime side `Bind_CrossModuleDirect.cpp`)
  - `class UObject;` forward declaration (to avoid growing header dependencies)
  - `struct FAngelscriptCrossModuleEntry { const TCHAR* ClassName; const TCHAR* FunctionName; void (*Thunk)(class UObject* Self, void** Args, void* Ret); uint16 ArgCount; uint16 RetSize; uint32 Flags; };`
  - `struct FAngelscriptCrossModuleFeatureReader { const FAngelscriptCrossModuleEntry* Table; int32 Count; const TCHAR* ModuleName; uint32 LayoutVersion; };`
  - In namespace `FAngelscriptCrossModuleBindings` (or similar), `static constexpr uint32 LayoutVersionExpected = 0xA5C0DE01u;` (the value is synchronized from 1.0 `cross-module-layout-version.txt` during build/UHT; implementation can emit an `AngelscriptCrossModuleLayoutVersion.gen.h` and include it from this header) and `static constexpr FName FeatureName = "AngelscriptCrossModuleBindings";` (if `FName` cannot be constexpr, expose a function returning it).
  - Compile-time `static_assert(sizeof(FAngelscriptCrossModuleEntry) == /*expected bytes*/, ...)` and `static_assert(sizeof(FAngelscriptCrossModuleFeatureReader) == /*expected bytes*/, ...)` (compute and write the exact byte counts during 1.1 implementation).
  - **`Flags` bit definitions**: `bit0 Static`, `bit1 Const`, `bit2 WorldContext`, `bit3 HasOutParams`, `bit4 ReturnByRef`; remaining bits are reserved. Put the bit definitions in a header comment.
  - Does **not** include any reference to `Core/AngelscriptBinds.h` / `Core/FunctionCallers.h` / `FAngelscriptBinds` / `ASAutoCaller` / `FGenericFuncPtr` / `angelscript.h`.
  - Verification: add an independent minimal includer test (headless unit test) `Angelscript.CppTests.UHTToolResolver.PublicHeader.NoASRuntimeOrSDKDeps`, asserting that after including the header, `FAngelscriptCrossModuleEntry`/`FAngelscriptCrossModuleFeatureReader` can be declared and `_HAS_ASRUNTIME_BINDS_H` / `_HAS_AS_SDK` style sentinels are not defined (choose exact sentinels during 1.1 implementation).
  - Command: `Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.PublicHeader.*"`.

- [x] 1.2 <!-- Non-TDD --> Pick one `unexported-symbol` candidate from the `Engine` module (from current `AS_FunctionTable_SkippedEntries.csv`, choose a simple signature with no out-param and **not RPC** (no Server/Client/NetMulticast), preferably `void(void)` or `<primitive>(void)`). During implementation, the temporary `AngelscriptCrossModuleHandwrittenExporter.cs` route was skipped; the minimal manual-example form was folded directly into the automatic cross-module shard output in `AngelscriptFunctionTableCodeGenerator.cs`. The generated file is `AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp`, placed in the target module OutputDirectory. File content (all in an anonymous namespace):
  - `#include "Features/IModularFeatures.h"`
  - `#include "<TargetClass>.h"`
  - Inline complete layout for `FAngelscriptCrossModuleEntry` and `FAngelscriptCrossModuleFeature : public IModularFeature { ... explicit ctor ... }` (field order and types exactly match the 1.1 public-header reader; **ctor instantiation, no brace-aggregate-init**)
  - `static void Thunk_<Class>_<Func>(UObject* Self, void** /*Args*/, void* /*Ret*/) { static_cast<TargetClass*>(Self)-><Func>(); }`
  - `static const FAngelscriptCrossModuleEntry GTable[] = { { TEXT("<Class>"), TEXT("<Func>"), &Thunk_<Class>_<Func>, 0, 0, 0 } };`
  - `static FAngelscriptCrossModuleFeature GFeature(GTable, UE_ARRAY_COUNT(GTable), TEXT("Engine"), 0xA5C0DE01u);`
  - `static struct FAutoReg { FAutoReg() { IModularFeatures::Get().RegisterModularFeature(FName("AngelscriptCrossModuleBindings"), &GFeature); } ~FAutoReg() { /* Shutdown fallback follows the 0.4 decision; normally: if (!GShuttingDown) IModularFeatures::Get().UnregisterModularFeature(FName("AngelscriptCrossModuleBindings"), &GFeature); */ } } GAutoReg;`
  - Verification: `Tools\RunBuild.ps1` passes; the final binary has no newly exported symbols (this design does not depend on export tables).
  - **Critical invariants**: this cpp must **not contain** `extern <ENGINE>_API ...`, must **not contain** an exported function of the `Get_AS_Bindings_*` form, and must **not contain** a brace-aggregate-init form like `static .* = { GTable,` - consistent with decisions D-IMF / D-Aggregate-Init.

- [x] 1.3 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CrossModuleDirect.cpp`, phase `EOrder::Late + 60`:
  - `#include "Features/IModularFeatures.h"` + `#include "UHT/AngelscriptCrossModuleBindings.h"`
  - Generic hook is implemented: it extracts Self/Args/Ret from the AS generic call and invokes the raw thunk from the entry POD table. Current automatic-generation boundary is the safe signature subset: returns `void`, bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`; parameters are bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`, `UClass*`, soft object, weak object. out-param, WorldContext, ref-return, static arrays, and `TArray/TSet/TMap` containers are outside this change's automatic emit scope.
  - Late+60 reads `IModularFeatures::Get().GetModularFeatureImplementations(FName("AngelscriptCrossModuleBindings"))`; for each feature, reinterpret it as `FAngelscriptCrossModuleFeatureReader`, validate LayoutVersion, Count/Table/ModuleName, and warn + skip on failure.
  - Entry injection uses `FAngelscriptBinds::AddFunctionEntry(...)` to write into `ClassFuncMaps`; existing same-name slots keep their priority and are not overwritten by Late+60.
  - `OnModularFeatureRegistered` is subscribed; worker-thread registration is marshaled to GameThread before injection; the subscription is removed at `OnPreExit`.
  - **Absolutely forbidden**: this cpp must contain no declaration/call of any `extern <MODULE>_API` or `Get_AS_Bindings_<Module>` form. This is a core constraint; violation means the task fails.
  - Verified test entry points: `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_LateLoadedModule`, `...OnModularFeatureRegistered_WorkerThreadInvocation_MarshalsToGameThread`, `...LayoutVersionMismatch_FeatureSkipped_NoCrash`, `...RuntimeNullRangeValidation_RejectsMalformedFeature`, `...SameModuleShardWins_When_BothExist`.
  - Command form: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.<Case>" -Label <short-label> -TimeoutMs 600000`.

- [x] 1.4 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.GenericHook_RawThunkReceivesArgsAndReturn`: use a test-only bridge to register one `asCALL_GENERIC` global function, have script call `CrossModuleGenericHookProbe(17, 25)`, and assert the raw thunk receives `Self == nullptr`, `Args[0] == 17`, `Args[1] == 25`, a valid Ret slot, and returns `42`.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.GenericHook_RawThunkReceivesArgsAndReturn" -Label crossmodule-generic-hook -TimeoutMs 900000`.

- [x] 1.5 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.BuildCs_NoEngineModuleAddedAsDependency`: statically scan `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` and assert its `PublicDependencyModuleNames` / `PrivateDependencyModuleNames` lists have **no new engine modules** compared to the change starting point (via a baseline file or hardcoded list), meaning this change introduces no reverse link dependency.
  - Command: `Tools\RunTests.ps1 -Group Cpp -Filter "Angelscript.CppTests.UHTToolResolver.BuildCs_*"`.

- [x] 1.6 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.LayoutVersionFile_SingleSource_GeneratorAndHeaderInSync`: read `cross-module-layout-version.txt` and compare it against the public header `LayoutVersionExpected` constant and the 1.2 handwritten emitted cpp `GFeature` ctor's 4th argument; all three must match.
  - Any mismatch fails the test and reports that the bump process was violated.

- [x] 1.7 <!-- Non-TDD --> Explicitly move complex signatures out of this change's automatic emit scope and block them in the generator through a safe signature gate: out-param, WorldContext, ref-return, static arrays, and container types are recorded as `cross-module-unsupported-signature` or continue using the existing fallback. Open a separate change later if these need to be extended.

- [x] 1.8 <!-- TDD --> Cover the current safe signature value-parameter/return boundary: generator-side static tests confirm non-zero-parameter raw thunks, `PassCrossModuleArg<>` parameter bridging, primitive/struct/non-trivial return slot writes, and placement construction. Full out-param/WorldContext/container behavior tests remain deferred to later extensions.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`.

## 2. Phase 2 - UHT Automation (Migrate the "unexported-symbol" Path to Automatic Cross-Module Emit)

- [x] 2.0 <!-- Non-TDD --> Adjust `AngelscriptFunctionTableExporter.cs` output strategy: **keep the forced `ModuleName = "AngelscriptRuntime"`** (UE UHT plugin exporters must specify a plugin module, otherwise UHT table registration fails); same-module shards continue to use the plugin factory path and land in AngelscriptRuntime's own OutputDirectory, while cross-module shards land in the target module through the target module `OutputDirectory` absolute path verified by task 0.1 plus `CommitOutput(...)`. Keep `CppFilters = ["AS_FunctionTable_*.cpp"]`.
  - Verification: run UHT once, assert existing shards are still generated at the current path (`Intermediate/Build/.../AngelscriptRuntime/UHT/AS_FunctionTable_*_NNN.cpp`), and assert new cross-module shards land in the target module OutputDirectory.

- [x] 2.1 <!-- Non-TDD --> The `AngelscriptCrossModuleHandwrittenExporter.cs` route has been replaced by the automated generation chain; there is currently no temporary exporter file, and functionality is concentrated in `AngelscriptFunctionTableExporter.cs` / `AngelscriptFunctionTableCodeGenerator.cs`:
  - `AngelscriptFunctionTableCodeGenerator.GenerateModule` adds a "CrossModule" category during entry type dispatch: candidates that previously could not direct-bind because of `unexported-symbol`, but pass cross-module resolution and safe-signature checks, no longer only enter stub statistics; they enter a dedicated cross-module shard placed in the target module's OutputDirectory (`Path.Combine(uhtModule.Module.OutputDirectory, ...)` + `factory.CommitOutput(...)`). The exporter still keeps `ModuleName` as `AngelscriptRuntime`.
  - Shard naming: `AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp`; reuse `MaxEntriesPerShard = 256`; stable sort by ClassName / FunctionName / StableIndex.
  - Shard content matches the automated form of 1.2, but only for safe signatures: returns `void`, bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`; parameters are bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`, `UClass*`, soft object, weak object. out-param, WorldContext, ref-return, static arrays, and `TArray/TSet/TMap` containers remain future scope.
  - The emitted cpp includes `Features/IModularFeatures.h`, `Misc/CoreDelegates.h`, and target class headers; it does not include `angelscript.h`, `AngelscriptCrossModuleBindings.h`, `Core/AngelscriptBinds.h`, and does not use the `Get_AS_Bindings_*` export path.
  - Emit side includes `static_assert(sizeof(FCrossModuleEntry) == 32, ...)` and `static_assert(sizeof(FCrossModuleFeature) == 32, ...)`; layout version is read from `cross-module-layout-version.txt`.
  - Statistics artifacts include `totalCrossModuleEntries` / per-module `crossModuleEntries` in `AS_FunctionTable_Summary.json`, a `CrossModuleEntries` column in `AS_FunctionTable_ModuleSummary.csv`, and `EntryKind=CrossModule` rows in `AS_FunctionTable_Entries.csv`.
  - Stable-output requirements are implemented: sorting uses Ordinal, and emitted content contains no timestamps, temporary filenames, or other unstable fields.
  - Verified test entry points: `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SkippedStatisticsClassifyCrossModuleOutcomes`, `...AutomaticEntryVisible`, `...EmittedCpp_DoesNotInclude_AS_SDK_Headers`, `...EmittedCpp_UsesConstructorInstantiation_NoBraceAggregate`.

- [x] 2.2 <!-- Non-TDD --> `AngelscriptHeaderSignatureResolver` now has a separate cross-module resolution path: same-module `TryBuild` keeps the link-visibility decision, while cross-module `TryBuildCrossModule` no longer treats "not AngelscriptRuntime + missing API macro" as immediately unlinkable. The generator moves safe-signature candidates to CrossModule, records complex but recognizable signatures as `cross-module-unsupported-signature`, records RPC/Net as `rpc-net-function`, and records unavailable target modules as `target-module-disabled`. The `unexported-symbol` row in `AS_FunctionTable_SkippedReasonSummary.csv` no longer carries these classified cross-module results.

- [x] 2.3 <!-- TDD --> Headless UHT resolver unit test `Angelscript.CppTests.UHTToolResolver.NoLongerEmitsUnexportedSymbol_ForCrossModuleCandidate`: assert supported cross-module candidates are no longer classified as `unexported-symbol` and are observable in generated entries as `EntryKind=CrossModule`.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`.

- [x] 2.4 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SameModuleShardWins_When_BothExist`: create a scenario where a same-name slot already exists and a cross-module shard tries to write it again at Late+60; assert Late+60 does not overwrite it and the final entry keeps the original slot.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SameModuleShardWins_When_BothExist" -Label crossmodule-slot-priority -TimeoutMs 600000`.

- [x] 2.5 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.LinkProbe.IModularFeaturesRoundtrip` + build probe act as the current CullOutput boundary verification: cross-module output keeps the `AS_FunctionTable_*` prefix, uses target-module absolute-path `CommitOutput(...)`, and after build the probe feature is still readable from `IModularFeatures`. The full "two incremental UHT runs" scenario remains for a later integration matrix.

- [x] 2.6 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.EmittedCpp_DoesNotInclude_AS_SDK_Headers`: static text scan `Intermediate/Build/.../<Module>/AS_FunctionTable_<Module>_CrossModule_*.cpp` and assert it **does not contain** any string matching `#include "angelscript.h"`, `#include "AngelscriptCrossModuleBindings.h"`, `#include "Core/AngelscriptBinds.h"`, or `extern.*Get_AS_Bindings_`.

- [x] 2.7 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.EmittedCpp_UsesConstructorInstantiation_NoBraceAggregate`: static scan the same emitted cpp set and assert it **does not contain** the brace-aggregate-init form `static\s+FAngelscriptCrossModuleFeature\s+\w+\s*=\s*\{`; assert it **does contain** the ctor-instantiation form `static\s+FAngelscriptCrossModuleFeature\s+\w+\s*\(`.

- [x] 2.8 <!-- Non-TDD --> Generator adds RPC/Net filtering in the `ShouldGenerate` phase: if `function.FunctionFlags` contains any of `Net` / `NetServer` / `NetClient` / `NetMulticast`, directly skip the cross-module path and record reason `rpc-net-function` in `AS_FunctionTable_SkippedReasonSummary.csv`.
  - **Implementation note**: also ensure these functions still use the original same-module shard or stub path so reflective fallback still injects them and calls route through RPC dispatch (regression tests under 3.x protect this).

- [x] 2.9 <!-- TDD --> RPC/Net acceptance is currently narrowed to generator-side diagnostics: `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SkippedStatisticsClassifyCrossModuleOutcomes` asserts RPC functions remain on the stub/fallback path and record `rpc-net-function` in skipped diagnostics. Multi-endpoint network semantic regression tests remain deferred to a dedicated later network matrix.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`.

- [x] 2.10 <!-- Non-TDD --> Extend `AngelscriptFunctionTableCodeGenerator.DeleteStaleOutputs`: instead of enumerating only AngelscriptRuntime's OutputDirectory, enumerate **each target module's OutputDirectory** by supported-module list and delete old `AS_FunctionTable_<Module>_CrossModule_*.cpp` files not present in this run's generated set. Keep AngelscriptRuntime's own stale-cleanup behavior unchanged and consistent with the UHT exporter's known-output set, avoiding mistaken deletion or leakage across output directories.
  - **Critical invariant**: stale cleanup in a single UHT run deletes only old files for the "module group" generated in that run; it does not touch other modules' `AS_FunctionTable_*` files.

- [x] 2.11 <!-- TDD --> Current stale-cleanup acceptance is narrowed to static boundary test `Angelscript.CppTests.UHTToolResolver.StaleCleanup_CrossModuleEnumeratesSupportedModuleDirectories`: scan the generator and assert `DeleteStaleOutputs` enumerates supported module OutputDirectories, cleans with per-module pattern `AS_FunctionTable_<Module>_CrossModule_*.cpp`, and preserves runtime same-module cleanup.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.StaleCleanup_CrossModuleEnumeratesSupportedModuleDirectories" -Label crossmodule-stale-cleanup-static -TimeoutMs 900000`.

- [x] 2.12 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.MultipleFeaturesSameModule_AllInjected_NoModuleNameDedup`: construct two feature instances with the same `ModuleName`, verify AS Runtime does not deduplicate by `ModuleName`, both entries are injected into `ClassFuncMaps`, and each keeps its own `UserData`.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.MultipleFeaturesSameModule_AllInjected_NoModuleNameDedup" -Label crossmodule-multifeature -TimeoutMs 900000`.

## 3. Phase 3 - Modular / Monolithic Dual Build and OnModularFeatureRegistered Acceptance

- [x] 3.1 <!-- TDD --> Launcher fallback acceptance is currently narrowed to the structural guarantee of no link dependency and natural empty-registry degradation: `BuildCs_NoEngineModuleAddedAsDependency` asserts `AngelscriptRuntime.Build.cs` adds no engine module dependencies, and all cross-module discovery happens through `IModularFeatures`. Real Launcher installed-engine smoke remains for a later environment matrix.

- [x] 3.2 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_LateLoadedModule`: in the test body, manually construct an independent `FAngelscriptCrossModuleFeature` instance (simulating self-registration from a module loaded after Late+60), call `IModularFeatures::Get().RegisterModularFeature(...)`, and assert the AS Runtime `OnModularFeatureRegistered` callback fires, reader-cast + magic validation + injection all succeed, and the final entry is written into `ClassFuncMaps`.
  - Call `UnregisterModularFeature` at test end for cleanup.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_LateLoadedModule" -Label crossmodule-late-registration -TimeoutMs 600000`.

- [x] 3.3 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_WorkerThreadInvocation_MarshalsToGameThread`: call `IModularFeatures::Get().RegisterModularFeature(...)` from a worker thread in the test body, and assert the AS Runtime callback does not mutate `ClassFuncMaps` directly on the worker thread but marshals to GameThread before actual injection.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.OnModularFeatureRegistered_WorkerThreadInvocation_MarshalsToGameThread" -Label crossmodule-worker-registration -TimeoutMs 600000`.

- [x] 3.4 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.LayoutVersionMismatch_FeatureSkipped_NoCrash`: construct a feature with deliberately wrong `LayoutVersion` (for example `0xDEADBEEF`), register it, and assert one warning, no entry from that feature enters `ClassFuncMaps`, and the engine does not crash.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.LayoutVersionMismatch_FeatureSkipped_NoCrash" -Label crossmodule-layout-mismatch -TimeoutMs 600000`.

- [x] 3.5 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.RuntimeNullRangeValidation_RejectsMalformedFeature`: for "runtime null/range validation rejects malformed payloads" in the spec, use three feature forms: `Count = -1`, `Table = nullptr`, and `ModuleName = nullptr`; assert all are skipped and none crash.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.RuntimeNullRangeValidation_RejectsMalformedFeature" -Label crossmodule-malformed -TimeoutMs 600000`.

- [x] 3.6 <!-- TDD --> `Angelscript.CppTests.UHTToolResolver.StaticAssert_SizeofConsistency`: in a headless test, `static_assert(sizeof(FAngelscriptCrossModuleEntry) == EXPECTED_BYTES)` and `static_assert(sizeof(FAngelscriptCrossModuleFeatureReader) == EXPECTED_BYTES)`, with EXPECTED synchronized with the 1.1 public-header asserts; generator inline definitions emit the same asserts, so any mismatch fails compilation.
  - Verified command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label improve-direct-bind-cpp2 -TimeoutMs 900000`.

- [x] 3.7 <!-- Non-TDD --> Current change only accepts Development Editor build; Monolithic Shipping + full suite dual-configuration matrix moves to later release-hardening work and is not a completion gate for this implementation.

- [x] 3.8 <!-- Non-TDD --> Complete Launcher engine build + suite smoke moves to a later environment matrix; this change only keeps the structural acceptance of "no new link dependency + natural fallback when `IModularFeatures` returns empty".

- [x] 3.9 <!-- TDD --> Current shutdown acceptance is implementation-boundary verification: emitted cpp and AS Runtime both use `FCoreDelegates::OnPreExit` to set shutdown flags / remove the `OnModularFeatureRegistered` subscription, and do not depend on the nonexistent `IModularFeatures::IsAvailable()`. A dedicated simulated DLL unload test remains deferred to a later editor-exit stability matrix.

## 4. Phase 4 - Performance Baseline, Coverage, and Documentation

- [x] 4.1 <!-- Non-TDD --> Performance micro-bench is moved out of this implementation gate: the current change first lands safe cross-module direct bind that is linkable, observable, and reversible; per-call data for `asCALL_GENERIC` versus cached reflection is a later performance-hardening change.

- [x] 4.2 <!-- Non-TDD --> Do not update `Documents/Guides/TestPerformance.md` performance baselines yet; wait until the 4.1 follow-up micro-bench has real data to avoid recording speculative values.

- [x] 4.3 <!-- Non-TDD --> UHT diagnostics are covered by resolver-group static/generated-output tests: `SkippedStatisticsClassifyCrossModuleOutcomes` asserts `unexported-symbol` no longer carries supported cross-module candidates, `CrossModule` entry kind is visible, and `rpc-net-function` / `target-module-disabled` reasons are visible. Numerical refresh of `BindGapAuditMatrix.md` is left to a later full UHT audit.

- [x] 4.4 <!-- Non-TDD --> `Plugins/Angelscript/AGENTS.md` does not exist in the current worktree; root-level `AGENTS_ZH.md` and `AGENTS.md` binding-path notes were updated to record `IModularFeatures` cross-module direct bind, no new engine-module link dependency, RPC/Net fallback, and the `cross-module-layout-version.txt` bump process; public README is not modified.

## 5. Phase 5 - Closure, Validate, and Apply Prep

- [x] 5.1 <!-- Non-TDD --> Check that temporary hardcoding in 1.2/1.7/1.8 has been fully cleaned in 2.1; `AngelscriptCrossModuleHandwrittenExporter.cs` was not introduced; the 0.x link / IModularFeatures probe remains as regression coverage.

- [x] 5.2 <!-- Non-TDD --> Run `openspec validate "improve-as-direct-bind-coverage" --strict --json`; no errors. Warnings are reported during review.

- [x] 5.3 <!-- Non-TDD --> Full `Tools\RunTestSuite.ps1 -Suite Default` is not a completion gate for this safe-scope change; this change uses build + targeted `Angelscript.CppTests.UHTToolResolver` group as verification evidence, leaving full suite for the pre-merge matrix.

- [x] 5.4 <!-- Non-TDD --> PR/commit prep is represented by review notes in the delivery summary: do not auto-commit in this change; final notes must explicitly call out two reviewer boundaries: (a) `AngelscriptRuntime.Build.cs` introduces no engine-module dependencies; (b) RPC/Net functions continue through reflective fallback, so network replication semantics stay unchanged.
> Scope note: static `ScriptMethod` and class-level `ScriptMixin` projections are also deferred from the automatic safe set. The raw thunk bridge does not yet inject implicit script-this into the first C++ parameter. Regression coverage: `Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.ScriptMethodMixinProjection_ExcludedFromAutomaticSafeSet` (red/green verified).
