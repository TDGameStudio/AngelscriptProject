// Theme: HotReload VersionPair Before. Pre-PIE soft LevelScript V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::ReloadBeforePIEStartsUsesReloadedScriptInPIE
// Retained: GameMode, LevelScript UClass identity, SetReplicates(false) through the pre-PIE FullyHandled soft reload.
// Replaced: GetValue 11 -> 22, which PIE then observes.
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
		return 11;
	}
}
