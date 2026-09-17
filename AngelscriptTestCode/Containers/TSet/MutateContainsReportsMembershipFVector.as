/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Add so Contains becomes true.
 * @topic Containers
 *
 * MutateContainsReportsMembershipFVector
 */
/**
 * @begin MutateContainsReportsMembershipFVector
 * @summary An &inout TSet<FVector> receives Add so Contains becomes true.
 * @topic Containers
 */
void MutateContainsReportsMembershipFVector(TSet<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
