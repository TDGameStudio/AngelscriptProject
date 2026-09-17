/**
 * @version v1
 * @summary An &inout TMap<FName, int> overwrites an existing key by Add.
 * @topic Containers
 *
 * MutateAddOverwriteReplacesValueFName
 */
/**
 * @begin MutateAddOverwriteReplacesValueFName
 * @summary An &inout TMap<FName, int> overwrites an existing key by Add.
 * @topic Containers
 */
void MutateAddOverwriteReplacesValueFName(TMap<FName, int>&inout Values)
{
	Values.Add(n"Red", 9);
}
/** @end */
