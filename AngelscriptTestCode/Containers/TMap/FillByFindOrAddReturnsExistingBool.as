/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 *
 * FillByFindOrAddReturnsExistingBool
 */
/**
 * @begin FillByFindOrAddReturnsExistingBool
 * @summary An &out TMap<int, bool> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 */
void FillByFindOrAddReturnsExistingBool(TMap<int, bool>&out Result)
{
	Result.FindOrAdd(1, true);
	Result.FindOrAdd(1, false);
}
/** @end */
