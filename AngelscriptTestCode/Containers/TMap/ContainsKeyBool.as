/**
 * @version v1
 * @summary Contains is true for present int keys in a TMap of bool values.
 * @topic Containers
 *
 * ContainsKeyBool
 */
/**
 * @begin ContainsKeyBool
 * @summary Contains is true for present int keys in a TMap of bool values.
 * @topic Containers
 */
bool ContainsKeyBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Add(2, false);
	Map.Add(3, true);
	return Map.Contains(1) && Map.Contains(2) && Map.Contains(3);
}
/** @end */
