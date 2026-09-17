/**
 * @version v1
 * @summary Contains is false for an FName member that was never added.
 * @topic Containers
 *
 * ContainsMissingFName
 */
/**
 * @begin ContainsMissingFName
 * @summary Contains is false for an FName member that was never added.
 * @topic Containers
 */
bool ContainsMissingFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	return !Values.Contains(n"Missing") && Values.Contains(n"Red");
}
/** @end */
