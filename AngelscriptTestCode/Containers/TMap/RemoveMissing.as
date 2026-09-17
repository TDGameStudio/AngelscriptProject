/**
 * @version v1
 * @summary Remove of an absent key returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissing
 */
/**
 * @begin RemoveMissing
 * @summary Remove of an absent key returns false and does not throw.
 * @topic Containers
 */
bool RemoveMissing()
{
	TMap<int, int> Map;
	Map.Add(10, 100);
	return !Map.Remove(99) && Map.Num() == 1 && Map.Contains(10);
}
/** @end */
