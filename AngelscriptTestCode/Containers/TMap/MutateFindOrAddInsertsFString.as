/**
 * @version v1
 * @summary An &inout TMap<FString, int> inserts a missing key by FindOrAdd.
 * @topic Containers
 *
 * MutateFindOrAddInsertsFString
 */
/**
 * @begin MutateFindOrAddInsertsFString
 * @summary An &inout TMap<FString, int> inserts a missing key by FindOrAdd.
 * @topic Containers
 */
void MutateFindOrAddInsertsFString(TMap<FString, int>&inout Values)
{
	Values.FindOrAdd("gamma") = 300;
}
/** @end */
