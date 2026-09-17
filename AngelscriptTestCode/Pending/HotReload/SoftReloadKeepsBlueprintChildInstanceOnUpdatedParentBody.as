/**
 * @version v1
 * @summary HotReload VersionPair Before. Soft-reload parent ExampleValue=30, GetValue returns 30.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Soft-reload parent ExampleValue=30, GetValue returns 30.
 * @topic Baseline
 */
UCLASS()
class AHotReloadBlueprintChildSoftReloadParent : AActor
{
	UPROPERTY()
	int ExampleValue = 30;

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
 * @summary HotReload VersionPair After. Body-only GetValue = ExampleValue + 12.
 * @topic HotReload
 */
UCLASS()
class AHotReloadBlueprintChildSoftReloadParent : AActor
{
	UPROPERTY()
	int ExampleValue = 30;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExampleValue + 12;
	}
}
/** @end */
