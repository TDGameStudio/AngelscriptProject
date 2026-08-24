// Theme: HotReload VersionPair After. During-PIE soft LevelScript V2.
// C++: AngelscriptHotReloadPIESessionTests.cpp::SoftReloadDuringPIEUpdatesLiveLevelScriptBody
// Retained: GameMode, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue 10 -> 20 on the live PIE LevelScript.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadPIEDuringSoftGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringSoftLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UFUNCTION()
	int GetValue()
	{
		return 20;
	}
}
