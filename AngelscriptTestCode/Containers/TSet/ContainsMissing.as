/**
 * @version v1
 * @summary Contains is false for a member that was never added.
 * @topic Containers
 *
 * ContainsMissing
 */
/**
 * @begin ContainsMissing
 * @summary Contains is false for a member that was never added.
 * @topic Containers
 */
bool ContainsMissing()
{
	TSet<int> Values;
	Values.Add(10);
	return !Values.Contains(99) && Values.Contains(10);
}
/** @end */
