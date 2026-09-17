/**
 * @version v1
 * @summary An &inout TArray<bool> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 *
 * MutateRemoveAtSwapBool
 */
/**
 * @begin MutateRemoveAtSwapBool
 * @summary An &inout TArray<bool> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 */
void MutateRemoveAtSwapBool(TArray<bool>&inout Values)
{
	Values.RemoveAtSwap(0);
}
/** @end */
