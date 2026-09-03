// Theme: HotReload VersionPair Before. Only GetValue returns 1.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionAddedSuggestsFullReload
// Retained: UHotReloadChangeClassificationFunctionAddedTarget and GetValue.
// Replaced after After.as: GetExtraValue is added.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationFunctionAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
