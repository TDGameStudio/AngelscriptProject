// Theme: HotReload VersionPair After. Adds unused delegate type at module scope.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateAddedSuggestsFullReload
// Retained: class and GetValue returning 1.
// Replaced: module gains FHotReloadChangeClassificationAddedSignal. FullReloadSuggested.
// FixtureIsolated.

delegate void FHotReloadChangeClassificationAddedSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateAddedTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
