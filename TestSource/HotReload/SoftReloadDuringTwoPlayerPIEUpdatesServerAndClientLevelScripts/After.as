// Theme: HotReload VersionPair After. Two-player PIE soft LevelScript V2.
// C++: AngelscriptHotReloadMultiplayerPIETests.cpp::SoftReloadDuringTwoPlayerPIEUpdatesServerAndClientLevelScripts
// Retained: AHotReloadMultiplayerPIESoftGameMode, LevelScript UClass identity, SetReplicates(false), FullyHandled soft path.
// Replaced: GetValue 100 -> 200 on live server and client LevelScripts.
// FixtureIsolated.

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
		return 200;
	}
}
