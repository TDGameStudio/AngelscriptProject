/**
 * @version v1
 * @summary An &out TArray<float> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 *
 * FillByFindIndexReturnsFirstOrMinusOneFloat
 */
/**
 * @begin FillByFindIndexReturnsFirstOrMinusOneFloat
 * @summary An &out TArray<float> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 */
void FillByFindIndexReturnsFirstOrMinusOneFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Add(10.0f);
}
/** @end */
