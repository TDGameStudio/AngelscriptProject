/**
 * @version v1
 * @summary Contains is true for a bool member that was added.
 * @topic Containers
 *
 * ContainsReportsMembershipBool
 */
/**
 * @begin ContainsReportsMembershipBool
 * @summary Contains is true for a bool member that was added.
 * @topic Containers
 */
bool ContainsReportsMembershipBool()
{
	TSet<bool> Values;
	Values.Add(true);
	Values.Add(false);
	return Values.Contains(false);
}
/** @end */
