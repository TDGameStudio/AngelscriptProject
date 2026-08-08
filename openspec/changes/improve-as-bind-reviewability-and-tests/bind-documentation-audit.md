# Bind Registrar Documentation Audit

This inventory is content-driven: every Bind_*.cpp containing a real AS_FORCE_LINK const FAngelscriptBind must own exactly one file-head AngelScript surface block before its first registrar. Files without a registrar, including ordinary `_Functions.cpp` and `Bind_<Family>_Type.cpp` implementations, are outside this inventory.

Current snapshot: **120 registrar files**; **120 documented**, **0 pending**.

The per-row gap column records the final owning-coverage state; detailed fresh evidence is summarized in **Implementation Reconciliation**.

| Registrar file | Logical registrar(s) | Phase(s) | Surface kind | Documentation | Contract coverage |
| --- | --- | --- | --- | --- | --- |
| Bind_AActor.cpp | AActor.Manual<br>AActor.PostReflection | ManualBindings<br>PostReflectionBindings | Dynamic/hybrid | Documented | Actor contract verified by focused and final suites |
| Bind_APlayerController.cpp | AController.Functions<br>APlayerController.Functions<br>APawn.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_AssetManagerScriptMixins.cpp | AssetManagerScriptMixins.GeneratedOverrides | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_AssetRegistry.cpp | AssetRegistry.TopLevelAssetPathToStringContribution<br>AssetRegistry.Manual | TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_AVolume.cpp | AVolume | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_BlueprintEvent.cpp | BlueprintEvents.HelperGlobals | ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_BlueprintType.cpp | BlueprintType.ReferenceClasses<br>TObjectPtr.Declaration<br>TSubclassOf.Declaration<br>TWeakObjectPtr.Declaration<br>TObjectPtr.MethodSurface<br>TSubclassOf.MethodSurface<br>TWeakObjectPtr.MethodSurface<br>UObject.TypeInfrastructure<br>BlueprintType.ReflectionBindings<br>BlueprintType.StaticClasses | TypeDeclarations<br>TypeInfrastructure<br>ReflectionBindings<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_CollisionProfile.cpp | CollisionProfile | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_ConfigEnums.cpp | ConfigEnums | TypeDeclarations | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Console.cpp | Console.Types<br>Console.Variables<br>Console.Commands | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_CoreGlobals.cpp | CoreGlobals | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Debugging.cpp | Debugging.Manual | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Delegates.cpp | Delegates.Declarations<br>Delegates.Functions | TypeDeclarations<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Deprecations.cpp | Deprecations | TypeDeclarations | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FAnchors.cpp | FAnchors | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FAngelscriptDelegateWithPayload.cpp | FAngelscriptDelegateWithPayload.Manual | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FAngelscriptGameThreadScopeWorldContext.cpp | FAngelscriptGameThreadScopeWorldContext | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FApp.cpp | FApp | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FBodyInstance.cpp | FBodyInstance | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FBox.cpp | FBox.Type<br>FBox.ToStringContribution<br>FBox.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FBox3f.cpp | FBox3f.Type<br>FBox3f.ToStringContribution<br>FBox3f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FBoxSphereBounds.cpp | FBoxSphereBounds.Type<br>FBoxSphereBounds.ToStringContribution<br>FBoxSphereBounds.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FBoxSphereBounds3f.cpp | FBoxSphereBounds3f.Type<br>FBoxSphereBounds3f.ToStringContribution<br>FBoxSphereBounds3f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FCollisionQueryParams.cpp | FCollisionQueryParams.TypeDeclarations<br>FCollisionQueryParams.TypeInfrastructure<br>FCollisionQueryParams.ManualBindings | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FCollisionShape.cpp | FCollisionShape.Types<br>FCollisionShape.Functions | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FColor.cpp | FColor<br>FColor.ToStringContribution | ManualBindings<br>TypeInfrastructure | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FCommandLine.cpp | FCommandLine | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FCpuProfilerTraceScoped.cpp | FCpuProfilerTraceScoped | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FDateTime.cpp | FDateTime.ToStringContribution<br>FDateTime.Functions | TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FFileHelper.cpp | FFileHelper.Types<br>FFileHelper.Functions | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FFormatArgumentValue.cpp | FFormatArgumentValue.Type<br>FFormatArgumentValue.Infrastructure<br>FFormatArgumentValue.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FGenericPlatformMisc.cpp | FGenericPlatformMisc | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FGeometry.cpp | FGeometry | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FGuid.cpp | EGuidFormats<br>FGuid | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FHitResult.cpp | FHitResult.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FInputActionKeyMapping.cpp | FInputActionKeyMapping | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FInputActionValue.cpp | FInputActionValue | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FInputBindingHandle.cpp | FInputBindingHandle.Types<br>FInputBindingHandle.Functions | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FInstancedStruct.cpp | FInstancedStruct.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FIntPoint.cpp | FIntPoint.Type<br>FIntPoint.Functions<br>FIntPoint.ToStringContribution | TypeDeclarations<br>ManualBindings<br>TypeInfrastructure | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FIntVector.cpp | FIntVector.Type<br>FIntVector.ToStringContribution<br>FIntVector.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FIntVector2.cpp | FIntVector2.Type<br>FIntVector2.ToStringContribution<br>FIntVector2.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FIntVector4.cpp | FIntVector4.Type<br>FIntVector4.ToStringContribution<br>FIntVector4.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FLatentActionInfo.cpp | FLatentActionInfo | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FLinearColor.cpp | FLinearColor.Type<br>FLinearColor.Infrastructure<br>FLinearColor.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FMargin.cpp | FMargin | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FMath.cpp | FMath.Manual | ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FMemoryReader.cpp | FMemoryReader.Type<br>FMemoryReader.Functions | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FMessageDialog.cpp | FMessageDialog | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FName.cpp | FName.Type<br>FName.Infrastructure<br>FName.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FNumberFormattingOptions.cpp | FNumberFormattingOptions.Type<br>FNumberFormattingOptions.Manual | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FOverlapResult.cpp | FOverlapResult | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FParse.cpp | FParse | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FPaths.cpp | FPaths | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FPlane.cpp | FPlane | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FPlane4f.cpp | FPlane4f | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FPlatformApplicationMisc.cpp | FPlatformApplicationMisc | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FPlatformMisc.cpp | FPlatformMisc | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FPlatformProcess.cpp | FPlatformProcess | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FQuat.cpp | FQuat.Type<br>FQuat.Infrastructure<br>FQuat.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FQuat4f.cpp | FQuat4f.Type<br>FQuat4f.Infrastructure<br>FQuat4f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FRandomStream.cpp | FRandomStream.Type<br>FRandomStream.Functions<br>FRandomStream.ToStringContribution | TypeDeclarations<br>ManualBindings<br>TypeInfrastructure | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FRotator.cpp | FRotator.Type<br>FRotator.Infrastructure<br>FRotator.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FRotator3f.cpp | FRotator3f.Type<br>FRotator3f.Infrastructure<br>FRotator3f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FSphere.cpp | FSphere.Type<br>FSphere.Functions | TypeDeclarations<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FSphere3f.cpp | FSphere3f.Type<br>FSphere3f.Functions | TypeDeclarations<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FString.cpp | FString.TypeDeclarations<br>FString.TypeInfrastructure<br>FString.ManualBindings | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FStringTableRegistry.cpp | FStringTableRegistry.Types<br>FStringTableRegistry.Manual | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FText.cpp | FText.Type<br>FText.Infrastructure<br>FText.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FTimespan.cpp | FTimespan.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FTransform.cpp | FTransform.Type<br>FTransform.Infrastructure<br>FTransform.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FTransform3f.cpp | FTransform3f.Type<br>FTransform3f.Infrastructure<br>FTransform3f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FunctionLibraryMixins.cpp | FunctionLibraryMixins.PostReflection | PostReflectionBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FVector.cpp | FVector.TypeDeclarations<br>FVector.TypeInfrastructure<br>FVector<br>FVector.ToStringContribution | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FVector2D.cpp | FVector2D.Type<br>FVector2D.Infrastructure<br>FVector2D.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FVector2f.cpp | FVector2f.Type<br>FVector2f.Infrastructure<br>FVector2f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FVector3f.cpp | FVector3f.TypeDeclarations<br>FVector3f.TypeInfrastructure<br>FVector3f.Manual | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FVector4.cpp | FVector4.Type<br>FVector4.Infrastructure<br>FVector4.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_FVector4f.cpp | FVector4f.Type<br>FVector4f.Infrastructure<br>FVector4f.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Hash.cpp | Hash | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_InputComponentScriptMixins.cpp | InputComponentScriptMixins.GeneratedOverrides | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_InputEvents.cpp | InputEvents.FKeyToStringContribution<br>InputEvents.Manual | TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Json.cpp | Json.TypeDeclarations<br>Json.Manual | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_JsonObjectConverter.cpp | JsonObjectConverter.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_LandscapeProxy.cpp | ALandscapeProxy.GetHeightAtLocation | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Logging.cpp | Logging.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_NativeModuleFunctionBinding.cpp | NativeModuleFunctionBinding.GeneratedTransport | GeneratedBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Primitives.cpp | PrimitiveTypes.TypeInfrastructure<br>PrimitiveTypes.ToStringContribution<br>PrimitiveTypes.Constants | TypeInfrastructure | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_SoftObjectPath.cpp | SoftObjectPath.Functions<br>SoftObjectPath.ToStringContributions | ManualBindings<br>TypeInfrastructure | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Stats.cpp | Stats.Types<br>Stats.Functions | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_Subsystems.cpp | Subsystems.PostReflection | PostReflectionBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_SystemTimers.cpp | SystemTimers | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_TArray.cpp | TArray.Declaration<br>TArray.MethodSurface<br>TArray.TypeInfrastructure | TypeDeclarations<br>TypeInfrastructure | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_TMap.cpp | TMap.Declaration<br>TMap.MethodSurface<br>TMap.TypeInfrastructure | TypeDeclarations<br>TypeInfrastructure | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_TOptional.cpp | TOptional.Declaration<br>TOptional.MethodSurface<br>TOptional.TypeInfrastructure | TypeDeclarations<br>TypeInfrastructure | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_TSet.cpp | TSet.Declaration<br>TSet.MethodSurface<br>TSet.TypeInfrastructure | TypeDeclarations<br>TypeInfrastructure | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_TSoftObjectPtr.cpp | SoftReferences.Declarations<br>SoftReferences.TypeInfrastructure<br>SoftReferences.Functions | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UActorComponent.cpp | UActorComponent.Manual<br>UActorComponent.PostReflection | ManualBindings<br>PostReflectionBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UAssetManager.cpp | UAssetManager.PrimaryAssetToStringContributions<br>UAssetManager.Functions | TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UCollisionProfile.cpp | UCollisionProfile | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UDataTable.cpp | UDataTable | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UEnhancedInputComponent.cpp | UEnhancedInputComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UEnum.cpp | Enums<br>EGetByNameFlags<br>UEnum | TypeDeclarations<br>ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UFXSystemComponent.cpp | UFXSystemComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UGameInstance.cpp | UGameInstance | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UInputMappingContext.cpp | UInputMappingContext.InputAction<br>UInputMappingContext.EnhancedActionKeyMapping<br>UInputMappingContext.Functions | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UInputSettings.cpp | UInputSettings | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_ULocalPlayer.cpp | ULocalPlayer | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UObject.cpp | UObject.Base<br>UObject.ToStringContribution<br>UClass.Base<br>UFunction.Base<br>UObject.Operations | ManualBindings<br>TypeInfrastructure | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UPackage.cpp | UPackage | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UPoseableMeshComponent.cpp | UPoseableMeshComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UPrimitiveComponent.cpp | UPrimitiveComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UProjectileMovementComponent.cpp | UProjectileMovementComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_USceneComponent.cpp | USceneComponent.Functions | ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_USkeletalMeshComponent.cpp | USkeletalMeshComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_USkinnedMeshComponent.cpp | USkinnedMeshComponent | ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UStruct.cpp | UStruct.TypeDeclarations<br>UStruct.TypeInfrastructure<br>UStruct.ReflectionBindings<br>UStruct.TypeDeclarations<br>UStruct.TypeInfrastructure<br>UStruct.ReflectionBindings | TypeDeclarations<br>TypeInfrastructure<br>ReflectionBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UUserWidget.cpp | UUserWidget.Manual | ManualBindings | Dynamic/hybrid | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_UWorld.cpp | UWorld.WorldType<br>UWorld.NetMode<br>UWorld.Functions | TypeDeclarations<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |
| Bind_WorldCollision.cpp | WorldCollision.TypeDeclarations<br>WorldCollision.TypeInfrastructure<br>WorldCollision.ManualBindings | TypeDeclarations<br>TypeInfrastructure<br>ManualBindings | Static | Documented | Owning behavior coverage verified by focused and final suites |

## Implementation Reconciliation

Status: **Complete and verified**. The final static audit, build, focused binding/type/StaticJIT tests, 35-bucket All suite, and Standalone CTest all completed.

| Audit item | Result |
| --- | ---: |
| Registrar files in the frozen inventory | 120 |
| Documented registrar files | 120 |
| Pending registrar files | 0 |
| Logical AngelScript surface entries | 2979 |
| Non-obvious `@param` notes | 1052 |
| Missing or duplicate file-head documentation markers | 0 issues |
| Marker placement after the first registrar | 0 issues |
| Table width or separator-width violations | 0 issues |
| Lone `)` / `);` continuation lines | 0 issues |
| Multiple declarations collapsed into one catalogue entry | 0 issues |
| Invalid or under-specified generic surface entries | 0 issues |
| Duplicate catalogue entries | 0 issues |

Final verification evidence:

- final UE build passed at `Saved/Build/bind-family-ownership-refactor-iwyu/20260809_020255_921_7c29613e/Build.log`, with zero compiler/fatal/IWYU first-header diagnostics;
- focused SourceLayout `28/28`, Actor PropertyInterface `7/7`, Engine Hooks `4/4`, TypeUsage `5/5`, TypeRegistry `1/1`, TypeDatabase `3/3`, StaticJIT NativeForms `4/4`, StaticJIT AOT `12/12`, and full Bindings `275/275` all passed with zero failures/skips;
- the final All suite passed 35 UE buckets at `2521/2521` with zero failures/skips, and Standalone CTest passed `19/19`;
- `git diff --check` exits `0`, strict OpenSpec validation passes, and no permanent automation test was added for comment markers, table presence, canonical filenames, or include spelling.

## Completion Rules

- Static registrars list every stable type, enum, constructor, property, constant, method, mixin, global, and overload using actual AngelScript spelling.
- Dynamic and reflection registrars list stable script patterns and explain runtime expansion while still listing their static declarations exactly.
- Purpose / parameter notes uses compact purpose text and only non-obvious Doxygen-style @param notes.
- Final verification requires the plugin build, owning behavior tests, the frozen 120-row implementation-time audit, and diff review to pass, with any real contract-test gap closed at the narrowest behavior-owning layer. Do not add a permanent automation test for comment markers, table presence, canonical filenames, or include spelling.
