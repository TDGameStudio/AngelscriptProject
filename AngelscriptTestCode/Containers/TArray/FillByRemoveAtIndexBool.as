/**
 * @version v1
 * @summary An &out TArray<bool> is filled then RemoveAt drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtIndexBool
 */
/**
 * @begin FillByRemoveAtIndexBool
 * @summary An &out TArray<bool> is filled then RemoveAt drops the first index.
 * @topic Containers
 */
void FillByRemoveAtIndexBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
	Result.RemoveAt(0);
}
/** @end */
