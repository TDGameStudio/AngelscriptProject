/**
 * @version v1
 * @summary Contains is true for an FVector member that was added.
 * @topic Containers
 *
 * ContainsReportsMembershipFVector
 */
/**
 * @begin ContainsReportsMembershipFVector
 * @summary Contains is true for an FVector member that was added.
 * @topic Containers
 */
bool ContainsReportsMembershipFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	return Values.Contains(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
