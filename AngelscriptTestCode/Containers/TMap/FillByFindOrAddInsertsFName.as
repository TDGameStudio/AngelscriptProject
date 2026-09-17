/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled by FindOrAdd of three keys.
 * @topic Containers
 *
 * FillByFindOrAddInsertsFName
 */
/**
 * @begin FillByFindOrAddInsertsFName
 * @summary An &out TMap<FName, int> is filled by FindOrAdd of three keys.
 * @topic Containers
 */
void FillByFindOrAddInsertsFName(TMap<FName, int>&out Result)
{
	Result.FindOrAdd(n"Red") = 1;
	Result.FindOrAdd(n"Green") = 2;
	Result.FindOrAdd(n"Blue") = 3;
}
/** @end */
