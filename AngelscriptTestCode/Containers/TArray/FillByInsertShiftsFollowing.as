/**
 * @version v1
 * @summary An &out TArray<int32> is filled by Insert at an index.
 * @topic Containers
 *
 * FillByInsertShiftsFollowing
 */
/**
 * @begin FillByInsertShiftsFollowing
 * @summary An &out TArray<int32> is filled by Insert at an index.
 * @topic Containers
 */
void FillByInsertShiftsFollowing(TArray<int32>&out Result)
{
	Result.Add(10);
	Result.Add(20);
	Result.Add(30);
	Result.Insert(15, 1);
}
/** @end */
