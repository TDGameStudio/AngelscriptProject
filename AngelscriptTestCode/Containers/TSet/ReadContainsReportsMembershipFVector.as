/**
 * @version v1
 * @summary A const&in TSet<FVector> reports Contains for a present member.
 * @topic Containers
 *
 * ReadContainsReportsMembershipFVector
 */
/**
 * @begin ReadContainsReportsMembershipFVector
 * @summary A const&in TSet<FVector> reports Contains for a present member.
 * @topic Containers
 */
bool ReadContainsReportsMembershipFVector(const TSet<FVector>&in Values)
{
	return Values.Contains(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
