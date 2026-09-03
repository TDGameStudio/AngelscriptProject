// Theme: HotReload VersionPair Version_02. Multi-session PIE sequence V2.
// C++: AngelscriptHotReloadPIESessionTests.cpp::MultiplePIESessionsAndReloadsStayConsistent
// Retained: GameMode, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue 1 -> 2.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadPIESequenceGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIESequenceLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
