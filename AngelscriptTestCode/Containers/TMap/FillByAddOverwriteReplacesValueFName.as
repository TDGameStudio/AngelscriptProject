/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled by Add then overwrite of the same key.
 * @topic Containers
 *
 * FillByAddOverwriteReplacesValueFName
 */
/**
 * @begin FillByAddOverwriteReplacesValueFName
 * @summary An &out TMap<FName, int> is filled by Add then overwrite of the same key.
 * @topic Containers
 */
void FillByAddOverwriteReplacesValueFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Red", 9);
}
/** @end */
