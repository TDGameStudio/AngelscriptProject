/**
 * @version v1
 * @summary Add of the same key twice keeps Num and stores the last value.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add of the same key twice keeps Num and stores the last value.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Observe Add overwrite: the second Add replaces the value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs TMap<int, int> Add(10, 100); Add(10, 999)
	 * @Return true when Num() is 1 and [10] is 999
	 */
	UFUNCTION()
	bool AddSameKeyKeepsLastValue()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		if (Map.Num() != 1 || Map[10] != 100)
		{
			return false;
		}

		Map.Add(10, 999);
		return Map.Num() == 1 && Map.Contains(10) && Map[10] == 999;
	}
}
/** @end */
