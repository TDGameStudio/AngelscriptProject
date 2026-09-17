/**
 * @version v1
 * @summary An &out TMap<int, int> is filled by Add then overwrite of the same key.
 * @topic Containers
 *
 * FillByAddOverwriteReplacesValue
 */
/**
 * @begin FillByAddOverwriteReplacesValue
 * @summary An &out TMap<int, int> is filled by Add then overwrite of the same key.
 * @topic Containers
 */
void FillByAddOverwriteReplacesValue(TMap<int, int>&out Result)
{
	Result.Add(10, 100);
	Result.Add(10, 999);
}
/** @end */
