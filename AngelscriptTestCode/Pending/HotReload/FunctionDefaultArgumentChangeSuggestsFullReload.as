/**
 * @version v1
 * @summary HotReload VersionPair Before. SumWithDefault(int Value = 1).
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. SumWithDefault(int Value = 1).
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationFunctionDefaultTarget : UObject
{
	/** SumWithDefault: exercises the sum with default behaviour. */
	UFUNCTION()
	int SumWithDefault(int Value = 1)
	{
		return Value;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. SumWithDefault default argument is 2.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationFunctionDefaultTarget : UObject
{
	/** SumWithDefault: exercises the sum with default behaviour. */
	UFUNCTION()
	int SumWithDefault(int Value = 2)
	{
		return Value;
	}
}
/** @end */
