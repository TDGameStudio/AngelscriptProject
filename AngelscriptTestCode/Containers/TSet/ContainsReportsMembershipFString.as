/**
 * @version v1
 * @summary Contains is true for an FString member that was added.
 * @topic Containers
 *
 * ContainsReportsMembershipFString
 */
/**
 * @begin ContainsReportsMembershipFString
 * @summary Contains is true for an FString member that was added.
 * @topic Containers
 */
bool ContainsReportsMembershipFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	return Values.Contains("beta");
}
/** @end */
