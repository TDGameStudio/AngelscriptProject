/**
 * @version v1
 * @summary An &out TMap<int, int> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 *
 * FillByRemoveAndCopyValue
 */
/**
 * @begin FillByRemoveAndCopyValue
 * @summary An &out TMap<int, int> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 */
void FillByRemoveAndCopyValue(TMap<int, int>&out Result)
{
	int OutValue = -1;
	Result.Add(10, 9);
	Result.RemoveAndCopyValue(10, OutValue);
}
/** @end */
