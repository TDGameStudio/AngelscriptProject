/**
 * @version v1
 * @summary SetNumZeroed throws "Invalid negative Num" when NewNum is negative.
 * @topic Containers
 */
/**
 * @version root
 * @summary SetNumZeroed throws "Invalid negative Num" when NewNum is negative.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * SetNumZeroed with a negative size throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.SetNumZeroed
	 * @Inputs Empty TArray<int>; SetNumZeroed(-1)
	 * @Return void; throws "Invalid negative Num"
	 * @Boundary NewNum < 0
	 */
	UFUNCTION()
	void SetNumZeroedNegative()
	{
		TArray<int> Values;
		Values.SetNumZeroed(-1);
	}
}
/** @end */
