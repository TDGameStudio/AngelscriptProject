/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled by FindOrAdd of three keys.
 * @topic Containers
 *
 * FillByFindOrAddInsertsBool
 */
/**
 * @begin FillByFindOrAddInsertsBool
 * @summary An &out TMap<int, bool> is filled by FindOrAdd of three keys.
 * @topic Containers
 */
void FillByFindOrAddInsertsBool(TMap<int, bool>&out Result)
{
	Result.FindOrAdd(1) = true;
	Result.FindOrAdd(2) = false;
	Result.FindOrAdd(3) = true;
}
/** @end */
