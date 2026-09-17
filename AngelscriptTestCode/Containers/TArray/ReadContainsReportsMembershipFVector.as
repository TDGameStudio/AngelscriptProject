/**
 * @version v1
 * @summary A const&in TArray<FVector> reports Contains for present and absent values.
 * @topic Containers
 *
 * ReadContainsReportsMembershipFVector
 */
/**
 * @begin ReadContainsReportsMembershipFVector
 * @summary A const&in TArray<FVector> reports Contains for present and absent values.
 * @topic Containers
 */
bool ReadContainsReportsMembershipFVector(const TArray<FVector>&in Values)
{
	return Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 0.0f, 1.0f))
		&& !Values.Contains(FVector(1.0f, 1.0f, 1.0f));
}
/** @end */
