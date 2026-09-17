/**
 * @version v1
 * @summary An &out TArray<float> is filled then overwritten by Copy.
 * @topic Containers
 *
 * FillByCopyRangeFloat
 */
/**
 * @begin FillByCopyRangeFloat
 * @summary An &out TArray<float> is filled then overwritten by Copy.
 * @topic Containers
 */
void FillByCopyRangeFloat(TArray<float>&out Result)
{
	Result.Add(0.0f);
	Result.Add(0.0f);
	Result.Add(0.0f);
	Result.Add(0.0f);
	TArray<float> Source;
	Source.Add(7.0f);
	Source.Add(8.0f);
	Source.Add(9.0f);
	Result.Copy(Source, 0, 3, 1);
}
/** @end */
