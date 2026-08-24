// Theme: HotReload VersionPair Before. UTexture2D-only reference delegate.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeReferenceSignatureAfterReload
// Retained after reload: FHotReloadReferenceSignal name, UHotReloadReferenceReceiver, HandleReferences, RunReferences.
// Replaced in After: UClass, TSubclassOf, TSoftObjectPtr, TSoftClassPtr parameters.
// Oracle: valid texture -> 17; null texture would return 0. FixtureIsolated.

delegate int FHotReloadReferenceSignal(UTexture2D Texture);

UCLASS()
class UHotReloadReferenceReceiver : UObject
{
	UFUNCTION()
	int HandleReferences(UTexture2D Texture)
	{
		int Result = IsValid(Texture) ? 17 : 0;
		Log(n"HotReloadDelegateTests", "Reference V1 HandleReferences TextureValid=" + IsValid(Texture) + " Result=" + Result);
		return Result;
	}
}

int RunReferences(UHotReloadReferenceReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Reference V1 RunReferences: creating texture");
	UTexture2D Texture = Cast<UTexture2D>(NewObject(GetTransientPackage(), UTexture2D::StaticClass()));

	FHotReloadReferenceSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleReferences");
	int Result = Signal.Execute(Texture);
	Log(n"HotReloadDelegateTests", "Reference V1 RunReferences Result=" + Result);
	return Result;
}
