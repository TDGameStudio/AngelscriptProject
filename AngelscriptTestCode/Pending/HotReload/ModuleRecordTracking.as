/**
 * @version v1
 * @summary HotReload VersionPair Before. ModuleRecordTracking Module A.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. ModuleRecordTracking Module A.
 * @topic Baseline
 */
UCLASS()
class UTrackedObjectA : UObject
{
	UPROPERTY()
	int ValueA;

	default ValueA = 10;

	/** Returns the value a. */
	UFUNCTION()
	int GetValueA()
	{
		return ValueA;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. ModuleRecordTracking Module B.
 * @topic HotReload
 */
UCLASS()
class UTrackedObjectB : UObject
{
	UPROPERTY()
	int ValueB;

	default ValueB = 20;

	/** Returns the value b. */
	UFUNCTION()
	int GetValueB()
	{
		return ValueB;
	}
}
/** @end */
