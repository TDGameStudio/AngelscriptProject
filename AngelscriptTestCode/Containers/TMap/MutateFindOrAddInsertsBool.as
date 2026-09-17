/**
 * @version v1
 * @summary An &inout TMap<int, bool> inserts a missing key by FindOrAdd.
 * @topic Containers
 *
 * MutateFindOrAddInsertsBool
 */
/**
 * @begin MutateFindOrAddInsertsBool
 * @summary An &inout TMap<int, bool> inserts a missing key by FindOrAdd.
 * @topic Containers
 */
void MutateFindOrAddInsertsBool(TMap<int, bool>&inout Values)
{
	Values.FindOrAdd(3) = true;
}
/** @end */
