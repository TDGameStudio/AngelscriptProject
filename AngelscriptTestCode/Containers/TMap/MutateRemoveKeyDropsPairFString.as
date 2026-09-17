/**
 * @version v1
 * @summary An &inout TMap<FString, int> Removes one present key in place.
 * @topic Containers
 *
 * MutateRemoveKeyDropsPairFString
 */
/**
 * @begin MutateRemoveKeyDropsPairFString
 * @summary An &inout TMap<FString, int> Removes one present key in place.
 * @topic Containers
 */
void MutateRemoveKeyDropsPairFString(TMap<FString, int>&inout Values)
{
	Values.Remove("beta");
}
/** @end */
