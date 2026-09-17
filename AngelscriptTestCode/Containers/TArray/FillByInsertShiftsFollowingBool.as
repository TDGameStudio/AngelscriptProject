/**
 * @version v1
 * @summary An &out TArray<bool> is filled by Insert at an index.
 * @topic Containers
 *
 * FillByInsertShiftsFollowingBool
 */
/**
 * @begin FillByInsertShiftsFollowingBool
 * @summary An &out TArray<bool> is filled by Insert at an index.
 * @topic Containers
 */
void FillByInsertShiftsFollowingBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
	Result.Insert(true, 1);
}
/** @end */
