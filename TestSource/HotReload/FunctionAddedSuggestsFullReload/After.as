// Theme: HotReload VersionPair After. Adds GetExtraValue returning 2.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionAddedSuggestsFullReload
// Retained: GetValue returning 1.
// Replaced: function set gains GetExtraValue. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	/** Returns the extra value. */
	UFUNCTION()
	int GetExtraValue()
	{
		return 2;
	}
}
