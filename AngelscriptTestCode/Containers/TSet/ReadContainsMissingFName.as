/**
 * @version v1
 * @summary A const&in TSet<FName> reports Contains false for an absent member.
 * @topic Containers
 *
 * ReadContainsMissingFName
 */
/**
 * @begin ReadContainsMissingFName
 * @summary A const&in TSet<FName> reports Contains false for an absent member.
 * @topic Containers
 */
bool ReadContainsMissingFName(const TSet<FName>&in Values)
{
	return !Values.Contains(n"Missing") && Values.Contains(n"Red");
}
/** @end */
