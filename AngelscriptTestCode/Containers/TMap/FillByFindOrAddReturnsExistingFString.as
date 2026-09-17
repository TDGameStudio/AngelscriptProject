/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 *
 * FillByFindOrAddReturnsExistingFString
 */
/**
 * @begin FillByFindOrAddReturnsExistingFString
 * @summary An &out TMap<FString, int> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 */
void FillByFindOrAddReturnsExistingFString(TMap<FString, int>&out Result)
{
	Result.FindOrAdd("delta", 9);
	Result.FindOrAdd("delta", 3);
}
/** @end */
