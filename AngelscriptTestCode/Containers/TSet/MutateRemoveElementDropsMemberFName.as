/**
 * @version v1
 * @summary An &inout TSet<FName> receives Remove of a present member.
 * @topic Containers
 *
 * MutateRemoveElementDropsMemberFName
 */
/**
 * @begin MutateRemoveElementDropsMemberFName
 * @summary An &inout TSet<FName> receives Remove of a present member.
 * @topic Containers
 */
void MutateRemoveElementDropsMemberFName(TSet<FName>&inout Values)
{
	Values.Remove(n"Red");
}
/** @end */
