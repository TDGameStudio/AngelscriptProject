/**
 * Insert throws when Index is not in [0, Num]. Insert at Num is valid;
 * Index < 0 or Index > Num is not. Message is not the generic opIndex text.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Insert
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArrayInsertOutOfBounds
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * Insert at a negative index throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Insert
	 * @Inputs [10]; Insert(9, -1)
	 * @Return void; throws "Array index out of bounds. Need to insert between 0 and ArraySize"
	 * @Boundary Index < 0
	 */
	UFUNCTION()
	void InsertNegativeIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Insert(9, -1);
	}

	/**
	 * Insert past Num throws. Index == Num is legal and is not this case.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Insert
	 * @Inputs [10]; Insert(9, 2)
	 * @Return void; throws "Array index out of bounds. Need to insert between 0 and ArraySize"
	 * @Boundary Index > Num()
	 */
	UFUNCTION()
	void InsertPastNum()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Insert(9, 2);
	}
}
