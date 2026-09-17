/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Remove of a present member.
 * @topic Containers
 *
 * MutateRemoveElementDropsMemberUObject
 */
/**
 * @begin MutateRemoveElementDropsMemberUObject
 * @summary An &inout TSet<UObject> receives Remove of a present member.
 * @topic Containers
 */
void MutateRemoveElementDropsMemberUObject(TSet<UObject>&inout Values)
{
	UObject Drop = nullptr;
	for (UObject Item : Values)
	{
		Drop = Item;
		break;
	}
	Values.Remove(Drop);
}
/** @end */
