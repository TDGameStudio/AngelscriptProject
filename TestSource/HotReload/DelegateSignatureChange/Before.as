// Theme: HotReload VersionPair Before. FReloadAnalysisSignal(int Value) on carrier.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateSignatureChange
// Retained: UReloadDelegateAnalysisCarrier and Signal property name.
// Replaced after After.as: delegate signature gains int Tag.
// Oracle: FullReloadRequired; bWantsFullReload true; bNeedsFullReload true.
// FixtureIsolated. Load Before then After in recorded order.

/** Delegate FReloadAnalysisSignal: carries (int Value) for this reload scenario. */
delegate void FReloadAnalysisSignal(int Value);

UCLASS()
class UReloadDelegateAnalysisCarrier : UObject
{
	UPROPERTY()
	FReloadAnalysisSignal Signal;
}
