/**
 * @version v1
 * @summary An &inout TArray<float> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 *
 * MutateRemoveAtSwapFloat
 */
/**
 * @begin MutateRemoveAtSwapFloat
 * @summary An &inout TArray<float> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 */
void MutateRemoveAtSwapFloat(TArray<float>&inout Values)
{
	Values.RemoveAtSwap(0);
}
/** @end */
