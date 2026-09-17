/**
 * @version v1
 * @summary An &inout TArray<int32> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 *
 * MutateRemoveAtSwap
 */
/**
 * @begin MutateRemoveAtSwap
 * @summary An &inout TArray<int32> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 */
void MutateRemoveAtSwap(TArray<int32>&inout Values)
{
	Values.RemoveAtSwap(0);
}
/** @end */
