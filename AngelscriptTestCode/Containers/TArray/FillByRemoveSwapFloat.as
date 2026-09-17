/**
 * @version v1
 * @summary An &out TArray<float> is filled then RemoveSwap deletes every match.
 * @topic Containers
 *
 * FillByRemoveSwapFloat
 */
/**
 * @begin FillByRemoveSwapFloat
 * @summary An &out TArray<float> is filled then RemoveSwap deletes every match.
 * @topic Containers
 */
void FillByRemoveSwapFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	Result.Add(3.0f);
	Result.Add(2.0f);
	Result.Add(4.0f);
	Result.RemoveSwap(2.0f);
}
/** @end */
