/**
 * @version v1
 * @summary Contains is true for a present bool and false on an empty array.
 * @topic Containers
 *
 * ContainsReportsMembershipBool
 */
/**
 * @begin ContainsReportsMembershipBool
 * @summary Contains is true for a present bool and false on an empty array.
 * @topic Containers
 */
bool ContainsReportsMembershipBool()
{
	TArray<bool> Empty;
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Add(false);
	return !Empty.Contains(true) && Values.Contains(false) && Values.Contains(true);
}
/** @end */
