/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Add of a new member.
 * @topic Containers
 *
 * MutateAddElementIsContainedFVector
 */
/**
 * @begin MutateAddElementIsContainedFVector
 * @summary An &inout TSet<FVector> receives Add of a new member.
 * @topic Containers
 */
void MutateAddElementIsContainedFVector(TSet<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
