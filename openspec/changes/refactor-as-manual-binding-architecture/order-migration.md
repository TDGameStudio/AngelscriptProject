# Legacy Order to Seven-Phase Migration

The legacy-expression counts below preserve the pre-migration inventory of 233 parsed file-static C++ provider objects in 135 files, plus the UHT RuntimeLinked emitter template. A current-source audit on 2026-08-08 found 250 syntactic direct-provider declarations in 131 source files. Collapsing the two mutually exclusive `Bind_UStruct.cpp` branches leaves 247 unique symbol/name/phase identities; one is the `WITH_DEV_AUTOMATION_TESTS`-only `Bind_DirectBindArchitectureProbe`. Excluding that probe gives 246 production identities in 130 hand-written provider files. UHT RuntimeLinked and Editor CodeGen providers are emitted text and are audited separately below rather than counted as checked-in provider objects.

| Current phase | Production identities |
|---|---:|
| `TypeDeclarations` | 57 |
| `TypeInfrastructure` | 54 |
| `ManualBindings` | 128 |
| `GeneratedBindings` | 1 |
| `ReflectionBindings` | 2 |
| `PostReflectionBindings` | 4 |
| `Finalization` | 0; the only checked-in direct record is the dev-only architecture probe |

## Phase invariants

- `TypeDeclarations`: typedef, enum, funcdef, object/value/interface declaration only.
- `TypeInfrastructure`: adapters/finders, string factory, default array, well-known slots, interface/type scaffolding needed after declaration.
- `ManualBindings`: hand-written behaviours, constructors, methods, properties, globals, namespaces, and exact UFunction-address overrides.
- `GeneratedBindings`: UHT RuntimeLinked tables, editor CodeGen output, and the Runtime-side NativeModuleFunctionAddress bridge bootstrap.
- `ReflectionBindings`: reflected type/property/UFunction/default binding and reflective fallback creation.
- `PostReflectionBindings`: reflection-dependent mixins and actor/component/subsystem method synthesis that still registers script callables.
- `Finalization`: ToString completeness checks, BindDB metadata/save inputs, and consistency checks; no new AS type/function/property registration. ToString contributions are produced in `TypeInfrastructure` and consumed into script-visible `FString` conversions in `ManualBindings`.

One legacy callback may produce several rows after migration. Physical legacy callback boundaries are not preserved when they mix responsibilities.

## Complete expression mapping

| Legacy expression | Parsed objects | Migration rule |
|---|---:|---|
| Constructor default / raw integer test order | 17 | Production registration defaults to `ManualBindings`; split any declaration work to `TypeDeclarations`. Test-only raw-order fixtures are replaced by local collection phase tests. |
| `Early - 1` | 5 | `TypeDeclarations`. |
| `Early` | 60 | `TypeDeclarations`; split any adapters/finders or callable registrations to `TypeInfrastructure` / `ManualBindings`. |
| `Early + 1` | 5 | `TypeDeclarations`, with template/struct infrastructure split to `TypeInfrastructure`. |
| `Normal` | 2 | Split value-type declaration to `TypeDeclarations` and callable surface to `ManualBindings`. |
| `Late - 10` | 3 | `TypeInfrastructure` for UObject pointer/template scaffolding, then `ManualBindings` for ordinary callable surface where present. |
| `Late - 5` | 1 | `ManualBindings`. |
| `Late - 1` | 9 | `ManualBindings`. |
| `Late` | 113 | `ManualBindings` by default; reflection enumeration moves to `ReflectionBindings`, reflection-dependent callable synthesis to `PostReflectionBindings`, and pure completion work to `Finalization`. |
| `Late + 1` | 2 | `ManualBindings`. |
| `Late + 2` | 2 | `ManualBindings`. |
| `Late + 10` | 1 | `ManualBindings`. |
| `Late + 49` | 2 | `ManualBindings`; exact UFunction-address entries must precede UHT RuntimeLinked generated tables. |
| UHT `Late + 50` | generated | `GeneratedBindings` for RuntimeLinked shards. |
| `Late + 60` | 1 | `GeneratedBindings` Runtime-side NativeModuleFunctionAddress bootstrap; current POD/`IModularFeatures` dynamic transport remains the recorded exception. |
| `Late + 100` | 2 | `ReflectionBindings`. |
| `Late + 101` | 3 | Test-only `PostReflectionBindings`, because the test UClasses exist only after reflected binding work. |
| `Late + 105` | 1 | `ReflectionBindings`. |
| `Late + 110` | 1 | `PostReflectionBindings`. |
| `Late + 150` | 3 | `PostReflectionBindings`. |

## Non-default provider resolutions

| Provider | Legacy order | Target phase / split |
|---|---|---|
| `Bind_ConfigEnums` | `Early - 1` | `TypeDeclarations` |
| `Bind_QueryMobilityType` | `Early - 1` | `TypeDeclarations` |
| `Bind_FCollisionObjectQueryParams_InitType` | `Early - 1` | `TypeDeclarations` |
| `Bind_CollisionShape` | `Early - 1` | `TypeDeclarations` |
| `Bind_Enums` | `Early - 1` | `TypeDeclarations` |
| `Bind_FName` | `Early + 1` | split `TypeDeclarations` / `TypeInfrastructure` / `ManualBindings` |
| `Bind_TMap` | `Early + 1` | split `TypeDeclarations` / `TypeInfrastructure` / `ManualBindings` |
| `Bind_TSet` | `Early + 1` | split `TypeDeclarations` / `TypeInfrastructure` / `ManualBindings` |
| `Bind_StructDeclarations` (both preprocessor branches) | `Early + 1` | `TypeDeclarations` plus `TypeInfrastructure` where the branch installs finders/adapters |
| `Bind_AActor_Base` | `Late - 1` | `ManualBindings` |
| `Bind_ConsoleVariables` | `Late - 1` | `ManualBindings` |
| `Bind_ConsoleCommands` | `Late - 1` | `ManualBindings` |
| `Bind_UObject_Base` | `Late - 1` | `ManualBindings` |
| `Bind_UClass_Base` | `Late - 1` | `ManualBindings` |
| `Bind_UFunction_Base` | `Late - 1` | `ManualBindings` |
| `Bind_UObject_Operations` | `Late - 1` | `ManualBindings` |
| `Bind_USceneComponent_Base` | `Late - 1` | `ManualBindings` |
| `Bind_AngelscriptGASLibrary` (legacy object `Bind_AngelscriptGAS`) | `Late - 1` | `ManualBindings` exact UFunction-address overrides before `GeneratedBindings` |
| `Bind_TSubclassOf` | `Late - 10` | split `TypeInfrastructure` / `ManualBindings` |
| `Bind_TObjectPtr` | `Late - 10` | split `TypeInfrastructure` / `ManualBindings` |
| `Bind_TWeakObjectPtr` | `Late - 10` | split `TypeInfrastructure` / `ManualBindings` |
| `Bind_SoftReferences` | `Late - 5` | `ManualBindings` |
| `Bind_FCollisionResponseParams_Late` | `Late + 1` | `ManualBindings` |
| `Bind_FLatentActionInfo` | `Late + 1` | `ManualBindings` |
| `Bind_AngelscriptTest` | `Late + 2` | `ManualBindings` |
| `Bind_AngelscriptScriptTestSuite` | `Late + 2` | `ManualBindings` |
| `Bind_FString_Conversion` | `Late + 10` | `ManualBindings` |
| `Bind_AssetManagerScriptMixins` | `Late + 49` | `ManualBindings` |
| `Bind_InputComponentScriptMixins` | `Late + 49` | `ManualBindings` |
| UHT RuntimeLinked generated provider | `Late + 50` | `GeneratedBindings` |
| `Bind_AS_NativeModuleFunctionBinding` | `Late + 60` | `GeneratedBindings` bootstrap with retained transport exception |
| `Bind_BlueprintType_ReflectionBindings` (single physical callback covering both preprocessor branches) | `Late + 100` via two legacy `Bind_Defaults` providers | `ReflectionBindings` |
| `Bind_AngelscriptOptionalNullNativeRefForTesting` | `Late + 101` | test-only `PostReflectionBindings` |
| `Bind_AngelscriptCoverageGCTestHelpers` | `Late + 101` | test-only `PostReflectionBindings` |
| `Bind_AngelscriptPerformanceTestTargetObject` | `Late + 101` | test-only `PostReflectionBindings` |
| `Bind_StructDetails` | `Late + 105` | `ReflectionBindings` |
| `Bind_FunctionLibraryMixins` | `Late + 110` | `PostReflectionBindings` |
| `Bind_Actors` | `Late + 150` | `PostReflectionBindings` |
| `Bind_Subsystems` | `Late + 150` | `PostReflectionBindings` |
| `Bind_Components` | `Late + 150` | `PostReflectionBindings` |

## Implemented provider evidence

| Provider | Implemented phase / split | Evidence |
|---|---|---|
| `Bind_FColor`, `Bind_FColor_ToStringContribution` | `TypeInfrastructure` formatter contribution / `ManualBindings` | FColor 3/3 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_FVector_TypeDeclarations`, `Bind_FVector_TypeInfrastructure`, `Bind_FVector_ToStringContribution`, `Bind_FVector` | `TypeDeclarations` / `TypeInfrastructure` / `ManualBindings` | FVector 36/36 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_Deprecations` | `TypeDeclarations` | engine startup through focused binding runs; SourceLayout PASS |
| `Bind_CoreGlobals` | `ManualBindings` | Global 2/2 PASS; PlatformMisc 4/4 PASS; SourceLayout PASS |
| `Bind_FGenericPlatformMisc` | `ManualBindings` | PlatformMisc 4/4 PASS; SourceLayout PASS |
| `Bind_ConfigEnums` | `TypeDeclarations` | PlatformMisc 4/4 PASS including explicit enum execution; ExplicitContext and SourceLayout PASS |
| `Bind_CollisionProfile` | `ManualBindings` | CollisionProfile 2/2 PASS; ExplicitContext and SourceLayout PASS |
| `Bind_FBodyInstance`, `Bind_FInputActionKeyMapping`, `Bind_UFXSystemComponent`, `Bind_UInputSettings`, `Bind_ULocalPlayer`, `Bind_UPackage`, `Bind_USkeletalMeshComponent`, `Bind_USkinnedMeshComponent` | `ManualBindings` | DirectMemberProviders 1/1 PASS with all signatures compiled together and no module warnings; SourceLayout 5/5 PASS |
| `Bind_FPlatformApplicationMisc`, `Bind_TraceCPUProfilerEventScoped`, `Bind_FApp`, `Bind_UPoseableMeshComponent`, `Bind_FAngelscriptGameThreadScopeWorldContext`, `Bind_ALandscapeProxy`, `Bind_FCommandLine`, `Bind_FPlatformMisc` | `ManualBindings` | CpuProfiler 1/1, Utility 5/5, Volume 2/2, MeshComponent 3/3, InputMixin 1/1, ScopeWorldContext 1/1, and SourceLayout 6/6 PASS |
| `Bind_UCollisionProfile`, `Bind_FMessageDialog`, `Bind_FLatentActionInfo`, `Bind_UProjectileMovementComponent`, `Bind_AVolume`, `Bind_FParse`, `Bind_FGeometry`, `Bind_FOverlapResult` | `ManualBindings` | CollisionProfile 2/2, MessageDialog 1/1, BodyInstance 2/2, MeshComponent 3/3, Volume 2/2, Utility 5/5, CollisionValue 2/2, UILayout 3/3, and SourceLayout 6/6 PASS |
| `Bind_UGameInstance`, `Bind_FPlatformProcess`, `Bind_FPlane4f`, `Bind_FAnchors`, `Bind_UEnhancedInputComponent`, `Bind_Hash` | `ManualBindings` | GameInstanceLocalPlayer 1/1, MathAndPlatform 4/4, Sphere3f 4/4, UILayout 3/3, EnhancedInput 8/8, Utility 5/5, and SourceLayout 6/6 PASS |
| `Bind_SystemTimers`, `Bind_UPrimitiveComponent`, `Bind_FInputActionValue` | `ManualBindings` | TimerRuntimeBehavior 1/1, PrimitiveComponent 1/1, EnhancedInput 8/8, and SourceLayout 6/6 PASS |
| `Bind_FFileHelper` (enum/type and callable split), `Bind_FNumberFormattingOptions` (type-adapter and callable split), `Bind_FStringTableRegistry` (enum and callable split) | `TypeDeclarations` / `ManualBindings` | FileAndDelegate 7/7, CoreMisc 4/4, StringTable 1/1, and SourceLayout 6/6 PASS |
| `Bind_AssetManagerScriptMixins`, `Bind_InputComponentScriptMixins` | `ManualBindings` before `GeneratedBindings` | ExplicitContext 1/1 proves target-engine isolation; AssetManager 2/2, InputMixin 1/1, GeneratedFunctionBinding 3/3, and SourceLayout 7/7 PASS |
| `Bind_FPlane`, `Bind_FMargin`, `Bind_FPaths` | `ManualBindings` | named-callable ownership, explicit target routing, and focused Plane/Margin/Paths behavior in 23/23 combined PASS; SourceLayout 7/7 PASS |
| `Bind_EGuidFormats`, `Bind_FGuid` | `TypeDeclarations` / `ManualBindings` | Guid parse/format/constructor behavior and explicit `FUNC/FUNCPR_TRIVIAL` facade coverage in 23/23 combined PASS; SourceLayout 7/7 PASS |
| `Bind_AngelscriptGASLibrary`, `Bind_FGameplayAbilitySpec`, `Bind_FGameplayAttribute`, `Bind_FGameplayEffectSpec`, `Bind_FGameplayTagBlueprintPropertyMap` | five `ManualBindings` providers; the four exact-address library entries retain precedence over `GeneratedBindings`; companion callable counts are 11 / 1 / 2 / 1 for AbilitySpec / Attribute / EffectSpec / PropertyMap | `Saved/Build/direct-bind-parallel-provider-integration-build/20260808_152844_283_b21f4081/RunMetadata.json` has exit code 0. `Saved/Tests/direct-bind-gas-full-green/20260808_152932_538_ff59f4af/Report/index.json` completed 251/251 with 0 failed and 0 not run (234 succeeded + 17 succeeded-with-warnings), including the three binding-architecture checks and generated-function-table coverage. The earlier `direct-bind-gas-green` build has exit code 1 and is not PASS evidence. |
| `Bind_FInputBindingHandle`, `Bind_FEnhancedInputActionEventBinding`, `Bind_FEnhancedInputActionValueBinding`, `Bind_FInputDebugKeyBinding` | `TypeDeclarations` / `ManualBindings` | four declarations split from callable surface; EnhancedInput/Random/SourceLayout combined 19/19 PASS |
| `Bind_FRandomStream`, `Bind_FRandomStream_Late` | `TypeDeclarations` / `TypeInfrastructure` formatter contribution / `ManualBindings` | explicit type adapter and ToString targeting; EnhancedInput/Random/SourceLayout combined 19/19 PASS; ToStringContribution 1/1 PASS |
| `Bind_FSoftObjectPath`, `Bind_FSoftClassPath` | `TypeInfrastructure` formatter contributions / `ManualBindings` | FileAndDelegate 7/7 PASS, including object/class path ToString, resolve, and load behavior; SourceLayout 7/7 PASS |
| `Bind_CollisionShape` | `TypeDeclarations` / `ManualBindings` | CollisionValue 2/2 PASS; SourceLayout 7/7 PASS |
| `Bind_FIntPoint` | `TypeDeclarations` / `TypeInfrastructure` formatter contribution / `ManualBindings` | IntVector 4/4 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_FDateTime` | `TypeInfrastructure` formatter contribution / `ManualBindings` | DateTime 6/6 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_FTimespan` | `ManualBindings` | Timespan 6/6 PASS; SourceLayout 7/7 PASS |
| `Bind_FIntVector`, `Bind_FIntVector2`, `Bind_FIntVector4` | `TypeDeclarations` / `TypeInfrastructure` formatter contributions / `ManualBindings` | IntVector 4/4 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_FSphere`, `Bind_FSphere3f` | `TypeDeclarations` / `ManualBindings` | Sphere3f 4/4 PASS; SourceLayout 7/7 PASS |
| `Bind_FBox`, `Bind_FBox3f`, `Bind_FBoxSphereBounds`, `Bind_FBoxSphereBounds3f` | `TypeDeclarations` / `TypeInfrastructure` formatter contributions / `ManualBindings` | Box3f 4/4 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_Stats_Types`, `Bind_Stats` | `TypeDeclarations` / `ManualBindings` | Stats 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_FHitResult` | `ManualBindings` | HitResult 3/3 PASS; CollisionValue 2/2 PASS; SourceLayout 7/7 PASS |
| `Bind_FVector4`, `Bind_FVector4f` | `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / `ManualBindings` | MathGeometricStructs 11/11 PASS; Quat3f 4/4 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_FVector2D`, `Bind_FVector2f` | `TypeDeclarations` / `TypeInfrastructure` adapter, finder, and formatter contribution / `ManualBindings` | FVector2DExpression 5/5 PASS; MathAndPlatform 4/4 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_UAssetManager` | `TypeInfrastructure` PrimaryAsset formatter contributions / `ManualBindings` | FunctionLibraries.AssetManager 2/2 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS |
| `Bind_JsonObjectConverter` | `ManualBindings` | JsonObjectConverter 2/2 PASS; SourceLayout 7/7 PASS |
| `Bind_FInstancedStruct` | `ManualBindings` | InstancedStruct 2/2 PASS; FInstancedStructCoverageSemantics 1/1 PASS; SourceLayout 7/7 PASS; baseline/migrated native-form registration count 12/12 |
| `Bind_UWorld` | `TypeDeclarations` for `EWorldType` / `ENetMode`; `ManualBindings` for functions | World focused prefix 4/4 PASS; SourceLayout 7/7 PASS; native-form count 11/11 |
| `Bind_FMemoryReader` | `TypeDeclarations` / `ManualBindings` | MemoryReader 2/2 PASS; SourceLayout 7/7 PASS; no native forms before or after |
| `Bind_UInputMappingContext` | three `ManualBindings` providers preserving input-action / mapping value / context grouping | EnhancedInput 8/8 PASS; SourceLayout 7/7 PASS; native-form count 5/5 |
| `Bind_Console` | `TypeDeclarations` / separate variable and command `ManualBindings` providers | Console 11/11 PASS; SourceLayout 7/7 PASS; no native forms before or after |
| `Bind_Logging` | `ManualBindings` | Coverage.Logging 13/13 PASS; SourceLayout 7/7 PASS; compile-out and WorldContext traits preserved |
| `Bind_FQuat`, `Bind_FQuat4f` | `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / `ManualBindings` | Quat combined prefix 10/10 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS; native-form counts 66/66 and 64/64 |
| `Bind_FRotator`, `Bind_FRotator3f` | `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / `ManualBindings` | Engine 4/4 PASS; Quat3f 4/4 PASS; Math Orientation 2/2 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS; native-form counts 44/44 and 34/34 |
| `Bind_FunctionLibraryMixins` | `PostReflectionBindings` | Curve 2/2 PASS; World 4/4 PASS; SceneComponent 8/8 PASS; Parity 15/15 PASS; SourceLayout 7/7 PASS; guarded component overload fallback preserves clone-engine parity |
| `Bind_Subsystems` | `PostReflectionBindings` | WorldSubsystem 3/3 PASS; GameInstanceSubsystem 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; dynamic `ClassName::Get()` user data preserved |
| `Bind_AController`, `Bind_APlayerController`, `Bind_APawn` | three `ManualBindings` providers in `Bind_APlayerController.cpp` | NativeEngine 6/6 PASS; Subsystem 3/3 PASS; SourceLayout 7/7 PASS; native-form count 2/2 |
| `Bind_USceneComponent` | `ManualBindings` | NativeEngine 6/6 PASS; Coverage.SceneComponent 8/8 PASS; SourceLayout 7/7 PASS; native-form count 3/3; wildcard and scoped-movement semantics preserved |
| `Bind_FLinearColor`, `Bind_FLinearColor_Conversion` | `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / unified `ManualBindings` | Bindings.Color 3/3 PASS; Coverage.FLinearColorExpression 7/7 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS; native-form count 21/21 |
| `Bind_UDataTable` | `ManualBindings` | Bindings.DataTable 2/2 PASS including wildcard error paths; SourceLayout 7/7 PASS; native-form count 8/8 |
| `Bind_FName` | `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / `ManualBindings` | Bindings.FName 4/4 PASS; StringInterpolationAndFNameLiteral 1/1 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS; baseline native forms preserved |
| `Bind_FTransform`, `Bind_FTransform_Interactions`, `Bind_FTransform3f`, `Bind_FTransform3f_Interactions` | paired `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / unified `ManualBindings` | Transform 3/3 PASS; Quat3f 4/4 PASS; FTransformExpression 8/8 PASS; ToStringContribution 1/1 PASS; SourceLayout 7/7 PASS; native-form counts 52/52 and 49/49 |
| `Bind_FFormatArgumentValue`, `Bind_FText` | paired `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / `ManualBindings` | TextFormatting 3/3 PASS with generic, ordered, and named formatting; ToStringContribution 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; native-form counts 9/9 and 10/10; explicit-target generic-function facade exercised |
| `Bind_AActor`, `Bind_AActor_Base`, `Bind_Actors`, `Bind_UActorComponent`, `Bind_Components` | unified actor/component `ManualBindings` plus reflection-dependent typed accessors in `PostReflectionBindings` | Actor.Component.Management 4/4 PASS; Functional.Actor.SpawnPatterns 1/1 PASS; Coverage.Component 25/25 PASS; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; native-form counts 14/14 and 12/12; fluent output-type and script-function traits replace legacy previous-bind mutation |
| `Bind_Debugging` | `ManualBindings` | Bindings.Debug 2/2 PASS; Coverage.Debug 17/17 PASS; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; named end-play callback and exact fluent ensure/check compile-out traits retained |
| `Bind_AngelscriptDelegateWithPayload` | `ManualBindings` | Engine.DelegateWithPayload 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; wildcard payload adapter moved without changing delegate payload marshalling or domain methods |
| `Bind_AssetData`, `Bind_AssetRegistry` | `TypeInfrastructure` formatter contribution / `ManualBindings` | Bindings.AssetRegistry 1/1 PASS; ToStringContribution 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; native-form count 2/2 and asset query/CDO/path-regex behavior retained |
| `Bind_UUserWidget` | `ManualBindings` | Bindings.UserWidget 2/2 PASS; Parity 15/15 PASS including paint/Slate compilation; ExplicitContext 1/1 PASS; SourceLayout 7/7 PASS; native-form count 1/1 and fluent output-type, WorldContext, and no-discard traits retained |
| `Bind_AS_NativeModuleFunctionBinding` | `GeneratedBindings` transport bootstrap | build PASS; ExplicitContext 1/1 PASS; SourceLayout 8/8 PASS with dedicated direct-phase guard; source-engine-only runtime tests are compiled out in the installed-engine target (`WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS=0`); modular-feature transport/layout code unchanged |
| UHT RuntimeLinked emitted provider | one generated owner callback `BindGeneratedFunctionBindings_<Module>` in `GeneratedBindings`, with helper batches capped at 256 registrations; one file-static provider record per generated module and no hand-written companion | `Saved/Build/direct-bind-uht-green/20260808_152438_163_8c950b0e/RunMetadata.json` has exit code 0. GeneratedFunctionBinding 5/5, UHT strategy 2/2, and UHT output 1/1 all succeeded with zero warnings/failures/not-run in `Saved/Tests/direct-bind-uht-green/20260808_152511_712_c16483a3/Report/index.json`, `Saved/Tests/direct-bind-uht-strategy-green/20260808_152651_171_f34baaad/Report/index.json`, and `Saved/Tests/direct-bind-uht-output-green/20260808_152725_694_e0aaed3b/Report/index.json`; the fixture preserves the direct-native `AGameModeBase::GetNumPlayers` row and the RPC `APlayerController::ClientSetHUD` erase-only row. |
| Editor CodeGen emitted provider | generated per-class `Bind_<Class>(FAngelscriptBinds&)` owners merge into one module callback `BindGeneratedFunctionBindings_<Module>` in `GeneratedBindings`; one file-static provider per generated module, empty `StartupModule()`, and no hand-written companion | `Saved/Build/direct-bind-editor-codegen-final-rerun/20260808_154555_102_4691c53c/RunMetadata.json` has exit code 0. Editor CodeGen 7/7 and final GeneratedBindings 2/2 succeeded with zero warnings/failures/not-run in `Saved/Tests/direct-bind-editor-codegen-all-green/20260808_154358_851_77d06dbc/Report/index.json` and `Saved/Tests/direct-bind-editor-codegen-final/20260808_154604_192_b5406b82/Report/index.json`; the fixture preserves the native `AActor::TearOff` method-pointer spelling through the exact generated facade. |
| `Bind_FVector3f`, `Bind_FVector3f_Conversion` | `TypeDeclarations` / `TypeInfrastructure` adapter and formatter contribution / unified `ManualBindings` | Quat3f 4/4 PASS; Box3f 4/4 PASS; Sphere3f 4/4 PASS; ToStringContribution 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 8/8 PASS; native-form count 79/79 and fluent documentation/constructor traits retained |
| `Bind_Enums`, `Bind_EGetByNameFlags`, `Bind_UEnum` | paired `TypeDeclarations` enum/type-adapter callbacks / `ManualBindings` member-pointer surface | Coverage.UEnum 13/13 PASS; ExplicitContext 1/1 PASS; SourceLayout 9/9 PASS; BindLifecycle 4/4 PASS; native-form count 16/16; BindDB, type finder, script-enum lookup/slot, and type documentation now explicitly target the selected engine |
| `Bind_TOptional` | `TypeDeclarations` template declaration / ordered `TypeInfrastructure` method-surface completion and type-adapter/finder contribution | `Bind_TOptional.cpp` contains three providers, nine method registrations, two constructors, one template callback, 13 exact `.NativeTemplateInstantiatedCall(...)` attachments, and zero `SCRIPT_NATIVE_TEMPLATED_CALL*` consumers. `Saved/Build/direct-bind-container-native-green/20260808_154110_854_54bdf25d/RunMetadata.json` has exit code 0; Container behavior 28/28 and SourceLayout 26/26 succeeded with zero warnings/failures/not-run; StaticJIT NativeForms completed 4/4 with 0 failed/0 not run (3 succeeded + 1 succeeded-with-warnings). |
| `Bind_InputEvents_ToStringContribution`, `Bind_InputEvents` | `TypeInfrastructure` formatter contribution / `ManualBindings` | Input 5/5 PASS with FKey, FInputChord, and FEventReply execution; ExplicitContext 1/1 PASS; SourceLayout 11/11 PASS; declaration parity 128/128 and `EKeys` token parity 187/187; 25 named owner callables retain non-native classification |
| `Bind_FCollisionQueryParams_TypeDeclarations`, `Bind_FCollisionQueryParams_TypeInfrastructure`, `Bind_FCollisionQueryParams_ManualBindings` | `TypeDeclarations` / `TypeInfrastructure` adapter and finder contribution / `ManualBindings` | CollisionParams 4/4 PASS with overload, constructor, namespace-helper, assignment, and no-discard execution; SourceLayout 11/11 PASS; declaration parity 90/90, native/trivial term parity 40/40, and native constructor parity 16/16 |
| `Bind_Json_TypeDeclarations`, `Bind_Json` | `TypeDeclarations` / `ManualBindings` | Json 7/7 PASS with nested container/copy, serialization/error, and iterator-boundary coverage; ExplicitContext 1/1 PASS; SourceLayout 11/11 PASS; declaration parity 51/51 and enum parity 7/7; historical copy-constructor declaration corrected from unusable by-value input to matching `const&` wrapper semantics |
| `Bind_FMath` | `ManualBindings` | Math 8/8 PASS including direct named-owner dispatch; ExplicitContext 1/1 PASS; SourceLayout 13/13 PASS; 265/265 registration source points, 205/205 native/trivial terms, and 29/29 documentation attachments preserved |
| `Bind_Primitives_Infrastructure`, `Bind_Primitives_Constants`, `Bind_Primitives_ToStringContribution` | three `TypeInfrastructure` contributions | Global 4/4 PASS; PrimitiveComponent 1/1 PASS; ToStringContribution 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 13/13 PASS; parity preserved for 11 types, 5 aliases, 4 slots, 45 globals/constants, 32 documentation attachments, 11 formatter contributions, and 2 native/trivial terms |
| `Bind_TSoftObjectPtr_Declarations`, `Bind_TSoftObjectPtr_TypeInfrastructure`, `Bind_TSoftObjectPtr_Functions` | `TypeDeclarations` / `TypeInfrastructure` adapter and finder contribution / `ManualBindings` | Object 3/3 PASS; AssetLoading reference load 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 13/13 PASS; 36/36 declaration literals and 46/46 direct callable registration sites preserved |
| `Bind_Delegate_Declarations`, `Bind_Delegates` | `TypeDeclarations` / `ManualBindings` | FileAndDelegate 8/8 PASS; ExplicitContext 1/1 PASS; SourceLayout 14/14 PASS; declaration multiset 46/46, native/trivial terms 39/39, script-function injection 7/7, and no-discard traits 3/3 preserved |
| `Bind_FString_TypeDeclarations`, `Bind_FString_TypeInfrastructure`, `Bind_FString_ManualBindings` | `TypeDeclarations` / string adapter, static type info, and string factory in `TypeInfrastructure` / core and conversion surface in `ManualBindings` | FString 10/10 PASS including multi-engine format; ToStringContribution 1/1 PASS; ExplicitContext 1/1 PASS; SourceLayout 14/14 PASS; value class 1/1, methods 69/69, globals 24/24, and native/trivial metadata 40/40 preserved |
| `Bind_WorldCollision_TypeDeclarations`, `Bind_WorldCollision_TypeInfrastructure`, `Bind_WorldCollision_ManualBindings` | `TypeDeclarations` / three value-type adapters in `TypeInfrastructure` / value and sync/async query surface in `ManualBindings` | WorldCollision 3/3 PASS; FunctionLibraries.WorldCollision 2/2 PASS; ExplicitContext 1/1 PASS; SourceLayout 14/14 PASS; 46/46 global declarations/UWorld forwards, 50/50 named callables, and original local registration order preserved |
| `Bind_TArray_TypeDeclarations`, `Bind_TArray_MethodSurface`, `Bind_TArray_TypeInfrastructure` | `TypeDeclarations` template declarations / ordered `TypeInfrastructure` method-surface completion before engine-owned well-known array-template, default-array, adapter, and finder contribution | fresh build PASS; Bindings.Container 28/28 PASS; StaticJIT.NativeForms 4/4 PASS; SourceLayout 26/26 PASS; 24 template forms and 6 specialized TArray forms use exact fluent results; 24/24 template HEAD argument parity and all 35 script-object traits remain; native metadata macros are zero-consumer |
| `Bind_TSet_TypeDeclarations`, `Bind_TSet_MethodSurface`, `Bind_TSet_TypeInfrastructure` | `TypeDeclarations` template declarations / ordered `TypeInfrastructure` method-surface completion before adapter/finder contribution | fresh build PASS; Bindings.Container 28/28 PASS; StaticJIT.NativeForms 4/4 PASS; SourceLayout 26/26 PASS; 10 template forms and 2 iterator forms use exact fluent results; 10/10 template HEAD argument parity and all 18 script-object traits remain; native metadata macros are zero-consumer |
| `Bind_TMap_TypeDeclarations`, `Bind_TMap_MethodSurface`, `Bind_TMap_TypeInfrastructure` | `TypeDeclarations` template declarations / ordered `TypeInfrastructure` method-surface completion before adapter/finder contribution | fresh build PASS; Bindings.Container 28/28 PASS; StaticJIT.NativeForms 4/4 PASS; SourceLayout 26/26 PASS; 13 template forms and 2 iterator forms use exact fluent results; 13/13 template HEAD argument parity, all 25 script-object traits, and 5 documentation attachments remain; native metadata macros are zero-consumer |
| `Bind_UObject_Base`, `Bind_UClass_Base`, `Bind_UFunction_Base`, `Bind_UObject_Operations`, `Bind_UObject_ToStringContribution` | four `ManualBindings` providers plus one `TypeInfrastructure` formatter contribution | unified build PASS; UObject 10/10 PASS; BlueprintType 4/4 PASS; ExplicitContext 4/4 PASS; SourceLayout 19/19 PASS; exact output-type, documentation, cast, and native/trivial metadata preserved |
| `Bind_UStruct_TypeDeclarations`, `Bind_UStruct_TypeInfrastructure`, `Bind_UStruct_ReflectionBindings` | `TypeDeclarations` / type adapter and property finder in `TypeInfrastructure` / special members and reflected properties in `ReflectionBindings`; both preprocessor branches expose the same phase split | unified and independent-TU builds PASS; UStruct 1/1 PASS; ExplicitContext 4/4 PASS; SourceLayout 20/20 PASS; non-BindDB phases reuse one engine-owned stable snapshot while preserving legacy `TObjectRange` / `Binds.Cache` order; native-form parity 15/15 |
| `Bind_AngelscriptOptionalNullNativeRefForTesting`, `Bind_AngelscriptCoverageGCTestHelpers`, `Bind_AngelscriptPerformanceTestTargetObject` | three test-only `PostReflectionBindings` providers | unified build PASS; SourceLayout 19/19 PASS; all provider mutation is explicit-target; performance provider preserves 32 exact editor-only traits and all native/trivial pointers |
| `Bind_BlueprintType_ReflectionBindings`, BlueprintEvent, BlueprintCallable, and `BlueprintCallableReflectiveFallback` | one `ReflectionBindings` provider; explicit target prepare/commit helpers; exact `FAngelscriptBoundFunction` primary results | final reflection-wave selection 75/75 PASS; Editor and non-Editor Game/BindDB builds PASS; independent `Bind_BlueprintType.cpp` TU PASS; ordinary reflected callable and real client-RPC exact native-form tests 2/2 PASS |
| `Bind_Skip`, `Bind_AngelscriptTest`, `Bind_AngelscriptScriptTestSuite`, `Bind_ScriptEditorPrompts` | four out-of-`Binds/` providers migrated to `ManualBindings` | unified build PASS; SourceLayout 25/25 PASS; runtime test framework 55/55 PASS; editor prompts 2/2 PASS; the cited GAS selection completed 251/251 with 0 failed/0 not run (234 succeeded + 17 succeeded-with-warnings); file-static direct callbacks use explicit target bind state, engine, namespace, class, and global-function APIs |
| `Bind_FGameplayTagQuery_ManualBindings`, `Bind_FGameplayTag_ToStringContribution`, `Bind_FGameplayTag_ManualBindings` | one `TypeInfrastructure` formatter contribution plus two `ManualBindings` providers; private `FAngelscriptFGameplayTagBinds` owns exactly two project callables (`AppendToString` and non-native `RemoveTag`) | all 35 native/trivial terms remain direct UE member/free-pointer forms. `Saved/Build/direct-bind-gameplaytags-tdd-green-build/20260808_141502_402_fb27d061/RunMetadata.json` has exit code 0; `Saved/Tests/direct-bind-gameplaytags-tdd-green/20260808_141521_271_162f8489/Report/index.json` is 1/1 succeeded and `Saved/Tests/direct-bind-gameplaytags-full/20260808_141607_712_88d54bdf/Report/index.json` is 13/13 succeeded, both with zero warnings/failures/not-run. |

The completed architecture contains no compatibility bridge or legacy integer-order pass. All providers execute directly through the sealed seven-phase collection. The final source guards reject legacy `EOrder`, `BindOrder`, `CallBinds`, and `GetSortedBindArray` production references.

The former numeric distinction between `Bind_FunctionLibraryMixins` at `Late + 110` and the actor/component/subsystem providers at `Late + 150` is intentionally removed. No dependency on that numeric gap exists: the sealed same-phase lexical order is `AActor.PostReflection`, `FunctionLibraryMixins.PostReflection`, `Subsystems.PostReflection`, then `UActorComponent.PostReflection`, and the active observation-pass regression records that exact order. Direct callbacks are recorded only while an observation pass is active, so nested test-engine construction cannot pollute the primary observation.

`GBlueprintEventsByScriptName` remains a process-global, reconstructible cache of UE reflection objects. It is not binding target state and is cleaned/rebuilt across engine cycles; this wave therefore records it as a compatibility exception rather than pretending it is an engine-local binding registry. All mutation of script engines, type databases, bind databases, documentation stores, event-signature ownership, and callable registration in this reflection chain is explicitly target-routed.

## Final evidence after the row audit

- Task 5.9 is complete: representative StaticJIT/AOT coverage completed 12/12 in `Saved/Tests/direct-bind-final-staticjit-aot-green/20260808_172657_286_6d6625f6/Report/index.json`; native-form classification completed 4/4 in `Saved/Tests/direct-bind-final-staticjit-nativeforms-green/20260808_172611_971_352d5208/Report/index.json`.
- Task 5.11 is complete: the complete binding prefix completed 275/275 in `Saved/Tests/direct-bind-final-bindings-green/20260808_172430_367_ee78f08d/Report/index.json`, and the focused architecture selection completed 90/90 in `Saved/Tests/direct-bind-final-focused-green/20260808_171945_585_f7bb71dd/Report/index.json`.
- The installed-engine configuration sets `WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS=0`; the source-engine-only transport/runtime cases therefore remain undiscoverable in the cited runs, so transport behavior is not marked fully verified by this matrix.
- `Saved/Tests/direct-bind-staticjit-native-forms-green/20260808_154505_550_f4c6d8c6/Report/index.json` completed 4/4 with 0 failed and 0 not run, but its top-level result is 3 succeeded + 1 succeeded-with-warnings. Container rows that use the shorter `4/4 PASS` label must be read with that qualification.
- `Saved/Tests/direct-bind-gas-full-green/20260808_152932_538_ff59f4af/Report/index.json` likewise has 17 succeeded-with-warnings; it is zero-failure focused evidence, not an all-clean 251-success report.

## Completion rule

Each provider row records its implemented split next to the corresponding row in `callable-migration.md`. Future dependencies that cannot be expressed by these seven phases, callback splitting, or same-callback local order require a separate OpenSpec rather than a numeric escape hatch.
