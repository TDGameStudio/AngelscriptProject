/**
 * @version v1
 * @summary An &out TMap<int, int> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 *
 * FillByFindOrAddReturnsExisting
 */
/**
 * @begin FillByFindOrAddReturnsExisting
 * @summary An &out TMap<int, int> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 */
void FillByFindOrAddReturnsExisting(TMap<int, int>&out Result)
{
	Result.FindOrAdd(10, 9);
	Result.FindOrAdd(10, 3);
}
/** @end */
