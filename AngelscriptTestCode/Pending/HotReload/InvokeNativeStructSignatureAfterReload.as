/**
 * @version v1
 * @summary HotReload VersionPair Before. Native FVector-only delegate.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Native FVector-only delegate.
 * @topic Baseline
 */
// Retained after reload: FHotReloadNativeStructSignal name, UHotReloadNativeStructReceiver, HandleStructs, RunNativeStruct.
// Replaced in After: Offset, Transform, Tint, PackedColor, Id parameters.
// Oracle: Execute(FVector(1,2,3)) -> 6. Extra: zero vector would sum 0. FixtureIsolated.

/** Delegate FHotReloadNativeStructSignal: carries (FVector Location) for this reload scenario. */
delegate int FHotReloadNativeStructSignal(FVector Location);

UCLASS()
class UHotReloadNativeStructReceiver : UObject
{
	/** Handles the structs callback. */
	UFUNCTION()
	int HandleStructs(FVector Location)
	{
		int Result = int(Location.X + Location.Y + Location.Z);
		Log(n"HotReloadDelegateTests", "NativeStruct V1 HandleStructs Location=" + Location + " Result=" + Result);
		return Result;
	}
}

/** Runs the native struct path and returns the observed result. */
int RunNativeStruct(UHotReloadNativeStructReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "NativeStruct V1 RunNativeStruct: binding HandleStructs");
	FHotReloadNativeStructSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleStructs");
	int Result = Signal.Execute(FVector(1.0, 2.0, 3.0));
	Log(n"HotReloadDelegateTests", "NativeStruct V1 RunNativeStruct Result=" + Result);
	return Result;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Native struct parameter expansion.
 * @topic HotReload
 */
/** Delegate FHotReloadNativeStructSignal: carries (FVector Location, FVector2D Offset, FTransform Transform, FLinearColor Tint, FColor PackedColor, FGuid Id) for this reload scenario. */
delegate int FHotReloadNativeStructSignal(FVector Location, FVector2D Offset, FTransform Transform, FLinearColor Tint, FColor PackedColor, FGuid Id);

UCLASS()
class UHotReloadNativeStructReceiver : UObject
{
	/** Handles the structs callback. */
	UFUNCTION()
	int HandleStructs(FVector Location, FVector2D Offset, FTransform Transform, FLinearColor Tint, FColor PackedColor, FGuid Id)
	{
		FVector Translation = Transform.GetTranslation();
		Log(n"HotReloadDelegateTests", "NativeStruct V2 HandleStructs Location=" + Location + " Offset=" + Offset + " Translation=" + Translation + " Tint=" + Tint + " PackedColor=" + PackedColor + " Id=" + Id.ToString());
		int Result = int(
			Location.X + Location.Y + Location.Z +
			Offset.X + Offset.Y +
			Translation.X + Translation.Y + Translation.Z +
			Tint.R * 10.0f + Tint.G * 10.0f + Tint.B * 10.0f +
			PackedColor.R + PackedColor.G + PackedColor.B +
			Id[0] + Id[1] + Id[2] + Id[3]);
		Log(n"HotReloadDelegateTests", "NativeStruct V2 HandleStructs Result=" + Result);
		return Result;
	}
}

/** Runs the native struct path and returns the observed result. */
int RunNativeStruct(UHotReloadNativeStructReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "NativeStruct V2 RunNativeStruct: binding HandleStructs");
	FHotReloadNativeStructSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleStructs");
	int Result = Signal.Execute(
		FVector(1.0, 2.0, 3.0),
		FVector2D(4.0, 5.0),
		FTransform(FVector(6.0, 7.0, 8.0)),
		FLinearColor(0.1f, 0.2f, 0.3f, 1.0f),
		FColor(9, 10, 11, 255),
		FGuid(12, 13, 14, 15));
	Log(n"HotReloadDelegateTests", "NativeStruct V2 RunNativeStruct Result=" + Result);
	return Result;
}
/** @end */
