/**
 * @version v1
 * @summary HotReload VersionPair Before. During-PIE soft LevelScript V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. During-PIE soft LevelScript V1.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. During-PIE soft LevelScript V2.
 * @topic HotReload
 */
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
		return 20;
	}
}
/** @end */
