/**
 * @version v1
 * @summary Remove of an absent key returns false and does not throw.
 * @topic Containers
 */
/**
 * @version root
 * @summary Remove of an absent key returns false and does not throw.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Observe Remove miss: an absent key is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<int, int> with Add(10, 100); Remove(99)
	 * @Return true when Remove(99) is false and Num() stays 1
	 */
	UFUNCTION()
	bool RemoveMissingKeyReturnsFalse()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		return !Map.Remove(99) && Map.Num() == 1 && Map.Contains(10);
	}
}
/** @end */
