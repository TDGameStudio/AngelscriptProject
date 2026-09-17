/**
 * @version v1
 * @summary An &inout TMap<FString, int> copies a value out and drops the pair.
 * @topic Containers
 *
 * MutateRemoveAndCopyValueFString
 */
/**
 * @begin MutateRemoveAndCopyValueFString
 * @summary An &inout TMap<FString, int> copies a value out and drops the pair.
 * @topic Containers
 */
void MutateRemoveAndCopyValueFString(TMap<FString, int>&inout Values)
{
	int OutValue = -1;
	Values.RemoveAndCopyValue("alpha", OutValue);
}
/** @end */
