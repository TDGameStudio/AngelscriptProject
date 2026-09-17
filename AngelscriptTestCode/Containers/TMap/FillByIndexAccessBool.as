/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled so bracket access can read stored values.
 * @topic Containers
 *
 * FillByIndexAccessBool
 */
/**
 * @begin FillByIndexAccessBool
 * @summary An &out TMap<int, bool> is filled so bracket access can read stored values.
 * @topic Containers
 */
void FillByIndexAccessBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(2, false);
	Result.Add(3, true);
}
/** @end */
