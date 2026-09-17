/**
 * @version v1
 * @summary SetNum grows the array so Num() matches the requested larger size.
 * @topic Containers
 */
/**
 * @version root
 * @summary SetNum grows the array so Num() matches the requested larger size.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe SetNum growing: Num matches the new size.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs TArray<int> [1, 2]; SetNum(4)
	 * @Return true when Num is 4
	 */
	UFUNCTION()
	bool SetNumGrowsAndNumMatches()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.SetNum(4);
		return Values.Num() == 4;
	}
}
/** @end */
