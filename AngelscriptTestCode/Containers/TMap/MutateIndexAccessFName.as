/**
 * @version v1
 * @summary An &inout TMap<FName, int> writes an existing key through bracket access.
 * @topic Containers
 *
 * MutateIndexAccessFName
 */
/**
 * @begin MutateIndexAccessFName
 * @summary An &inout TMap<FName, int> writes an existing key through bracket access.
 * @topic Containers
 */
void MutateIndexAccessFName(TMap<FName, int>&inout Values)
{
	Values[n"Red"] = 9;
}
/** @end */
