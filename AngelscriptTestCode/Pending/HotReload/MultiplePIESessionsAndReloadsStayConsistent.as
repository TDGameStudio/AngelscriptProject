/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Multi-session PIE sequence V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Multi-session PIE sequence V1.
 * @topic Baseline
 */
UCLASS(Blueprintable)
class AHotReloadPIESequenceGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIESequenceLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Multi-session PIE sequence V2.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIESequenceGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIESequenceLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Multi-session PIE sequence V3.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIESequenceGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIESequenceLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 3;
	}
}
/** @end */
/**
 * @version version-04
 * @parent root
 * @summary HotReload VersionPair Version_04. Multi-session PIE sequence V4.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIESequenceGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIESequenceLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 4;
	}
}
/** @end */
