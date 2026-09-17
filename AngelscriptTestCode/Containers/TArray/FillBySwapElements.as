/**
 * @version v1
 * @summary An &out TArray<int32> is filled then Swap exchanges ends.
 * @topic Containers
 *
 * FillBySwapElements
 */
/**
 * @begin FillBySwapElements
 * @summary An &out TArray<int32> is filled then Swap exchanges ends.
 * @topic Containers
 */
void FillBySwapElements(TArray<int32>&out Result)
{
	Result.Add(10);
	Result.Add(20);
	Result.Add(30);
	Result.Swap(0, 2);
}
/** @end */
