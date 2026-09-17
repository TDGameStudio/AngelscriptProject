/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 *
 * FillByRemoveAndCopyValueBool
 */
/**
 * @begin FillByRemoveAndCopyValueBool
 * @summary An &out TMap<int, bool> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 */
void FillByRemoveAndCopyValueBool(TMap<int, bool>&out Result)
{
	bool OutValue = false;
	Result.Add(1, true);
	Result.RemoveAndCopyValue(1, OutValue);
}
/** @end */
