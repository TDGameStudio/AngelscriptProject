/**
 * @version v1
 * @summary An &out TArray<float> is filled then emptied by Reset.
 * @topic Containers
 *
 * FillThenResetFloat
 */
/**
 * @begin FillThenResetFloat
 * @summary An &out TArray<float> is filled then emptied by Reset.
 * @topic Containers
 */
void FillThenResetFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	Result.Add(3.0f);
	Result.Reset();
}
/** @end */
