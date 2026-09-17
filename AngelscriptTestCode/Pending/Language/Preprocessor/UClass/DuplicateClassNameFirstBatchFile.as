/**
 * @version v1
 * @summary The first file of the conflicting hot-reload batch. On its own this class compiles and returns its value; the C++ diagnostic fires only when the file is batched with the seed that already published UDuplicateCarrier.
 * @topic Language
 */
/**
 * @version root
 * @summary The first file of the conflicting hot-reload batch. On its own this class compiles and returns its value; the C++ diagnostic fires only when the file is batched with the seed that already published UDuplicateCarrier.
 * @topic Baseline
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
