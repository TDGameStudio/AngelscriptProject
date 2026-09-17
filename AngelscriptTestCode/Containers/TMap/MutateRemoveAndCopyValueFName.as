/**
 * @version v1
 * @summary An &inout TMap<FName, int> copies a value out and drops the pair.
 * @topic Containers
 *
 * MutateRemoveAndCopyValueFName
 */
/**
 * @begin MutateRemoveAndCopyValueFName
 * @summary An &inout TMap<FName, int> copies a value out and drops the pair.
 * @topic Containers
 */
void MutateRemoveAndCopyValueFName(TMap<FName, int>&inout Values)
{
	int OutValue = -1;
	Values.RemoveAndCopyValue(n"Red", OutValue);
}
/** @end */
