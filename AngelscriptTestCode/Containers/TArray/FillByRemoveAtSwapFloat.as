/**
 * @version v1
 * @summary An &out TArray<float> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtSwapFloat
 */
/**
 * @begin FillByRemoveAtSwapFloat
 * @summary An &out TArray<float> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 */
void FillByRemoveAtSwapFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	Result.Add(3.0f);
	Result.Add(4.0f);
	Result.RemoveAtSwap(0);
}
/** @end */
