/**
 * @version v1
 * @summary A const&in TSet<int32> reports Contains false for an absent member.
 * @topic Containers
 *
 * ReadContainsMissing
 */
/**
 * @begin ReadContainsMissing
 * @summary A const&in TSet<int32> reports Contains false for an absent member.
 * @topic Containers
 */
bool ReadContainsMissing(const TSet<int32>&in Values)
{
	return !Values.Contains(99) && Values.Contains(10);
}
/** @end */
