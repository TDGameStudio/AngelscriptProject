/**
 * @version v1
 * @summary An &inout TMap<FName, int> Removes one present key in place.
 * @topic Containers
 *
 * MutateRemoveKeyDropsPairFName
 */
/**
 * @begin MutateRemoveKeyDropsPairFName
 * @summary An &inout TMap<FName, int> Removes one present key in place.
 * @topic Containers
 */
void MutateRemoveKeyDropsPairFName(TMap<FName, int>&inout Values)
{
	Values.Remove(n"Green");
}
/** @end */
