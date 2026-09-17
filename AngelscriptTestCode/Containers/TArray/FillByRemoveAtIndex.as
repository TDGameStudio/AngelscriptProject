/**
 * @version v1
 * @summary An &out TArray<int32> is filled then RemoveAt drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtIndex
 */
/**
 * @begin FillByRemoveAtIndex
 * @summary An &out TArray<int32> is filled then RemoveAt drops the first index.
 * @topic Containers
 */
void FillByRemoveAtIndex(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(3);
	Result.Add(4);
	Result.RemoveAt(0);
}
/** @end */
