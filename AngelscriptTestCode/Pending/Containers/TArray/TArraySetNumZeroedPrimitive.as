/**
 * @version v1
 * @summary SetNumZeroed on TArray<int> grows and writes zeros into the new slots.
 * @topic Containers
 */
/**
 * @version root
 * @summary SetNumZeroed on TArray<int> grows and writes zeros into the new slots.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe SetNumZeroed on a primitive array: added slots are 0.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNumZeroed
	 * @Inputs Empty TArray<int>; SetNumZeroed(2)
	 * @Return true when Num is 2 and both slots are 0
	 */
	UFUNCTION()
	bool SetNumZeroedZerosPrimitiveSlots()
	{
		TArray<int> Values;
		Values.SetNumZeroed(2);
		if (Values.Num() != 2)
		{
			return false;
		}
		if (Values[0] != 0)
		{
			return false;
		}
		return Values[1] == 0;
	}
}
/** @end */
