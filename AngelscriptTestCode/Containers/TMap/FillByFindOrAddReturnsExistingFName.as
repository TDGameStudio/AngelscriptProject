/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 *
 * FillByFindOrAddReturnsExistingFName
 */
/**
 * @begin FillByFindOrAddReturnsExistingFName
 * @summary An &out TMap<FName, int> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 */
void FillByFindOrAddReturnsExistingFName(TMap<FName, int>&out Result)
{
	Result.FindOrAdd(n"Delta", 9);
	Result.FindOrAdd(n"Delta", 3);
}
/** @end */
