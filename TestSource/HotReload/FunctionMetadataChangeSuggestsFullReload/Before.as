// Theme: HotReload VersionPair Before. GetValue meta DisplayName Alpha.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionMetadataChangeSuggestsFullReload
// Retained: UHotReloadChangeClassificationFunctionMetadataTarget, GetValue returns 1.
// Replaced after After.as: DisplayName Alpha -> Beta.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationFunctionMetadataTarget : UObject
{
	UFUNCTION(meta=(DisplayName="Alpha"))
	int GetValue()
	{
		return 1;
	}
}
