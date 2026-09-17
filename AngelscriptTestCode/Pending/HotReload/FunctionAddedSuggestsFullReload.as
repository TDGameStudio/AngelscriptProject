/**
 * @version v1
 * @summary HotReload VersionPair Before. Only GetValue returns 1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Only GetValue returns 1.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationFunctionAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Adds GetExtraValue returning 2.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationFunctionAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	/** Returns the extra value. */
	UFUNCTION()
	int GetExtraValue()
	{
		return 2;
	}
}
/** @end */
