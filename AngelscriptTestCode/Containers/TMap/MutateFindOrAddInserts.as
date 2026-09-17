/**
 * @version v1
 * @summary An &inout TMap<int, int> inserts a missing key by FindOrAdd.
 * @topic Containers
 *
 * MutateFindOrAddInserts
 */
/**
 * @begin MutateFindOrAddInserts
 * @summary An &inout TMap<int, int> inserts a missing key by FindOrAdd.
 * @topic Containers
 */
void MutateFindOrAddInserts(TMap<int, int>&inout Values)
{
	Values.FindOrAdd(30) = 300;
}
/** @end */
