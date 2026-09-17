/**
 * @version v1
 * @summary Contains is true for a present float and false for a missing one.
 * @topic Containers
 *
 * ContainsReportsMembershipFloat
 */
/**
 * @begin ContainsReportsMembershipFloat
 * @summary Contains is true for a present float and false for a missing one.
 * @topic Containers
 */
bool ContainsReportsMembershipFloat()
{
	TArray<float> Empty;
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	Values.Add(30.0f);
	return !Empty.Contains(10.0f) && Values.Contains(20.0f) && !Values.Contains(99.0f);
}
/** @end */
