/**
 * @version v1
 * @summary HotReload VersionPair Before. Class with GetValue only; no delegate type.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Class with GetValue only; no delegate type.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationDelegateAddedTarget : UObject
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
 * @summary HotReload VersionPair After. Adds unused delegate type at module scope.
 * @topic HotReload
 */
/** Delegate FHotReloadChangeClassificationAddedSignal: carries (int Value) for this reload scenario. */
delegate void FHotReloadChangeClassificationAddedSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateAddedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
/** @end */
