/**
 * @version v1
 * @summary An &inout TSet<bool> receives Remove of an absent member.
 * @topic Containers
 *
 * MutateRemoveMissingBool
 */
/**
 * @begin MutateRemoveMissingBool
 * @summary An &inout TSet<bool> receives Remove of an absent member.
 * @topic Containers
 */
void MutateRemoveMissingBool(TSet<bool>&inout Values)
{
	Values.Remove(false);
}
/** @end */
