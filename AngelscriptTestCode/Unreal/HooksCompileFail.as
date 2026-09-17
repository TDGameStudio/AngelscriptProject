/**
 * @version v1
 * @summary UCLASS hook forms that do not compile.
 * @topic Unreal
 * @topic Hooks
 *
 * duplicate-class-name-first-batch-file
 * duplicate-class-name-second-batch-file
 * duplicate-class-name-seed-carrier
 */
/**
 * @begin duplicate-class-name-first-batch-file
 * @summary The first file of the conflicting hot-reload batch. On its own this class compiles and returns its value; the C++ diagnostic fires only when the file is batched with the seed that already published UDuplicateCarrier.
 * @topic Negative
 */
UCLASS()
class UDuplicateCarrier : UObject
{
	/**
	 * Reports the hot-reload batch value.
	 *
	 * @Covers Preprocessor.Classes
	 * @Inputs none
	 * @Return 2
	 */
	UFUNCTION()
	int GetHotReloadValue()
	{
		return 2;
	}

	/**
	 * Observe the value this file reports when compiled alone.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Classes
	 * @Inputs GetHotReloadValue()
	 * @Return true when the value is 2
	 */
	UFUNCTION()
	bool FirstBatchFileReportsValue()
	{
		return GetHotReloadValue() == 2;
	}
}
/** @end */
/**
 * @begin duplicate-class-name-second-batch-file
 * @summary The second file of the conflicting hot-reload batch. Isolated, this empty carrier would compile; C++ fails the batch because the first module already published UDuplicateCarrier. Keep the class body empty — adding.
 * @topic Negative
 */
UCLASS()
class UDuplicateCarrier : UObject
{
}
/** @end */
/**
 * @begin duplicate-class-name-seed-carrier
 * @summary The seed file of the hot-reload duplicate-class case. It compiles and publishes UDuplicateCarrier; the conflict C++ reports only arises later, when the batch adds another module declaring the same class name.
 * @topic Negative
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
