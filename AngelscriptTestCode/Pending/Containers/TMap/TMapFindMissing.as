/**
 * @version v1
 * @summary Find of an absent key returns false and does not throw.
 * @topic Containers
 */
/**
 * @version root
 * @summary Find of an absent key returns false and does not throw.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Observe Find miss: an absent key does not copy a value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<int, int> with Add(10, 100); Find(99, Out)
	 * @Return true when Find(99) is false and Out stays 0
	 */
	UFUNCTION()
	bool FindMissingReturnsFalse()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		int Miss = 0;
		return !Map.Find(99, Miss) && Miss == 0 && Map.Num() == 1;
	}
}
/** @end */
