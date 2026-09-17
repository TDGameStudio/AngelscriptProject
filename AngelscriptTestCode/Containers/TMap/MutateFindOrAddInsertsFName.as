/**
 * @version v1
 * @summary An &inout TMap<FName, int> inserts a missing key by FindOrAdd.
 * @topic Containers
 *
 * MutateFindOrAddInsertsFName
 */
/**
 * @begin MutateFindOrAddInsertsFName
 * @summary An &inout TMap<FName, int> inserts a missing key by FindOrAdd.
 * @topic Containers
 */
void MutateFindOrAddInsertsFName(TMap<FName, int>&inout Values)
{
	Values.FindOrAdd(n"Blue") = 3;
}
/** @end */
