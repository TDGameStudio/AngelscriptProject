/**
 * @version v1
 * @summary An &out TArray<bool> is filled then RemoveSwap deletes every match.
 * @topic Containers
 *
 * FillByRemoveSwapBool
 */
/**
 * @begin FillByRemoveSwapBool
 * @summary An &out TArray<bool> is filled then RemoveSwap deletes every match.
 * @topic Containers
 */
void FillByRemoveSwapBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
	Result.RemoveSwap(true);
}
/** @end */
