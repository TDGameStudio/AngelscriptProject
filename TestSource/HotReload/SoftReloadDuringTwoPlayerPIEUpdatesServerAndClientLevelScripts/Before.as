// Theme: HotReload VersionPair Before. Two-player PIE soft LevelScript V1.
// C++: AngelscriptHotReloadMultiplayerPIETests.cpp::SoftReloadDuringTwoPlayerPIEUpdatesServerAndClientLevelScripts
// Retained during PIE soft reload: GameMode class, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue 100 -> 200 on both server and client LevelScripts.
// FixtureIsolated. C++ AssertServerAndClientGetValue baseline is 100.

UCLASS(Blueprintable)
class AHotReloadMultiplayerPIESoftGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadMultiplayerPIESoftLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UFUNCTION()
	int GetValue()
	{
		return 100;
	}
}
