// Theme: HotReload VersionPair Version_03. Soft-reload CDO/instance consistency Before.
// C++: AngelscriptHotReloadVersionChainTests.cpp::RunCDOAndInstanceConsistency ScriptV1
// Retained after Version_04: UClass identity; Counter default 5; existing instance storage.
// Replaced in Version_04: GetValue body Counter -> Counter+100.
// Oracle Before: GetValue == 5.
// FixtureIsolated. Pair with Version_04. Version_01/02 are the separate full-reload pair.

UCLASS()
class AHotReloadSoftReloadConsistencyTarget : AActor
{
	UPROPERTY()
	int Counter = 5;

	UFUNCTION()
	int GetValue()
	{
		return Counter;
	}
}
