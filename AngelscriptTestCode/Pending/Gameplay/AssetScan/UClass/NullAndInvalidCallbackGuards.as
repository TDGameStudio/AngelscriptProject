/**
 * @version v1
 * @summary Two scan-receiver classes: one exposes OnScanComplete, the other exposes a different function that is not the scan callback. C++ compiles both then exercises valid versus missing callback names, so the UCLASS, UFUNCTION.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Two scan-receiver classes: one exposes OnScanComplete, the other exposes a different function that is not the scan callback. C++ compiles both then exercises valid versus missing callback names, so the UCLASS, UFUNCTION.
 * @topic Baseline
 */
UCLASS()
class UAssetManagerValidScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	/**
	 * Increment CallbackCount as the valid scan callback.
	 *
	 * @Kind Action
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return CallbackCount increased by one
	 */
	UFUNCTION()
	void OnScanComplete()
	{
		CallbackCount += 1;
	}

	/**
	 * Observe that an untouched valid receiver starts at zero.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return CallbackCount == 0;
	}

	/**
	 * Observe that calling OnScanComplete increments the count.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 1
	 */
	UFUNCTION()
	bool OnScanCompleteIncrements()
	{
		OnScanComplete();
		return CallbackCount == 1;
	}
}

UCLASS()
class UAssetManagerMissingScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	/**
	 * Increment CallbackCount from a function that is not the scan callback.
	 *
	 * @Kind Action
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return CallbackCount increased by one
	 */
	UFUNCTION()
	void DifferentFunction()
	{
		CallbackCount += 1;
	}

	/**
	 * Observe that an untouched missing-callback receiver starts at zero.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return CallbackCount == 0;
	}

	/**
	 * Observe that calling DifferentFunction directly still increments the count.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 1
	 */
	UFUNCTION()
	bool DifferentFunctionDirectCall()
	{
		DifferentFunction();
		return CallbackCount == 1;
	}
}
/** @end */
