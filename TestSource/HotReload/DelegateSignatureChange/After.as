// Theme: HotReload VersionPair After. Delegate gains Tag parameter.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateSignatureChange
// Retained: carrier class and Signal UPROPERTY.
// Replaced: FReloadAnalysisSignal(int Value) -> (int Value, int Tag). FullReloadRequired.
// FixtureIsolated.

delegate void FReloadAnalysisSignal(int Value, int Tag);

UCLASS()
class UReloadDelegateAnalysisCarrier : UObject
{
	UPROPERTY()
	FReloadAnalysisSignal Signal;
}
