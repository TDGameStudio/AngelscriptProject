/**
 * @version v1
 * @summary An &inout TArray<FVector> has every matching element deleted by RemoveSwap.
 * @topic Containers
 *
 * MutateRemoveSwapFVector
 */
/**
 * @begin MutateRemoveSwapFVector
 * @summary An &inout TArray<FVector> has every matching element deleted by RemoveSwap.
 * @topic Containers
 */
void MutateRemoveSwapFVector(TArray<FVector>&inout Values)
{
	Values.RemoveSwap(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
