/**
 * @version v1
 * @summary An &inout TMap<int, bool> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 *
 * MutateFindOrAddReturnsExistingBool
 */
/**
 * @begin MutateFindOrAddReturnsExistingBool
 * @summary An &inout TMap<int, bool> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 */
void MutateFindOrAddReturnsExistingBool(TMap<int, bool>&inout Values)
{
	Values.FindOrAdd(1, false);
}
/** @end */
