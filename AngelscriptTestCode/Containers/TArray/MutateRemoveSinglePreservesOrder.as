/**
 * @version v1
 * @summary An &inout TArray<int32> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 *
 * MutateRemoveSinglePreservesOrder
 */
/**
 * @begin MutateRemoveSinglePreservesOrder
 * @summary An &inout TArray<int32> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 */
void MutateRemoveSinglePreservesOrder(TArray<int32>&inout Values)
{
	Values.RemoveSingle(2);
}
/** @end */
