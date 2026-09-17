/**
 * @version v1
 * @summary Remove deletes a present FName key and returns false for a missing key.
 * @topic Containers
 *
 * RemoveKeyDropsPairFName
 */
/**
 * @begin RemoveKeyDropsPairFName
 * @summary Remove deletes a present FName key and returns false for a missing key.
 * @topic Containers
 */
bool RemoveKeyDropsPairFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Add(n"Green", 2);
	bool bRemoved = Map.Remove(n"Red");
	bool bMissing = Map.Remove(n"Missing");
	return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains(n"Green") && !Map.Contains(n"Red");
}
/** @end */
