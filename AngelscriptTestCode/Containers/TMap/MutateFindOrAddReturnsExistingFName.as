/**
 * @version v1
 * @summary An &inout TMap<FName, int> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 *
 * MutateFindOrAddReturnsExistingFName
 */
/**
 * @begin MutateFindOrAddReturnsExistingFName
 * @summary An &inout TMap<FName, int> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 */
void MutateFindOrAddReturnsExistingFName(TMap<FName, int>&inout Values)
{
	Values.FindOrAdd(n"Delta", 3);
}
/** @end */
