# UHT Naming Map

This file records the coordinated naming and configuration migration for `AngelscriptUHTTool`. Implementation remains tracked by `tasks.md`.

## Canonical Concepts

| Responsibility | Final name |
| --- | --- |
| Global compile selection | `EAngelscriptFunctionBindingMethod` / `FunctionBindingMethod` |
| Runtime-linked module config array | `NativeRuntimeLinkedModules` |
| Target-module config array | `NativeModuleFunctionAddressModules` |
| Config serialization | UE enum tokens and `+TArrayProperty=ModuleName` syntax |
| Per-function diagnostic/statistics category | `FunctionBindingCategory` |
| Aggregate counts, rates, and module totals | `FunctionBindingStatistics` |
| UHT outer pipeline concept | `FunctionBinding` |
| UHT exporter identifier | `AngelscriptFunctionBinding` |
| Generated source prefix | `AS_FunctionBinding_` |
| Target-module binding descriptor | `FAngelscriptNativeModuleFunctionBinding` |
| Target-module shared bridge header | `NativeModuleFunctionBindingBridge.h` |
| Target-module shared bridge namespace | `FAngelscriptNativeModuleFunctionBindingBridge` |
| Target-module Modular Feature name | `AngelscriptNativeModuleFunctionBinding` |
| Target-module compile capability | `WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS` |
| Stable bridge header location | `Source/AngelscriptRuntime/FunctionBinding/NativeModuleFunctionBindingBridge.h` |
| Engine distribution values | `SourceBuilt`, `Installed`, `Unknown` |
| ABI layout file | `native-module-function-binding-layout-version.txt` |

The old JSON module profile/policy files are retired. Module lists come from the two UE compile-options arrays.

## UHT Domain Records

| Current name | Final name | Reason |
| --- | --- | --- |
| `AngelscriptFunctionTableExporter` | `AngelscriptFunctionBindingExporter` | The UHT hook exports binding registrations, not a generic table. |
| `AngelscriptGeneratedFunctionBinding` | `AngelscriptGeneratedFunctionRegistration` | Represents generated registration data and emits a registration line. |
| `AngelscriptModuleBinding` | `AngelscriptNativeModuleFunctionBinding` | Describes a target-module-provided native function binding. |
| `AngelscriptSupportedModules` | `AngelscriptFunctionBindingModuleConfiguration` | Reads the UE method and module arrays; it is not a JSON policy object. |
| `AngelscriptModuleBindingGenerationConfig` | Remove | JSON profile configuration is retired. |
| `AngelscriptModuleBindingGenerationProfiles` | Remove | Distribution-specific JSON profiles are retired. |
| `AngelscriptModuleBindingGenerationSelection` | Remove | The selected method and UE arrays replace profile selection. |
| `AngelscriptModuleGenerationSummary` | `AngelscriptFunctionBindingModuleStatistics` | This is per-module binding statistics, not generic module generation. |
| `AngelscriptGeneratedFunctionDiagnosticRow` | `AngelscriptFunctionBindingDiagnosticRow` | The row is a binding diagnostic record. |
| `AngelscriptSkippedFunctionBinding` | `AngelscriptSkippedFunctionDiagnostic` | The record describes a skipped-function diagnostic. |
| `FGeneratedFunctionTableTimingSummary` | `FGeneratedFunctionBindingTimingSummary` | Generated shard timing belongs to FunctionBinding, not a generic table. |
| `RecordGeneratedFunctionTableShardTiming` | `RecordGeneratedFunctionBindingShardTiming` | Runtime timing API follows the outer FunctionBinding concept. |

## UHT Pipeline Responsibilities

`AngelscriptFunctionTableCodeGenerator` is not replaced by one new monolithic name. Its responsibilities are split as follows:

| Current responsibility | Final type |
| --- | --- |
| UE method/array/config loading | `AngelscriptFunctionBindingModuleConfiguration` |
| Per-function eligibility and category analysis | `AngelscriptFunctionBindingAnalyzer` |
| Unified header/UHT signature resolution | `AngelscriptFunctionSignatureResolver` |
| Runtime-linked generated binding source emission | `AngelscriptFunctionBindingEmitter` |
| Target-module thunk emission | `AngelscriptNativeModuleFunctionBindingEmitter` |
| JSON, CSV, and log statistics | `AngelscriptFunctionBindingStatisticsWriter` |
| Stale generated-file cleanup | `AngelscriptFunctionBindingOutputCleaner` |

`AngelscriptFunctionBindingExporter` remains the UHT exporter hook and consumes the shared analysis result. `AngelscriptHeaderSignatureResolver` becomes the lower-level header declaration parser, while `AngelscriptFunctionSignatureBuilder` becomes the higher-level signature resolver.

## UHT Field and Helper Names

| Current name | Final name |
| --- | --- |
| `EntryKind` | `FunctionBindingCategory` |
| `ThunkStyle` | Remove |
| `ModuleBindingOnly` | `NativeModuleFunctionAddressModules` |
| `ModuleBindingGenerationEnabled` | Remove; `FunctionBindingMethod` is the source of truth |
| `ModuleBindingGenerationProfile` | Remove; UE config arrays are the source of truth |
| `ModuleBindingGenerationConfigPath` | Remove |
| `ModuleBindingConfigured` | `ConfiguredNativeModuleFunctionAddressModules` |
| `DirectBindEntries` | `NativeRuntimeLinkedCount` |
| `StubEntries` | `ReflectiveFallbackCount` |
| `ModuleBindingEntries` | `NativeModuleFunctionAddressCount` |
| `directBindRate` | `nativeRuntimeLinkedRate` |
| `stubRate` | `reflectiveFallbackRate` |
| `moduleBindingRate` | `nativeModuleFunctionAddressRate` |
| `WriteCoverageDiagnostics` | `WriteFunctionBindingStatistics` |
| `WriteGenerationSummary` | `WriteFunctionBindingStatisticsJson` |
| `WriteModuleSummaryCsv` | `WriteFunctionBindingModuleStatisticsCsv` |
| `WriteEntryCsv` | `WriteFunctionBindingDiagnosticsCsv` |
| `WriteSkippedEntriesCsv` | `WriteSkippedFunctionDiagnosticsCsv` |
| `WriteSkippedReasonSummaryCsv` | `WriteSkippedFunctionReasonStatisticsCsv` |
| `ApiMacroPattern` | `ExportVisibilityMacroPattern` |
| `ShouldGenerate` | `ShouldGenerateFunctionBinding` |
| `TryBuild` | `TryResolveFunctionSignature` |
| `TryBuildModuleBinding` | `TryResolveNativeModuleFunctionSignature` |
| `IsWhitelistedDirectBindFallback` | `IsExplicitSignatureFallbackAllowed` |
| `ClassifyUnsupportedModuleBindingProtocol` | `ClassifyUnsupportedNativeModuleFunctionBindingSignature` |
| `ReadModuleBindingSetting` | `ReadFunctionBindingMethod` |

## Target-Module Bridge Names

| Current name | Final name |
| --- | --- |
| `AngelscriptModuleBindingProtocol.h` | `NativeModuleFunctionBindingBridge.h` |
| `FAngelscriptModuleBindingCallFrame` | `FAngelscriptNativeModuleFunctionBindingCallFrame` |
| `FAngelscriptModuleBinding` | `FAngelscriptNativeModuleFunctionBinding` |
| `FAngelscriptModuleBindingFeatureView` | `FAngelscriptNativeModuleFunctionBindingView` |
| `FAngelscriptModuleBindingProtocol` | `FAngelscriptNativeModuleFunctionBindingBridge` |
| `AngelscriptModuleBindingFeature` | `AngelscriptNativeModuleFunctionBinding` |
| `Bind_ModuleBinding.cpp` | `Bind_NativeModuleFunctionBinding.cpp` |
| `GAngelscriptModuleBindingGenericHook` | `GAngelscriptNativeModuleFunctionBindingGenericThunk` |
| `InjectModuleBindingFeature` | `RegisterNativeModuleFunctionBindings` |
| `ResolveModuleBindingClass` | `ResolveNativeModuleFunctionClass` |
| `MakeModuleBindingGenericFuncPtr` | `MakeNativeModuleFunctionBindingGenericFuncPtr` |
| `ModuleBindingLinkProbe` | `NativeModuleFunctionBindingBridgeProbe` |

## Generated Artifacts

| Current name | Final name |
| --- | --- |
| `AS_FunctionTable_<Module>_*.gen.cpp` | `AS_FunctionBinding_<Module>_*.gen.cpp` |
| `AS_FunctionTable_<Module>_ModuleBinding_*.cpp` | `AS_FunctionBinding_<Module>_NativeModuleFunctionAddress_*.cpp` |
| `AS_FunctionTable_Summary.json` | `AS_FunctionBindingStatistics.json` |
| `AS_FunctionTable_ModuleSummary.csv` | `AS_FunctionBindingModuleStatistics.csv` |
| `AS_FunctionTable_Entries.csv` | `AS_FunctionBindingDiagnostics.csv` |
| `AS_FunctionTable_SkippedEntries.csv` | `AS_FunctionBindingSkippedFunctions.csv` |
| `AS_FunctionTable_SkippedReasonSummary.csv` | `AS_FunctionBindingSkippedFunctionStatistics.csv` |
| `module-binding-generation-modules.json` | Remove; use UE compile-options arrays |
| `native-module-function-address-profiles.json` | Remove; use `NativeModuleFunctionAddressModules` |
| `module-binding-layout-version.txt` | `native-module-function-binding-layout-version.txt` |
| `AS_FunctionTable_Engine_ModuleBinding_LinkProbe.cpp` | `AS_FunctionBinding_Engine_NativeModuleFunctionBindingBridgeProbe.cpp` |

`AngelscriptFunctionSignature`, `FAngelscriptFunctionBinding`, and `RegisterFunctionBinding` remain valid names and are not part of this rename. The word `Table` remains valid for an actual contiguous target-module payload table, but not for the outer UHT pipeline or generated source-shard family.
