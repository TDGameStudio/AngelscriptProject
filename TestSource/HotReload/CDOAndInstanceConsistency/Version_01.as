// Theme: HotReload VersionPair Version_01. Full-reload CDO/instance chain Before.
// C++: AngelscriptHotReloadVersionChainTests.cpp::RunVersionChainAndCDOConsistency ScriptV1
// Retained on old class after reload: Version default 1 (captured pre-reload); no Mana; NewerVersion -> Version_02 class.
// Replaced in Version_02: UClass identity; Version default 2; Mana=5; GetMana.
// Oracle Before: CDO Version==1; Mana absent.
// FixtureIsolated. Pair with Version_02. Version_03/04 are the separate soft-reload pair.

UCLASS()
class AHotReloadVersionChainTarget : AActor
{
	UPROPERTY()
	int Version = 1;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
