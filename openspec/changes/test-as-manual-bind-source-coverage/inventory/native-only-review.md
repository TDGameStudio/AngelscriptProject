# Native-only and infrastructure review

This file prevents physical shard accounting from turning internal implementation details into fake script tests. The AS-callable behavior of these shards is owned by the matching logical Bind task in `manual-bind-surface.csv`.

## Dynamic publication infrastructure

| Physical file | Logical owner | Disposition | Reason |
|---|---|---|---|
| `Bind_BlueprintCallable.cpp` | `BlueprintCallable` | `InfrastructureOnly` | Builds and publishes reflected UFunction signatures dynamically. It owns no fixed AS signature; generated/reflected call-route tests belong to a later reflected-surface change. |

## Type adapter shards

These 39 files implement type conversion, debugger values, default-value translation, ordering, hashing, GC/reference traversal, CppForm, or property/type-database adaptation. They are native evidence for their logical unit; their user-visible construction/operators/methods remain planned through the main Bind file.

| Physical file | Logical owner | Disposition |
|---|---|---|
| `Bind_Delegates_Type.cpp` | `Delegates` | `NativeOnlyTypeAdapter` |
| `Bind_FBox_Type.cpp` | `FBox` | `NativeOnlyTypeAdapter` |
| `Bind_FBox3f_Type.cpp` | `FBox3f` | `NativeOnlyTypeAdapter` |
| `Bind_FBoxSphereBounds_Type.cpp` | `FBoxSphereBounds` | `NativeOnlyTypeAdapter` |
| `Bind_FBoxSphereBounds3f_Type.cpp` | `FBoxSphereBounds3f` | `NativeOnlyTypeAdapter` |
| `Bind_FCollisionQueryParams_Type.cpp` | `FCollisionQueryParams` | `NativeOnlyTypeAdapter` |
| `Bind_FCollisionShape_Type.cpp` | `FCollisionShape` | `NativeOnlyTypeAdapter` |
| `Bind_FFormatArgumentValue_Type.cpp` | `FFormatArgumentValue` | `NativeOnlyTypeAdapter` |
| `Bind_FIntPoint_Type.cpp` | `FIntPoint` | `NativeOnlyTypeAdapter` |
| `Bind_FIntVector_Type.cpp` | `FIntVector` | `NativeOnlyTypeAdapter` |
| `Bind_FIntVector2_Type.cpp` | `FIntVector2` | `NativeOnlyTypeAdapter` |
| `Bind_FIntVector4_Type.cpp` | `FIntVector4` | `NativeOnlyTypeAdapter` |
| `Bind_FLinearColor_Type.cpp` | `FLinearColor` | `NativeOnlyTypeAdapter` |
| `Bind_FName_Type.cpp` | `FName` | `NativeOnlyTypeAdapter` |
| `Bind_FNumberFormattingOptions_Type.cpp` | `FNumberFormattingOptions` | `NativeOnlyTypeAdapter` |
| `Bind_FQuat_Type.cpp` | `FQuat` | `NativeOnlyTypeAdapter` |
| `Bind_FQuat4f_Type.cpp` | `FQuat4f` | `NativeOnlyTypeAdapter` |
| `Bind_FRandomStream_Type.cpp` | `FRandomStream` | `NativeOnlyTypeAdapter` |
| `Bind_FRotator_Type.cpp` | `FRotator` | `NativeOnlyTypeAdapter` |
| `Bind_FRotator3f_Type.cpp` | `FRotator3f` | `NativeOnlyTypeAdapter` |
| `Bind_FSphere_Type.cpp` | `FSphere` | `NativeOnlyTypeAdapter` |
| `Bind_FSphere3f_Type.cpp` | `FSphere3f` | `NativeOnlyTypeAdapter` |
| `Bind_FString_Type.cpp` | `FString` | `NativeOnlyTypeAdapter` |
| `Bind_FText_Type.cpp` | `FText` | `NativeOnlyTypeAdapter` |
| `Bind_FTransform_Type.cpp` | `FTransform` | `NativeOnlyTypeAdapter` |
| `Bind_FTransform3f_Type.cpp` | `FTransform3f` | `NativeOnlyTypeAdapter` |
| `Bind_FVector_Type.cpp` | `FVector` | `NativeOnlyTypeAdapter` |
| `Bind_FVector2D_Type.cpp` | `FVector2D` | `NativeOnlyTypeAdapter` |
| `Bind_FVector2f_Type.cpp` | `FVector2f` | `NativeOnlyTypeAdapter` |
| `Bind_FVector3f_Type.cpp` | `FVector3f` | `NativeOnlyTypeAdapter` |
| `Bind_Primitives_Type.cpp` | `Primitives` | `NativeOnlyTypeAdapter` |
| `Bind_TArray_Type.cpp` | `TArray` | `NativeOnlyTypeAdapter` |
| `Bind_TMap_Type.cpp` | `TMap` | `NativeOnlyTypeAdapter` |
| `Bind_TOptional_Type.cpp` | `TOptional` | `NativeOnlyTypeAdapter` |
| `Bind_TSet_Type.cpp` | `TSet` | `NativeOnlyTypeAdapter` |
| `Bind_TSoftObjectPtr_Type.cpp` | `TSoftObjectPtr` | `NativeOnlyTypeAdapter` |
| `Bind_UEnum_Type.cpp` | `UEnum` | `NativeOnlyTypeAdapter` |
| `Bind_UStruct_Type.cpp` | `UStruct` | `NativeOnlyTypeAdapter` |
| `Bind_WorldCollision_Type.cpp` | `WorldCollision` | `NativeOnlyTypeAdapter` |

## Helper and thunk shards

These 38 files hold native helpers, wrappers, generated-function bodies, or implementation split-outs used by registrations in the matching logical main file. They do not receive independent TestSource directories; their effects are tested through the AS-facing signatures that call them.

| Physical file | Logical owner | Disposition |
|---|---|---|
| `Bind_AActor_Functions.cpp` | `AActor` | `NativeOnlyHelper` |
| `Bind_APlayerController_Functions.cpp` | `APlayerController` | `NativeOnlyHelper` |
| `Bind_AssetRegistry_Functions.cpp` | `AssetRegistry` | `NativeOnlyHelper` |
| `Bind_Console_Functions.cpp` | `Console` | `NativeOnlyHelper` |
| `Bind_Debugging_Functions.cpp` | `Debugging` | `NativeOnlyHelper` |
| `Bind_FCollisionQueryParams_Functions.cpp` | `FCollisionQueryParams` | `NativeOnlyHelper` |
| `Bind_FInstancedStruct_Functions.cpp` | `FInstancedStruct` | `NativeOnlyHelper` |
| `Bind_FIntVector_Functions.cpp` | `FIntVector` | `NativeOnlyHelper` |
| `Bind_FIntVector2_Functions.cpp` | `FIntVector2` | `NativeOnlyHelper` |
| `Bind_FIntVector4_Functions.cpp` | `FIntVector4` | `NativeOnlyHelper` |
| `Bind_FMath_Functions.cpp` | `FMath` | `NativeOnlyHelper` |
| `Bind_FMemoryReader_Functions.cpp` | `FMemoryReader` | `NativeOnlyHelper` |
| `Bind_FQuat_Functions.cpp` | `FQuat` | `NativeOnlyHelper` |
| `Bind_FQuat4f_Functions.cpp` | `FQuat4f` | `NativeOnlyHelper` |
| `Bind_FRotator_Functions.cpp` | `FRotator` | `NativeOnlyHelper` |
| `Bind_FRotator3f_Functions.cpp` | `FRotator3f` | `NativeOnlyHelper` |
| `Bind_FString_Functions.cpp` | `FString` | `NativeOnlyHelper` |
| `Bind_FText_Functions.cpp` | `FText` | `NativeOnlyHelper` |
| `Bind_FTransform_Functions.cpp` | `FTransform` | `NativeOnlyHelper` |
| `Bind_FTransform3f_Functions.cpp` | `FTransform3f` | `NativeOnlyHelper` |
| `Bind_FVector_Functions.cpp` | `FVector` | `NativeOnlyHelper` |
| `Bind_FVector2D_Functions.cpp` | `FVector2D` | `NativeOnlyHelper` |
| `Bind_FVector2f_Functions.cpp` | `FVector2f` | `NativeOnlyHelper` |
| `Bind_FVector3f_Functions.cpp` | `FVector3f` | `NativeOnlyHelper` |
| `Bind_InputEvents_Functions.cpp` | `InputEvents` | `NativeOnlyHelper` |
| `Bind_Json_Functions.cpp` | `Json` | `NativeOnlyHelper` |
| `Bind_JsonObjectConverter_Functions.cpp` | `JsonObjectConverter` | `NativeOnlyHelper` |
| `Bind_Logging_Functions.cpp` | `Logging` | `NativeOnlyHelper` |
| `Bind_Subsystems_Functions.cpp` | `Subsystems` | `NativeOnlyHelper` |
| `Bind_TSoftObjectPtr_Functions.cpp` | `TSoftObjectPtr` | `NativeOnlyHelper` |
| `Bind_UAssetManager_Functions.cpp` | `UAssetManager` | `NativeOnlyHelper` |
| `Bind_UDataTable_Functions.cpp` | `UDataTable` | `NativeOnlyHelper` |
| `Bind_UInputMappingContext_Functions.cpp` | `UInputMappingContext` | `NativeOnlyHelper` |
| `Bind_UObject_Functions.cpp` | `UObject` | `NativeOnlyHelper` |
| `Bind_USceneComponent_Functions.cpp` | `USceneComponent` | `NativeOnlyHelper` |
| `Bind_UStruct_Functions.cpp` | `UStruct` | `NativeOnlyHelper` |
| `Bind_UUserWidget_Functions.cpp` | `UUserWidget` | `NativeOnlyHelper` |
| `Bind_WorldCollision_Functions.cpp` | `WorldCollision` | `NativeOnlyHelper` |

## Review rule

A future source implementation must not promote an entry from this file into an AS task unless current registration code exposes a concrete AS declaration. If such a declaration is found, add it to `manual-bind-surface.csv`, give it a stable SurfaceId, assign a TaskId, update the owning matrix, and retain this shard as implementation evidence.
