/**
 * @version v1
 * @summary HotReload VersionPair Before. Pre-PIE soft LevelScript V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Pre-PIE soft LevelScript V1.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Pre-PIE soft LevelScript V2.
 * @topic HotReload
 */
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
/** @end */
