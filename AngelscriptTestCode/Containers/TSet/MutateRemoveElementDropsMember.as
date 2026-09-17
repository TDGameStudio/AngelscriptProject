/**
 * @version v1
 * @summary An &inout TSet<int32> receives Remove of a present member.
 * @topic Containers
 *
 * MutateRemoveElementDropsMember
 */
/**
 * @begin MutateRemoveElementDropsMember
 * @summary An &inout TSet<int32> receives Remove of a present member.
 * @topic Containers
 */
void MutateRemoveElementDropsMember(TSet<int32>&inout Values)
{
	Values.Remove(1);
}
/** @end */
