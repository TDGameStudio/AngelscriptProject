/**
 * @version v1
 * @summary Copy throws "Count should not be negative." when Count is less than 0.
 * @topic Containers
 */
/**
 * @version root
 * @summary Copy throws "Count should not be negative." when Count is less than 0.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Copy with a negative Count throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Source [10]; Dest [0]; Copy(Source, 0, -1, 0)
	 * @Return void; throws "Count should not be negative."
	 * @Boundary Count < 0
	 */
	UFUNCTION()
	void CopyNegativeCount()
	{
		TArray<int> Source;
		Source.Add(10);
		TArray<int> Dest;
		Dest.Add(0);
		Dest.Copy(Source, 0, -1, 0);
	}
}
/** @end */
