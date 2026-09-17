/**
 * @version v1
 * @summary An &inout TArray<bool> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 *
 * MutateRemoveSinglePreservesOrderBool
 */
/**
 * @begin MutateRemoveSinglePreservesOrderBool
 * @summary An &inout TArray<bool> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 */
void MutateRemoveSinglePreservesOrderBool(TArray<bool>&inout Values)
{
	Values.RemoveSingle(false);
}
/** @end */
