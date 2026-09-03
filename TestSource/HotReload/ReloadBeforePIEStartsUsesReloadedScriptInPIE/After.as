// Theme: HotReload VersionPair After. Pre-PIE soft LevelScript V2.
// C++: AngelscriptHotReloadPIESessionTests.cpp::ReloadBeforePIEStartsUsesReloadedScriptInPIE
// Retained: GameMode, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue 11 -> 22. PIE session uses this body.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadPIEBeforeGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEBeforeLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 22;
	}
}
