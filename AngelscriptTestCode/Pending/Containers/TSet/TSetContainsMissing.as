/**
 * @version v1
 * @summary Contains is false for a member that was never added.
 * @topic Containers
 */
/**
 * @version root
 * @summary Contains is false for a member that was never added.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Observe Contains miss after Add of a different member.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs TSet<int> with Add(10); Contains(99)
	 * @Return true when Contains(99) is false and Contains(10) is true
	 */
	UFUNCTION()
	bool ContainsMissingIsFalse()
	{
		TSet<int> Values;
		Values.Add(10);
		return !Values.Contains(99) && Values.Contains(10);
	}
}
/** @end */
