# AngelscriptTest Self-Containment Audit

Change: `fix-angelscript-test-nonunity-self-containment`
Date: 2026-06-24
Scope: `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`
Mode: record-only; no test source files are changed by this audit.

## Summary

The reported build failure is a test translation-unit self-containment issue. Some test `.cpp` files compile only when UBT's unity chunk happens to include another file first, or when a local helper header re-exports a dependency that the `.cpp` actually uses directly.

Current scan records:

- 9 first-wave implementation touch points: the reported failures plus one same-pattern `CreateIsolatedFullEngine` direct-include gap, and two additional single-file compile self-containment gaps.
- 27 strict direct-include candidates across SDK execution helpers, parser/native support, engine macros, isolated engine acquisition, and memory probe helpers.
- 67 functional-helper namespace candidates: 1 known missing namespace resolution failure and 66 file-level `using namespace AngelscriptFunctionalTestUtils;` imports to review or localize.
- 1 StaticJIT SDK type-boundary fix where `asCModule*` is passed to an API declared as `asIScriptModule*`.

## Helper Ownership

Use this map when implementing the changes:

- `ExecuteScriptFunction` and `FSdkFunctionInvoker`: `AngelScriptSDK/AngelscriptSDKTestExecutionHelpers.h`
- `AngelscriptNativeTestSupport::FParserAccessor`: `AngelScriptSDK/AngelscriptNativeTestSupport.h`
- `ASTEST_CREATE_ENGINE`, `ASTEST_GET_ENGINE`, `ASTEST_CREATE_ENGINE_FULL`, `ASTEST_CREATE_ENGINE_NATIVE`, `ASTEST_RESET_ENGINE`: `Shared/AngelscriptTestMacros.h`
- `CreateIsolatedFullEngine`: `Shared/AngelscriptTestEngineAcquisition.h`
- `AcquireTransientFullTestEngine`, `AcquireTransientFullTestEngineWithProbe`, `GetTransientFullTestEngineStorage`: `Shared/AngelscriptTestMemoryProbe.h`
- `CompileScriptModule`, `SpawnScriptActor`, `BeginPlayActor`, `ReadPropertyValue`, `ReadIntPropertyChecked`, `ReadStringPropertyChecked`: namespace `AngelscriptFunctionalTestUtils`, header `Shared/AngelscriptFunctionalTestUtils.h`

Prefer the local include style already used by the target file (`"AngelscriptTestMacros.h"` vs `"Shared/AngelscriptTestMacros.h"`). The important invariant is that the file sees the owning declaration without relying on another `.cpp`.

## First-Wave Required Fixes

These are the changes most directly tied to the cross-machine compile errors or the same strict self-containment pattern.

| Path | Line | Symbol / issue | Required action |
| --- | ---: | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptGlobalVarTests.cpp` | 234 | `ExecuteScriptFunction` not found | Include `AngelscriptSDKTestExecutionHelpers.h` directly. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptParserTests.cpp` | 98 | `AngelscriptNativeTestSupport::FParserAccessor` not found | Include `AngelscriptNativeTestSupport.h` directly. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITDiagnosticsTests.cpp` | 106 | `ASTEST_CREATE_ENGINE` not found | Include `AngelscriptTestMacros.h` directly. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp` | 451 | `CreateIsolatedFullEngine` not found | Include `AngelscriptTestEngineAcquisition.h` directly. |
| `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp` | 207 | `CreateIsolatedFullEngine` via transitive macro/umbrella path | Include `AngelscriptTestEngineAcquisition.h` directly. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp` | 56 | `asCModule*` to `asIScriptModule*` conversion | Make the `asCModule : asIScriptModule` relationship visible at the call site, or cast once at the public API boundary. |
| `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadVersionChainTests.cpp` | 124 | `CompileScriptModule`, plus later `SpawnScriptActor`, `BeginPlayActor`, `ReadPropertyValue` | Qualify calls with `AngelscriptFunctionalTestUtils::` or add a function-local `using namespace AngelscriptFunctionalTestUtils;` inside each affected static test body. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` | 592 | `FCoreDelegates::EOnScreenMessageSeverity` used in a public header | Include `Misc/CoreDelegates.h` directly. |
| `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp` | 108 | `TObjectIterator<UPackage>` dereferences `UPackage` through only a forward declaration | Include `UObject/Package.h` directly. |

## Strict Direct-Include Candidates

These are all `.cpp` files from the current scan that use a known helper symbol without directly including the owning header. Some compile today through a themed helper or compatibility umbrella; implementation can either add the direct include or explicitly decide that the themed helper owns the re-export contract.

### SDK Execution Helper

Owning header: `AngelScriptSDK/AngelscriptSDKTestExecutionHelpers.h`

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderBytecodeTests.cpp:171`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptBuilderGlobalVariableTests.cpp:129`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptGlobalVarTests.cpp:234`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptSDKOperatorTests.cpp:31`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptSDKTypeTests.cpp:85`

Notes:

- `AngelscriptBuilderBytecodeTests.cpp` and `AngelscriptBuilderGlobalVariableTests.cpp` currently get the helper through `AngelscriptBuilderTestSupport.h`.
- `AngelscriptSDKOperatorTests.cpp` and `AngelscriptSDKTypeTests.cpp` currently compile through SDK support headers. Under the strict rule, add the direct owning include or record the re-export as intentional.

### Native Parser Support

Owning header: `AngelScriptSDK/AngelscriptNativeTestSupport.h`

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptParserTests.cpp:98`

### Test Engine Macros

Owning header: `Shared/AngelscriptTestMacros.h`

- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorAsyncTests.cpp:311`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorBasicTests.cpp:35`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorClassTests.cpp:41`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorCompilationEventsTests.cpp:38`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorContextTests.cpp:22`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorDirectiveTests.cpp:38`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorFunctionMacroTests.cpp:40`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorImportTests.cpp:41`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorMacroShapeTests.cpp:36`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorNamespaceTests.cpp:53`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorPathTests.cpp:39`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorPropertyTests.cpp:53`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorStructTests.cpp:41`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorSummaryTests.cpp:63`
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptVirtualScriptPathPreprocessorTests.cpp:15`
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITDiagnosticsTests.cpp:106`

Notes:

- The Preprocessor files currently get macros through `Preprocessor/AngelscriptPreprocessorTestHelpers.h`, which includes `AngelscriptTestMacros.h`.
- If the project wants theme helpers to own macro re-export, keep these as documented exceptions. If it wants strict `.cpp` direct includes, add `AngelscriptTestMacros.h` to each file.

### Isolated Engine Acquisition

Owning header: `Shared/AngelscriptTestEngineAcquisition.h`

- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFormatEngineScopeTests.cpp:60`
- `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp:207`
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp:451`

Notes:

- `AngelscriptFormatEngineScopeTests.cpp` currently gets this through `AngelscriptTestUtilities.h`.
- `AngelscriptEngineMemoryLifecycleTests.cpp` currently gets this through `AngelscriptTestMacros.h` -> `AngelscriptTestUtilities.h`.

### Memory Probe Acquisition

Owning header: `Shared/AngelscriptTestMemoryProbe.h`

- `Plugins/Angelscript/Source/AngelscriptTest/Memory/BindFreeEvidenceTests.cpp:6`
- `Plugins/Angelscript/Source/AngelscriptTest/Memory/GlobalContainerCycleBoundedTests.cpp:51`

Notes:

- Both files currently use `AngelscriptTestUtilities.h`. New code should prefer `AngelscriptTestMemoryProbe.h` for the probe acquisition/storage helpers.

## Functional Helper Namespace Candidates

The direct compile failure is `HotReload/AngelscriptHotReloadVersionChainTests.cpp`, which includes `AngelscriptFunctionalTestUtils.h` but calls helper names unqualified and without any local/file-level import.

The broader hygiene issue is file-level `using namespace AngelscriptFunctionalTestUtils;`. The archived unity-symbol cleanup prefers explicit qualification or function-body imports because file-level imports leak helper names through unity chunks.

### Missing Namespace Resolution

- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadVersionChainTests.cpp:124`

Required action: qualify the helper calls or add function-local imports inside `RunVersionChainAndCDOConsistency` and `RunCDOAndInstanceConsistency`.

### File-Level Namespace Imports To Review

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptDebuggerValueTests.cpp:15`
- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptGameplayFunctionLibraryTests.cpp:36`
- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptSoftReferenceFunctionLibraryTests.cpp:35`
- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptWorldCollisionAsyncSweepBindingsTests.cpp:32`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassActorConstructionTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassComponentConstructionTests.cpp:16`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassComponentMetadataTests.cpp:10`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassConstructionContextTests.cpp:15`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassHelperTests.cpp:18`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassObjectConstructionTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassReferenceSchemaTests.cpp:17`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassReplicationTests.cpp:15`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassTickSettingsTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASFunctionDispatchTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASFunctionMetadataTests.cpp:14`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASFunctionOptimizedCallTests.cpp:14`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASFunctionProcessEventTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASFunctionWorldContextTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptInterfaceDispatchBridgeTests.cpp:15`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptLiteralAssetPostInitTests.cpp:11`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptScriptClassCreationTests.cpp:19`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptScriptClassShapeTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptScriptClassStructureTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptCodeCoverageTests.cpp:136`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptComponentProcessEventTests.cpp:16`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptDebuggerAutoEvaluationTests.cpp:16`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorComponentManagementTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorComponentTests.cpp:13`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorInteractionTests.cpp:10`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorLifecycleTests.cpp:9`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorMixinTests.cpp:7`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorPropertyInterfaceTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorScriptOverrideTests.cpp:9`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorSpawnPatternsTests.cpp:20`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorTimerRuntimeBehaviorTests.cpp:25`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Animation/AngelscriptAnimationAnimNotifyScriptTests.cpp:19`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Animation/AngelscriptAnimationAnimNotifyStateScriptTests.cpp:19`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Blueprint/AngelscriptBlueprintChildTests.cpp:7`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Blueprint/AngelscriptBlueprintImpactTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Component/AngelscriptComponentDefaultPropertyOverrideTests.cpp:20`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Component/AngelscriptComponentLifecycleExtendedTests.cpp:17`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Component/AngelscriptComponentMultiLevelHierarchyTests.cpp:22`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Component/AngelscriptComponentSplineUsageTests.cpp:22`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Component/AngelscriptComponentTests.cpp:16`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Delegate/AngelscriptDelegateBroadcastWithParamsTests.cpp:20`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Delegate/AngelscriptDelegateTests.cpp:14`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Functions/AngelscriptFunctionMixinReferenceMatrixTests.cpp:20`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativeBridgeTests.cpp:26`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp:15`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativePointerOffsetTests.cpp:40`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativeTests.cpp:31`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Objects/AngelscriptObjectModelTests.cpp:14`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Property/AngelscriptPropertyAccessorRemovalTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Property/AngelscriptPropertyMetaMatrixTests.cpp:19`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Rendering/AngelscriptRenderingDynamicMaterialTests.cpp:21`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Types/AngelscriptTypesScriptDataAssetTests.cpp:20`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Types/AngelscriptTypesStringInterpolationAndFNameLiteralTests.cpp:20`
- `Plugins/Angelscript/Source/AngelscriptTest/Functional/Widget/AngelscriptWidgetBindWidgetTests.cpp:22`
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadLiteralAssetTests.cpp:12`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptRuntimeMicrobenchmarkTests.cpp:14`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestWorldTests.cpp:28`
- `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp:17`
- `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp:19`
- `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GameLifetime.cpp:45`
- `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp:89`
- `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_WorldTick.cpp:88`

Recommended action: replace each file-level import with explicit qualification or move the import into the narrowest function body that uses several helpers. Batch this by directory to keep review size manageable.

## StaticJIT Type Boundary

Path: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp:56`

Problem: `ModuleDesc->ScriptModule` is an `asCModule*`, while `GenerateStaticJITAotArtifactsForDiagnostics` is declared on the public `asIScriptModule*` interface. On some include orders the derived/base relationship is not visible at that call site.

Implementation options:

- Prefer including the SDK internal module header that makes `asCModule : asIScriptModule` visible, if that is the existing local pattern for StaticJIT AOT tests.
- If visibility is still compiler-dependent, cast once at the public API boundary to `asIScriptModule*`, keeping the diagnostics API public-facing.

## Exclusions And False Positives

- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptAssetManagerFunctionLibraryTests.cpp` has a local `ReadIntPropertyChecked` helper in its own namespace; it is not an `AngelscriptFunctionalTestUtils` miss.
- `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleDirectBindRuntimeTests.cpp` already includes `Shared/AngelscriptTestMacros.h`; the direct-include scan should accept path-qualified includes.
- Files that already use `AngelscriptFunctionalTestUtils::` qualification, such as `GC/AngelscriptGCTests.cpp`, are not namespace failures.
- Header files are excluded from this audit. The immediate issue is `.cpp` translation-unit self-containment.

## Verification Plan

After implementation, run:

1. `git -C Plugins/Angelscript diff --check`
2. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label nonunity-self-containment -TimeoutMs 600000 -NoXGE`
3. If the editor keeps the plugin DLLs locked, run targeted compile verification with `-NoHotReloadFromIDE -NoLink -File=<reported cpp>` for each reported file.
4. If an audit script is added for this change, run it first in advisory mode, then with `-FailOnRequired` once the first-wave fixes are applied.

If the build finds additional missing symbols, add them to this file before applying the same direct-include or local-namespace pattern.

## Verification Result

- 2026-06-25: Full build passed with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label nonunity-self-containment-full -TimeoutMs 600000 -NoXGE`.
- Build log: `D:\Workspace\AngelscriptProject\Saved\Build\nonunity-self-containment-full\20260625_095001_487_41dd1e06\Build.log`.
- UBT executed 407 actions and linked `UnrealEditor-AngelscriptRuntime.dll` and `UnrealEditor-AngelscriptTest.dll` successfully.
- 2026-07-01: Added `scan-test-self-containment.ps1` and ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec\changes\fix-angelscript-test-nonunity-self-containment\scan-test-self-containment.ps1 -FailOnRequired`.
- Result: required failures `0`; advisories `154`.
- Decision: keep the scan as an OpenSpec-local advisory diagnostic for now. The remaining advisories are mostly broad `AngelscriptFunctionalTestUtils` file-level imports and native SDK helper umbrella re-exports; those should be handled in a separate hygiene pass instead of expanding this cross-machine compile fix into a large mechanical refactor.
- 2026-07-02: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label nonunity-closeout -TimeoutMs 1800000 -NoXGE` passed after the final direct-include additions.
