/**
 * @version v1
 * @summary Remove deletes a present FString key and returns false for a missing key.
 * @topic Containers
 *
 * RemoveKeyDropsPairFString
 */
/**
 * @begin RemoveKeyDropsPairFString
 * @summary Remove deletes a present FString key and returns false for a missing key.
 * @topic Containers
 */
bool RemoveKeyDropsPairFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Add("beta", 200);
	bool bRemoved = Map.Remove("alpha");
	bool bMissing = Map.Remove("missing");
	return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains("beta") && !Map.Contains("alpha");
}
/** @end */
