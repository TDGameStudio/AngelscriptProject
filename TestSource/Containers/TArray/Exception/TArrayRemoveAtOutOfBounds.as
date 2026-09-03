/**
 * RemoveAt and RemoveAtSwap throw when Index is not in [0, Num).
 *
 * @Theme Containers.TArray
 * @Subject TArray.RemoveAt
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArrayRemoveAtOutOfBounds
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * RemoveAt(1) on a one-element array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.RemoveAt
	 * @Inputs [10]; RemoveAt(1)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary Index == Num()
	 */
	UFUNCTION()
	void RemoveAtPastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.RemoveAt(1);
	}

	/**
	 * RemoveAt(-1) throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.RemoveAt
	 * @Inputs [10]; RemoveAt(-1)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary Index < 0
	 */
	UFUNCTION()
	void RemoveAtNegativeIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.RemoveAt(-1);
	}

	/**
	 * RemoveAtSwap(1) on a one-element array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs [10]; RemoveAtSwap(1)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary Index == Num()
	 */
	UFUNCTION()
	void RemoveAtSwapPastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.RemoveAtSwap(1);
	}

	/**
	 * RemoveAtSwap(-1) throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs [10]; RemoveAtSwap(-1)
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary Index < 0
	 */
	UFUNCTION()
	void RemoveAtSwapNegativeIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.RemoveAtSwap(-1);
	}
}
