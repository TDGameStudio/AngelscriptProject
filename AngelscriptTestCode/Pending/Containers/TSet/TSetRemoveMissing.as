/**
 * @version v1
 * @summary Remove of an absent member returns false and does not throw.
 * @topic Containers
 */
/**
 * @version root
 * @summary Remove of an absent member returns false and does not throw.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Observe Remove miss: an absent member is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Inputs TSet<int> with Add(10); Remove(99)
	 * @Return true when Remove(99) is false and Num() stays 1
	 */
	UFUNCTION()
	bool RemoveMissingReturnsFalse()
	{
		TSet<int> Values;
		Values.Add(10);
		return !Values.Remove(99) && Values.Num() == 1 && Values.Contains(10);
	}
}
/** @end */
