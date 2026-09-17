/**
 * @version v1
 * @summary An &out TArray<float> is filled then Swap exchanges ends.
 * @topic Containers
 *
 * FillBySwapElementsFloat
 */
/**
 * @begin FillBySwapElementsFloat
 * @summary An &out TArray<float> is filled then Swap exchanges ends.
 * @topic Containers
 */
void FillBySwapElementsFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Add(30.0f);
	Result.Swap(0, 2);
}
/** @end */
