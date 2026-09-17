/**
 * @version v1
 * @summary HotReload VersionPair Before. Parent NotEditable ExampleValue=15, GetValue returns 15.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Parent NotEditable ExampleValue=15, GetValue returns 15.
 * @topic Baseline
 */
UCLASS()
class AHotReloadBlueprintChildEditSpecifierParent : AActor
{
	UPROPERTY(NotEditable)
	int ExampleValue = 15;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExampleValue;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Same class; EditAnywhere and GetValue + 1.
 * @topic HotReload
 */
UCLASS()
class AHotReloadBlueprintChildEditSpecifierParent : AActor
{
	UPROPERTY(EditAnywhere)
	int ExampleValue = 15;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExampleValue + 1;
	}
}
/** @end */
