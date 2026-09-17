/**
 * @version v1
 * @summary Contains is true for a present FString and false for a missing one.
 * @topic Containers
 *
 * ContainsReportsMembershipFString
 */
/**
 * @begin ContainsReportsMembershipFString
 * @summary Contains is true for a present FString and false for a missing one.
 * @topic Containers
 */
bool ContainsReportsMembershipFString()
{
	TArray<FString> Empty;
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	return !Empty.Contains("alpha") && Values.Contains("beta") && !Values.Contains("omega");
}
/** @end */
