# Bind Provider-Lambda Audit

## Frozen Source Snapshot

Production roots: Runtime `Plugins/Angelscript/Source/AngelscriptRuntime/Binds`; GameplayTags `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTags/Private/Binds`; GAS `Plugins/AngelscriptGAS/Source/AngelscriptGAS/Private/Binds`.

Baseline source scan: **126 registrar files**, **242 logical registrars**, **245 baseline source definitions**, **5 direct local lambdas**, and **240 named provider callback pointers**. Final reconciliation records **248/248** body-expanded direct non-capturing registrar-local `[](FAngelscriptBinds& Binds) { ... }` callbacks, with zero named provider pointers, standalone provider functions, or forwarding wrappers. `Bind_UStruct.cpp` retains three logical identities in both `AS_USE_BIND_DB` branches; the three extra final source definitions are the DB/non-DB branch-local `Bind_BlueprintType.cpp` providers.

## Complete File Inventory

Legend: each entry is `symbol [logical name; phase; callback]`; `D` is a direct registrar-local lambda. Every row has been reconciled to the final state.

### Runtime

- `Bind_AActor.cpp` — `Bind_AActor` [AActor.Manual; ManualBindings; D]; `Bind_Actors` [AActor.PostReflection; PostReflectionBindings; D]. Target: retain direct body.
- `Bind_APlayerController.cpp` — `Bind_AController` [AController.Functions; ManualBindings; D]; `Bind_APlayerController` [APlayerController.Functions; ManualBindings; D]; `Bind_APawn` [APawn.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_AssetManagerScriptMixins.cpp` — `Bind_AssetManagerScriptMixins` [AssetManagerScriptMixins.GeneratedOverrides; ManualBindings; D]. Target: direct body expanded.
- `Bind_AssetRegistry.cpp` — `Bind_AssetRegistry_ToStringContribution` [AssetRegistry.TopLevelAssetPathToStringContribution; TypeInfrastructure; D]; `Bind_AssetRegistry` [AssetRegistry.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_AVolume.cpp` — `Bind_AVolume` [AVolume; ManualBindings; D]. Target: direct body expanded.
- `Bind_BlueprintEvent.cpp` — `Bind_BlueprintEvents` [BlueprintEvents.HelperGlobals; ManualBindings; D]. Target: direct body expanded.
- `Bind_BlueprintType.cpp` — `Bind_BlueprintType_ReferenceClassDeclarations` [BlueprintType.ReferenceClasses; TypeDeclarations; D]; `Bind_TObjectPtr_TypeDeclarations` [TObjectPtr.Declaration; TypeDeclarations; D]; `Bind_TSubclassOf_TypeDeclarations` [TSubclassOf.Declaration; TypeDeclarations; D]; `Bind_TWeakObjectPtr_TypeDeclarations` [TWeakObjectPtr.Declaration; TypeDeclarations; D]; `Bind_TObjectPtr_MethodSurface` [TObjectPtr.MethodSurface; TypeInfrastructure; D]; `Bind_TSubclassOf_MethodSurface` [TSubclassOf.MethodSurface; TypeInfrastructure; D]; `Bind_TWeakObjectPtr_MethodSurface` [TWeakObjectPtr.MethodSurface; TypeInfrastructure; D]; `Bind_BlueprintType_Infrastructure` [UObject.TypeInfrastructure; TypeInfrastructure; D]; `Bind_BlueprintType_ReflectionBindings` [BlueprintType.ReflectionBindings; ReflectionBindings; D]; `Bind_BlueprintType_StaticClasses` [BlueprintType.StaticClasses; ManualBindings; D]. Target: direct body expanded.
- `Bind_CollisionProfile.cpp` — `Bind_CollisionProfile` [CollisionProfile; ManualBindings; D]. Target: direct body expanded.
- `Bind_ConfigEnums.cpp` — `Bind_ConfigEnums` [ConfigEnums; TypeDeclarations; D]. Target: direct body expanded.
- `Bind_Console.cpp` — `Bind_ConsoleTypes` [Console.Types; TypeDeclarations; D]; `Bind_ConsoleVariables` [Console.Variables; ManualBindings; D]; `Bind_ConsoleCommands` [Console.Commands; ManualBindings; D]. Target: direct body expanded.
- `Bind_CoreGlobals.cpp` — `Bind_CoreGlobals` [CoreGlobals; ManualBindings; D]. Target: direct body expanded.
- `Bind_Debugging.cpp` — `Bind_Debugging` [Debugging.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_Delegates.cpp` — `Bind_Delegate_Declarations` [Delegates.Declarations; TypeDeclarations; D]; `Bind_Delegates` [Delegates.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_Deprecations.cpp` — `Bind_Deprecations` [Deprecations; TypeDeclarations; D]. Target: direct body expanded.
- `Bind_FAnchors.cpp` — `Bind_FAnchors` [FAnchors; ManualBindings; D]. Target: direct body expanded.
- `Bind_FAngelscriptDelegateWithPayload.cpp` — `Bind_AngelscriptDelegateWithPayload` [FAngelscriptDelegateWithPayload.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_FAngelscriptGameThreadScopeWorldContext.cpp` — `Bind_FAngelscriptGameThreadScopeWorldContext` [FAngelscriptGameThreadScopeWorldContext; ManualBindings; D]. Target: direct body expanded.
- `Bind_FApp.cpp` — `Bind_FApp` [FApp; ManualBindings; D]. Target: direct body expanded.
- `Bind_FBodyInstance.cpp` — `Bind_FBodyInstance` [FBodyInstance; ManualBindings; D]. Target: direct body expanded.
- `Bind_FBox.cpp` — `Bind_FBox_Type` [FBox.Type; TypeDeclarations; D]; `Bind_FBox_ToStringContribution` [FBox.ToStringContribution; TypeInfrastructure; D]; `Bind_FBox` [FBox.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FBox3f.cpp` — `Bind_FBox3f_Type` [FBox3f.Type; TypeDeclarations; D]; `Bind_FBox3f_ToStringContribution` [FBox3f.ToStringContribution; TypeInfrastructure; D]; `Bind_FBox3f` [FBox3f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FBoxSphereBounds.cpp` — `Bind_FBoxSphereBounds_Type` [FBoxSphereBounds.Type; TypeDeclarations; D]; `Bind_FBoxSphereBounds_ToStringContribution` [FBoxSphereBounds.ToStringContribution; TypeInfrastructure; D]; `Bind_FBoxSphereBounds` [FBoxSphereBounds.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FBoxSphereBounds3f.cpp` — `Bind_FBoxSphereBounds3f_Type` [FBoxSphereBounds3f.Type; TypeDeclarations; D]; `Bind_FBoxSphereBounds3f_ToStringContribution` [FBoxSphereBounds3f.ToStringContribution; TypeInfrastructure; D]; `Bind_FBoxSphereBounds3f` [FBoxSphereBounds3f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FCollisionQueryParams.cpp` — `Bind_FCollisionQueryParams_TypeDeclarations` [FCollisionQueryParams.TypeDeclarations; TypeDeclarations; D]; `Bind_FCollisionQueryParams_TypeInfrastructure` [FCollisionQueryParams.TypeInfrastructure; TypeInfrastructure; D]; `Bind_FCollisionQueryParams_ManualBindings` [FCollisionQueryParams.ManualBindings; ManualBindings; D]. Target: direct body expanded.
- `Bind_FCollisionShape.cpp` — `Bind_FCollisionShape_Types` [FCollisionShape.Types; TypeDeclarations; D]; `Bind_FCollisionShape` [FCollisionShape.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FColor.cpp` — `Bind_FColor` [FColor; ManualBindings; D]; `Bind_FColor_ToStringContribution` [FColor.ToStringContribution; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_FCommandLine.cpp` — `Bind_FCommandLine` [FCommandLine; ManualBindings; D]. Target: direct body expanded.
- `Bind_FCpuProfilerTraceScoped.cpp` — `Bind_TraceCPUProfilerEventScoped` [FCpuProfilerTraceScoped; ManualBindings; D]. Target: direct body expanded.
- `Bind_FDateTime.cpp` — `Bind_FDateTime_ToStringContribution` [FDateTime.ToStringContribution; TypeInfrastructure; D]; `Bind_FDateTime` [FDateTime.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FFileHelper.cpp` — `Bind_FFileHelper_Types` [FFileHelper.Types; TypeDeclarations; D]; `Bind_FFileHelper` [FFileHelper.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FFormatArgumentValue.cpp` — `Bind_FFormatArgumentValue_Type` [FFormatArgumentValue.Type; TypeDeclarations; D]; `Bind_FFormatArgumentValue_Infrastructure` [FFormatArgumentValue.Infrastructure; TypeInfrastructure; D]; `Bind_FFormatArgumentValue` [FFormatArgumentValue.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGenericPlatformMisc.cpp` — `Bind_FGenericPlatformMisc` [FGenericPlatformMisc; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGeometry.cpp` — `Bind_FGeometry` [FGeometry; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGuid.cpp` — `Bind_EGuidFormats` [EGuidFormats; TypeDeclarations; D]; `Bind_FGuid` [FGuid; ManualBindings; D]. Target: direct body expanded.
- `Bind_FHitResult.cpp` — `Bind_FHitResult` [FHitResult.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FInputActionKeyMapping.cpp` — `Bind_FInputActionKeyMapping` [FInputActionKeyMapping; ManualBindings; D]. Target: direct body expanded.
- `Bind_FInputActionValue.cpp` — `Bind_FInputActionValue` [FInputActionValue; ManualBindings; D]. Target: direct body expanded.
- `Bind_FInputBindingHandle.cpp` — `Bind_FInputBindingHandle_Types` [FInputBindingHandle.Types; TypeDeclarations; D]; `Bind_FInputBindingHandle` [FInputBindingHandle.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FInstancedStruct.cpp` — `Bind_FInstancedStruct` [FInstancedStruct.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FIntPoint.cpp` — `Bind_FIntPoint_Type` [FIntPoint.Type; TypeDeclarations; D]; `Bind_FIntPoint` [FIntPoint.Functions; ManualBindings; D]; `Bind_FIntPoint_ToStringContribution` [FIntPoint.ToStringContribution; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_FIntVector.cpp` — `Bind_FIntVector_Type` [FIntVector.Type; TypeDeclarations; D]; `Bind_FIntVector_ToStringContribution` [FIntVector.ToStringContribution; TypeInfrastructure; D]; `Bind_FIntVector` [FIntVector.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FIntVector2.cpp` — `Bind_FIntVector2_Type` [FIntVector2.Type; TypeDeclarations; D]; `Bind_FIntVector2_ToStringContribution` [FIntVector2.ToStringContribution; TypeInfrastructure; D]; `Bind_FIntVector2` [FIntVector2.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FIntVector4.cpp` — `Bind_FIntVector4_Type` [FIntVector4.Type; TypeDeclarations; D]; `Bind_FIntVector4_ToStringContribution` [FIntVector4.ToStringContribution; TypeInfrastructure; D]; `Bind_FIntVector4` [FIntVector4.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FLatentActionInfo.cpp` — `Bind_FLatentActionInfo` [FLatentActionInfo; ManualBindings; D]. Target: direct body expanded.
- `Bind_FLinearColor.cpp` — `Bind_FLinearColor_Type` [FLinearColor.Type; TypeDeclarations; D]; `Bind_FLinearColor_Infrastructure` [FLinearColor.Infrastructure; TypeInfrastructure; D]; `Bind_FLinearColor` [FLinearColor.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FMargin.cpp` — `Bind_FMargin` [FMargin; ManualBindings; D]. Target: direct body expanded.
- `Bind_FMath.cpp` — `Bind_FMath` [FMath.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_FMemoryReader.cpp` — `Bind_FMemoryReaderType` [FMemoryReader.Type; TypeDeclarations; D]; `Bind_FMemoryReader` [FMemoryReader.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FMessageDialog.cpp` — `Bind_FMessageDialog` [FMessageDialog; ManualBindings; D]. Target: direct body expanded.
- `Bind_FName.cpp` — `Bind_FName_Type` [FName.Type; TypeDeclarations; D]; `Bind_FName_Infrastructure` [FName.Infrastructure; TypeInfrastructure; D]; `Bind_FName` [FName.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FNumberFormattingOptions.cpp` — `Bind_FNumberFormattingOptions_Type` [FNumberFormattingOptions.Type; TypeDeclarations; D]; `Bind_FNumberFormattingOptions` [FNumberFormattingOptions.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_FOverlapResult.cpp` — `Bind_FOverlapResult` [FOverlapResult; ManualBindings; D]. Target: direct body expanded.
- `Bind_FParse.cpp` — `Bind_FParse` [FParse; ManualBindings; D]. Target: direct body expanded.
- `Bind_FPaths.cpp` — `Bind_FPaths` [FPaths; ManualBindings; D]. Target: direct body expanded.
- `Bind_FPlane.cpp` — `Bind_FPlane` [FPlane; ManualBindings; D]. Target: direct body expanded.
- `Bind_FPlane4f.cpp` — `Bind_FPlane4f` [FPlane4f; ManualBindings; D]. Target: direct body expanded.
- `Bind_FPlatformApplicationMisc.cpp` — `Bind_FPlatformApplicationMisc` [FPlatformApplicationMisc; ManualBindings; D]. Target: direct body expanded.
- `Bind_FPlatformMisc.cpp` — `Bind_FPlatformMisc` [FPlatformMisc; ManualBindings; D]. Target: direct body expanded.
- `Bind_FPlatformProcess.cpp` — `Bind_FPlatformProcess` [FPlatformProcess; ManualBindings; D]. Target: direct body expanded.
- `Bind_FQuat.cpp` — `Bind_FQuat_Type` [FQuat.Type; TypeDeclarations; D]; `Bind_FQuat_Infrastructure` [FQuat.Infrastructure; TypeInfrastructure; D]; `Bind_FQuat` [FQuat.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FQuat4f.cpp` — `Bind_FQuat4f_Type` [FQuat4f.Type; TypeDeclarations; D]; `Bind_FQuat4f_Infrastructure` [FQuat4f.Infrastructure; TypeInfrastructure; D]; `Bind_FQuat4f` [FQuat4f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FRandomStream.cpp` — `Bind_FRandomStream_Type` [FRandomStream.Type; TypeDeclarations; D]; `Bind_FRandomStream` [FRandomStream.Functions; ManualBindings; D]; `Bind_FRandomStream_ToStringContribution` [FRandomStream.ToStringContribution; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_FRotator.cpp` — `Bind_FRotator_Type` [FRotator.Type; TypeDeclarations; D]; `Bind_FRotator_Infrastructure` [FRotator.Infrastructure; TypeInfrastructure; D]; `Bind_FRotator` [FRotator.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FRotator3f.cpp` — `Bind_FRotator3f_Type` [FRotator3f.Type; TypeDeclarations; D]; `Bind_FRotator3f_Infrastructure` [FRotator3f.Infrastructure; TypeInfrastructure; D]; `Bind_FRotator3f` [FRotator3f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FSphere.cpp` — `Bind_FSphere_Type` [FSphere.Type; TypeDeclarations; D]; `Bind_FSphere` [FSphere.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FSphere3f.cpp` — `Bind_FSphere3f_Type` [FSphere3f.Type; TypeDeclarations; D]; `Bind_FSphere3f` [FSphere3f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FString.cpp` — `Bind_FString_TypeDeclarations` [FString.TypeDeclarations; TypeDeclarations; D]; `Bind_FString_TypeInfrastructure` [FString.TypeInfrastructure; TypeInfrastructure; D]; `Bind_FString_ManualBindings` [FString.ManualBindings; ManualBindings; D]. Target: direct body expanded.
- `Bind_FStringTableRegistry.cpp` — `Bind_FStringTableRegistry_Types` [FStringTableRegistry.Types; TypeDeclarations; D]; `Bind_FStringTableRegistry` [FStringTableRegistry.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_FText.cpp` — `Bind_FText_Type` [FText.Type; TypeDeclarations; D]; `Bind_FText_Infrastructure` [FText.Infrastructure; TypeInfrastructure; D]; `Bind_FText` [FText.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FTimespan.cpp` — `Bind_FTimespan` [FTimespan.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FTransform.cpp` — `Bind_FTransform_Type` [FTransform.Type; TypeDeclarations; D]; `Bind_FTransform_Infrastructure` [FTransform.Infrastructure; TypeInfrastructure; D]; `Bind_FTransform` [FTransform.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FTransform3f.cpp` — `Bind_FTransform3f_Type` [FTransform3f.Type; TypeDeclarations; D]; `Bind_FTransform3f_Infrastructure` [FTransform3f.Infrastructure; TypeInfrastructure; D]; `Bind_FTransform3f` [FTransform3f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FunctionLibraryMixins.cpp` — `Bind_FunctionLibraryMixins` [FunctionLibraryMixins.PostReflection; PostReflectionBindings; D]. Target: direct body expanded.
- `Bind_FVector.cpp` — `Bind_FVector_TypeDeclarations` [FVector.TypeDeclarations; TypeDeclarations; D]; `Bind_FVector_TypeInfrastructure` [FVector.TypeInfrastructure; TypeInfrastructure; D]; `Bind_FVector` [FVector; ManualBindings; D]; `Bind_FVector_ToStringContribution` [FVector.ToStringContribution; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_FVector2D.cpp` — `Bind_FVector2D_Type` [FVector2D.Type; TypeDeclarations; D]; `Bind_FVector2D_Infrastructure` [FVector2D.Infrastructure; TypeInfrastructure; D]; `Bind_FVector2D` [FVector2D.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FVector2f.cpp` — `Bind_FVector2f_Type` [FVector2f.Type; TypeDeclarations; D]; `Bind_FVector2f_Infrastructure` [FVector2f.Infrastructure; TypeInfrastructure; D]; `Bind_FVector2f` [FVector2f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FVector3f.cpp` — `Bind_FVector3f_TypeDeclarations` [FVector3f.TypeDeclarations; TypeDeclarations; D]; `Bind_FVector3f_TypeInfrastructure` [FVector3f.TypeInfrastructure; TypeInfrastructure; D]; `Bind_FVector3f` [FVector3f.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_FVector4.cpp` — `Bind_FVector4_Type` [FVector4.Type; TypeDeclarations; D]; `Bind_FVector4_Infrastructure` [FVector4.Infrastructure; TypeInfrastructure; D]; `Bind_FVector4` [FVector4.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_FVector4f.cpp` — `Bind_FVector4f_Type` [FVector4f.Type; TypeDeclarations; D]; `Bind_FVector4f_Infrastructure` [FVector4f.Infrastructure; TypeInfrastructure; D]; `Bind_FVector4f` [FVector4f.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_Hash.cpp` — `Bind_Hash` [Hash; ManualBindings; D]. Target: direct body expanded.
- `Bind_InputComponentScriptMixins.cpp` — `Bind_InputComponentScriptMixins` [InputComponentScriptMixins.GeneratedOverrides; ManualBindings; D]. Target: direct body expanded.
- `Bind_InputEvents.cpp` — `Bind_InputEvents_ToStringContribution` [InputEvents.FKeyToStringContribution; TypeInfrastructure; D]; `Bind_InputEvents` [InputEvents.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_Json.cpp` — `Bind_Json_TypeDeclarations` [Json.TypeDeclarations; TypeDeclarations; D]; `Bind_Json` [Json.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_JsonObjectConverter.cpp` — `Bind_JsonObjectConverter` [JsonObjectConverter.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_LandscapeProxy.cpp` — `Bind_ALandscapeProxy` [ALandscapeProxy.GetHeightAtLocation; ManualBindings; D]. Target: direct body expanded.
- `Bind_Logging.cpp` — `Bind_Logging` [Logging.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_NativeModuleFunctionBinding.cpp` — `Bind_AS_NativeModuleFunctionBinding` [NativeModuleFunctionBinding.GeneratedTransport; GeneratedBindings; D]. Target: direct body expanded.
- `Bind_Primitives.cpp` — `Bind_PrimitiveTypes_TypeInfrastructure` [PrimitiveTypes.TypeInfrastructure; TypeInfrastructure; D]; `Bind_PrimitiveTypes_ToStringContribution` [PrimitiveTypes.ToStringContribution; TypeInfrastructure; D]; `Bind_PrimitiveTypes` [PrimitiveTypes.Constants; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_SoftObjectPath.cpp` — `Bind_SoftObjectPath` [SoftObjectPath.Functions; ManualBindings; D]; `Bind_SoftObjectPath_ToStringContributions` [SoftObjectPath.ToStringContributions; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_Stats.cpp` — `Bind_Stats_Types` [Stats.Types; TypeDeclarations; D]; `Bind_Stats` [Stats.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_Subsystems.cpp` — `Bind_Subsystems` [Subsystems.PostReflection; PostReflectionBindings; D]. Target: direct body expanded.
- `Bind_SystemTimers.cpp` — `Bind_SystemTimers` [SystemTimers; ManualBindings; D]. Target: direct body expanded.
- `Bind_TArray.cpp` — `Bind_TArray_TypeDeclarations` [TArray.Declaration; TypeDeclarations; D]; `Bind_TArray_MethodSurface` [TArray.MethodSurface; TypeInfrastructure; D]; `Bind_TArray_TypeInfrastructure` [TArray.TypeInfrastructure; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_TMap.cpp` — `Bind_TMap_TypeDeclarations` [TMap.Declaration; TypeDeclarations; D]; `Bind_TMap_MethodSurface` [TMap.MethodSurface; TypeInfrastructure; D]; `Bind_TMap_TypeInfrastructure` [TMap.TypeInfrastructure; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_TOptional.cpp` — `Bind_TOptional_TypeDeclarations` [TOptional.Declaration; TypeDeclarations; D]; `Bind_TOptional_MethodSurface` [TOptional.MethodSurface; TypeInfrastructure; D]; `Bind_TOptional_TypeInfrastructure` [TOptional.TypeInfrastructure; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_TSet.cpp` — `Bind_TSet_TypeDeclarations` [TSet.Declaration; TypeDeclarations; D]; `Bind_TSet_MethodSurface` [TSet.MethodSurface; TypeInfrastructure; D]; `Bind_TSet_TypeInfrastructure` [TSet.TypeInfrastructure; TypeInfrastructure; D]. Target: direct body expanded.
- `Bind_TSoftObjectPtr.cpp` — `Bind_TSoftObjectPtr_TypeDeclarations` [SoftReferences.Declarations; TypeDeclarations; D]; `Bind_TSoftObjectPtr_TypeInfrastructure` [SoftReferences.TypeInfrastructure; TypeInfrastructure; D]; `Bind_TSoftObjectPtr_Functions` [SoftReferences.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_UActorComponent.cpp` — `Bind_UActorComponent` [UActorComponent.Manual; ManualBindings; D]; `Bind_Components` [UActorComponent.PostReflection; PostReflectionBindings; D]. Target: direct body expanded.
- `Bind_UAssetManager.cpp` — `Bind_UAssetManager_ToStringContributions` [UAssetManager.PrimaryAssetToStringContributions; TypeInfrastructure; D]; `Bind_UAssetManager` [UAssetManager.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_UCollisionProfile.cpp` — `Bind_UCollisionProfile` [UCollisionProfile; ManualBindings; D]. Target: direct body expanded.
- `Bind_UDataTable.cpp` — `Bind_UDataTable` [UDataTable; ManualBindings; D]. Target: direct body expanded.
- `Bind_UEnhancedInputComponent.cpp` — `Bind_UEnhancedInputComponent` [UEnhancedInputComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_UEnum.cpp` — `Bind_Enums` [Enums; TypeDeclarations; D]; `Bind_EGetByNameFlags` [EGetByNameFlags; TypeDeclarations; D]; `Bind_UEnum` [UEnum; ManualBindings; D]. Target: direct body expanded.
- `Bind_UFXSystemComponent.cpp` — `Bind_UFXSystemComponent` [UFXSystemComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_UGameInstance.cpp` — `Bind_UGameInstance` [UGameInstance; ManualBindings; D]. Target: direct body expanded.
- `Bind_UInputMappingContext.cpp` — `Bind_UInputAction_Late` [UInputMappingContext.InputAction; ManualBindings; D]; `Bind_FEnhancedActionKeyMapping_Late` [UInputMappingContext.EnhancedActionKeyMapping; ManualBindings; D]; `Bind_UInputMappingContext_Late` [UInputMappingContext.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_UInputSettings.cpp` — `Bind_UInputSettings` [UInputSettings; ManualBindings; D]. Target: direct body expanded.
- `Bind_ULocalPlayer.cpp` — `Bind_ULocalPlayer` [ULocalPlayer; ManualBindings; D]. Target: direct body expanded.
- `Bind_UObject.cpp` — `Bind_UObject_Base` [UObject.Base; ManualBindings; D]; `Bind_UObject_ToStringContribution` [UObject.ToStringContribution; TypeInfrastructure; D]; `Bind_UClass_Base` [UClass.Base; ManualBindings; D]; `Bind_UFunction_Base` [UFunction.Base; ManualBindings; D]; `Bind_UObject_Operations` [UObject.Operations; ManualBindings; D]. Target: direct body expanded.
- `Bind_UPackage.cpp` — `Bind_UPackage` [UPackage; ManualBindings; D]. Target: direct body expanded.
- `Bind_UPoseableMeshComponent.cpp` — `Bind_UPoseableMeshComponent` [UPoseableMeshComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_UPrimitiveComponent.cpp` — `Bind_UPrimitiveComponent` [UPrimitiveComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_UProjectileMovementComponent.cpp` — `Bind_UProjectileMovementComponent` [UProjectileMovementComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_USceneComponent.cpp` — `Bind_USceneComponent` [USceneComponent.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_USkeletalMeshComponent.cpp` — `Bind_USkeletalMeshComponent` [USkeletalMeshComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_USkinnedMeshComponent.cpp` — `Bind_USkinnedMeshComponent` [USkinnedMeshComponent; ManualBindings; D]. Target: direct body expanded.
- `Bind_UStruct.cpp` — `Bind_UStruct_TypeDeclarations` [UStruct.TypeDeclarations; TypeDeclarations; D]; `Bind_UStruct_TypeInfrastructure` [UStruct.TypeInfrastructure; TypeInfrastructure; D]; `Bind_UStruct_ReflectionBindings` [UStruct.ReflectionBindings; ReflectionBindings; D]; `Bind_UStruct_TypeDeclarations` [UStruct.TypeDeclarations; TypeDeclarations; D]; `Bind_UStruct_TypeInfrastructure` [UStruct.TypeInfrastructure; TypeInfrastructure; D]; `Bind_UStruct_ReflectionBindings` [UStruct.ReflectionBindings; ReflectionBindings; D]. Target: direct body expanded; AS_USE_BIND_DB: each listed identity appears in both branches.
- `Bind_UUserWidget.cpp` — `Bind_UUserWidget` [UUserWidget.Manual; ManualBindings; D]. Target: direct body expanded.
- `Bind_UWorld.cpp` — `Bind_WorldType` [UWorld.WorldType; TypeDeclarations; D]; `Bind_NetMode` [UWorld.NetMode; TypeDeclarations; D]; `Bind_World` [UWorld.Functions; ManualBindings; D]. Target: direct body expanded.
- `Bind_WorldCollision.cpp` — `Bind_WorldCollision_TypeDeclarations` [WorldCollision.TypeDeclarations; TypeDeclarations; D]; `Bind_WorldCollision_TypeInfrastructure` [WorldCollision.TypeInfrastructure; TypeInfrastructure; D]; `Bind_WorldCollision_ManualBindings` [WorldCollision.ManualBindings; ManualBindings; D]. Target: direct body expanded.

### GameplayTags

- `Bind_FGameplayTag.cpp` — `Bind_FGameplayTagQuery_ManualBindings` [FGameplayTagQuery.ManualBindings; ManualBindings; D]; `Bind_FGameplayTag_ToStringContribution` [FGameplayTag.ToStringContribution; TypeInfrastructure; D]; `Bind_FGameplayTag_ManualBindings` [FGameplayTag.ManualBindings; ManualBindings; D]. Target: retain direct body.

### GAS

- `Bind_AngelscriptGASLibrary.cpp` — `Bind_AngelscriptGASLibrary` [AngelscriptGASLibrary.GeneratedOverrides; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGameplayAbilitySpec.cpp` — `Bind_FGameplayAbilitySpec` [FGameplayAbilitySpec; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGameplayAttribute.cpp` — `Bind_FGameplayAttribute` [FGameplayAttribute; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGameplayEffectSpec.cpp` — `Bind_FGameplayEffectSpec` [FGameplayEffectSpec; ManualBindings; D]. Target: direct body expanded.
- `Bind_FGameplayTagBlueprintPropertyMap.cpp` — `Bind_FGameplayTagBlueprintPropertyMap` [FGameplayTagBlueprintPropertyMap; ManualBindings; D]. Target: direct body expanded.

## Implementation Rules

- Retain every existing registrar symbol, logical name, phase, script-visible declaration, direct callable owner, and pointer/native form. Only the provider callback body moves to its registration site.
- `[](FAngelscriptBinds& Binds) { BindXxx(Binds); }` is a forbidden forwarding wrapper; the former provider body must be expanded directly.
- Keep anonymous namespaces that still own real private constants, helper types, or reusable algorithms; remove them only when empty.
- Preserve both branch-specific `Bind_UStruct` definitions. Keep each large `Bind_BlueprintType` branch body in place and give its DB/non-DB branches same-identity direct registrar-local lambdas.
- Adapt existing structural tests only where provider/callable classification requires it. Do not add a global layout-only test.

## Reconciliation Gate

Before BIND-005 becomes Verified, repeat this audit and record exactly `126` files, `242` logical registrars, `248` source definitions, `248` direct registrar-local providers, and zero named provider pointers, standalone provider functions, or forwarding wrappers. The three post-migration additions must be the explicit `Bind_BlueprintType` DB/non-DB branch pairs. Use this as a delivery audit together with the required project build/test entry points; it is not a permanent global layout-only automation test.
