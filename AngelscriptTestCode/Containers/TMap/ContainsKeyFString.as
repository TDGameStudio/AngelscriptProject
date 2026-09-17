/**
 * @version v1
 * @summary Contains is true for present FString keys after Add.
 * @topic Containers
 *
 * ContainsKeyFString
 */
/**
 * @begin ContainsKeyFString
 * @summary Contains is true for present FString keys after Add.
 * @topic Containers
 */
bool ContainsKeyFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Add("beta", 200);
	Map.Add("gamma", 300);
	return Map.Contains("alpha") && Map.Contains("beta") && Map.Contains("gamma");
}
/** @end */
