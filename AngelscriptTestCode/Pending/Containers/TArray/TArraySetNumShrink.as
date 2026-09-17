/**
 * @version v1
 * @summary SetNum shrinks the array so Num() matches the requested smaller size.
 * @topic Containers
 */
/**
 * @version root
 * @summary SetNum shrinks the array so Num() matches the requested smaller size.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe SetNum shrinking: Num matches the new size.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs TArray<int> [1, 2, 3, 4]; SetNum(2)
	 * @Return true when Num is 2
	 */
	UFUNCTION()
	bool SetNumShrinksAndNumMatches()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(4);
		Values.SetNum(2);
		return Values.Num() == 2;
	}
}
/** @end */
