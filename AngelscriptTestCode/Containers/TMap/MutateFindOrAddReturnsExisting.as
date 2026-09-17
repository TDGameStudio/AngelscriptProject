/**
 * @version v1
 * @summary An &inout TMap<int, int> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 *
 * MutateFindOrAddReturnsExisting
 */
/**
 * @begin MutateFindOrAddReturnsExisting
 * @summary An &inout TMap<int, int> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 */
void MutateFindOrAddReturnsExisting(TMap<int, int>&inout Values)
{
	Values.FindOrAdd(10, 3);
}
/** @end */
