/**
 * @version v1
 * @summary An &inout TArray<FVector> has its first index deleted by RemoveAt.
 * @topic Containers
 *
 * MutateRemoveAtIndexFVector
 */
/**
 * @begin MutateRemoveAtIndexFVector
 * @summary An &inout TArray<FVector> has its first index deleted by RemoveAt.
 * @topic Containers
 */
void MutateRemoveAtIndexFVector(TArray<FVector>&inout Values)
{
	Values.RemoveAt(0);
}
/** @end */
