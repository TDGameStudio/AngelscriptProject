/**
 * @version v1
 * @summary HotReload VersionPair Before. ComputeValue() returns int 1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. ComputeValue() returns int 1.
 * @topic Baseline
 */
UCLASS()
class UReloadFunctionTarget : UObject
{
	/** Computes the value and returns the result. */
	UFUNCTION()
	int ComputeValue()
	{
		return 1;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. ComputeValue(float Scale) returns Scale.
 * @topic HotReload
 */
UCLASS()
class UReloadFunctionTarget : UObject
{
	/** Computes the value and returns the result. */
	UFUNCTION()
	float ComputeValue(float Scale)
	{
		return Scale;
	}
}
/** @end */
