/**
 * @version v1
 * @summary An &out TArray<int32> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtSwap
 */
/**
 * @begin FillByRemoveAtSwap
 * @summary An &out TArray<int32> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 */
void FillByRemoveAtSwap(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(3);
	Result.Add(4);
	Result.RemoveAtSwap(0);
}
/** @end */
