/**
 * @version v1
 * @summary An &out TArray<int32> is filled then RemoveSwap deletes every match.
 * @topic Containers
 *
 * FillByRemoveSwap
 */
/**
 * @begin FillByRemoveSwap
 * @summary An &out TArray<int32> is filled then RemoveSwap deletes every match.
 * @topic Containers
 */
void FillByRemoveSwap(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(3);
	Result.Add(2);
	Result.Add(4);
	Result.RemoveSwap(2);
}
/** @end */
