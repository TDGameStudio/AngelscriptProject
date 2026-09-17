/**
 * @version v1
 * @summary A const&in TSet<FString> reports Contains for a present member.
 * @topic Containers
 *
 * ReadContainsReportsMembershipFString
 */
/**
 * @begin ReadContainsReportsMembershipFString
 * @summary A const&in TSet<FString> reports Contains for a present member.
 * @topic Containers
 */
bool ReadContainsReportsMembershipFString(const TSet<FString>&in Values)
{
	return Values.Contains("beta");
}
/** @end */
