/**
 * @version v1
 * @summary HotReload VersionPair Before. Only GetValue, no BlueprintEvent.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Only GetValue, no BlueprintEvent.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationBlueprintEventAddedTarget : UObject
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
 * @summary HotReload VersionPair After. Adds BlueprintEvent GetExtraValue.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationBlueprintEventAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	/** Returns the extra value. */
	UFUNCTION(BlueprintEvent)
	int GetExtraValue()
	{
		return 2;
	}
}
/** @end */
