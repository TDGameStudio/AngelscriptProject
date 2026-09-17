/**
 * @version v1
 * @summary An &out TMap<int, int> is filled by FindOrAdd of three keys.
 * @topic Containers
 *
 * FillByFindOrAddInserts
 */
/**
 * @begin FillByFindOrAddInserts
 * @summary An &out TMap<int, int> is filled by FindOrAdd of three keys.
 * @topic Containers
 */
void FillByFindOrAddInserts(TMap<int, int>&out Result)
{
	Result.FindOrAdd(10) = 100;
	Result.FindOrAdd(20) = 200;
	Result.FindOrAdd(30) = 300;
}
/** @end */
