/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Remove of a present member.
 * @topic Containers
 *
 * MutateRemoveElementDropsMemberFVector
 */
/**
 * @begin MutateRemoveElementDropsMemberFVector
 * @summary An &inout TSet<FVector> receives Remove of a present member.
 * @topic Containers
 */
void MutateRemoveElementDropsMemberFVector(TSet<FVector>&inout Values)
{
	Values.Remove(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
