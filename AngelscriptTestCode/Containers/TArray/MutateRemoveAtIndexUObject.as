/**
 * @version v1
 * @summary An &inout TArray<UObject> has its first index deleted by RemoveAt.
 * @topic Containers
 *
 * MutateRemoveAtIndexUObject
 */
/**
 * @begin MutateRemoveAtIndexUObject
 * @summary An &inout TArray<UObject> has its first index deleted by RemoveAt.
 * @topic Containers
 */
void MutateRemoveAtIndexUObject(TArray<UObject>&inout Values)
{
	Values.RemoveAt(0);
}
/** @end */
