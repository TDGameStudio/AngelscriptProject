/**
 * @version v1
 * @summary Copy writes one source element into a dest that already has room.
 * @topic Containers
 */
/**
 * @version root
 * @summary Copy writes one source element into a dest that already has room.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe a one-element Copy into dest slots that already exist.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Dest [0]; Source [10]; Copy(Source, 0, 1, 0)
	 * @Return true when Dest is [10] and Num stays 1
	 */
	UFUNCTION()
	bool CopyOneElementIntoExistingSlot()
	{
		TArray<int> Dest;
		Dest.Add(0);
		TArray<int> Source;
		Source.Add(10);
		Dest.Copy(Source, 0, 1, 0);
		if (Dest.Num() != 1)
		{
			return false;
		}
		return Dest[0] == 10;
	}
}
/** @end */
