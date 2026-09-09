# Runtime provider inventory

Captured from the selected primary workspace and the reference workspace on 2026-09-08 before product edits. This is a source coverage inventory, not passing installation evidence. Duplicate source entries can be mutually exclusive preprocessor branches; the runtime collection must select and explain the active branch. Provider target conditions, dependencies and declaration outputs must be evaluated from the named source during migration and reflected in Coverage tests.

## Source identities

- Primary parent: a9afd56e73b9289ed32dee8210d7b96ac0b3b578; Angelscript: edc13e98d7a63fa22b76620302d1294fe6126641 (clean at capture).
- Reference parent: fd16e5b592111dbc1433c9f9038d5d34caa4325f; Angelscript: ed22fbdf0fc1a3793b006bb703aeb62a7500b25a (dirty, including new TypeBindInfo files).
- Reference root: `.worktrees/refactor-as-subsystem-typeinfo-bind-cache`; read-only source material, never a merge target.

## Providers (253 source declarations; 247 distinct names)

| Provider | Existing phase | Current source | Reference correspondence | Migration task |
|---|---|---|---|---|
| `AActor.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp:119` | renamed/consolidated or absent | 7.3 |
| `AActor.PostReflection` | PostReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp:193` | renamed/consolidated or absent | 7.3 |
| `AController.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp:60` | renamed/consolidated or absent | 7.3 |
| `APlayerController.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp:74` | renamed/consolidated or absent | 7.3 |
| `APawn.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp:88` | renamed/consolidated or absent | 7.3 |
| `AssetBundleData.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetBundleData.cpp:58` | renamed/consolidated or absent | 7.5 |
| `AssetBundleData` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetBundleData.cpp:68` | renamed/consolidated or absent | 7.5 |
| `AssetManagerScriptMixins.GeneratedOverrides` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetManagerScriptMixins.cpp:21` | renamed/consolidated or absent | 7.5 |
| `AssetRegistry.TopLevelAssetPathToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetRegistry.cpp:93` | renamed/consolidated or absent | 7.5 |
| `AssetRegistry.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetRegistry.cpp:104` | renamed/consolidated or absent | 7.5 |
| `AVolume` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AVolume.cpp:33` | renamed/consolidated or absent | 7.3 |
| `BlueprintEvents.HelperGlobals` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp:586` | renamed/consolidated or absent | 6.8 |
| `BlueprintType.ReflectionBindings` | ReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:1067` | renamed/consolidated or absent | 6.5 |
| `BlueprintType.ReflectionBindings` | ReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:1477` | renamed/consolidated or absent | 6.5 |
| `BlueprintType.ReferenceClasses` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2632` | renamed/consolidated or absent | 6.2 |
| `BlueprintType.StaticClasses` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2663` | renamed/consolidated or absent | 6.3 |
| `BlueprintType.ReferenceClasses` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2705` | renamed/consolidated or absent | 6.2 |
| `BlueprintType.StaticClasses` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2728` | renamed/consolidated or absent | 6.3 |
| `TObjectPtr.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2746` | renamed/consolidated or absent | 6.7 |
| `TSubclassOf.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2761` | renamed/consolidated or absent | 6.7 |
| `TWeakObjectPtr.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2776` | renamed/consolidated or absent | 6.7 |
| `TObjectPtr.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2791` | renamed/consolidated or absent | 6.7 |
| `TSubclassOf.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2832` | renamed/consolidated or absent | 6.7 |
| `TWeakObjectPtr.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2892` | renamed/consolidated or absent | 6.7 |
| `UObject.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2947` | renamed/consolidated or absent | 6.3 |
| `CollisionProfile` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CollisionProfile.cpp:38` | renamed/consolidated or absent | 7.2 |
| `ConfigEnums` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ConfigEnums.cpp:20` | renamed/consolidated or absent | 7.10 |
| `Console.Types` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp:47` | renamed/consolidated or absent | 7.8 |
| `Console.Variables` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp:57` | renamed/consolidated or absent | 7.8 |
| `Console.Commands` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp:95` | renamed/consolidated or absent | 7.8 |
| `CoreGlobals` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CoreGlobals.cpp:68` | renamed/consolidated or absent | 7.7 |
| `Debugging.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.cpp:41` | renamed/consolidated or absent | 7.8 |
| `Delegates.Declarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp:701` | renamed/consolidated or absent | 6.8 |
| `Delegates.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp:784` | renamed/consolidated or absent | 6.8 |
| `Deprecations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Deprecations.cpp:36` | renamed/consolidated or absent | 7.10 |
| `FActorSpawnParameters.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters.cpp:43` | renamed/consolidated or absent | 7.3 |
| `FActorSpawnParameters.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters.cpp:58` | renamed/consolidated or absent | 7.3 |
| `FActorSpawnParameters.ExplicitBindings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters.cpp:66` | renamed/consolidated or absent | 7.3 |
| `FAnchors` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAnchors.cpp:38` | renamed/consolidated or absent | 4.6 |
| `FAngelscriptDelegateWithPayload.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp:50` | renamed/consolidated or absent | 6.8 |
| `FAngelscriptGameThreadScopeWorldContext` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptGameThreadScopeWorldContext.cpp:23` | renamed/consolidated or absent | 6.6 |
| `FApp` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FApp.cpp:23` | renamed/consolidated or absent | 7.7 |
| `FBodyInstance` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBodyInstance.cpp:21` | renamed/consolidated or absent | 7.2 |
| `FBox.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox.cpp:86` | renamed/consolidated or absent | 4.5 |
| `FBox.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox.cpp:98` | renamed/consolidated or absent | 4.5 |
| `FBox.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox.cpp:106` | renamed/consolidated or absent | 4.5 |
| `FBox2D` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox2D.cpp:25` | renamed/consolidated or absent | 4.5 |
| `FBox3f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f.cpp:68` | renamed/consolidated or absent | 4.5 |
| `FBox3f.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f.cpp:80` | renamed/consolidated or absent | 4.5 |
| `FBox3f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f.cpp:88` | renamed/consolidated or absent | 4.5 |
| `FBoxSphereBounds.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds.cpp:62` | renamed/consolidated or absent | 4.5 |
| `FBoxSphereBounds.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds.cpp:74` | renamed/consolidated or absent | 4.5 |
| `FBoxSphereBounds.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds.cpp:82` | renamed/consolidated or absent | 4.5 |
| `FBoxSphereBounds3f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f.cpp:69` | renamed/consolidated or absent | 4.5 |
| `FBoxSphereBounds3f.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f.cpp:81` | renamed/consolidated or absent | 4.5 |
| `FBoxSphereBounds3f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f.cpp:89` | renamed/consolidated or absent | 4.5 |
| `FCollisionQueryParams.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp:422` | renamed/consolidated or absent | 7.2 |
| `FCollisionQueryParams.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp:456` | renamed/consolidated or absent | 7.2 |
| `FCollisionQueryParams.ExplicitBindings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp:468` | renamed/consolidated or absent | 7.2 |
| `FCollisionShape.Types` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp:78` | renamed/consolidated or absent | 7.2 |
| `FCollisionShape.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp:95` | renamed/consolidated or absent | 7.2 |
| `FColor` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp:86` | renamed/consolidated or absent | 4.6 |
| `FColor.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp:148` | renamed/consolidated or absent | 4.6 |
| `FCommandLine` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCommandLine.cpp:23` | renamed/consolidated or absent | 7.7 |
| `FCpuProfilerTraceScoped` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCpuProfilerTraceScoped.cpp:21` | renamed/consolidated or absent | 7.8 |
| `FDateTime.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime.cpp:166` | renamed/consolidated or absent | 4.9 |
| `FDateTime.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime.cpp:174` | renamed/consolidated or absent | 4.9 |
| `FFileHelper.Types` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFileHelper.cpp:49` | renamed/consolidated or absent | 7.7 |
| `FFileHelper.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFileHelper.cpp:83` | renamed/consolidated or absent | 7.7 |
| `FFormatArgumentValue.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue.cpp:32` | renamed/consolidated or absent | 4.8 |
| `FFormatArgumentValue.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue.cpp:42` | renamed/consolidated or absent | 4.8 |
| `FFormatArgumentValue.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue.cpp:50` | renamed/consolidated or absent | 4.8 |
| `FFrameTime` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFrameTime.cpp:33` | renamed/consolidated or absent | 4.9 |
| `FGenericPlatformMisc` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGenericPlatformMisc.cpp:14` | renamed/consolidated or absent | 7.7 |
| `FGeometry` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGeometry.cpp:34` | renamed/consolidated or absent | 4.6 |
| `EGuidFormats` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGuid.cpp:55` | renamed/consolidated or absent | 4.9 |
| `FGuid` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGuid.cpp:71` | renamed/consolidated or absent | 4.9 |
| `FHitResult.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp:102` | renamed/consolidated or absent | 7.2 |
| `FInputActionKeyMapping` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionKeyMapping.cpp:15` | renamed/consolidated or absent | 7.4 |
| `FInputActionValue` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionValue.cpp:52` | renamed/consolidated or absent | 7.4 |
| `FInputBindingHandle.Types` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle.cpp:62` | renamed/consolidated or absent | 7.4 |
| `FInputBindingHandle.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle.cpp:74` | renamed/consolidated or absent | 7.4 |
| `FInstancedStruct.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp:43` | renamed/consolidated or absent | 7.6 |
| `FIntPoint.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint.cpp:60` | renamed/consolidated or absent | 4.3 |
| `FIntPoint.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint.cpp:71` | renamed/consolidated or absent | 4.3 |
| `FIntPoint.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint.cpp:117` | renamed/consolidated or absent | 4.3 |
| `FIntVector.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector.cpp:71` | renamed/consolidated or absent | 4.3 |
| `FIntVector.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector.cpp:82` | renamed/consolidated or absent | 4.3 |
| `FIntVector.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector.cpp:90` | renamed/consolidated or absent | 4.3 |
| `FIntVector2.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2.cpp:36` | renamed/consolidated or absent | 4.3 |
| `FIntVector2.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2.cpp:47` | renamed/consolidated or absent | 4.3 |
| `FIntVector2.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2.cpp:55` | renamed/consolidated or absent | 4.3 |
| `FIntVector4.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4.cpp:60` | renamed/consolidated or absent | 4.3 |
| `FIntVector4.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4.cpp:71` | renamed/consolidated or absent | 4.3 |
| `FIntVector4.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4.cpp:79` | renamed/consolidated or absent | 4.3 |
| `FLatentActionInfo` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLatentActionInfo.cpp:38` | renamed/consolidated or absent | 6.8 |
| `FLinearColor.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp:133` | renamed/consolidated or absent | 4.6 |
| `FLinearColor.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp:143` | renamed/consolidated or absent | 4.6 |
| `FLinearColor.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp:152` | renamed/consolidated or absent | 4.6 |
| `FMargin` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMargin.cpp:52` | renamed/consolidated or absent | 4.6 |
| `FMath.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp:769` | renamed/consolidated or absent | 4.9 |
| `FMatrix` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMatrix.cpp:32` | renamed/consolidated or absent | 4.4 |
| `FMemoryReader.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMemoryReader.cpp:49` | renamed/consolidated or absent | 7.6 |
| `FMemoryReader.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMemoryReader.cpp:57` | renamed/consolidated or absent | 7.6 |
| `FMessageDialog` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMessageDialog.cpp:33` | renamed/consolidated or absent | 7.8 |
| `FName.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp:65` | renamed/consolidated or absent | 4.7 |
| `FName.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp:75` | renamed/consolidated or absent | 4.7 |
| `FName.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp:84` | renamed/consolidated or absent | 4.7 |
| `FNumberFormattingOptions.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FNumberFormattingOptions.cpp:43` | renamed/consolidated or absent | 4.8 |
| `FNumberFormattingOptions.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FNumberFormattingOptions.cpp:54` | renamed/consolidated or absent | 4.8 |
| `FOverlapResult` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FOverlapResult.cpp:40` | renamed/consolidated or absent | 7.2 |
| `FParse` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FParse.cpp:32` | renamed/consolidated or absent | 7.7 |
| `FPaths` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths.cpp:123` | renamed/consolidated or absent | 7.7 |
| `FPlane` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane.cpp:42` | renamed/consolidated or absent | 4.5 |
| `FPlane4f` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane4f.cpp:32` | renamed/consolidated or absent | 4.5 |
| `FPlatformApplicationMisc` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformApplicationMisc.cpp:24` | renamed/consolidated or absent | 7.7 |
| `FPlatformMisc` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformMisc.cpp:28` | renamed/consolidated or absent | 7.7 |
| `FPlatformProcess` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformProcess.cpp:60` | renamed/consolidated or absent | 7.7 |
| `FQuat.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat.cpp:184` | renamed/consolidated or absent | 4.4 |
| `FQuat.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat.cpp:194` | renamed/consolidated or absent | 4.4 |
| `FQuat.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat.cpp:202` | renamed/consolidated or absent | 4.4 |
| `FQuat4f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f.cpp:184` | renamed/consolidated or absent | 4.4 |
| `FQuat4f.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f.cpp:194` | renamed/consolidated or absent | 4.4 |
| `FQuat4f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f.cpp:202` | renamed/consolidated or absent | 4.4 |
| `FRandomStream.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp:63` | renamed/consolidated or absent | 4.9 |
| `FRandomStream.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp:74` | renamed/consolidated or absent | 4.9 |
| `FRandomStream.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp:100` | renamed/consolidated or absent | 4.9 |
| `FRange` | PostReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRange.cpp:147` | renamed/consolidated or absent | 4.9 |
| `FRotator.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator.cpp:132` | renamed/consolidated or absent | 4.4 |
| `FRotator.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator.cpp:142` | renamed/consolidated or absent | 4.4 |
| `FRotator.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator.cpp:150` | renamed/consolidated or absent | 4.4 |
| `FRotator3f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f.cpp:103` | renamed/consolidated or absent | 4.4 |
| `FRotator3f.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f.cpp:113` | renamed/consolidated or absent | 4.4 |
| `FRotator3f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f.cpp:121` | renamed/consolidated or absent | 4.4 |
| `FSphere.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere.cpp:47` | renamed/consolidated or absent | 4.5 |
| `FSphere.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere.cpp:59` | renamed/consolidated or absent | 4.5 |
| `FSphere3f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere3f.cpp:44` | renamed/consolidated or absent | 4.5 |
| `FSphere3f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere3f.cpp:56` | renamed/consolidated or absent | 4.5 |
| `FString.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp:1461` | renamed/consolidated or absent | 4.7 |
| `FString.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp:1469` | renamed/consolidated or absent | 4.7 |
| `FString.ExplicitBindings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp:1480` | renamed/consolidated or absent | 4.7 |
| `FStringTableRegistry.Types` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FStringTableRegistry.cpp:48` | renamed/consolidated or absent | 4.8 |
| `FStringTableRegistry.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FStringTableRegistry.cpp:59` | renamed/consolidated or absent | 4.8 |
| `FText.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp:120` | renamed/consolidated or absent | 4.8 |
| `FText.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp:140` | renamed/consolidated or absent | 4.8 |
| `FText.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp:151` | renamed/consolidated or absent | 4.8 |
| `FTimespan.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTimespan.cpp:123` | renamed/consolidated or absent | 4.9 |
| `FTransform.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform.cpp:153` | renamed/consolidated or absent | 4.4 |
| `FTransform.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform.cpp:164` | renamed/consolidated or absent | 4.4 |
| `FTransform.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform.cpp:173` | renamed/consolidated or absent | 4.4 |
| `FTransform3f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f.cpp:159` | renamed/consolidated or absent | 4.4 |
| `FTransform3f.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f.cpp:170` | renamed/consolidated or absent | 4.4 |
| `FTransform3f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f.cpp:179` | renamed/consolidated or absent | 4.4 |
| `FunctionLibraryMixins.PostReflection` | PostReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FunctionLibraryMixins.cpp:87` | renamed/consolidated or absent | 6.6 |
| `FVector.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp:239` | renamed/consolidated or absent | 4.3 |
| `FVector.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp:250` | renamed/consolidated or absent | 4.3 |
| `FVector` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp:276` | renamed/consolidated or absent | 4.3 |
| `FVector.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp:478` | renamed/consolidated or absent | 4.3 |
| `FVector2D.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp:121` | renamed/consolidated or absent | 4.3 |
| `FVector2D.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp:132` | renamed/consolidated or absent | 4.3 |
| `FVector2D.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp:141` | renamed/consolidated or absent | 4.3 |
| `FVector2f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp:127` | renamed/consolidated or absent | 4.3 |
| `FVector2f.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp:138` | renamed/consolidated or absent | 4.3 |
| `FVector2f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp:162` | renamed/consolidated or absent | 4.3 |
| `FVector3f.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f.cpp:220` | renamed/consolidated or absent | 4.3 |
| `FVector3f.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f.cpp:231` | renamed/consolidated or absent | 4.3 |
| `FVector3f.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f.cpp:241` | renamed/consolidated or absent | 4.3 |
| `FVector4.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4.cpp:54` | renamed/consolidated or absent | 4.3 |
| `FVector4.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4.cpp:65` | renamed/consolidated or absent | 4.3 |
| `FVector4.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4.cpp:74` | renamed/consolidated or absent | 4.3 |
| `FVector4f.Type` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f.cpp:59` | renamed/consolidated or absent | 4.3 |
| `FVector4f.Infrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f.cpp:70` | renamed/consolidated or absent | 4.3 |
| `FVector4f.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f.cpp:79` | renamed/consolidated or absent | 4.3 |
| `Hash` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Hash.cpp:40` | renamed/consolidated or absent | 4.9 |
| `InputComponentScriptMixins.GeneratedOverrides` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins.cpp:21` | renamed/consolidated or absent | 7.4 |
| `InputEvents.FKeyToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp:301` | renamed/consolidated or absent | 7.4 |
| `InputEvents.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp:309` | renamed/consolidated or absent | 7.4 |
| `Json.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json.cpp:152` | renamed/consolidated or absent | 7.6 |
| `Json.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json.cpp:172` | renamed/consolidated or absent | 7.6 |
| `JsonObjectConverter.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_JsonObjectConverter.cpp:34` | renamed/consolidated or absent | 7.6 |
| `ALandscapeProxy.GetHeightAtLocation` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_LandscapeProxy.cpp:22` | renamed/consolidated or absent | 7.3 |
| `Logging.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Logging.cpp:80` | renamed/consolidated or absent | 7.8 |
| `NativeModuleFunctionBinding.GeneratedTransport` | GeneratedBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp:634` | renamed/consolidated or absent | 6.4 |
| `PrimitiveTypes.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp:128` | renamed/consolidated or absent | 4.2 |
| `PrimitiveTypes.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp:179` | renamed/consolidated or absent | 7.10 |
| `PrimitiveTypes.Constants` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp:240` | renamed/consolidated or absent | 4.2 |
| `SoftObjectPath.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SoftObjectPath.cpp:77` | renamed/consolidated or absent | 6.7 |
| `SoftObjectPath.ToStringContributions` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SoftObjectPath.cpp:110` | renamed/consolidated or absent | 6.7 |
| `Stats.Types` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Stats.cpp:47` | renamed/consolidated or absent | 7.8 |
| `Stats.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Stats.cpp:59` | renamed/consolidated or absent | 7.8 |
| `Subsystems.PostReflection` | PostReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp:47` | renamed/consolidated or absent | 7.9 |
| `SystemTimers` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp:37` | renamed/consolidated or absent | 7.9 |
| `TArray.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp:1084` | renamed/consolidated or absent | 5.3 |
| `TArray.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp:1102` | renamed/consolidated or absent | 5.3 |
| `TArray.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp:1296` | renamed/consolidated or absent | 5.3 |
| `TMap.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp:492` | renamed/consolidated or absent | 5.5 |
| `TMap.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp:510` | renamed/consolidated or absent | 5.5 |
| `TMap.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp:660` | renamed/consolidated or absent | 5.5 |
| `TOptional.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp:246` | renamed/consolidated or absent | 5.6 |
| `TOptional.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp:260` | renamed/consolidated or absent | 5.6 |
| `TOptional.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp:330` | renamed/consolidated or absent | 5.6 |
| `TSet.Declaration` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp:324` | renamed/consolidated or absent | 5.4 |
| `TSet.MethodSurface` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp:342` | renamed/consolidated or absent | 5.4 |
| `TSet.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp:440` | renamed/consolidated or absent | 5.4 |
| `SoftReferences.Declarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp:142` | renamed/consolidated or absent | 6.7 |
| `SoftReferences.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp:156` | renamed/consolidated or absent | 6.7 |
| `SoftReferences.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp:209` | renamed/consolidated or absent | 6.7 |
| `UActorComponent.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent.cpp:120` | renamed/consolidated or absent | 7.3 |
| `UActorComponent.PostReflection` | PostReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent.cpp:185` | renamed/consolidated or absent | 7.3 |
| `UAssetManager.PrimaryAssetToStringContributions` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UAssetManager.cpp:62` | renamed/consolidated or absent | 7.5 |
| `UAssetManager.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UAssetManager.cpp:71` | renamed/consolidated or absent | 7.5 |
| `UCollisionProfile` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UCollisionProfile.cpp:28` | renamed/consolidated or absent | 7.2 |
| `UDataTable` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UDataTable.cpp:56` | renamed/consolidated or absent | 7.5 |
| `UEnhancedInputComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnhancedInputComponent.cpp:84` | renamed/consolidated or absent | 7.4 |
| `Enums` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp:128` | renamed/consolidated or absent | 6.3 |
| `EGetByNameFlags` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp:323` | renamed/consolidated or absent | 6.3 |
| `UEnum` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp:335` | renamed/consolidated or absent | 6.3 |
| `UFXSystemComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UFXSystemComponent.cpp:14` | renamed/consolidated or absent | 7.3 |
| `UGameInstance` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp:50` | renamed/consolidated or absent | 7.9 |
| `UInputMappingContext.InputAction` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp:69` | renamed/consolidated or absent | 7.4 |
| `UInputMappingContext.EnhancedActionKeyMapping` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp:85` | renamed/consolidated or absent | 7.4 |
| `UInputMappingContext.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp:111` | renamed/consolidated or absent | 7.4 |
| `UInputSettings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings.cpp:29` | renamed/consolidated or absent | 7.4 |
| `ULocalPlayer` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp:16` | renamed/consolidated or absent | 7.9 |
| `UObject.Base` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp:166` | renamed/consolidated or absent | 6.3 |
| `UObject.ToStringContribution` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp:229` | renamed/consolidated or absent | 6.3 |
| `UClass.Base` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp:241` | renamed/consolidated or absent | 6.3 |
| `UFunction.Base` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp:271` | renamed/consolidated or absent | 6.3 |
| `UObject.Operations` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp:358` | renamed/consolidated or absent | 6.3 |
| `UPackage` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPackage.cpp:13` | renamed/consolidated or absent | 6.3 |
| `UPoseableMeshComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPoseableMeshComponent.cpp:22` | renamed/consolidated or absent | 7.3 |
| `UPrimitiveComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPrimitiveComponent.cpp:37` | renamed/consolidated or absent | 7.3 |
| `UProjectileMovementComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UProjectileMovementComponent.cpp:24` | renamed/consolidated or absent | 7.3 |
| `USceneComponent.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp:41` | renamed/consolidated or absent | 7.3 |
| `USkeletalMeshComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkeletalMeshComponent.cpp:18` | renamed/consolidated or absent | 7.3 |
| `USkinnedMeshComponent` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkinnedMeshComponent.cpp:16` | renamed/consolidated or absent | 7.3 |
| `UStruct.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp:241` | renamed/consolidated or absent | 6.3 |
| `UStruct.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp:262` | renamed/consolidated or absent | 6.3 |
| `UStruct.ReflectionBindings` | ReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp:276` | renamed/consolidated or absent | 6.3 |
| `UStruct.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp:493` | renamed/consolidated or absent | 6.3 |
| `UStruct.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp:511` | renamed/consolidated or absent | 6.3 |
| `UStruct.ReflectionBindings` | ReflectionBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp:525` | renamed/consolidated or absent | 6.3 |
| `UUserWidget.Manual` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget.cpp:90` | renamed/consolidated or absent | 7.4 |
| `UWorld.WorldType` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp:122` | renamed/consolidated or absent | 7.3 |
| `UWorld.NetMode` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp:138` | renamed/consolidated or absent | 7.3 |
| `UWorld.Functions` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp:151` | renamed/consolidated or absent | 7.3 |
| `WorldCollision.TypeDeclarations` | TypeDeclarations | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp:555` | renamed/consolidated or absent | 7.2 |
| `WorldCollision.TypeInfrastructure` | TypeInfrastructure | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp:566` | renamed/consolidated or absent | 7.2 |
| `WorldCollision.ExplicitBindings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp:576` | renamed/consolidated or absent | 7.2 |
| `DirectBindArchitectureProbe` | Finalization | `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp:565` | same provider name | 7.10 |
| `SkipBinds.Defaults` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp:31` | renamed/consolidated or absent | 7.10 |
| `AngelscriptTest.ExplicitBindings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest.cpp:388` | renamed/consolidated or absent | 7.9 |
| `AngelscriptScriptTestSuite.ExplicitBindings` | ExplicitBindings | `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTestSuite.cpp:175` | renamed/consolidated or absent | 7.9 |

## Final runtime reconciliation

The task 8.2 Windows Editor/Development capture reconciles the static inventory against the actual registered collection and installed Store by exact provider identity, including owner, provider name, and phase. The 267 runtime provider records resolve to 258 recorded providers and 9 policy-excluded providers. Exactly 240 recorded identities contribute at least one type, member, effect, primitive definition, or native function map. The remaining 18 recorded identities are the explicit intentional-no-output set asserted in `RuntimeCollectionAndInstalledSnapshotHaveExactProviderAccounting`; any missing or unknown identity fails even when total counts balance. There are no unsupported or unaccounted providers.

The independently validated full-runtime manifest contains 19,126 intended AngelScript type identities, 18,573 members, and 22,881 separately captured reflected native identities. Two fresh captures are byte-identical and semantically equal; `verification-full-runtime.md` records their artifact hashes, exact runs, target policy, and independent validation commands.

## Coverage mapping rules

- TypeDeclarations become detached nominal/native-layout records; TypeInfrastructure becomes adapter, template and finder recipes.
- ExplicitBindings and PostReflectionBindings retain complete method/property/global surfaces and source precedence.
- GeneratedBindings captures native function maps before reflection resolution.
- ReflectionBindings captures the loaded UE type snapshot and callable/property recipes on GameThread.
- Finalization is individually translated into recorded or per-engine effects; it cannot replay legacy Register* calls.
- All target conditions and actual output counts are validated in the production coverage test, not inferred from this static count.
- Migration task is the primary full-surface owner, not execution state. Shared declaration/lifetime and template foundations belong to 6.2, 4.2 and 5.2. Task 8.2 reconciles actual eligible outputs with this inventory; tasks.md remains the sole execution-state authority.

## Source file SHA-256

| File | Primary | Reference |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp` | `c413c1bf18a8ae2c43587d7bb18de03dd676391024d164919ea56463c6601792` | `382809204090ff31f5d4c70cf28a60dd33c6d65551a36bccd36c352b3ff11cd7` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp` | `f32ac7df2f7eff828c0f4bc7a472dd3e5c5846493a88ff8e0782980bdd99d5cc` | `e58f0e243c1a176243eb1b4a80f420779554ecc0bb5a536c1bb111a4c2dc95a1` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetBundleData.cpp` | `1eba34b4e7952dc8a658e96fdf769821220f5fd8c3894da2bbe46ea71bb6bf1d` | `48ce7ff851f02005a08ee6d9a9b407013be89ccffd19f0440b2b7aa043de9e38` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetManagerScriptMixins.cpp` | `d433475a4305e49cf912105cae67f18e535725e88748c1b20e25af1b2cabce3a` | `5ae553cf688bcb7e7c84f81c297516c59267c920577ac516f8b26d4cdb2a0f0c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetRegistry.cpp` | `2058c76cdf086812c271bbfd599d63301c04596f047a6c56420377292d0a419b` | `22bc2dcfdd670d5912e59553b3e7fa82958765c05262b06243b99d6c3a0ad2ef` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AVolume.cpp` | `2812d7e6eba43011b1e00bbec3b986c39d33839f5fd9a001db46ee068564ad1a` | `3d857ec6ad42ec450d75bfd1de6368c6964f0cee52e1256dbe8eaeb89875ba79` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp` | `e9ad6f38eb60fd0ad7bb10cf5d4567542edc4c422376d752b8ad7adf014ac824` | `232e689e049ab3ea2af333687778e209cde8c4ab5d0cea12ba2cefb11c885f24` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` | `3b210919cd3dcdb2a873cd2ccb0a22c8524fcb50442e273d2c44689f2e6382d6` | `8c74a4051e40537231b72e1adec288dff72412c42eaf6d6ca917f74ab50dcaf4` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CollisionProfile.cpp` | `1a4c57bad0cc77e4169edea4ce065f268068131ee625f8885dc939e2069624ab` | `88932d4ea04664b239a578cf9b91eb33328cbf3a70941d27ff57b7978609ab6e` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ConfigEnums.cpp` | `a84bf66c6dd3172c90c9158352ea72422a98e88d63f69ff386082e6618235b00` | `c32e3c90be3e891c3ab787b128ad43d83f0444ea1a74658aff4bcbf94f483277` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp` | `5141912fb117daddbf1b390c39778d3f40056344898cf3aa04f02894d3a8a02c` | `4d59c6ebd6e2b1615105a60db12645d328cc551d8f20b07f0a2e938fb7f0da21` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CoreGlobals.cpp` | `efe2a6e5c822f83baafd449241598e5ac45753766dc1eac26a2454c5cb1d6f2b` | `44d8f6facbf4ccd149cb2b03ba16ee0d6c0b00b1db98103e577007bde71c2187` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.cpp` | `d610e7e6f754bbacc1eb18b247c3b71e79c44176b5b05955d5b96d5a27300059` | `d34fb167e4f2c7894ebd6edada6418242db2a6ce3e650f75f24bd3d9647bf2de` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp` | `73256dc9e9c0b692973a8ae31d7d9b9ae51f34c97e4182dc4f161ea4051b66db` | `bb989a5ae88ce541db51a37af7008e0ae3e6aed7758c74ef6f2dc4eeaf2a5803` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Deprecations.cpp` | `885366227c477005a4095822fb5e780195b111eaf0f5980760df2232019c3712` | `7c84f2f5b03e771ec1e3113edd5d53dc2e8b6fa0f64b22cc3a461bcbcd4c5902` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters.cpp` | `8b7726c3c580dfcdb5c2933399e0d16dc5b98b4a26a642bd547f8339504f99e8` | `837d505746f6d2cb85ab4b15187c5396dcdd7c18d1a08fbf5f0612d35188c91c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAnchors.cpp` | `e640e7419e4452886f3650a6690bc3389bca7de24b148578846b7aa18e3bc82d` | `d8fc21ecfbf2bd9aa396b5dc59f9f9844d75ed72a79e7ff6ed075d49367089c5` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp` | `a8a22c80ee4a8fa7f7f38a2ab221bda231f9f8d448c96531e1c85390691208c6` | `874cda07a4911521c0d2fe8ee28d85d88e0bc47acd0e682b68bf56c11eb840f3` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptGameThreadScopeWorldContext.cpp` | `b6acb8a66193a07943b6d0f37ec1183dc283438732293d9af786a6927551d55c` | `2035e0fb7034e36667cba42e18c22715d607d45b518d2659c6eeff5fd59a3b5a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FApp.cpp` | `51028373ba09c51f5c4decce024ebb71a8cc1f764214f534ab9014708ebc1086` | `57c6dc2c8ea3098c1e03f006ef45d19fddea414770454c2c5c63b6b1ba3bcfd4` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBodyInstance.cpp` | `e2b575eee93d2889f44b4d148b73e8fff05aa31821a7797796d6f8c2d5067c7c` | `eeed464c17e65447211bf71ac6b0bcc206bf09c233a19698dd5492a33298134c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox.cpp` | `c0c4a77849332a1589c9b6d77b116a3248003787c3b3411363c9111e0c98c29f` | `a474ee268fdc23df9339d9db2f1a4fb47d8f11452d547e0cb4182e3e5ab0a6cc` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox2D.cpp` | `e2662f815c637aa7f6cccc6e87b18ce46b6bf898eb765119af4176db8d5cbf10` | `4e07c5498003269b61b2e3d18ad460a15710bb52126b768610a51fcf430761bd` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f.cpp` | `24acf6ef79226612024d9c059be32a4e6b4923605ba95d767fed4a7380aed9d4` | `cf455f00ca828206a5f26aae68992310621f31b718aee3a6a6aed20c9ceba4b8` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds.cpp` | `62adf89d8c8806231123140e5b2c6ed481acfd025997af4719cfb1eaf2f45edd` | `be10b07491895e64b711131f5b8d410469e81c41c0b96010399a536fe31d2b97` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f.cpp` | `1963017903013afba1d0f39e12245625c3ca6151aa530a5badd535456a7f1432` | `3c30d70b46f82490ac381cc08893e0572664983468932aed8181c3ee1c285479` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp` | `e75e2b88b31f4be842a937d754a4de0e34bd2de3a7c3f779f19f6c063a964e3e` | `35e317b5f781531f169482c30a055e799453fce8ed31b6661f11fed37d3335a8` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp` | `fbd90b2bff2cc24be7e3bf3980ae196f0ee20c32b4565e7546afa236938215ee` | `6309a632c482f80884b01ba834224d208460afe12d690dcfa9996f628409ba80` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp` | `f2c0ced59df78a18db8b6b31a5531953ecfdf7ba5e321d8f3beb2f84891318aa` | `8ca69e914cce0672b13c8caa6617a9da5cc77c27ea2f12230401cb3b392d6ef1` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCommandLine.cpp` | `4ad11763776147e3daf973c0cd4ad7a6b5a6f4ddcb5a1329c3b587099de4b4f9` | `74a2830fb8a3fe3ba9cdfe66f50b5bd0e451f7fd86954e0abf76937ed94a109a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCpuProfilerTraceScoped.cpp` | `179475ece26ba65d10fb4fb0ba2b811176d3b11cf795e28f5769d1d45108e6c9` | `a0b5f326f5dd0933484f7b78fa05c4c24cab4f758c03fa791cccdc55aa592f1e` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime.cpp` | `69bd25d6fb66775920a10b12aaec1dea4daea0497cee91e4d71a110a6588fcc3` | `9b281ad0983a11b5cdfe09c745993518b2194c196f67543afac0ff0b27af7770` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFileHelper.cpp` | `1f83d085b2fb532569e8137f940ba4fa7f27afc73459e20647344caf0850410e` | `744b544f6bce95593c75055c3a4265e9ed3b16640327d43dc31861607e85248c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue.cpp` | `e205519a912c2d4c609deab2908a0b05e30d7df133ca40e3f8e0e8aba27ea790` | `6b14d61d5c25eba177c6d3decbc2418019ca9642ff7c658033279c13cdee73f0` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFrameTime.cpp` | `2ca0dd0b2dbc6e2b8902b215564c4c452022a88bf589da2bfe8618a31c760a4b` | `5d3d50090d32aae781014ac319d4d9062b5125bd2184e85d44ce39bc3632b01b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGenericPlatformMisc.cpp` | `11965939a06f9ffe1fb72390ce44cce697cee59c3fa6633412bfdf273f62ee7a` | `8b93bcb3b7ae3a65caa755e6de0279865930e15d4dec1da9fa20baf7bc0ee6d0` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGeometry.cpp` | `c6397d509411a9d9b402e2fbbf1dac2d22e5fa21a9f34789672ea2a802bc5158` | `b9a697678af9ddfa71ab24db39da53c4255ddd524615a8ac38d2fd003e4bd686` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGuid.cpp` | `4166aa29b891bcc1607c305392a2f072ca7c2855c3b3989842a8806348c3e3f9` | `01b3f208c758cadc667c7418aeb3330eade54ce2c633bd4908b5a92237dbca6f` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp` | `c7b99a62587b9f039af1ad070383cb71f50fd143e8c929c30c10e150d3b2dc74` | `e939189f476651200ccd4e8330bda2b42f1441168e58ad08a54d7ad7f7a5ee47` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionKeyMapping.cpp` | `f2467a50ddf36deac68905885cebf1447e272ac26e5bc8377c4052fe8e47ba71` | `36ac42ecd3a9c7a0b2fde4150fb31285874e692a7223f1f3af0a2fc4ca924109` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionValue.cpp` | `7c7d92aaf7344eb44b0dc96caf5ea386e60fa3782c37489e5da86962e64b8105` | `62cd89a48aa5ac46e754c2cc1ff8f82e0aa1b7715fb4395052a92aa1e356491b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle.cpp` | `1ebdda4e17895835c8f87caf336bd56cda951b961ead66f0a414d169c8a19da3` | `259a16b88397a52c72983410906e7dabc9adfbe5e7a36789b808051800dd6eae` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp` | `ead286ff98c0c74df32a5edd6672c5877813c29a6ff5444b0f72b89a1d4015c3` | `4fb92817d83d45f42430f087a9f0b4869230df3780a2572e9b477c682953c818` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint.cpp` | `04c3829a4a74bab2016d90b4b7607cad881b3159097763e489259d47e021041f` | `5bcc750aef6e0986d078dbabedc38dc0517b20970369c7c766b4820b3ecd61c7` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector.cpp` | `2bf527bc7532af5ca76fe5285d742adffebfe1ad131e0cc9edd4a804ce82c45b` | `d1f581b20b7d314906f1edac8fac1d7f270d692d84702b68ddbe2304b0dc053e` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2.cpp` | `beeb31518a3f399fbac09964d1de67569a361cc06824309389358fd049bab7e8` | `9eda4beb6a653756ecb6ab5d333eb176c43f96a7973c988c928a06a4a3e713f5` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4.cpp` | `e6b1ac93d28965008a542ccc56178cb21a61c3db1d0960b76024415ea6007ea0` | `cd10c4f39390dfa162ea86e660171d535055bcac3130daae87861e1383d65342` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLatentActionInfo.cpp` | `7a4eab98b668d125c90da5c09f942a66bccc37c0e30c93cb00128437c7983ae2` | `a9503290d78b9bfcea15ba3c88ebabea653c8c1168fbea3e773a07d535001a1f` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp` | `21c51dfd286c9792ab672ce0b669ce528cd1071eeb8bd8b90754bcd6acdb8d95` | `b2cb3b496007d24a69e925a28defd86d0c4a488747a839d8d383383e73d1ec8d` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMargin.cpp` | `ea86060130c8b8006717b86709f0f92a760091f2abd91680d08bdf35d1fc7718` | `1b30f68ba534101d5d0808a65e8aad8f26bcfd4a102d02e3d459760046a33179` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp` | `b35af944f29c49a1190b9b41ce7544ff5d16d5caac35b6134b493d7b15128b13` | `55b53c77af3a62c619435808707de23ba0d1e8a949963ec1428795170ab9f6d4` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMatrix.cpp` | `d50d26d06380348d08500c9ec53a620ba8e6fb2c731058c1cfd650682c28b684` | `b74be5d5e9355ad02e18b82d68530e03b867b1dc706e1806519681b4e2545745` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMemoryReader.cpp` | `769289cce9cc197667c80cdf9745bb64e32b6e9622a676308f90cb04556f83c0` | `6e724cb274a0f7efd6d6b941c2ce2081193af60cf9a6065e521cde09754bda6b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMessageDialog.cpp` | `1fdcc9a09973a86f88c498ebf9ab7ccbae27013dc1cedf30f71f05459ac64176` | `bcb23a5fed768951d573679106b7423dad7f169978509e31ed3f0feccc16c564` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp` | `c11785e841e74768a639b185ac09a8c9321e1ccba620abf662fff9a5d2110197` | `d59e815b4fbdd293ecb7f1238408f3f34927f6a1a05b37a416e26f0c7ef69b2e` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FNumberFormattingOptions.cpp` | `4f921c1e38926ba3ef2c417c7628cc2d2ed70b9f9c8c6e7228887b5289e9f940` | `e8d82a1dfbd57532bda5184df3ee18086dcbfbf98a42b3476a86281f479ccdb5` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FOverlapResult.cpp` | `f02b1ed7323d1b9565123bf509799a8675f687c47c5aabca12d39b2d35daa17c` | `cd3c8548b7f83fc7823c4ac90e29713aec61955f25ddcd17a72914f1795aa6fe` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FParse.cpp` | `68f4ff86af0a6f384c5f037b605c9726565cb456aba69aa86c4df3fe8010b64a` | `69591d4a2fba0f353bd160f9422a5f3f4a77b70c949a2de86a7089b19cbdf256` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths.cpp` | `fb84fce2df74a70a56c214291ac62e7a0040cc31a58bef18bd1358134c9df966` | `d408b5479eae378da6d1754861ab8074ff5f5ed49459f6524c18e042c00db968` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane.cpp` | `5bc286723f82b24baeed8ef02d73e448ad757e24eef0da809956736d53f875d3` | `d490f6098ef1b29e4fc1ff43c72cd8afff892bef2a1a6868a5c3122d75d99850` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane4f.cpp` | `e08b16173fe6eea72dd896f6f66907962913d041f8612053414c0636cacf146e` | `d1b26ad9928c6774cb9b8a945131cf6c805ca446fe61e92a6128a0b1ab4883a7` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformApplicationMisc.cpp` | `c7423fffcaec88ca9dda0ccfee7ff99284b10024f268028ad89119a99835cd40` | `01d5e312b475fb780d173a628fe1f953ce1757ef5c96c7c85f6a3b58289e25dc` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformMisc.cpp` | `3a7fa524519c7a2ca795f2e92a41e93a525d1e33cf6f608306e7784c29304b34` | `917d092c237b6f77e8e27980daf1bf61004559de3eb6ccc94fb68c2448c99c25` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformProcess.cpp` | `35e0d2582edc9f8972061d88a86d1037321297f42130ebde062d76af4dd293f6` | `89de408aa27a9df4ed486d8367d6c0f072b40e2527e254a19ec1677e17fe458a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat.cpp` | `ab2ef7490296e6916c5059ddfcbcb62c7e1154a2c11f2957ab85ba6ee6f026c1` | `44e1c65afe8e6752d2247f53bf22455d330dd4e900b89a1abd8092a3e18841cc` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f.cpp` | `dc9fdcfbcc56348a0c1b4c3d5e9b90a96e3185e3216fba7f8dd5d9da147a0c83` | `cc7214f018473077b14f9a9681dec0ec5acde57e10fbea922ab0312fee462e02` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp` | `a114b45778b3e1dfbefac9050abfcf1537cba9151815c15dddd1901bfc6160f0` | `2c35d7675b8ffc64a5e785fbba3d138cba85e61f67a05e3e83461376725c178d` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRange.cpp` | `eddb670ba02084a6492d440c63086b983be67e95c1e3032c2fefe1f019009fe9` | `5ea77c370d678b2401cb657b76e7e0e15ea725a9096851f44e90662ff91b6c8f` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator.cpp` | `835f90c90f08006fcbb668fa42754c43c4d39e1408772c83093e12b6a4c892a7` | `f28a0fb2f1bec3830eb24144257ed1400cd8bfa1112f664ae70659a5cdff87e0` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f.cpp` | `7394074fdbbef26402c72a63c0de435c0b2aca2f27ed1cbc32b4278bfedc396a` | `f259011d7975aa5d162550b1be25dfb281c5315ec917ee000a5a9e7ea5c15666` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere.cpp` | `b6951a03cf5f14bf97efa3f2a85033ef8ecb4f4e683acd1b84b9972c6d3bfd2d` | `7886549683cce55146118f86d44c855d7e1e09ab44fe5ad553bb7840b5a933fc` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere3f.cpp` | `10e188cfd68239825b701d46afbddd9bf21343381091c6aa6f97120263ba69b8` | `02cd92e689260cd2fabc6a7e3ae752626b69ffa372a619dd2cf5f4fbacf6c744` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp` | `67b72c209f0d5fdcce933f60a9fec1b40dd25cdbe016a3aae09e03dae57f90e1` | `a80ca4545454c10ef3e74f4c44fd464777bbc3e00777cfe1b86421b93f94e5c0` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FStringTableRegistry.cpp` | `18b662c65da250ea71c812b902ea3082a3dbf6fe81d18bbc854dfa9124dfd082` | `67ceb14f18076b6c8711bb634800e82559b8cbf134872b1f2b52fb780bffdb39` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp` | `43f9cd1dafd4147b438cd9ea2126fb67f926d6233b3ffcd8ff1ad662337d1b5d` | `ffa7498687edb6b8da9d94cee9cd8db3813e39cd0e680f92297810db15c1829c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTimespan.cpp` | `e2bcd791df9f61ec0533d4744ec0a86809467bb69322686fb6f22d8067e20a19` | `91e648236825fec1ff5d6747611eec1ce2feee255db2e31f3d3e4fe0374d2725` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform.cpp` | `3c7dc9305fc2b887d99d33e3be13d0ae8b331a775345ec5de1ae1585a5eb9085` | `1422d7e0420376071e99c7106cb49bfb492efa1655a282dc4c2491abb24d0206` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f.cpp` | `c61706f7d8653082c3a1bdee941d22453c7d76b0e18a65e87d1f2095c79cb351` | `aed9f90342e644b0ced02bf284148d8e421278baaa54566fe4424b41f7f95efc` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FunctionLibraryMixins.cpp` | `9a3fba3b004940bccfd3aa35e70745cc65f69aaca7defe007f81eddcfc7a8e5f` | `089dd826bc1de120ac219e8e29d1bc9efcd32474ab5925ac75f222659f401c4a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp` | `5f6dabdeda3e06f99c9feffe4335bc11700b29383e7e660e8ae5e649edd936c0` | `a0464916fa59faa0308ed99276afcac08a2809157eb9c9631edd9bb487db5158` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp` | `59101dda8d52087ed8f26eb1f99f04ca3e756ec8cfcb272e516c83d486c6c701` | `9058539cd43284058770e7c8a29c48eb18e9f39b46da8dd3ab6719a5bbef4c8a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp` | `744c1238009e2e05f983adc463ea0d3f4d02d73f6f08f3e1e009dfa283fd3746` | `ff1fafcaa9c2c721770145f977dbd4bee16641079106b0c7f154907039e432ac` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f.cpp` | `140ebdc458370d4b5a390c927b7233750e0f27788f94a5b3045ed336926f6a8b` | `1b50874e99a0f8839f93d319a022ca1861840912ee3ddbe01bd20c8e2e9dcc89` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4.cpp` | `0573b10cb10879568576c3311f9121863795d7a5b5c3f03ca4fa0338bed8962a` | `b3aac87c2b16c297adf77a420d7f846775e9e48a2ae2da1d9a38322012a6ef17` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f.cpp` | `e802143a00a7c69607373becd020b82b5791664c185fdcfef309436e84343cbb` | `9e11483f05f229369e717a95b06d932430290f0d2e8d03a67395f8201152cacf` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Hash.cpp` | `b95ffbdc3a043088d8478e8f91cd2c71822d76cf37581292e706c7b2e822bab4` | `afdca173408f0781a5d62e431d416de54a03da745f6816ac55fbc2d9137814ed` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins.cpp` | `ed0e4dd31a9983c110338cb82ad564aac1f4c99614d639aa1da3a02a7f99d952` | `50d8a0a66431584b4886ee3d796fd82bd3f90e93d1c2fc5f69ddd78b638214ea` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp` | `8ca7731ca2a93e66a158a096460c89cbbb6deba32eee43ffaa120fdf68718b2b` | `e5b463e9153b626aea8738be82ec0b7b7bff1816a85e847b4f1f82eba830795b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json.cpp` | `34baf98aa5f823c8f3da4772b649e6bae56d93e2522014c5e1e492dd6002e179` | `28ab405ff83fb68fd2f379307c71aa48b32f1605be404804535253fe006e502d` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_JsonObjectConverter.cpp` | `baaff84e4e4a79ddd712da9cb55db5694d8ed85d2cfb918b75191f19a3746fac` | `e938a2ee1a2b8b51bf2098b4b4639d2230fc8a1cf4711fae7eb3296d518f754b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_LandscapeProxy.cpp` | `280873d145153a03258b9005f31579d1c654c9e973b83a30cb302c3d69c8b86c` | `b2b58d4439d9c47cf9fb19a10387d41680b4bc6d0173eed3c241db18588acdc4` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Logging.cpp` | `b6b4976770a216849805af9f5032b763082144f20ee30b3a05d8e771e5eb50fe` | `db115c7d63b894c6a2db7655aca624bd834882d9bdea77d3bfa0ef8556c3ed77` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp` | `6c2a3aef3d208b28f722b28ad898e1227c03e80a491f040cdf5741b2492f4785` | `af73d07e5ea30335b9875bf5f9be70316c30378d497b5b191442247469cb3c56` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp` | `9b232f5e77ed07905092050e8eec4fb818358012dc3e863be4e088c2ecaf0bf4` | `bc9110bb2d6cd86daeca22d97720f7eeccd99501fa5a26f61f653f5f48489024` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SoftObjectPath.cpp` | `06083e5f3bc0968715fd91cf3bcbdeb8e192466c8b20411e860fd64c1ba72acf` | `d30ddb3549b7c4ab03c2ddee9d66330fed0b6b1004c24fc0d93c34c58b2fee70` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Stats.cpp` | `c5c2c5f727282cb384538625bd9a7060d7f7534c891693a373e248668d51eb0d` | `f98c1035f40413eb995d64b4f2d0f904bda7ea735f5520f3056de244a3405ae8` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp` | `263df2f5fe5bcb3c42117b0236ff66d769d148ae0061133e7868f8d63e8fe85d` | `40ffbda70feeaa9c7eb38ea8cfe9ae94df914415238fa72efcf06ed941a70311` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp` | `00ba3d8efc1a3e632657413690ad669d859dcf298bb590877d7b2005c6868f3a` | `6af1323d4025b2c8a233be3d9a561a02f092f3f02c8bfb9a3873ea3b92e6fa88` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp` | `c90015601f5bf9407df67cf631279319f9a8489c0e10fd67c1862e43630dcdac` | `3ae81a26555dfee9adb9a7ef3e4bef296c086991661c22416d26278d8bcca1da` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp` | `4bcddb94be669459045cf6e45a8c5c0fb0c5d3412bcf561dccf5b4ce0a9b2cb8` | `e838d5f05362bf38a1c9ec1e6bced4250859945ade17993fa03d1de0a76a1ecb` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp` | `0a55073238d399500b5c9e8ec33976651528321c78b94b8e885f171b21f9998f` | `641018eae640146de86cdac31b6c511fd7f074fbefff3484026d7d8cd609c989` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp` | `f05434e3fcf0dc5e48b730202d7b990fea535f3cb5ec2b458d077ecf808fe17a` | `84588ec42844e4ca75233a8cb39918cb8868ec50d3cf5b6c0c13b95e39b4086f` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp` | `93da39c6c5e7b793e872b57c96defdf0e3d9b6d79a035fa85cf1296c83164307` | `2ba6db64565cb1fbc50d635cff1b502addc8a4c1bd78304721f3747c59d70946` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent.cpp` | `5c406e2cd8d5225761acc5215570bae2588f66adf24137c792a8d3a6e620dd7c` | `3213a28b92f05ff9a9679ef34a793cb62008dce39e2cf21fd815dced43059943` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UAssetManager.cpp` | `df22c8b8ffe6e13f5a823bf29cfa5c9eb4d4341fc2826a36c439126e0418486c` | `3d5099dbfa1062ae3128ffe288daf9d2e895dbfeeefd9d0160e5dfaacea88393` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UCollisionProfile.cpp` | `7adcbda99ecf4a97c8e484af00c09bcf3473fa48e0b57c65f86eb4ad9ae15e8e` | `d3749dbee332711f2383e60f29a4a600fa75da0ec71a68b0c8afb25b6b4f8ac9` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UDataTable.cpp` | `0ebfd7f1da46ebed861eb6f371d73df5c25d4975c4fe839c5a37aeb2903ada46` | `e6e26fa921129b608617bb84128ace1e2e62e72ae8018997ed433e09e655bae8` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnhancedInputComponent.cpp` | `cd50bb26a31d1712e1ffbac5ec0f64aa126f2dd75e8d33bd5099bae6c1b1edb9` | `5b6a5aace318d2efadc6cfd070bbc9618b75154925632d3113068224303375e5` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp` | `b52419047507c0895aee7c8ad79046ba4c41af8efa1d3c4119cf454fdb1562ae` | `e8c966be81b0b069d56e9d1b5fbafe005111b6e7ae6b643d48597facbaf4dac5` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UFXSystemComponent.cpp` | `eb5ea9c4c700131ae1eaa5b641af938de794335611e20884b145eeebb5f50f0b` | `0e6b04647b558a414e13c76e245bc706d8630b2f8d0ee86e23b7b49257918f24` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp` | `d72cc976f91fcfbf2158f70f989e8b18c68aca7c2b84eb4f0a08d13871308de3` | `be249b6d0c72667cff0af56d7dfd298a2eb5ca7eb527f91e1a985835b9c782ae` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp` | `f266395c277244f1712dc900271b1312c595e4974eb8fc2b8d54f3a9204f0adf` | `355caf1b16684a24f7ae1d93e1604eebc6781bff8278ffb0a4ca682051904bfa` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings.cpp` | `6b89d10eba8b48ca2d4912115e25292118e4a83a7593e152be6c2f14c236cf82` | `efecf8e81ccd414f94e193dd06327c70a00e115fe22befe99b312eefd9160225` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp` | `52be207a17e91776ae8cbd79732769d58086800dbda4662952756c11c386dfb4` | `e4097cc05016f171bbafafddee141ed088ac12f871ffb199efc48a817e82a6d1` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp` | `3e90288d08ebf9d89d173df2f80590b53dff2bcd5f99b6289150cf213aca301d` | `254210e8f61ea630771c1d99dd4c44c48e04265c354682bbb0cd637989c0ad09` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPackage.cpp` | `e969628622d60433d27f9fa336b5c51953d5c10c411ad2f1f1c43e456e68bd7c` | `6e6ab8ea04f40f94c367de40b2443d5b9186b5909a7680aa809799717d51e745` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPoseableMeshComponent.cpp` | `5a621b06ccdba57cf42861ca680101c646a2ba6b132d4e600fc295120beafa9c` | `88be96f56f4aea3d3286969337579ec5786745feba7e233d763ae2d9bb809cbc` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPrimitiveComponent.cpp` | `643d272b0770a18d0f6da00e304c8ccc290ad7521353619e778080fd46794701` | `aca5eb6ca2ac374a6c74622ae8a95a57dbae8afcb28ee191a9ca9b14824692a2` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UProjectileMovementComponent.cpp` | `dc297ad13dda53d45f2d0a4781facb4fe6b154e025ff0f717d5f233a7f3572ad` | `eb8c452c1b9cc857cef407e6ef6982c5fd73e19e445bc950805cf00c972a3a6b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp` | `587b23c3e087f0ed55f093f8a69868745e6a61014b0c6c05e56cd091cbdbe19a` | `8fb737f0e7785ac02981b834d03f3afaae74d20b5c2bf7cd53d87d8f0479f2c4` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkeletalMeshComponent.cpp` | `096fc7409b951cae70a3961fa588f32652427b707845e2d69a46960e957ab31d` | `2900e1e33ca6d0394198f8cea4dbd938cb13e173bdb42ed0c32db1c360c7d46f` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkinnedMeshComponent.cpp` | `1f23a0c4025d77a12e9128ff30c676479f87a2eccb9d6033a90c3995ba8f5659` | `460b3cb8bf2d07b4918fcfd32142bd74de20992c844c357897c1561582958c6f` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp` | `bd29611fe9766d5b0c6ce743ce800928ad1ed62d1924d890f42be650e2c89fc4` | `aead5bf4b9bb58d00fdc5441b5e51c05986358e033bd614dcd9271c896cf6797` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget.cpp` | `8139506b7cec2ba3bd6ff8ab6c8c12d49dad33a52fe146526984b41e2f9ac578` | `bc20f30b0fad82b1366deceac78e80812938a13330096a47295be789a175c120` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp` | `b254cd227d0e1785c6fb90016e4ceefbf3dec285659612159dd43f95971467e3` | `609674b50b06876bc76833b53e5b9367dda3ff3638a22ffb549b429d5ca3c13a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp` | `a223ad0254e8e480f9a80174b649c0ac42dbfd1b355188fbd8db57dd8a435edb` | `0c4d2458b4ee2c83910dfe10aee992f3bce568db9913bbdbe29f2192667ae35b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` | `501614cd27e3869367e47eb81fb67cd9f2e706f69f64a03816774c39993c2925` | `88ae7e60610b3444e6e23cd762cdff1225ab43e97a10d798740cae9e67977140` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp` | `a485186192e2e0e272fe4ee28267b97b8b2139ef07f8a9c697129c31415b019a` | `d228ec102df2181539999907a22dd7caf30f3df8da1ff8bd695a494d2e912121` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest.cpp` | `54b1d62d46bcfb453ba3868467862a2c8fe19f7139a44a41451bca9390820e81` | `48e4775c73026a085bff0cb3590dac28e4cf6b03bfaec6ce805a32c44c613be3` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTestSuite.cpp` | `a6e6fe8deff9c325ce84939930f297d64d07354f008f4bd662c68f6e7421b558` | `da1195155fa4adb73fb7eedb96bb34feb6563695ee3204fd106e5ae98ab73a47` |

## Additional reference TypeBindInfo SHA-256

| File | Reference |
|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.cpp` | `d9884c55f581bda5b925cf6c2d84d90943938a19bdb3ba0cf840bb27c38347a0` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | `6b8e33466fdf3ad328e4556f5467eac0d49c1b2ef2e932c40b8632ddaccac7b8` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp` | `f86b26170537383f0d27193cb00233ef5a80b274b6f856498f6d09240250f7c2` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h` | `34356c32b136532eb5665edcf306937c8d2e47b2bf4dfcf1364ca9ffe1908f92` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDsl.inl` | `519f9aa9f83d0e10b24380da7166ed0b76829959dbaa3657834c8b8976944315` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.cpp` | `193a20bbae56a8347ae5ed96ef02a3ded49b940d07efa85301070feac7ee128a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.h` | `82f8bff6f5fd56b12cf175c9efa396ee7a32697f6eb8b17a7a00f6a9c7fc3162` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.cpp` | `eed920253f9fa01307e5c679aa29dcebf21d74fe2941f9f443b89485605a7182` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h` | `6224cc8ef45612e23938f29b3419cc4764fe9a3f98102d4baaa1e6f457400d22` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoTiming.cpp` | `5fe744f78242af64a40a7816cbbe11e3a83484ffd72eedd2145a215f85140c0a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoTiming.h` | `15cb4afef9b82d74cb2c3f8b79d33afe1fb24b562a7f3cc212f376b3020d3d3f` |
