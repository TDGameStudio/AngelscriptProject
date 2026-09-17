/**
 * @version v1
 * @summary An &inout TArray<bool> has its first index deleted by RemoveAt.
 * @topic Containers
 *
 * MutateRemoveAtIndexBool
 */
/**
 * @begin MutateRemoveAtIndexBool
 * @summary An &inout TArray<bool> has its first index deleted by RemoveAt.
 * @topic Containers
 */
void MutateRemoveAtIndexBool(TArray<bool>&inout Values)
{
	Values.RemoveAt(0);
}
/** @end */
