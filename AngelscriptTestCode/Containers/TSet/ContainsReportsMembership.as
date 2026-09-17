/**
 * @version v1
 * @summary Contains is true for a member that was added.
 * @topic Containers
 *
 * ContainsReportsMembership
 */
/**
 * @begin ContainsReportsMembership
 * @summary Contains is true for a member that was added.
 * @topic Containers
 */
bool ContainsReportsMembership()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	return Values.Contains(2);
}
/** @end */
