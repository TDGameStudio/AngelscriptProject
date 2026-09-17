/**
 * @version v1
 * @summary HotReload VersionPair Before. GetValue meta DisplayName Alpha.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. GetValue meta DisplayName Alpha.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationFunctionMetadataTarget : UObject
{
	/** Returns the value. */
	UFUNCTION(meta=(DisplayName="Alpha"))
	int GetValue()
	{
		return 1;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. GetValue DisplayName becomes Beta.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationFunctionMetadataTarget : UObject
{
	/** Returns the value. */
	UFUNCTION(meta=(DisplayName="Beta"))
	int GetValue()
	{
		return 1;
	}
}
/** @end */
