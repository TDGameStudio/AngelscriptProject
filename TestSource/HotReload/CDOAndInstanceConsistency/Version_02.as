// Theme: HotReload VersionPair Version_02. Full-reload CDO/instance chain After.
// C++: AngelscriptHotReloadVersionChainTests.cpp::RunVersionChainAndCDOConsistency ScriptV2
// Retained: AHotReloadVersionChainTarget name; GetVersion; old CDO pre-reload Version==1.
// Replaced: UClass/CDO objects; Version default 2; Mana=5; GetMana; new actors inherit those defaults.
// Oracle After: NewClass != OldClass; GetMostUpToDateClass; spawned Version==2 Mana==5.
// FixtureIsolated. Pair with Version_01. Version_03/04 are the separate soft-reload pair.

UCLASS()
class AHotReloadVersionChainTarget : AActor
{
	UPROPERTY()
	int Version = 2;

	UPROPERTY()
	int Mana = 5;

	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}

	UFUNCTION()
	int GetMana()
	{
		return Mana;
	}
}
