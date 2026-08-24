// Theme: HotReload VersionPair Before. Single-int FHotReloadSignal.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastDelegateSignatureSwap
// Retained after reload: FHotReloadSignal name, UHotReloadDelegateSignatureCarrier, Signal property.
// Replaced in After: extra const FString& Label parameter.
// Oracle: DelegateReloadCount 1; old vs new function identity. FixtureIsolated.

delegate void FHotReloadSignal(int Value);

UCLASS()
class UHotReloadDelegateSignatureCarrier : UObject
{
	UPROPERTY()
	FHotReloadSignal Signal;
}
