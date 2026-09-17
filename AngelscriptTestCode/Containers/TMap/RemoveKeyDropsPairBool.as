/**
 * @version v1
 * @summary Remove deletes a present int key from a bool map and returns false for a missing key.
 * @topic Containers
 *
 * RemoveKeyDropsPairBool
 */
/**
 * @begin RemoveKeyDropsPairBool
 * @summary Remove deletes a present int key from a bool map and returns false for a missing key.
 * @topic Containers
 */
bool RemoveKeyDropsPairBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Add(2, false);
	bool bRemoved = Map.Remove(1);
	bool bMissing = Map.Remove(99);
	return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains(2) && !Map.Contains(1);
}
/** @end */
