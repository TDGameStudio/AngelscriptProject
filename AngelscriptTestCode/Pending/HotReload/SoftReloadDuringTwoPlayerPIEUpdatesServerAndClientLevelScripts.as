/**
 * @version v1
 * @summary HotReload VersionPair Before. Two-player PIE soft LevelScript V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Two-player PIE soft LevelScript V1.
 * @topic Baseline
 */
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

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 100;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Two-player PIE soft LevelScript V2.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadMultiplayerPIESoftGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadMultiplayerPIESoftLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 200;
	}
}
/** @end */
