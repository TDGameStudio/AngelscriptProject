/**
 * @version v1
 * @summary An &out TArray<bool> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtSwapBool
 */
/**
 * @begin FillByRemoveAtSwapBool
 * @summary An &out TArray<bool> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 */
void FillByRemoveAtSwapBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(false);
	Result.Add(false);
	Result.RemoveAtSwap(0);
}
/** @end */
