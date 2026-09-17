/**
 * @version v1
 * @summary An &inout TMap<int, bool> overwrites an existing key by Add.
 * @topic Containers
 *
 * MutateAddOverwriteReplacesValueBool
 */
/**
 * @begin MutateAddOverwriteReplacesValueBool
 * @summary An &inout TMap<int, bool> overwrites an existing key by Add.
 * @topic Containers
 */
void MutateAddOverwriteReplacesValueBool(TMap<int, bool>&inout Values)
{
	Values.Add(1, false);
}
/** @end */
