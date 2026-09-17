/**
 * @version v1
 * @summary Last throws when Num()-IndexFromEnd-1 is not a valid index.
 * @topic Containers
 */
/**
 * @version root
 * @summary Last throws when Num()-IndexFromEnd-1 is not a valid index.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Last() on an empty array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Last
	 * @Inputs Empty TArray<int>; Last()
	 * @Return does not return; throws "Array index out of bounds."
	 * @Boundary Num() == 0
	 */
	UFUNCTION()
	int LastOnEmpty()
	{
		TArray<int> Values;
		return Values.Last();
	}

	/**
	 * Last(1) on a one-element array is one past the start.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Last
	 * @Inputs TArray<int> with Add(10); Last(1)
	 * @Return does not return; throws "Array index out of bounds."
	 * @Boundary IndexFromEnd == Num()
	 */
	UFUNCTION()
	int LastOnePastStart()
	{
		TArray<int> Values;
		Values.Add(10);
		return Values.Last(1);
	}

	/**
	 * Last with IndexFromEnd far past Num throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Last
	 * @Inputs TArray<int> with Add(10); Last(8)
	 * @Return does not return; throws "Array index out of bounds."
	 * @Boundary IndexFromEnd >> Num()
	 */
	UFUNCTION()
	int LastFarPastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		return Values.Last(8);
	}
}
/** @end */
