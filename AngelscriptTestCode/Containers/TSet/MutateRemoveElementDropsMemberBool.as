/**
 * @version v1
 * @summary An &inout TSet<bool> receives Remove of a present member.
 * @topic Containers
 *
 * MutateRemoveElementDropsMemberBool
 */
/**
 * @begin MutateRemoveElementDropsMemberBool
 * @summary An &inout TSet<bool> receives Remove of a present member.
 * @topic Containers
 */
void MutateRemoveElementDropsMemberBool(TSet<bool>&inout Values)
{
	Values.Remove(true);
}
/** @end */
