/**
 * @version v1
 * @summary A const&in TArray<FString> reports Contains for present and absent values.
 * @topic Containers
 *
 * ReadContainsReportsMembershipFString
 */
/**
 * @begin ReadContainsReportsMembershipFString
 * @summary A const&in TArray<FString> reports Contains for present and absent values.
 * @topic Containers
 */
bool ReadContainsReportsMembershipFString(const TArray<FString>&in Values)
{
	return Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma") && !Values.Contains("omega");
}
/** @end */
