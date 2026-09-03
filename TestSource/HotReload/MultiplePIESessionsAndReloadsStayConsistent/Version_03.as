// Theme: HotReload VersionPair Version_03. Multi-session PIE sequence V3.
// C++: AngelscriptHotReloadPIESessionTests.cpp::MultiplePIESessionsAndReloadsStayConsistent
// Retained: GameMode, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue 2 -> 3.
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
		return 3;
	}
}
