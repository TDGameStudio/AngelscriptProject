/**
 * @version v1
 * @summary HotReload VersionPair Before. GetValue and GetRemovedValue both present.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. GetValue and GetRemovedValue both present.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationFunctionRemovedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	/** Returns the removed value. */
	UFUNCTION()
	int GetRemovedValue()
	{
		return 2;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. GetRemovedValue is gone.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationFunctionRemovedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
/** @end */
