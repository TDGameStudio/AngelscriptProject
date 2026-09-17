/**
 * @version v1
 * @summary Contains is true for a present FVector and false for a missing one.
 * @topic Containers
 *
 * ContainsReportsMembershipFVector
 */
/**
 * @begin ContainsReportsMembershipFVector
 * @summary Contains is true for a present FVector and false for a missing one.
 * @topic Containers
 */
bool ContainsReportsMembershipFVector()
{
	TArray<FVector> Empty;
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	return !Empty.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& !Values.Contains(FVector(1.0f, 1.0f, 1.0f));
}
/** @end */
