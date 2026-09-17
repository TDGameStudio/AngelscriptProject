/**
 * @version v1
 * @summary A const&in TSet<FName> reports Contains for a present member.
 * @topic Containers
 *
 * ReadContainsReportsMembershipFName
 */
/**
 * @begin ReadContainsReportsMembershipFName
 * @summary A const&in TSet<FName> reports Contains for a present member.
 * @topic Containers
 */
bool ReadContainsReportsMembershipFName(const TSet<FName>&in Values)
{
	return Values.Contains(n"Green");
}
/** @end */
