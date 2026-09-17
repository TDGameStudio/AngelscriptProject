/**
 * @version v1
 * @summary An &inout TArray<FVector> Adds one value so Contains can see a new member.
 * @topic Containers
 *
 * MutateContainsReportsMembershipFVector
 */
/**
 * @begin MutateContainsReportsMembershipFVector
 * @summary An &inout TArray<FVector> Adds one value so Contains can see a new member.
 * @topic Containers
 */
void MutateContainsReportsMembershipFVector(TArray<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
