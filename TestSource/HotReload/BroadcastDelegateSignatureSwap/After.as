// Theme: HotReload VersionPair After. FHotReloadSignal gains Label.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastDelegateSignatureSwap
// Retained: delegate name, carrier class, Signal UPROPERTY.
// Replaced: FHotReloadSignal(int Value, const FString&in Label).
// Oracle: DelegateReloadCount 1; replaced function pointer. FixtureIsolated.

/** Delegate FHotReloadSignal: carries (int Value, const FString&in Label) for this reload scenario. */
delegate void FHotReloadSignal(int Value, const FString&in Label);

UCLASS()
class UHotReloadDelegateSignatureCarrier : UObject
{
	UPROPERTY()
	FHotReloadSignal Signal;
}
