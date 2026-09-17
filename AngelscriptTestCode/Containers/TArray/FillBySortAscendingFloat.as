/**
 * @version v1
 * @summary An &out TArray<float> is filled then Sort orders it ascending.
 * @topic Containers
 *
 * FillBySortAscendingFloat
 */
/**
 * @begin FillBySortAscendingFloat
 * @summary An &out TArray<float> is filled then Sort orders it ascending.
 * @topic Containers
 */
void FillBySortAscendingFloat(TArray<float>&out Result)
{
	Result.Add(30.0f);
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Sort();
}
/** @end */
