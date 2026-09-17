/**
 * @version v1
 * @summary An &inout TSet<UObject> receives a duplicate Add of an existing handle.
 * @topic Containers
 *
 * MutateAddDuplicateIgnoredUObject
 */
/**
 * @begin MutateAddDuplicateIgnoredUObject
 * @summary An &inout TSet<UObject> receives a duplicate Add of an existing handle.
 * @topic Containers
 */
void MutateAddDuplicateIgnoredUObject(TSet<UObject>&inout Values)
{
	UObject First = nullptr;
	for (UObject Item : Values)
	{
		First = Item;
		break;
	}
	Values.Add(First);
}
/** @end */
