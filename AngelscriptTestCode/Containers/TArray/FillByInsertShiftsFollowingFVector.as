/**
 * @version v1
 * @summary An &out TArray<FVector> is filled by Insert at an index.
 * @topic Containers
 *
 * FillByInsertShiftsFollowingFVector
 */
/**
 * @begin FillByInsertShiftsFollowingFVector
 * @summary An &out TArray<FVector> is filled by Insert at an index.
 * @topic Containers
 */
void FillByInsertShiftsFollowingFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Add(FVector(1.0f, 1.0f, 0.0f));
	Result.Insert(FVector(0.0f, 1.0f, 0.0f), 1);
}
/** @end */
