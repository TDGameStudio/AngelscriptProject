/**
 * Swap throws when either index is not in [0, Num).
 *
 * @Theme Containers.TArray
 * @Subject TArray.Swap
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArraySwapOutOfBounds
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * Swap with a negative first index throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Swap
	 * @Inputs [10]; Swap(-1, 0)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary FirstIndexToSwap < 0
	 */
	UFUNCTION()
	void SwapNegativeFirstIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Swap(-1, 0);
	}

	/**
	 * Swap with second index == Num throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Swap
	 * @Inputs [10]; Swap(0, 1)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary SecondIndexToSwap == Num()
	 */
	UFUNCTION()
	void SwapSecondIndexPastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Swap(0, 1);
	}

	/**
	 * Swap(0, 0) on an empty array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Swap
	 * @Inputs Empty TArray<int>; Swap(0, 0)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary Num() == 0
	 */
	UFUNCTION()
	void SwapOnEmpty()
	{
		TArray<int> Values;
		Values.Swap(0, 0);
	}
}
