/**
 * @version v1
 * @summary An &out TArray<float> is filled by Insert at an index.
 * @topic Containers
 *
 * FillByInsertShiftsFollowingFloat
 */
/**
 * @begin FillByInsertShiftsFollowingFloat
 * @summary An &out TArray<float> is filled by Insert at an index.
 * @topic Containers
 */
void FillByInsertShiftsFollowingFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Add(30.0f);
	Result.Insert(15.0f, 1);
}
/** @end */
