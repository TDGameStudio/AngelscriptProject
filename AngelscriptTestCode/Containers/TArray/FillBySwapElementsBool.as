/**
 * @version v1
 * @summary An &out TArray<bool> is filled then Swap exchanges ends.
 * @topic Containers
 *
 * FillBySwapElementsBool
 */
/**
 * @begin FillBySwapElementsBool
 * @summary An &out TArray<bool> is filled then Swap exchanges ends.
 * @topic Containers
 */
void FillBySwapElementsBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(true);
	Result.Add(true);
	Result.Swap(0, 2);
}
/** @end */
