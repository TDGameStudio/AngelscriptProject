// Theme: HotReload VersionPair Before. During-PIE soft LevelScript V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::SoftReloadDuringPIEUpdatesLiveLevelScriptBody
// Retained during PIE: GameMode, live LevelScript actor, UClass identity, SetReplicates(false).
// Replaced: GetValue 10 -> 20 on the live LevelScript.
// FixtureIsolated. C++ InvokeGetValue baseline is 10.

UCLASS(Blueprintable)
class AHotReloadPIEDuringSoftGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringSoftLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 10;
	}
}
