/**
 * @version v1
 * @summary A const&in TSet<bool> reports Contains for a present member.
 * @topic Containers
 *
 * ReadContainsReportsMembershipBool
 */
/**
 * @begin ReadContainsReportsMembershipBool
 * @summary A const&in TSet<bool> reports Contains for a present member.
 * @topic Containers
 */
bool ReadContainsReportsMembershipBool(const TSet<bool>&in Values)
{
	return Values.Contains(false);
}
/** @end */
