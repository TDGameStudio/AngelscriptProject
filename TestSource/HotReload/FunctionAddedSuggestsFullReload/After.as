// Theme: HotReload VersionPair After. Adds GetExtraValue returning 2.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionAddedSuggestsFullReload
// Retained: GetValue returning 1.
// Replaced: function set gains GetExtraValue. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionAddedTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	UFUNCTION()
	int GetExtraValue()
	{
		return 2;
	}
}
