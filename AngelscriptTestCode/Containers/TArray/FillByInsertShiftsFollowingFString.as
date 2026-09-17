/**
 * @version v1
 * @summary An &out TArray<FString> is filled by Insert at an index.
 * @topic Containers
 *
 * FillByInsertShiftsFollowingFString
 */
/**
 * @begin FillByInsertShiftsFollowingFString
 * @summary An &out TArray<FString> is filled by Insert at an index.
 * @topic Containers
 */
void FillByInsertShiftsFollowingFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("gamma");
	Result.Add("delta");
	Result.Insert("beta", 1);
}
/** @end */
