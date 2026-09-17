/**
 * @version v1
 * @summary HotReload VersionPair Before. Echo(int FirstValue).
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Echo(int FirstValue).
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationFunctionArgumentNameTarget : UObject
{
	/** Echo: exercises the echo behaviour. */
	UFUNCTION()
	int Echo(int FirstValue)
	{
		return FirstValue;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Echo argument renamed SecondValue.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationFunctionArgumentNameTarget : UObject
{
	/** Echo: exercises the echo behaviour. */
	UFUNCTION()
	int Echo(int SecondValue)
	{
		return SecondValue;
	}
}
/** @end */
