/**
 * @version v1
 * @summary Contains is false for a key that was never added.
 * @topic Containers
 *
 * ContainsMissing
 */
/**
 * @begin ContainsMissing
 * @summary Contains is false for a key that was never added.
 * @topic Containers
 */
bool ContainsMissing()
{
	TMap<int, int> Map;
	Map.Add(10, 100);
	return !Map.Contains(99) && Map.Contains(10);
}
/** @end */
