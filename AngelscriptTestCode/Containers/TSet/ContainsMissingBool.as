/**
 * @version v1
 * @summary Contains is false for a bool member that was never added.
 * @topic Containers
 *
 * ContainsMissingBool
 */
/**
 * @begin ContainsMissingBool
 * @summary Contains is false for a bool member that was never added.
 * @topic Containers
 */
bool ContainsMissingBool()
{
	TSet<bool> Values;
	Values.Add(true);
	return !Values.Contains(false) && Values.Contains(true);
}
/** @end */
