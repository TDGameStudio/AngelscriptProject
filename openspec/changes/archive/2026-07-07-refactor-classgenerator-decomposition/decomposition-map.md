# ClassGenerator Decomposition Map

Execution contract for the phase split. Line ranges are planning snapshots from the current `AngelscriptClassGenerator.cpp` and `ASClass.cpp`; re-measure by symbol anchor before each batch since earlier batches shift line numbers and the file has already drifted past the original count. All moves are **cut/paste of bodies only** — no logic edits.

## Shared header

- `AngelscriptClassGenerator.h` — single declaration source for `FAngelscriptClassGenerator`, including the public surface (`AddModule`, `Setup`, `PerformFullReload`, `PerformSoftReload`, `WantsFullReload`, `NeedsFullReload`, `GetFullReloadLines`) and current private data/method declarations. Do not split private members into a second header in this pass.
- Optional later `AngelscriptClassGeneratorInternal.h` — only for file-local helper declarations or a follow-up collaborator extraction after the phase split is green; it MUST NOT become a partial declaration of `FAngelscriptClassGenerator`.

## Static helper and constant ownership

- `UniqueCounter` / `UniqueGeneratedCounter` stays single-owned. Do not copy it into multiple phase units; keep it in the driver or move it once into the unit that owns full-reload/reinstancing allocation, then expose only through one file-local helper path.
- `GetReflectedObjectForScriptType` moves with `_ReloadPlanning.cpp`; it is part of reflected-type reload comparison.
- `GetARO` moves with `_Reinstancing.cpp`; it is part of GC reference schema detection.
- File-static `FName` / `FString` constants must move with their only consumer when usage is single-phase. Constants shared by multiple target units should be duplicated only if they are immutable name literals with no state, or promoted to a small internal constants header after a non-unity build proves include boundaries.
- Any new helper that needs `FModuleData`, `FClassData`, `FDelegateData`, or `FReloadPropagation` access should be a private member declaration in `AngelscriptClassGenerator.h` or a function-local lambda inside the owning member; do not create file-level helpers that require widening private type visibility.

## `AngelscriptClassGenerator.cpp` → phase units

| Target unit | Functions (current lines) |
|---|---|
| `AngelscriptClassGenerator.cpp` (driver) | `AddModule` (84), `EnsureClassAnalyzed` (125), `GetClassDesc` (144), `GetUnrealName` (158), `PerformFullReload` (2436), `PerformSoftReload` (2441), `PerformReload` (2446–2852, break into steps), `EnsureReloaded*` (2852–2907), `EnsureClassFinalized` (2907), `GetFullReloadLines` (6170), `WantsFullReload` (6179), `NeedsFullReload` (6191), `Setup` (in header/driver) |
| `_Analyze.cpp` | `Analyze(Module,Class)` (175–1535, **~1360, break into steps**), `Analyze(Module,Delegate)` (1535), `InitEnums` (1713), `AnalyzeEnums` (1790), `SetupModule` (1875), `Analyze(Module)` (1953), `TryGenerateClassRenameRedirects` (2015), `IsReloadingModule` (1778) |
| `_ReloadPlanning.cpp` | `AddReloadDependency` x2 (2112, 2127), `PropagateReloadRequirements` x2 (2179, 2248), `ResolvePendingReloadDependees` (2267), `ShouldFullReload` x3 (2285, 2416, 2425), `HasInterfaceListChanged` (2298), `HasReloadedReflectedScriptType` x2 (2346, 2393), `GetReloadRequirementForNewScriptType` |
| `_FullReload.cpp` | `CreateFullReloadClass` (2919), `ResolveClassRedirectReplacedClass` (2974), `FullReloadRemoveClass` (3046), `CreateFullReloadStruct` (3053), `CreateFullReloadDelegate` (3108), `DoFullReload(Class)` (3140), `DoFullReloadStruct` (3530), `DoFullReloadClass` (3570–4044, **~470, break into steps**), `CopyClassInheritedMetaData` (4044), `DoFullReload(Enum)` (4076), `DoFullReload(Delegate)` (4224) |
| `_SoftReload.cpp` | `LinkSoftReloadClasses` x3 (4216, 4354, 4362), `PrepareSoftReload` (4404), `DoSoftReload` (4432–5088, **~650, break into steps**), `SoftReloadFunction` (5088), `SoftReloadType` (5102) |
| `_Generation.cpp` | `AddClassProperties` (3166–3443, **~280**), `GetDataFor` x2 (3443, 3451), `ResolveCodeSuperForProperty` (3485), `AddFunctionReturnType` (4273), `AddFunctionArgument` (4304) |
| `_Finalize.cpp` | `DestructScriptObject`/`ReinitializeScriptObject` may go here or Reinstancing (5117, 5134), `FinalizeClass` (5353), `FinalizeActorClass` (5517–5752, **~230**), `FinalizeComponentClass` (5752), `FinalizeObjectClass` (5764), `VerifyClass` (5770–6000, **~230**), `InitClassTickSettings` (6000), `CallPostInitFunctions` (6078), `InitDefaultObjects` (6121), `InitDefaultObject` (6160), `UpdateConstructAndDefaultsFunctions` (6203), `SetScriptStaticClass` (5269), `GetNamespacedTypeInfoForClass` (6226) |
| `_Reinstancing.cpp` | `DestructScriptObject` (5117), `ReinitializeScriptObject` (5134), `DetectAngelscriptReferences` (5168), `CreateDebugValuePrototype` (5237), `CleanupRemovedClass` (5299) |

## `ASClass.cpp/.h` → units

| Target unit | Contents |
|---|---|
| `ASClass.cpp/.h` | `UASClass` only: constructors, CDO/default-object, tick, replication, `ApplyScriptDefaults`, static constructors/destructor, `GetFirstASClass*` |
| `ASFunction.cpp` (+ header split) | `UASFunction` base: `FinalizeArguments`, `OptimizedCall_*`, `AllocateFunctionFor`, `UASFunctionNativeThunk`, `GetSourceFilePath/LineNumber` |
| `ASFunctionDispatchVariants.h/.cpp` | the explicit `~40` `UASFunction_*` `UCLASS()` declarations moved verbatim (or generated into committed explicit C++ before UHT runs); `AS_FUNCTION_DISPATCH_VARIANTS(X)` may be used for non-UHT implementation bodies/factory tables only |

`ASClass`/`UASFunction` work is second-stage: complete the ClassGenerator phase split first, then either continue here with a separate validation batch or split dispatch work into a follow-up OpenSpec change.

`ASStruct.cpp/.h` and `AngelscriptClassRedirects.cpp/.h` are already cohesive — leave as-is (optionally move redirect helpers if `_FullReload` needs them).

## Do-not-touch (owned by other changes)

- `WILL-EDIT` markers and `WITH_ANGELSCRIPT_HAZE` macros → `refactor-as-audit-remove-with-angelscript-haze`. Relocate verbatim if a moved function contains them; do not rewrite.
- `FAngelscriptEngine::Get()` / `CurrentWorldContext` call sites (81 in this file) → deferred de-globalization plan. Relocate verbatim; do not thread a context parameter here.

## Characterization coverage targets (task group 2)

Existing net is broad: `ClassGenerator/` (27 files), `HotReload` (31 files, incl. `ChangeClassification` 22-method reload-requirement matrix and `HotReloadProperty`), `Compiler`, `Coverage`, `Functional`, plus archived `test-uasfunction-*` dispatch coverage. Full covered-vs-gap breakdown in `coverage-gaps.md`. New direct tests fill only the confirmed gaps: reload dependency propagation, interface-list-change classification, `VerifyClass` reject branches, `Error`/name-conflict paths, argument marshalling matrix, `ResolveCodeSuperForProperty`, `CreateDebugValuePrototype`, live-instance reinstancing, override-component wiring, namespaced-UCLASS generation. Do not re-add already-covered scenarios.
