// Theme: HotReload VersionPair Version_04. Soft-reload CDO/instance consistency After.
// C++: AngelscriptHotReloadVersionChainTests.cpp::RunCDOAndInstanceConsistency ScriptV2
// Retained: AHotReloadSoftReloadConsistencyTarget UClass identity; Counter default 5.
// Replaced: GetValue body Counter+100.
// Oracle After: existing instance GetValue == 105; class object unchanged.
// FixtureIsolated. Pair with Version_03. Version_01/02 are the separate full-reload pair.

UCLASS()
class AHotReloadSoftReloadConsistencyTarget : AActor
{
	UPROPERTY()
	int Counter = 5;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Counter + 100;
	}
}
