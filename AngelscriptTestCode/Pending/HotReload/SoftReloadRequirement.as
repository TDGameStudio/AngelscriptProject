/**
 * @version v1
 * @summary HotReload VersionPair Before. Body-only GetValue returns 1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Body-only GetValue returns 1.
 * @topic Baseline
 */
UCLASS()
class UReloadSoftRequirementTarget : UObject
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
 * @summary HotReload VersionPair After. GetValue body returns 2.
 * @topic HotReload
 */
UCLASS()
class UReloadSoftRequirementTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
/** @end */
