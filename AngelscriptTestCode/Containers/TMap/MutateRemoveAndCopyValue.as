/**
 * @version v1
 * @summary An &inout TMap<int, int> copies a value out and drops the pair.
 * @topic Containers
 *
 * MutateRemoveAndCopyValue
 */
/**
 * @begin MutateRemoveAndCopyValue
 * @summary An &inout TMap<int, int> copies a value out and drops the pair.
 * @topic Containers
 */
void MutateRemoveAndCopyValue(TMap<int, int>&inout Values)
{
	int OutValue = -1;
	Values.RemoveAndCopyValue(10, OutValue);
}
/** @end */
