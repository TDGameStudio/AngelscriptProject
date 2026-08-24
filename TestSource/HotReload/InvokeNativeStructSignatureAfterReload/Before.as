// Theme: HotReload VersionPair Before. Native FVector-only delegate.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeNativeStructSignatureAfterReload
// Retained after reload: FHotReloadNativeStructSignal name, UHotReloadNativeStructReceiver, HandleStructs, RunNativeStruct.
// Replaced in After: Offset, Transform, Tint, PackedColor, Id parameters.
// Oracle: Execute(FVector(1,2,3)) -> 6. Extra: zero vector would sum 0. FixtureIsolated.

delegate int FHotReloadNativeStructSignal(FVector Location);

UCLASS()
class UHotReloadNativeStructReceiver : UObject
{
	UFUNCTION()
	int HandleStructs(FVector Location)
	{
		int Result = int(Location.X + Location.Y + Location.Z);
		Log(n"HotReloadDelegateTests", "NativeStruct V1 HandleStructs Location=" + Location + " Result=" + Result);
		return Result;
	}
}

int RunNativeStruct(UHotReloadNativeStructReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "NativeStruct V1 RunNativeStruct: binding HandleStructs");
	FHotReloadNativeStructSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleStructs");
	int Result = Signal.Execute(FVector(1.0, 2.0, 3.0));
	Log(n"HotReloadDelegateTests", "NativeStruct V1 RunNativeStruct Result=" + Result);
	return Result;
}
