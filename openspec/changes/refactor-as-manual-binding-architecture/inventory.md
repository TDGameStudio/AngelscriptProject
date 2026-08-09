# Implementation Baseline Inventory

Captured: 2026-08-08 before plugin source changes.

## Environment and verification baseline

- Parent checkout: `main` at `cd5cc87c9aa63b6d7035934ca549b53f357efe02`.
- Plugin submodules were clean before implementation:
  - `Plugins/Angelscript`: `4899ff5e37725ef32ba78329d28f62a763360b32`.
  - `Plugins/AngelscriptGameplayTags`: `a3c8a091ba21a94a305668d90cd025f91d082952`.
  - `Plugins/AngelscriptGAS`: `fce032f06649e345d084f4aa502943ce2dfca8d2`.
- Actual configured engine used by the project runner: Unreal Engine 5.8.0, CL 55116800.
- Baseline build: success, zero actions, report `Saved/Build/direct-bind-baseline/20260807_235541_544_8d79d8d7`.
- Generated binding tests: `3/3 PASS`, report `Saved/Tests/direct-bind-baseline-generated/20260807_235553_508_e6cfac5f`.
- Reflective fallback cache: `8/8 PASS`, report `Saved/Tests/direct-bind-baseline-reflection-cache/20260807_235724_046_8d515366`.
- RPC declarations: `6/6 PASS`, report `Saved/Tests/direct-bind-baseline-rpc/20260807_235835_626_02dc75b8`.
- GameplayTags: `12/12 PASS`, report `Saved/Tests/direct-bind-baseline-gameplaytags/20260807_235919_432_2d9347e9`.
- GAS: `248/248 PASS`, report `Saved/Tests/direct-bind-baseline-gas/20260807_235919_433_1f817710`.
- FColor binding contract: `3/3 PASS`, report `Saved/Tests/direct-bind-baseline-color/20260808_000733_852_0dff7e43`.
- FString format and binding behavior: `9/9 PASS`, report `Saved/Tests/direct-bind-baseline-fstring/20260808_001317_970_303d7308`.
- UHT resolver/emit fixtures: `3/3 PASS`, serialized rerun report `Saved/Tests/direct-bind-baseline-uht-fixed/20260808_001216_336_ae22a54d`. The first run was `2/3` because it overlapped another Editor process; the serialized rerun is the comparison baseline.
- Multi-engine lifecycle: `10/10 PASS` (`8` success and `2` success-with-warnings), report `Saved/Tests/direct-bind-baseline-multiengine/20260808_000733_852_543f889c`.
- TypeUsage: serialized rerun `5/5 PASS`, report `Saved/Tests/direct-bind-baseline-typeusage-serialized/20260808_000838_090_9e25b9ab`.
- A first parallel TypeUsage run reported `4/5` because three editors attempted to replace the same `Intermediate/CachedAssetRegistry` file; its sole error was `LogFileManager` cache-file contention, and the isolated rerun passed. Architecture validation runs that write the shared asset cache remain serialized.
- State dump: `3/3 PASS`; `34/34` CSVs, `601457` total rows, report `Saved/Tests/direct-bind-baseline-dump/20260808_000252_085_5bfe148e`, dump `Saved/Automation/StateDump/DumpAll_5676F055465C9CF82D8FA991D32E7871`.
- The documented reflective prefix was stale. The real registered prefix is `Angelscript.TestModule.Bindings.ReflectiveFallbackCache`; `Documents/Guides/Test.md` is corrected in this change.
- `Script/Binds.Cache`: 3,853,902 bytes, SHA-256 `DD482308E3EDE1DB990FD5230A55DE9A3A221886003EDD4670F6F49554C2E094`.
- `Script/Binds.Cache.Headers`: 2,241,487 bytes.

No separately labelled pre-edit run was retained for FVector, generic-call, startup timing/allocation, or the cache-create/load branch. Their pre-edit contracts were instead represented by the full checked-in source/tests, the state dump and cache hashes above, and the multi-engine/TypeUsage baselines. Final parity therefore uses focused post-edit tests, native-form source inventories, generated StaticJIT compilation, cache schema/hash comparisons, and a current full-suite run; `verification.md` records this limitation rather than inventing missing baseline artifacts.

## Legacy symbol inventory

Counts are exact source-text matches across the three plugin source trees at the baseline commit. They are navigation/zero-reference baselines, not semantic operation counts.

| Concept | Files | Matches |
|---|---:|---:|
| `FAngelscriptBinds::FBind` | 139 | 250 |
| Parsed file-static C++ provider objects | 135 | 233 |
| `RegisterBinds` | 3 | 13 |
| `CallBinds` | 10 | 22 |
| `GetSortedBindArray` | 1 | 4 |
| `EOrder` | 129 | 226 |
| PreviousBind family | 63 | 308 |
| `DisabledBindNames` | 9 | 97 |
| `StartupModule()` declarations in scanned source | 17 | 28 |
| Native arrival/unload hook terms | 5 | 50 |
| Ambient/current-engine access terms | 110 | 437 |
| Native/trivial/template-native form terms | 46 | 357 |

The parsed provider population consists of 233 C++ objects in 135 files. The broader 250-match set additionally includes declarations, tests, and the C# emitter template. Production binding directories contain 126 provider files; the direct-callable scan identifies 106 files with a candidate lambda passed to an AS callable registration API and 20 without such a lambda.

## Required out-of-directory coverage

The migration must not assume providers live only in `AngelscriptRuntime/Binds`. The baseline includes provider-like/test/generated sources in:

- `AngelscriptUHTTool/AngelscriptFunctionBindingEmitters.cs`
- `AngelscriptEditor/EditorMenuExtensions/ScriptEditorPrompts.cpp`
- `AngelscriptRuntime/Testing/AngelscriptTest.cpp`
- `AngelscriptRuntime/Testing/AngelscriptTestSuite.cpp`
- `AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp`
- `AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`
- `AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`
- `AngelscriptTest/Core/AngelscriptEngineParityTests.cpp`
- `AngelscriptTest/Core/AngelscriptMultiEngineLifecycleTests.cpp`
- `AngelscriptTest/Coverage/AngelscriptCoverageGCTestHelpers.cpp`
- `AngelscriptTest/Bindings/AngelscriptOptionalBindingsTests.cpp`
- `AngelscriptTest/Performance/AngelscriptPerformanceTestTypes.cpp`
- GameplayTags and GAS runtime bind directories.

NativeModuleFunctionAddress is separately inventoried as the retained exception: the target shards use Runtime-independent POD structs and `IModularFeatures`; the Runtime consumer owns registered/unregistered/object-constructed handlers and pending/injected state.

## Full legacy-reference file list

- `Plugins/Angelscript/Source/AngelscriptEditor/EditorMenuExtensions/ScriptEditorPrompts.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetManagerScriptMixins.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetRegistry.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AVolume.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CollisionProfile.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ConfigEnums.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CoreGlobals.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Deprecations.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAnchors.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptGameThreadScopeWorldContext.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FApp.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBodyInstance.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCommandLine.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCpuProfilerTraceScoped.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFileHelper.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGenericPlatformMisc.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGeometry.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGuid.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionKeyMapping.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionValue.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLatentActionInfo.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMargin.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMemoryReader.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMessageDialog.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FNumberFormattingOptions.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FOverlapResult.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FParse.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane4f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformApplicationMisc.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformMisc.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformProcess.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere3f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FStringTableRegistry.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTimespan.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FunctionLibraryMixins.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Hash.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_JsonObjectConverter.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_LandscapeProxy.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Logging.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SoftObjectPath.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Stats.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UAssetManager.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UCollisionProfile.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UDataTable.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnhancedInputComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UFXSystemComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPackage.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPoseableMeshComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPrimitiveComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UProjectileMovementComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkeletalMeshComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkinnedMeshComponent.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTestSuite.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptOptionalBindingsTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineParityTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptMultiEngineLifecycleTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageGCTestHelpers.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptPerformanceTestTypes.cpp`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionBindingEmitters.cs`
- `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTags/Private/Binds/Bind_FGameplayTag.cpp`
- `Plugins/AngelscriptGAS/Source/AngelscriptGAS/Private/Binds/Bind_AngelscriptGASLibrary.cpp`
- `Plugins/AngelscriptGAS/Source/AngelscriptGAS/Private/Binds/Bind_FGameplayAbilitySpec.cpp`
- `Plugins/AngelscriptGAS/Source/AngelscriptGAS/Private/Binds/Bind_FGameplayAttribute.cpp`
- `Plugins/AngelscriptGAS/Source/AngelscriptGAS/Private/Binds/Bind_FGameplayEffectSpec.cpp`
- `Plugins/AngelscriptGAS/Source/AngelscriptGAS/Private/Binds/Bind_FGameplayTagBlueprintPropertyMap.cpp`

## Reproduction commands

```powershell
rg -l -g '*.{h,cpp,cs}' 'FAngelscriptBinds::FBind' Plugins/Angelscript/Source Plugins/AngelscriptGameplayTags/Source Plugins/AngelscriptGAS/Source
rg -n -g '*.{h,cpp,cs}' 'RegisterBinds|CallBinds|GetSortedBindArray|EOrder|PreviouslyBoundFunction|PreviouslyBoundGlobalProperty|DisabledBindNames' Plugins/Angelscript/Source Plugins/AngelscriptGameplayTags/Source Plugins/AngelscriptGAS/Source
rg -n -g '*.{h,cpp,cs}' 'IModularFeatures|OnModularFeatureRegistered|OnModularFeatureUnregistered|ObjectConstructed' Plugins/Angelscript/Source
rg -n -g '*.{h,cpp,cs}' 'FAngelscriptEngine::Get\(\)|FAngelscriptEngine::GetCurrent\(\)|TryGetCurrentEngine\(' Plugins/Angelscript/Source Plugins/AngelscriptGameplayTags/Source Plugins/AngelscriptGAS/Source
```
