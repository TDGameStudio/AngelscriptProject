/**
 * @version v1
 * @summary An &inout TMap<int, UObject> copies a handle out and drops the pair.
 * @topic Containers
 *
 * MutateRemoveAndCopyValueUObject
 */
/**
 * @begin MutateRemoveAndCopyValueUObject
 * @summary An &inout TMap<int, UObject> copies a handle out and drops the pair.
 * @topic Containers
 */
void MutateRemoveAndCopyValueUObject(TMap<int, UObject>&inout Values)
{
	UObject OutValue = nullptr;
	Values.RemoveAndCopyValue(10, OutValue);
}
/** @end */
