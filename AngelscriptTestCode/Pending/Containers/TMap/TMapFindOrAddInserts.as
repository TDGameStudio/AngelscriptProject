/**
 * @version v1
 * @summary FindOrAdd of a missing key inserts a default and does not throw.
 * @topic Containers
 */
/**
 * @version root
 * @summary FindOrAdd of a missing key inserts a default and does not throw.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Observe FindOrAdd miss: the key is inserted with a default value.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs Empty TMap<int, int>; FindOrAdd(20)
	 * @Return true when Num() is 1, Contains(20), and the inserted value is 0
	 */
	UFUNCTION()
	bool FindOrAddMissingInsertsDefault()
	{
		TMap<int, int> Map;
		int Added = Map.FindOrAdd(20);
		return Added == 0 && Map.Num() == 1 && Map.Contains(20) && Map[20] == 0;
	}
}
/** @end */
