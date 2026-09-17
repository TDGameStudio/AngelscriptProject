/**
 * @version v1
 * @summary A const&in TArray<float> reports Contains for present and absent values.
 * @topic Containers
 *
 * ReadContainsReportsMembershipFloat
 */
/**
 * @begin ReadContainsReportsMembershipFloat
 * @summary A const&in TArray<float> reports Contains for present and absent values.
 * @topic Containers
 */
bool ReadContainsReportsMembershipFloat(const TArray<float>&in Values)
{
	return Values.Contains(10.0f) && Values.Contains(20.0f) && Values.Contains(30.0f) && !Values.Contains(99.0f);
}
/** @end */
