// Theme: HotReload VersionPair After. FHotReloadSignal gains Label.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastDelegateSignatureSwap
// Retained: delegate name, carrier class, Signal UPROPERTY.
// Replaced: FHotReloadSignal(int Value, const FString& Label).
// Oracle: DelegateReloadCount 1; replaced function pointer. FixtureIsolated.

delegate void FHotReloadSignal(int Value, const FString& Label);

UCLASS()
class UHotReloadDelegateSignatureCarrier : UObject
{
	UPROPERTY()
	FHotReloadSignal Signal;
}
