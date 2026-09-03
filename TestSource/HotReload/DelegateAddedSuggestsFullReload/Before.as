// Theme: HotReload VersionPair Before. Class with GetValue only; no delegate type.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateAddedSuggestsFullReload
// Retained: UHotReloadChangeClassificationDelegateAddedTarget and GetValue.
// Replaced after After.as: module gains FHotReloadChangeClassificationAddedSignal.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationDelegateAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
