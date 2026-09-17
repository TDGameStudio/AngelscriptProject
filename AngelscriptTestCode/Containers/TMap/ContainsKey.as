/**
 * @version v1
 * @summary Contains is true for present int keys after Add.
 * @topic Containers
 *
 * ContainsKey
 */
/**
 * @begin ContainsKey
 * @summary Contains is true for present int keys after Add.
 * @topic Containers
 */
bool ContainsKey()
{
	TMap<int, int> Map;
	Map.Add(10, 100);
	Map.Add(20, 200);
	Map.Add(30, 300);
	return Map.Contains(10) && Map.Contains(20) && Map.Contains(30);
}
/** @end */
