/**
 * @version v1
 * @summary An &inout TSet<int32> receives Remove of an absent member.
 * @topic Containers
 *
 * MutateRemoveMissing
 */
/**
 * @begin MutateRemoveMissing
 * @summary An &inout TSet<int32> receives Remove of an absent member.
 * @topic Containers
 */
void MutateRemoveMissing(TSet<int32>&inout Values)
{
	Values.Remove(99);
}
/** @end */
