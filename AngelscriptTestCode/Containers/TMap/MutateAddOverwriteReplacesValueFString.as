/**
 * @version v1
 * @summary An &inout TMap<FString, int> overwrites an existing key by Add.
 * @topic Containers
 *
 * MutateAddOverwriteReplacesValueFString
 */
/**
 * @begin MutateAddOverwriteReplacesValueFString
 * @summary An &inout TMap<FString, int> overwrites an existing key by Add.
 * @topic Containers
 */
void MutateAddOverwriteReplacesValueFString(TMap<FString, int>&inout Values)
{
	Values.Add("alpha", 999);
}
/** @end */
