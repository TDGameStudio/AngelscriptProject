// Theme: HotReload VersionPair Version_01. Multi-session PIE sequence V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::MultiplePIESessionsAndReloadsStayConsistent
// Retained: GameMode, LevelScript names, SetReplicates(false) across V1-V4.
// Replaced in later versions: GetValue 1 -> 2 -> 3 -> 4. Each soft reload keeps UClass identity.
// FixtureIsolated. InvokeGetValue V1 is 1.

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
		return 1;
	}
}
