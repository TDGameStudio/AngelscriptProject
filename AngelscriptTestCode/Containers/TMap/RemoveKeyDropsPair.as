/**
 * @version v1
 * @summary Remove deletes a present key and returns false for a missing key.
 * @topic Containers
 *
 * RemoveKeyDropsPair
 */
/**
 * @begin RemoveKeyDropsPair
 * @summary Remove deletes a present key and returns false for a missing key.
 * @topic Containers
 */
bool RemoveKeyDropsPair()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	bool bRemoved = Map.Remove(n"Alpha");
	bool bMissing = Map.Remove(n"Gamma");
	return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains(n"Beta") && !Map.Contains(n"Alpha");
}
/** @end */
