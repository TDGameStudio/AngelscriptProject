// Theme: HotReload VersionPair Version_04. Multi-session PIE sequence V4.
// C++: AngelscriptHotReloadPIESessionTests.cpp::MultiplePIESessionsAndReloadsStayConsistent
// Retained: GameMode, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue 3 -> 4.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadPIESequenceGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIESequenceLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UFUNCTION()
	int GetValue()
	{
		return 4;
	}
}
