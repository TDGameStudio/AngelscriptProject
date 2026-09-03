// Theme: HotReload VersionPair After. Adds unused delegate type at module scope.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateAddedSuggestsFullReload
// Retained: class and GetValue returning 1.
// Replaced: module gains FHotReloadChangeClassificationAddedSignal. FullReloadSuggested.
// FixtureIsolated.

/** Delegate FHotReloadChangeClassificationAddedSignal: carries (int Value) for this reload scenario. */
delegate void FHotReloadChangeClassificationAddedSignal(int Value);

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
