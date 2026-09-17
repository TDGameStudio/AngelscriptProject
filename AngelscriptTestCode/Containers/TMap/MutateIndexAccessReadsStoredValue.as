/**
 * @version v1
 * @summary An &inout TMap<int, int> writes an existing key through bracket access.
 * @topic Containers
 *
 * MutateIndexAccessReadsStoredValue
 */
/**
 * @begin MutateIndexAccessReadsStoredValue
 * @summary An &inout TMap<int, int> writes an existing key through bracket access.
 * @topic Containers
 */
void MutateIndexAccessReadsStoredValue(TMap<int, int>&inout Values)
{
	Values[10] = 999;
}
/** @end */
