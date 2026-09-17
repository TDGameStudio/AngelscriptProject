/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled by Add then overwrite of the same key.
 * @topic Containers
 *
 * FillByAddOverwriteReplacesValueBool
 */
/**
 * @begin FillByAddOverwriteReplacesValueBool
 * @summary An &out TMap<int, bool> is filled by Add then overwrite of the same key.
 * @topic Containers
 */
void FillByAddOverwriteReplacesValueBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(1, false);
}
/** @end */
