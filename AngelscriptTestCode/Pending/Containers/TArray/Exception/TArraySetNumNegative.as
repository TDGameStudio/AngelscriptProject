/**
 * @version v1
 * @summary SetNum throws "Invalid negative Num" when NewNum is negative.
 * @topic Containers
 */
/**
 * @version root
 * @summary SetNum throws "Invalid negative Num" when NewNum is negative.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * SetNum with a negative size throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.SetNum
	 * @Inputs Empty TArray<int>; SetNum(-1)
	 * @Return void; throws "Invalid negative Num"
	 * @Boundary NewNum < 0
	 */
	UFUNCTION()
	void SetNumNegative()
	{
		TArray<int> Values;
		Values.SetNum(-1);
	}
}
/** @end */
