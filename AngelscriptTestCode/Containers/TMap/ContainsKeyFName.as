/**
 * @version v1
 * @summary Contains is true for present FName keys after Add.
 * @topic Containers
 *
 * ContainsKeyFName
 */
/**
 * @begin ContainsKeyFName
 * @summary Contains is true for present FName keys after Add.
 * @topic Containers
 */
bool ContainsKeyFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Add(n"Green", 2);
	Map.Add(n"Blue", 3);
	return Map.Contains(n"Red") && Map.Contains(n"Green") && Map.Contains(n"Blue");
}
/** @end */
