/**
 * @version v1
 * @summary HotReload VersionPair Before. GetValue BlueprintCallable.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. GetValue BlueprintCallable.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationFunctionSpecifierTarget : UObject
{
	/** Returns the value. */
	UFUNCTION(BlueprintCallable)
	int GetValue()
	{
		return 1;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. GetValue BlueprintPure const.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationFunctionSpecifierTarget : UObject
{
	/** Returns the value. */
	UFUNCTION(BlueprintPure)
	int GetValue() const
	{
		return 1;
	}
}
/** @end */
