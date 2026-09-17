/**
 * @version v1
 * @summary An &inout TMap<int, int> overwrites an existing key by Add.
 * @topic Containers
 *
 * MutateAddOverwriteReplacesValue
 */
/**
 * @begin MutateAddOverwriteReplacesValue
 * @summary An &inout TMap<int, int> overwrites an existing key by Add.
 * @topic Containers
 */
void MutateAddOverwriteReplacesValue(TMap<int, int>&inout Values)
{
	Values.Add(10, 999);
}
/** @end */
