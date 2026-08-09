# Compact Bind Function Provider Inventory

This inventory is frozen for `refactor-as-compact-bind-functions`. A selected provider had a `Bind_*_Functions.cpp` below 100 physical lines in the 2026-08-09 source snapshot and is not a designated high-complexity geometry family.

## Selected providers (57)

`Bind_AVolume`, `Bind_FAnchors`, `Bind_FAngelscriptDelegateWithPayload`, `Bind_FAngelscriptGameThreadScopeWorldContext`, `Bind_FApp`, `Bind_FBox`, `Bind_FBox3f`, `Bind_FBoxSphereBounds`, `Bind_FBoxSphereBounds3f`, `Bind_FCollisionShape`, `Bind_FColor`, `Bind_FCommandLine`, `Bind_FCpuProfilerTraceScoped`, `Bind_FDateTime`, `Bind_FFileHelper`, `Bind_FFormatArgumentValue`, `Bind_FGeometry`, `Bind_FGuid`, `Bind_FHitResult`, `Bind_FInputActionValue`, `Bind_FInputBindingHandle`, `Bind_FIntPoint`, `Bind_FLatentActionInfo`, `Bind_FLinearColor`, `Bind_FMargin`, `Bind_FMessageDialog`, `Bind_FName`, `Bind_FNumberFormattingOptions`, `Bind_FOverlapResult`, `Bind_FParse`, `Bind_FPaths`, `Bind_FPlane`, `Bind_FPlane4f`, `Bind_FPlatformApplicationMisc`, `Bind_FPlatformMisc`, `Bind_FPlatformProcess`, `Bind_FRandomStream`, `Bind_FSphere`, `Bind_FSphere3f`, `Bind_FStringTableRegistry`, `Bind_FTimespan`, `Bind_FVector4`, `Bind_FVector4f`, `Bind_FunctionLibraryMixins`, `Bind_Hash`, `Bind_LandscapeProxy`, `Bind_SoftObjectPath`, `Bind_Stats`, `Bind_SystemTimers`, `Bind_UActorComponent`, `Bind_UCollisionProfile`, `Bind_UEnhancedInputComponent`, `Bind_UGameInstance`, `Bind_UPoseableMeshComponent`, `Bind_UPrimitiveComponent`, `Bind_UProjectileMovementComponent`, `Bind_UWorld`.

## Retained high-complexity geometry families (13)

`Bind_FVector`, `Bind_FVector2D`, `Bind_FVector2f`, `Bind_FVector3f`, `Bind_FIntVector`, `Bind_FIntVector2`, `Bind_FIntVector4`, `Bind_FQuat`, `Bind_FQuat4f`, `Bind_FRotator`, `Bind_FRotator3f`, `Bind_FTransform`, `Bind_FTransform3f`.

All remaining companion files are outside the compact threshold and remain separate in this change.
