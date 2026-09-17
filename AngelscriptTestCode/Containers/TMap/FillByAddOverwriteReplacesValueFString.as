/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled by Add then overwrite of the same key.
 * @topic Containers
 *
 * FillByAddOverwriteReplacesValueFString
 */
/**
 * @begin FillByAddOverwriteReplacesValueFString
 * @summary An &out TMap<FString, int> is filled by Add then overwrite of the same key.
 * @topic Containers
 */
void FillByAddOverwriteReplacesValueFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("alpha", 999);
}
/** @end */
