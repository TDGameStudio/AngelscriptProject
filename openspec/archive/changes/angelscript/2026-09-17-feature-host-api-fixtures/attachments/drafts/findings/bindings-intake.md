# Bindings leftovers and the full Pending inventory

Date: 2026-09-17. Source draft: `openspec/drafts/angelscript/language-fixture-quality/findings/bindings-intake.md` (Chinese original). Workspace `git_3b46972bbc7ef05a4244fd2890d18183`.

The directory name `Bindings` is rejected (Q22). This tree is holding inventory only.

## Pending map

CodeGen skips all of `Pending/`. Admitted today is only `Language/` (95 files / 475 `@begin`).

```
Pending/
├─ Language/                                              558
├─ Bindings-不要这个目录了测试之后收集移交/                 580   // ~2420 Observe_*
├─ Containers/                                            240
├─ Definitions/                                           521
├─ Feature/                                               367
├─ Gameplay/                                              152
├─ World/                                                 124
├─ Optional/                                              116   // GAS / GameplayTags, not TOptional
├─ Math/                                                  111   // overlaps Bindings math
├─ HotReload/                                              97
├─ TestFramework/                                          59
└─ Debugger/                                                3
```

This Change absorbs Bindings 580 + Containers 240 + overlapping Math 111. It does not absorb Language, World (Unreal first batch), Optional, Definitions, Feature, Gameplay, HotReload, TestFramework, or Debugger.

## Bindings leftovers: 580 files / 126 types / ~2420 Observe

Leaf names are API axes plus a numeric suffix: Behavior (132), Queries (131), NamespaceAndGlobalFunctions (82), MutationAndLifecycle (69), ConstructionAndAssignment (67), Operators (50), ConversionAndFormatting (37), IndexAndIteration (8), plus four one-off names.

Markers: every file still has `@version root`; `@begin` = 0; `Observe_*` in 576 files; `AS-facing API:` banners in 87; `UFUNCTION` in 28; `@Kind` in 4.

### Type families (all 126 folders)

**Value containers (25 files):** TArray 8, TMap 7, TSet 6, TOptional 4.

**Soft refs (12):** TSoftObjectPtr 8 (includes TSoftClassPtr), SoftObjectPath 4. No Bindings folders for TWeakObjectPtr, TSubclassOf, or TObjectPtr.

**Strings (28):** FString 13 (~74 Observe), FText 7, FName 5, FStringTableRegistry 3.

**Math / geometry (~200+):** FMath 27 (~161 Observe), FVector 13, FVector3f 14, FVector2D 10, FVector2f 9, FVector4 3, FVector4f 5, FQuat 11, FQuat4f 11, FRotator 10, FRotator3f 7, FTransform 9, FTransform3f 8, FBox 7, FBox3f 7, FBox2D 2, FBoxSphereBounds 6, FBoxSphereBounds3f 6, FSphere 3, FSphere3f 3, FPlane 2, FPlane4f 2, FMatrix 2, FColor 6, FLinearColor 8, FIntPoint 4, FIntVector 6, FIntVector2 3, FIntVector4 4, FRandomStream 7, FTimespan 8, FDateTime 8, FFrameTime 1, FRange 3, FAnchors 3, FMargin 3, FGeometry 2, Primitives 3.

**World / Actor / collision:** AActor 5, APlayerController 3, AVolume 3, UWorld 7, UActorComponent 3, USceneComponent 4, UGameInstance 3, FActorSpawnParameters 3, WorldCollision 10, FHitResult 4, FOverlapResult 3, FCollisionQueryParams 14, FCollisionShape 6, FBodyInstance 3, UCollisionProfile 1, CollisionProfile 1.

**Components:** UPrimitiveComponent 2, USkeletalMeshComponent 2, USkinnedMeshComponent 2, UPoseableMeshComponent 1, UProjectileMovementComponent 2, UFXSystemComponent 1, LandscapeProxy 1.

**Input:** InputEvents 17, UInputMappingContext 6, UInputSettings 2, UEnhancedInputComponent 4, FInputActionValue 4, FInputBindingHandle 4, FInputActionKeyMapping 1, InputComponentScriptMixins 1.

**UI:** UUserWidget 5 (plus FGeometry / FAnchors / FMargin above).

**Assets:** AssetRegistry 8, UAssetManager 5, AssetBundleData 3, AssetManagerScriptMixins 2.

**Object / reflection / Blueprint:** UObject 10 (~56 Observe), UEnum 5, UStruct 2, UPackage 1, FInstancedStruct 5, BlueprintType 7, BlueprintEvent 3.

**Platform / IO:** FPaths 7, FFileHelper 2, FPlatformMisc 2, FPlatformProcess 3, FPlatformApplicationMisc 1, FGenericPlatformMisc 1, FCommandLine 2, FParse 1, FApp 1, CoreGlobals 1, FMemoryReader 4.

**Delegates:** Delegates 6, FAngelscriptDelegateWithPayload 2.

**Other:** Json 9, JsonObjectConverter 2, Logging 5, Debugging 3, Stats 2, Hash 1, Console 4, UDataTable 4, SystemTimers 3, ULocalPlayer 1, Subsystems 1, FunctionLibraryMixins 2, ConfigEnums 1, Deprecations 1, NativeModuleFunctionBinding 1, FLatentActionInfo 1, FMessageDialog 1, FCpuProfilerTraceScoped 1, FAngelscriptGameThreadScopeWorldContext 1.

## Two container piles

Bindings container folders: TArray 8 / 40 Observe names, TMap 7 / 29, TSet 6 / 20, TOptional 4 / 8, TSoftObjectPtr 8 / 16, SoftObjectPath 4 / 17. Almost no UFUNCTION.

`Pending/Containers`: TArray 81, TMap 49, TSet 51, TOptional 23, TSoftObjectPtr 10, TWeakObjectPtr 10, TSubclassOf 9, TObjectPtr 7. Reject 37, Negative 38, Exception 21, Advance 28, UClass 14. UFUNCTION 170, `@Kind` 155.

Bindings has SoftObjectPath, TSoftClassPtr, axis splits, and declaration banners. Pending/Containers has compile-fail, runtime-fail, the three pointer types, UClass property cases, one-concern thicken, Advance, and at least ten TSet files that are not TSet API.

Rewrite both into `@begin` pockets. Do not copy either pile as-is.
