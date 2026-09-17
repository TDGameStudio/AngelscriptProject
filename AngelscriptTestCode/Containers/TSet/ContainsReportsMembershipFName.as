/**
 * @version v1
 * @summary Contains is true for an FName member that was added.
 * @topic Containers
 *
 * ContainsReportsMembershipFName
 */
/**
 * @begin ContainsReportsMembershipFName
 * @summary Contains is true for an FName member that was added.
 * @topic Containers
 */
bool ContainsReportsMembershipFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Add(n"Green");
	return Values.Contains(n"Green");
}
/** @end */
