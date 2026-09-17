/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Remove of an absent member.
 * @topic Containers
 *
 * MutateRemoveMissingFVector
 */
/**
 * @begin MutateRemoveMissingFVector
 * @summary An &inout TSet<FVector> receives Remove of an absent member.
 * @topic Containers
 */
void MutateRemoveMissingFVector(TSet<FVector>&inout Values)
{
	Values.Remove(FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
