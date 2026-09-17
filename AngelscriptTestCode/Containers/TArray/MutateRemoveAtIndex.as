/**
 * @version v1
 * @summary An &inout TArray<int32> has its first index deleted by RemoveAt.
 * @topic Containers
 *
 * MutateRemoveAtIndex
 */
/**
 * @begin MutateRemoveAtIndex
 * @summary An &inout TArray<int32> has its first index deleted by RemoveAt.
 * @topic Containers
 */
void MutateRemoveAtIndex(TArray<int32>&inout Values)
{
	Values.RemoveAt(0);
}
/** @end */
