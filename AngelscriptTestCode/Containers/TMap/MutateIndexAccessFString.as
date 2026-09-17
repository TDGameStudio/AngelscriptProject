/**
 * @version v1
 * @summary An &inout TMap<FString, int> writes an existing key through bracket access.
 * @topic Containers
 *
 * MutateIndexAccessFString
 */
/**
 * @begin MutateIndexAccessFString
 * @summary An &inout TMap<FString, int> writes an existing key through bracket access.
 * @topic Containers
 */
void MutateIndexAccessFString(TMap<FString, int>&inout Values)
{
	Values["alpha"] = 999;
}
/** @end */
