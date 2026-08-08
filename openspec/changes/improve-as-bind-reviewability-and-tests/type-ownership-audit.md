# Bind Family Header and Type Ownership Audit

This is the authoritative finite inventory for two related migrations:

1. remove the obsolete `Bind_Actor.h` shim and consolidate all 96 legacy `Bind_<Family>_Functions.h` files into canonical family headers;
2. move every non-Blueprint concrete `FAngelscriptType` adapter declaration into its canonical family header and every out-of-line Type implementation into `Bind_<Family>_Type.cpp`.

Status: **Implemented and verified**. Static ownership reconciliation, the final UE build, focused behavior tests, the 35-bucket All suite, and Standalone CTest are recorded below.

## Final Family Topology

For a family with all responsibilities, the only conventional files are:

| Path | Sole responsibility |
| --- | --- |
| `Bind_<Family>.h` | Canonical declarations for native callable owners and family-owned Type adapters; family-local templates/inline definitions that must be visible; family contract payloads that genuinely belong in the facade. |
| `Bind_<Family>.cpp` | `FAngelscriptBind` registrars, phases, provider callbacks, fluent registration, native-form attachment, and the sole script-facing surface table. |
| `Bind_<Family>_Functions.cpp` | Out-of-line native callable implementation and local algorithm/safety comments. |
| `Bind_<Family>_Type.cpp` | Out-of-line `FAngelscriptType` virtual implementation and Type-private helpers. |

There is no `Bind_<Family>_Functions.h` and no `Bind_<Family>Type.h/.cpp`. A `_Functions.cpp` or `_Type.cpp` is created only when the family owns that out-of-line responsibility. Required templates remain visible in the canonical family header or a shared helper header. Registrars never move out of `Bind_<Family>.cpp`.

## Actor Cleanup State

`Bind_Actor.h` and `Bind_AActor.h` are different paths:

- `Bind_Actor.h` is the compatibility-only shim being removed.
- `Bind_AActor.h` is the final canonical family header that replaced `Bind_AActor_Functions.h` during the 96-header migration.

The implemented cleanup deleted `Bind_Actor.h` and moved both consumers directly to the final canonical header:

| Consumer | Actual dependency | Final migration |
| --- | --- | --- |
| `Source/AngelscriptRuntime/StaticJIT/StaticJITHelperFunctions.h` | Exported `FAngelscriptActorBinds` declarations used by generated/native-form code | Includes `Binds/Bind_AActor.h`. |
| `Source/AngelscriptTest/Core/AngelscriptEngineHooksTests.cpp` | Direct C++ calls to `FAngelscriptActorBinds::CreateComponent` and `SpawnActor` | Includes `Binds/Bind_AActor.h`. |

`Source/AngelscriptEditor/Tests/AngelscriptEditorCodeGenTests.cpp` mentions generated `Bind_Actor.cpp` and `Bind_Actor(FAngelscriptBinds&)`; those are generated-module naming contracts, not the deleted header. `FAngelscriptActorBinds` is a callable owner rather than a Type adapter. Its exported declaration is now in `Bind_AActor.h`; its bodies remain in `Bind_AActor_Functions.cpp`.

The only intentional Actor behavior cleanup is the previously approved removal of the obsolete internal `__Actor_GetAllByClass` script binding, `GetAllActorsByClassUnchecked` native helper, disabled preprocessor stub, and internal-only test branch. The three public GetAll paths remain in the canonical surface. This scoped removal is not a header-migration declaration loss.

Status: **Implemented and verified**. Exact searches are clean; the final plugin build, Engine Hooks, existing Actor provider-lambda regression, Actor PropertyInterface, StaticJIT NativeForms/AOT, full Bindings, and All suite pass.

## Frozen 96 Legacy Callable Header Baseline

Frozen pre-implementation baseline: 96 `Bind_*_Functions.h` files, 95 matching `_Functions.cpp` files, and 120 registrar `.cpp` files. Every path below was mandatory: remove `_Functions` from the header name, merge declarations into the canonical `Bind_<Family>.h`, update consumers, and delete the old header. Existing `_Functions.cpp` bodies remain. `Bind_TArray_Functions.h` is the only legacy header without a matching `_Functions.cpp`; its required templates/inline definitions merge into `Bind_TArray.h`, and no empty implementation file is created.

```text
AActor
APlayerController
AssetRegistry
AVolume
Console
Debugging
FAnchors
FAngelscriptDelegateWithPayload
FAngelscriptGameThreadScopeWorldContext
FApp
FBox
FBox3f
FBoxSphereBounds
FBoxSphereBounds3f
FCollisionQueryParams
FCollisionShape
FColor
FCommandLine
FCpuProfilerTraceScoped
FDateTime
FFileHelper
FFormatArgumentValue
FGeometry
FGuid
FHitResult
FInputActionValue
FInputBindingHandle
FInstancedStruct
FIntPoint
FIntVector
FIntVector2
FIntVector4
FLatentActionInfo
FLinearColor
FMargin
FMath
FMemoryReader
FMessageDialog
FName
FNumberFormattingOptions
FOverlapResult
FParse
FPaths
FPlane
FPlane4f
FPlatformApplicationMisc
FPlatformMisc
FPlatformProcess
FQuat
FQuat4f
FRandomStream
FRotator
FRotator3f
FSphere
FSphere3f
FString
FStringTableRegistry
FText
FTimespan
FTransform
FTransform3f
FunctionLibraryMixins
FVector
FVector2D
FVector2f
FVector3f
FVector4
FVector4f
Hash
InputEvents
Json
JsonObjectConverter
LandscapeProxy
Logging
SoftObjectPath
Stats
Subsystems
SystemTimers
TArray
TSoftObjectPtr
UActorComponent
UAssetManager
UCollisionProfile
UDataTable
UEnhancedInputComponent
UGameInstance
UInputMappingContext
UObject
UPoseableMeshComponent
UPrimitiveComponent
UProjectileMovementComponent
USceneComponent
UStruct
UUserWidget
UWorld
WorldCollision
```

## Implementation Reconciliation

Status: **Implemented and verified**. The following static source reconciliation is backed by the final build and behavior results in the verification evidence section.

| Reconciliation item | Implemented state |
| --- | --- |
| Legacy callable headers | Frozen baseline `96`; current `Bind_*_Functions.h` files `0`; active references under `Plugins/Angelscript/Source` `0`. |
| Callable implementations | `95/95` `Bind_<Family>_Functions.cpp` files include the matching canonical `Bind_<Family>.h`; wrong canonical includes `0`; empty/tiny implementation facades `0`. |
| TArray exception | `Bind_TArray_Functions.h` had no matching `_Functions.cpp`; its callable declarations, inline/template definitions, and Type declarations are merged into `Bind_TArray.h`, with no empty `_Functions.cpp` added. |
| Frozen family coverage | All `96/96` canonical `Bind_<Family>.h` files exist. The 95 implementation families equal the frozen list minus TArray. |
| Declaration preservation | Static identifier reconciliation from all 96 legacy callable headers found no loss except the approved Actor scoped removal described above. Existing Console, Debugging, and TArray canonical-header declarations were also retained through their merges. |
| Type implementation ownership | Current `Bind_*_Type.cpp` files `41`; empty files `0`; registrar declarations/tokens `0`; matching canonical-header includes `41/41`. The only Type adapters remaining in a non-Type registrar implementation are the four intentionally deferred Blueprint adapters in `Bind_BlueprintType.cpp`: `FUObjectType`, `FSubclassOfType`, `FObjectPtrType`, and `FWeakObjectPtrType`. |
| Type implementation parity | Owner-aware reconciliation covered `492` out-of-line Type method definitions: `489` are token-exact against their pre-move definitions, while `FNameType::DefaultValue_UnrealToAngelscript`, `FNameType::DefaultValue_AngelscriptToUnreal`, and `FNameType::GetStringIdentifier` are behavior-preserving early-return/control-flow rewrites. Container and Primitive canonical headers preserve `168/168` inline/template bodies exactly. |
| Type contract preservation | Exported declarations are preserved. Focused reconciliation found no missing GC/property, `GetCppForm`, `TemplateObjectForm`, or `NeverRequiresGC` behavior across Primitives, containers, Delegates, UEnum, UStruct, WorldCollision, and collision-query adapters; the final build and owning behavior suites pass. |

Direct source consumer counts for the retained support and canonical-support headers are:

| Header | Direct consumers under `Plugins/Angelscript/Source` | Reconciled responsibility |
| --- | ---: | --- |
| `Bind_BlueprintTypePrep.h` | 3 | Shared Blueprint callable/event/type preparation contract. |
| `Bind_Console.h` | 2 | Canonical Console template, callable owner, registrar, and implementation boundary. |
| `Bind_Debugging.h` | 5 | Canonical Debugging owner plus exported test-control hooks consumed by Runtime and tests. |
| `Bind_Delegates.h` | 3 | Canonical delegate Type/operations surface consumed by registrar, Type implementation, and StaticJIT. |
| `Bind_Helpers.h` | 5 | Cross-family Type/binding helpers consumed by BlueprintType, Primitives, UStruct, and StaticJIT. |
| `Bind_TArray_Structs.h` | 1 | Exported iterator payload support included by canonical `Bind_TArray.h`, which is then consumed by registrar, Type implementation, and StaticJIT. |
| `Bind_TArray.h` | 3 | Canonical Array Type/operations/template surface. |
| `Bind_TMap.h` | 3 | Canonical Map Type/operations/template surface. |
| `Bind_TOptional.h` | 2 | Canonical Optional Type/operations/template surface. |
| `Bind_TSet.h` | 3 | Canonical Set Type/operations/template surface. |
| `Bind_TSubclassOf.h` | 2 | Distinct subclass helper boundary consumed by BlueprintType and StaticJIT. |

StaticJIT visibility is reconciled through canonical headers: `StaticJITHeader.h` includes `Binds/Bind_TArray.h`, while `StaticJITHelperFunctions.h` includes `Bind_Helpers.h`, `Bind_FInstancedStruct.h`, `Bind_TSubclassOf.h`, `Bind_TMap.h`, `Bind_TSet.h`, `Bind_Delegates.h`, and `Bind_AActor.h`. This chain is required because generated C++ directly needs helper-owner, template, exported, and native-form declarations such as `FArrayOperations`; the migration therefore affects StaticJIT compile visibility without changing StaticJIT runtime ownership.

Special merge collisions already present and therefore requiring merge rather than a competing header are at least:

- `Bind_Console.h`
- `Bind_Debugging.h`
- `Bind_TArray.h`

The migration must discover and handle any additional collision from the frozen list rather than rely only on these examples.

## Audited Support Headers

The following non-`_Functions.h` headers are not automatically deleted. Each must retain a distinct responsibility and real consumer evidence or merge into its canonical family header:

| Current header | Disposition rule |
| --- | --- |
| `Bind_BlueprintTypePrep.h` | May remain for the independently consumed Blueprint preparation contract; record consumers and do not duplicate the `Bind_BlueprintType.h` family facade. |
| `Bind_Console.h` | Canonical family header; merge `Bind_Console_Functions.h` declarations here. |
| `Bind_Debugging.h` | Canonical family header; merge `Bind_Debugging_Functions.h` declarations here. |
| `Bind_Delegates.h` | Canonical family header; retain exported delegate/native-form declarations and add Type declarations here. |
| `Bind_Helpers.h` | Shared cross-family helper; retain only while its cross-family responsibility and consumers remain distinct. |
| `Bind_TArray_Structs.h` | Support payload header; retain only if the structs require a separately consumed/exported/template-visible boundary. |
| `Bind_TArray.h` | Canonical family header; merge `Bind_TArray_Functions.h` and all Array Type declarations here. |
| `Bind_TMap.h` | Canonical family header; retain Map operations/callable declarations and add Map Type declarations here. |
| `Bind_TOptional.h` | Canonical family header; retain Optional operations/callable declarations and add Optional Type declarations here. |
| `Bind_TSet.h` | Canonical family header; retain Set operations/callable declarations and add Set Type declarations here. |
| `Bind_TSubclassOf.h` | May remain only if its generated/template support boundary is distinct from `Bind_BlueprintType.h`; record consumers and risk before retaining. |

No retained support header may act as a second family declaration catalogue or a forwarding-only compatibility shim.

## Type Inventory Counts

A complete declaration scan of `AngelscriptRuntime/Binds` finds:

- 82 direct/indirect Type-like declarations across 46 files.
- 71 concrete registered adapters across 43 non-helper definition files.
- 4 family-private, non-registered bases/templates: `TPrimitiveAngelscriptType`, `TNumericAngelscriptType`, `TIntegralAngelscriptType`, and `FBaseSoftReferenceType`.
- 7 shared templates in `Helper_CppType.h`, `Helper_PODType.h`, and `Helper_StructType.h`.
- 13 concrete adapters directly derived from `FAngelscriptType` across eight definition files.
- 4 concrete Blueprint object adapters deferred by this change, leaving 67 concrete registered adapters that must migrate now.

Only `FAngelscriptArrayType` and `FAngelscriptOptionalType` currently carry `ANGELSCRIPTRUNTIME_API`; their export visibility must be preserved. Exact class-name search finds no checked-in definition-file-external concrete adapter consumer other than the existing `FAngelscriptArrayType` header/implementation split. Moving a module-private declaration into a canonical header does not make it exported.

Base abbreviations used below:

```text
CPP<T>  = TAngelscriptCppType<T> -> FAngelscriptType
POD<T>  = TAngelscriptPODType<T> -> FAngelscriptType
PODP<P> = TAngelscriptPODPropertyType<P> -> POD<P::TCppType> -> FAngelscriptType
CPPP<P> = TAngelscriptCppPropertyType<P> -> CPP<P::TCppType> -> FAngelscriptType
CORE<T> = TAngelscriptCoreStructType<T, ...> -> CPP<T> -> FAngelscriptType
BASE<T> = TAngelscriptBaseStructType<T> -> CORE<T> -> CPP<T> -> FAngelscriptType
VAR<T>  = TAngelscriptVariantStructType<T> -> CORE<T> -> CPP<T> -> FAngelscriptType
```

## Mandatory Non-Blueprint Adapter Matrix

Every row below is part of the frozen ownership contract. Its source migration, final build, and owning verification are complete. The target header is the canonical family facade; there is no separate Type header.

| Family / current owner | Adapter symbols and direct/indirect base | Target ownership and constraints | Existing focused prefixes |
| --- | --- | --- | --- |
| `Delegates` / `Bind_Delegates.cpp` | `FScriptDelegateType: CPP<FScriptDelegate>`; `FMulticastScriptDelegateType: CPP<FMulticastScriptDelegate>`; `FScriptSparseDelegateType: FAngelscriptType` | Declarations in `Bind_Delegates.h`; implementations and Type-private delegate naming helpers in `Bind_Delegates_Type.cpp`. Keep registrars in `Bind_Delegates.cpp` and native callable bodies in `_Functions.cpp` when present. | `Delegate.Unicast`, `Delegate.Multicast`, `Coverage.Delegate`, `Coverage.DynamicDelegate`, `Coverage.MulticastDelegate`, `HotReload.Delegates`, `Engine.TypeUsage`, `StaticJIT.NativeForms` |
| `FBox` / `Bind_FBox.cpp` | `FBoxType: CORE<FBox>` | `Bind_FBox.h` + `Bind_FBox_Type.cpp`; merge the legacy callable header. | `Coverage.MathGeometricStructs`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FBox3f` / `Bind_FBox3f.cpp` | `FBox3fType: CORE<FBox3f>` | `Bind_FBox3f.h` + `Bind_FBox3f_Type.cpp`. | `Bindings.Box3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FBoxSphereBounds` / `Bind_FBoxSphereBounds.cpp` | `FBoxSphereBoundsType: CORE<FBoxSphereBounds>` | `Bind_FBoxSphereBounds.h` + `Bind_FBoxSphereBounds_Type.cpp`. | `Bindings.Box3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FBoxSphereBounds3f` / `Bind_FBoxSphereBounds3f.cpp` | `FBoxSphereBounds3fType: CORE<FBoxSphereBounds3f>` | `Bind_FBoxSphereBounds3f.h` + `Bind_FBoxSphereBounds3f_Type.cpp`. | `Bindings.Box3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FCollisionQueryParams` / `Bind_FCollisionQueryParams.cpp` | `FCollisionQueryParamsType: CPP<FCollisionQueryParams>`; `FCollisionEnabledMaskType: CPP<FCollisionEnabledMask>`; `FComponentQueryParamsType: CPP<FComponentQueryParams>`; `FCollisionResponseParamsType: CPP<FCollisionResponseParams>`; `FCollisionObjectQueryParamsType: CPP<FCollisionObjectQueryParams>` | All declarations in `Bind_FCollisionQueryParams.h`; out-of-line Type bodies in `Bind_FCollisionQueryParams_Type.cpp`; native bodies remain in `_Functions.cpp`. | `Bindings.CollisionParams`, `Bindings.Collision`, `Bindings.WorldCollision`, shared Type prefixes |
| `FCollisionShape` / `Bind_FCollisionShape.cpp` | `FCollisionShapeType: CPP<FCollisionShape>` | `Bind_FCollisionShape.h` + `Bind_FCollisionShape_Type.cpp`. | `Bindings.Collision`, `Bindings.CollisionValue`, `Bindings.WorldCollision`, shared Type prefixes |
| `FFormatArgumentValue` / `Bind_FFormatArgumentValue.cpp` | `FFormatArgumentValueType: CPP<FFormatArgumentValue>` | `Bind_FFormatArgumentValue.h` + `Bind_FFormatArgumentValue_Type.cpp`. | `Bindings.TextFormatting`, `Bindings.FormatEngineScope`, shared Type prefixes |
| `FIntPoint` / `Bind_FIntPoint.cpp` | `FIntPointType: BASE<FIntPoint>` | `Bind_FIntPoint.h` + `Bind_FIntPoint_Type.cpp`. | `Bindings.IntVector`, `Coverage.MathGeometricStructs`, shared Type prefixes |
| `FIntVector` / `Bind_FIntVector.cpp` | `FIntVectorType: BASE<FIntVector>` | `Bind_FIntVector.h` + `Bind_FIntVector_Type.cpp`. | `Bindings.IntVector`, `Coverage.MathGeometricStructs`, shared Type prefixes |
| `FIntVector2` / `Bind_FIntVector2.cpp` | `FIntVector2Type: CORE<FIntVector2>` | `Bind_FIntVector2.h` + `Bind_FIntVector2_Type.cpp`. | `Bindings.IntVector`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FIntVector4` / `Bind_FIntVector4.cpp` | `FIntVector4Type: CORE<FIntVector4>` | `Bind_FIntVector4.h` + `Bind_FIntVector4_Type.cpp`. | `Bindings.IntVector`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FLinearColor` / `Bind_FLinearColor.cpp` | `FLinearColorType: BASE<FLinearColor>` | `Bind_FLinearColor.h` + `Bind_FLinearColor_Type.cpp`. | `Coverage.FLinearColorExpression`, `Coverage.FLinearColorFunction`, `Coverage.FLinearColorProperty`, shared Type prefixes |
| `FName` / `Bind_FName.cpp` | `FNameType: PODP<FNameProperty>` | `Bind_FName.h` + `Bind_FName_Type.cpp`; preserve property/default/debugger semantics. | `Bindings.FName`, `Functional.Types.StringInterpolationAndFNameLiteral`, `Coverage.TypeConversion`, shared Type prefixes |
| `FNumberFormattingOptions` / `Bind_FNumberFormattingOptions.cpp` | `FNumberFormattingOptionsType: CPP<FNumberFormattingOptions>` | `Bind_FNumberFormattingOptions.h` + `Bind_FNumberFormattingOptions_Type.cpp`. | `Bindings.CoreMisc`, `Bindings.TextFormatting`, shared Type prefixes |
| `FQuat` / `Bind_FQuat.cpp` | `FQuatType: BASE<FQuat>` | `Bind_FQuat.h` + `Bind_FQuat_Type.cpp`. | `Bindings.Quat`, `Coverage.FQuatExpression`, `Coverage.FQuatFunction`, `Coverage.FQuatProperty` |
| `FQuat4f` / `Bind_FQuat4f.cpp` | `FQuat4fType: VAR<FQuat4f>` | `Bind_FQuat4f.h` + `Bind_FQuat4f_Type.cpp`. | `Bindings.Quat3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FRandomStream` / `Bind_FRandomStream.cpp` | `FRandomStreamType: BASE<FRandomStream>` | `Bind_FRandomStream.h` + `Bind_FRandomStream_Type.cpp`. | `Bindings.RandomStream`, shared Type prefixes |
| `FRotator` / `Bind_FRotator.cpp` | `FRotatorType: BASE<FRotator>` | `Bind_FRotator.h` + `Bind_FRotator_Type.cpp`. | `Coverage.FRotatorExpression`, `Coverage.FRotatorFunction`, `Coverage.FRotatorProperty` |
| `FRotator3f` / `Bind_FRotator3f.cpp` | `FRotator3fType: VAR<FRotator3f>` | `Bind_FRotator3f.h` + `Bind_FRotator3f_Type.cpp`. | `Bindings.Quat3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FSphere` / `Bind_FSphere.cpp` | `FSphereType: CORE<FSphere>` | `Bind_FSphere.h` + `Bind_FSphere_Type.cpp`. | `Bindings.Sphere3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FSphere3f` / `Bind_FSphere3f.cpp` | `FSphere3fType: TAngelscriptCoreStructType<FSphere, FGetSphere3f, false>` | `Bind_FSphere3f.h` + `Bind_FSphere3f_Type.cpp`; preserve the existing native base parameter exactly. | `Bindings.Sphere3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FString` / `Bind_FString.cpp` | `FStringType: CPPP<FStrProperty>` | `Bind_FString.h` + `Bind_FString_Type.cpp`. | `Bindings.FString`, `Bindings.FString.MultiEngine`, `Syntax.FString`, `Coverage.FStringExpression/Function/Method/Property` |
| `FText` / `Bind_FText.cpp` | `FTextType: CPPP<FTextProperty>` | `Bind_FText.h` + `Bind_FText_Type.cpp`. | `Bindings.TextFormatting`, `Coverage.TypeConversion`, `Coverage.UClass.Property` |
| `FTransform` / `Bind_FTransform.cpp` | `FTransformType: BASE<FTransform>` | `Bind_FTransform.h` + `Bind_FTransform_Type.cpp`. | `Bindings.Transform`, `Coverage.FTransformExpression/Function/Property` |
| `FTransform3f` / `Bind_FTransform3f.cpp` | `FTransform3fType: VAR<FTransform3f>` | `Bind_FTransform3f.h` + `Bind_FTransform3f_Type.cpp`. | `Bindings.Quat3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FVector` / `Bind_FVector.cpp` | `FVectorType: BASE<FVector>` | `Bind_FVector.h` + `Bind_FVector_Type.cpp`. | `Coverage.FVectorExpression/Function/Property`, `Coverage.MathGeometricStructs` |
| `FVector2D` / `Bind_FVector2D.cpp` | `FVector2DType: BASE<FVector2D>` | `Bind_FVector2D.h` + `Bind_FVector2D_Type.cpp`. | `Coverage.FVector2DExpression/Function/Property` |
| `FVector2f` / `Bind_FVector2f.cpp` | `FVector2fType: VAR<FVector2f>` | `Bind_FVector2f.h` + `Bind_FVector2f_Type.cpp`. | `Bindings.MathAndPlatform`, `Bindings.ToStringContribution`, `Parity` |
| `FVector3f` / `Bind_FVector3f.cpp` | `FVector3fType: VAR<FVector3f>` | `Bind_FVector3f.h` + `Bind_FVector3f_Type.cpp`. | `Bindings.Box3f`, `Bindings.Sphere3f`, `Bindings.ToStringContribution` |
| `FVector4` / `Bind_FVector4.cpp` | `FVector4Type: BASE<FVector4>` | `Bind_FVector4.h` + `Bind_FVector4_Type.cpp`. | `Coverage.MathGeometricStructs`, `Bindings.ToStringContribution`, shared Type prefixes |
| `FVector4f` / `Bind_FVector4f.cpp` | `FVector4fType: VAR<FVector4f>` | `Bind_FVector4f.h` + `Bind_FVector4f_Type.cpp`. | `Bindings.Quat3f`, `Bindings.ToStringContribution`, shared Type prefixes |
| `Primitives` / `Bind_Primitives.cpp` | Family-local bases `TPrimitiveAngelscriptType -> POD`, `TNumericAngelscriptType -> TPrimitive`, `TIntegralAngelscriptType -> TNumeric`; concrete `FIntType`, `FUIntType`, `FBoolType`, `FFloatType`, `FDoubleType`, `FInt64Type`, `FUInt64Type`, `FInt16Type`, `FUInt16Type`, `FInt8Type`, `FUInt8Type`, `FUnrealFloatParamExtendedToDoubleType` | Complete template definitions and all concrete declarations in `Bind_Primitives.h`; concrete/out-of-line Type bodies in `Bind_Primitives_Type.cpp`. Do not create a separate Type header. | `Coverage.Bool*`, `Coverage.Float*`, `Coverage.Int*`, `StaticJIT.PrimitiveConversions`, `Engine.TypeUsage`, `AngelScriptSDK.TypeSystem.Primitives` |
| `TArray` / `Bind_TArray.h/.cpp` | `FAngelscriptArrayType: FAngelscriptType`; `FAngelscriptArrayIteratorType: FAngelscriptType`; `FAngelscriptArrayConstIteratorType: FAngelscriptType` | All declarations in existing `Bind_TArray.h`; all out-of-line Type bodies in `Bind_TArray_Type.cpp`; merge/delete `_Functions.h`; preserve `ANGELSCRIPTRUNTIME_API` on primary. Keep independently justified structs support only. | `Bindings.Container.TArray`, `Bindings.Container.TArraySyntaxCompat`, `Coverage.TArrayAdvanced`, `Coverage.ContainerAdvanced/Nested`, `Engine.TypeUsage`, `StaticJIT.NativeForms` |
| `TMap` / `Bind_TMap.cpp` | `FAngelscriptMapType: FAngelscriptType`; `FAngelscriptMapIteratorType: FAngelscriptType`; `FAngelscriptMapConstIteratorType: FAngelscriptType` | Declarations merge into existing `Bind_TMap.h`; Type bodies move to `Bind_TMap_Type.cpp`; keep operations/callable declarations in the same canonical header and registrars in `.cpp`. | `Bindings.Container.Map`, `Coverage.TMapAdvanced`, `Coverage.ContainerParameter/Nested`, `Engine.TypeUsage`, `StaticJIT.NativeForms` |
| `TOptional` / `Bind_TOptional.cpp` | `FAngelscriptOptionalType: FAngelscriptType` | Declaration merges into existing `Bind_TOptional.h`; Type bodies move to `Bind_TOptional_Type.cpp`; preserve `ANGELSCRIPTRUNTIME_API`. | `Bindings.Container.Optional`, `Coverage.ContainerAdvanced`, `Coverage.UClass.Property`, `Coverage.UFunction`, `Engine.TypeUsage` |
| `TSet` / `Bind_TSet.cpp` | `FAngelscriptSetType: FAngelscriptType`; `FAngelscriptSetIteratorType: FAngelscriptType`; `FAngelscriptSetConstIteratorType: FAngelscriptType` | Declarations merge into existing `Bind_TSet.h`; Type bodies move to `Bind_TSet_Type.cpp`; preserve operation/callable/native-form boundaries. | `Bindings.Container.Set`, `Bindings.SetAdvanced`, `Coverage.TSetAdvanced`, `Coverage.ContainerParameter/Nested`, `Engine.TypeUsage`, `StaticJIT.NativeForms` |
| `TSoftObjectPtr` / `Bind_TSoftObjectPtr.cpp` | Non-registered base `FBaseSoftReferenceType: CPP<FSoftObjectPtr>`; concrete `FSoftObjectPtrType` and `FSoftClassPtrType` derive from it | Base and concrete declarations in `Bind_TSoftObjectPtr.h`; Type bodies in `Bind_TSoftObjectPtr_Type.cpp`; callable bodies remain in `_Functions.cpp`. | `Coverage.SoftReference`, `Coverage.WeakReference`, `FunctionLibraries.SoftReference`, `Syntax.SmartPointer`, `Engine.TypeUsage` |
| `UEnum` / `Bind_UEnum.cpp` | `FEnumType: FAngelscriptType` | Declaration in `Bind_UEnum.h`; implementation and Type-private metadata in `Bind_UEnum_Type.cpp`; retain enum discovery/table providers in registrar. | `Bindings.Enum`, `Coverage.UEnum`, `Engine.TypeUsage`, `HotReload.ReloadDelegates` |
| `UStruct` / `Bind_UStruct.cpp` | `FUStructType: FAngelscriptType` | Declaration merges into `Bind_UStruct.h`; Type body moves to `Bind_UStruct_Type.cpp`; preserve `AS_USE_BIND_DB` and non-BindDB construction paths, GC/property/debugger behavior, and `_Functions.cpp` callables. | `Bindings.UStruct`, `Coverage.UStruct`, `Coverage.UStructMember`, `Generator.ASStruct.*`, `HotReload.Struct`, `Engine.TypeUsage` |
| `WorldCollision` / `Bind_WorldCollision.cpp` | `FTraceHandleType: CPP<FTraceHandle>`; `FTraceDatumType: CPP<FTraceDatum>`; `FOverlapDatumType: CPP<FOverlapDatum>` | Declarations in `Bind_WorldCollision.h`; Type bodies in `Bind_WorldCollision_Type.cpp`; callables remain in `_Functions.cpp`. | `Bindings.WorldCollision`, `Bindings.WorldCollisionAsync`, `Bindings.WorldCollisionAsyncSweep`, `FunctionLibraries.WorldCollisionTrace/Component` |

Shared Type verification for every migrated row also includes:

- `Angelscript.TestModule.Engine.TypeUsage`
- TypeRegistry/TypeDatabase owning prefixes selected by the live catalog
- `Angelscript.TestModule.StaticJIT.NativeForms` when the family contributes a native form
- the plugin build through `Tools/RunBuild.ps1 -NoXGE`

## Shared Header-Only Template Infrastructure

These seven declarations do not move into family headers or `_Type.cpp` files:

| Header | Template | Base | Constraint |
| --- | --- | --- | --- |
| `Helper_CppType.h` | `TAngelscriptCppType<T>` | `FAngelscriptType` | Header-only shared template. |
| `Helper_CppType.h` | `TAngelscriptCppPropertyType<P>` | `TAngelscriptCppType<P::TCppType>` | Header-only shared template. |
| `Helper_PODType.h` | `TAngelscriptPODType<T>` | `FAngelscriptType` | Header-only shared template. |
| `Helper_PODType.h` | `TAngelscriptPODPropertyType<P>` | `TAngelscriptPODType<P::TCppType>` | Header-only shared template. |
| `Helper_StructType.h` | `TAngelscriptCoreStructType<T, ...>` | `TAngelscriptCppType<T>` | Header-only; used across many Runtime families and by the optional GameplayTags plugin. |
| `Helper_StructType.h` | `TAngelscriptBaseStructType<T>` | `TAngelscriptCoreStructType<T, TBaseStructure<T>>` | Header-only shared template. |
| `Helper_StructType.h` | `TAngelscriptVariantStructType<T>` | `TAngelscriptCoreStructType<T, TVariantStructure<T>>` | Header-only shared template. |

## Deferred Blueprint Object Adapters

These are inventoried but intentionally remain in `Bind_BlueprintType.cpp` for this change:

| Adapter | Base | Reason | Focused tests |
| --- | --- | --- | --- |
| `FUObjectType` | `POD<UObject*>` | Broad UObject property, GC, debugger, reflection, class lookup, and hot-reload coupling. | `Bindings.BlueprintType`, `Bindings.Object`, `Bindings.UObject`, `Engine.TypeUsage`, `HotReload.*` |
| `FSubclassOfType` | `CPP<TSubclassOf<UObject>>` | MetaClass, class-property, default-value, GC, debugger, and target BindDatabase coupling. | `Bindings.BlueprintType`, `Bindings.Object`, `Coverage.UClass.Property`, `Engine.TypeUsage` |
| `FObjectPtrType` | `CPP<TObjectPtr<UObject>>` | TObjectPtr property routing, GC, debugger, argument/return, and reflection coupling. | `Bindings.BlueprintType`, `Bindings.UObject`, `Coverage.UClass.Property`, `Engine.TypeUsage` |
| `FWeakObjectPtrType` | `CPP<TWeakObjectPtr<UObject>>` | Weak-property matching/creation, subtype, debugger, argument/return, and reflection coupling. | `Bindings.BlueprintType`, `Coverage.WeakReference`, `Syntax.SmartPointer`, `Engine.TypeUsage` |

Resumption trigger: a separate high-risk change that defines the Blueprint object family boundary and runs reflection/property/type-lookup/hot-reload verification. These four are the only deferred concrete adapter rows.

## Binds-Scope Exclusions

`AngelscriptClassGenerator_SoftReload.cpp` defines a function-local `FRawUnrealPropertyType : FAngelscriptType`. It is a transient soft-reload property fallback rather than a registered Bind family adapter, so it stays local; owning prefix is `Angelscript.TestModule.HotReload.SoftReload`.

Test-only `FAutomationRegisteredType`, `FAutomationPropertyMatchedType`, and `FExplicitSignatureMarkerType` are fixtures rather than production adapters.

## Verification Evidence

The final ownership audit reports 96/96 canonical family headers, 0 legacy `_Functions.h` files/references, 95/95 canonical `_Functions.cpp` includes, 41/41 canonical `_Type.cpp` includes, no registrars or empty implementations in `_Type.cpp`, 102/102 matching registrar first-header includes, and only the four explicitly deferred Blueprint object adapters outside `_Type.cpp`. Implementation-time static audits, build evidence, and diff review—not a permanent SourceLayout filename/include test—prove the file contract.

```powershell
rg -n 'Bind_[A-Za-z0-9_]+_Functions\.h' Plugins/Angelscript/Source
rg -n 'Bind_[A-Za-z0-9_]+Type\.(h|cpp)' Plugins/Angelscript/Source
rg -n 'AS_FORCE_LINK const FAngelscriptBind' Plugins/Angelscript/Source/AngelscriptRuntime/Binds -g 'Bind_*_Functions.cpp' -g 'Bind_*_Type.cpp'
openspec validate improve-as-bind-reviewability-and-tests --strict
```

The first three searches must have no forbidden ownership match. A retained support header is checked against the audited table rather than accepted by suffix alone. Runtime verification must use `Tools/RunBuild.ps1` and `Tools/RunTests.ps1`; direct UBT invocation is out of scope.

Fresh runtime evidence:

- final UE build: `Saved/Build/bind-family-ownership-refactor-iwyu/20260809_020255_921_7c29613e/Build.log`, exit `0`, zero compiler/fatal/IWYU first-header diagnostics;
- TypeUsage `5/5`, TypeRegistry `1/1`, TypeDatabase `3/3`, StaticJIT NativeForms `4/4`, StaticJIT AOT `12/12`, and full Bindings `275/275`, all with zero failures/skips in the corresponding `Saved/Tests/bind-refactor-*` reports;
- final All suite: 35 UE buckets, `2521/2521`, zero failures/skips, bounded by `Saved/Tests/All_01_Editor/20260809_021748_076_367c4a53/Summary.json` and `Saved/Tests/All_35_WorldSubsystem/20260809_025909_932_004ff3e2/Summary.json`;
- Standalone CTest: `19/19` at `Saved/StandaloneTests/All_36_Standalone/20260809_025941_333_1e4275ca/Summary.json`;
- `git diff --check` and `openspec validate improve-as-bind-reviewability-and-tests --strict` both exit `0`.
