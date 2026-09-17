/**
 * @version v1
 * @summary Contains is false for a key that was never added.
 * @topic Containers
 */
/**
 * @version root
 * @summary Contains is false for a key that was never added.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Observe Contains miss after Add of a different key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs TMap<int, int> with Add(10, 100); Contains(99)
	 * @Return true when Contains(99) is false and Contains(10) is true
	 */
	UFUNCTION()
	bool ContainsMissingKeyIsFalse()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		return !Map.Contains(99) && Map.Contains(10);
	}
}
/** @end */
