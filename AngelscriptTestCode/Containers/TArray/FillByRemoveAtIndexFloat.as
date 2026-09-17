/**
 * @version v1
 * @summary An &out TArray<float> is filled then RemoveAt drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtIndexFloat
 */
/**
 * @begin FillByRemoveAtIndexFloat
 * @summary An &out TArray<float> is filled then RemoveAt drops the first index.
 * @topic Containers
 */
void FillByRemoveAtIndexFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	Result.Add(3.0f);
	Result.Add(4.0f);
	Result.RemoveAt(0);
}
/** @end */
