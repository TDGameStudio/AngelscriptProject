/**
 * @version v1
 * @summary An &inout TMap<int, bool> copies a value out and drops the pair.
 * @topic Containers
 *
 * MutateRemoveAndCopyValueBool
 */
/**
 * @begin MutateRemoveAndCopyValueBool
 * @summary An &inout TMap<int, bool> copies a value out and drops the pair.
 * @topic Containers
 */
void MutateRemoveAndCopyValueBool(TMap<int, bool>&inout Values)
{
	bool OutValue = false;
	Values.RemoveAndCopyValue(1, OutValue);
}
/** @end */
