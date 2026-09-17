/**
 * @version v1
 * @summary An &inout TArray<FVector> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 *
 * MutateRemoveAtSwapFVector
 */
/**
 * @begin MutateRemoveAtSwapFVector
 * @summary An &inout TArray<FVector> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 */
void MutateRemoveAtSwapFVector(TArray<FVector>&inout Values)
{
	Values.RemoveAtSwap(0);
}
/** @end */
