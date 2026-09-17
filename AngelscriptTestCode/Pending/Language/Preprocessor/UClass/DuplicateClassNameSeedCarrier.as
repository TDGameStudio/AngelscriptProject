/**
 * @version v1
 * @summary The seed file of the hot-reload duplicate-class case. It compiles and publishes UDuplicateCarrier; the conflict C++ reports only arises later, when the batch adds another module declaring the same class name.
 * @topic Language
 */
/**
 * @version root
 * @summary The seed file of the hot-reload duplicate-class case. It compiles and publishes UDuplicateCarrier; the conflict C++ reports only arises later, when the batch adds another module declaring the same class name.
 * @topic Baseline
 */
UCLASS()
class UDuplicateCarrier : UObject
{
	/**
	 * Reports the seed value.
	 *
	 * @Covers Preprocessor.Classes
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int GetSeedValue()
	{
		return 1;
	}

	/**
	 * Observe that the seeded carrier publishes and returns 1.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Classes
	 * @Inputs GetSeedValue()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool SeedCarrierReportsValue()
	{
		return GetSeedValue() == 1;
	}
}
/** @end */
