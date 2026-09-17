/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Unchanged module analyzed against itself.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Unchanged module analyzed against itself.
 * @topic Baseline
 */
UCLASS()
class UReloadNoChangeTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}
/** @end */
