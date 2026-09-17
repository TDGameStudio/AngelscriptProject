/**
 * @version v1
 * @summary A const&in TSet<bool> reports Contains false for an absent member.
 * @topic Containers
 *
 * ReadContainsMissingBool
 */
/**
 * @begin ReadContainsMissingBool
 * @summary A const&in TSet<bool> reports Contains false for an absent member.
 * @topic Containers
 */
bool ReadContainsMissingBool(const TSet<bool>&in Values)
{
	return !Values.Contains(false) && Values.Contains(true);
}
/** @end */
