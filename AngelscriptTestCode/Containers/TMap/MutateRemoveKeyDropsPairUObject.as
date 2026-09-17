/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Removes one present key in place.
 * @topic Containers
 *
 * MutateRemoveKeyDropsPairUObject
 */
/**
 * @begin MutateRemoveKeyDropsPairUObject
 * @summary An &inout TMap<int, UObject> Removes one present key in place.
 * @topic Containers
 */
void MutateRemoveKeyDropsPairUObject(TMap<int, UObject>&inout Values)
{
	Values.Remove(20);
}
/** @end */
