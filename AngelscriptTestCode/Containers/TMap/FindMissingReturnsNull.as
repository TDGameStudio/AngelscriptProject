/**
 * @version v1
 * @summary Find of an absent key returns false and does not throw.
 * @topic Containers
 *
 * FindMissingReturnsNull
 */
/**
 * @begin FindMissingReturnsNull
 * @summary Find of an absent key returns false and does not throw.
 * @topic Containers
 */
bool FindMissingReturnsNull()
{
	TMap<int, int> Map;
	Map.Add(10, 100);
	int Miss = 0;
	return !Map.Find(99, Miss) && Miss == 0 && Map.Num() == 1;
}
/** @end */
