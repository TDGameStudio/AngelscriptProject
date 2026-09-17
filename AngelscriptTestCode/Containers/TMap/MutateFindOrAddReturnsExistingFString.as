/**
 * @version v1
 * @summary An &inout TMap<FString, int> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 *
 * MutateFindOrAddReturnsExistingFString
 */
/**
 * @begin MutateFindOrAddReturnsExistingFString
 * @summary An &inout TMap<FString, int> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 */
void MutateFindOrAddReturnsExistingFString(TMap<FString, int>&inout Values)
{
	Values.FindOrAdd("delta", 3);
}
/** @end */
