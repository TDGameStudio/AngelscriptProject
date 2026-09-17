/**
 * @version v1
 * @summary Add accepts a local copy of Values[0]; that path does not alias array storage.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add accepts a local copy of Values[0]; that path does not alias array storage.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe Add after copying Values[0] to a temporary.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs [10]; int Copy = Values[0]; Add(Copy)
	 * @Return true when the array is [10, 10]
	 */
	UFUNCTION()
	bool AddFromTemporaryCopy()
	{
		TArray<int> Values;
		Values.Add(10);
		int Copy = Values[0];
		Values.Add(Copy);
		if (Values.Num() != 2)
		{
			return false;
		}
		if (Values[0] != 10)
		{
			return false;
		}
		return Values[1] == 10;
	}
}
/** @end */
