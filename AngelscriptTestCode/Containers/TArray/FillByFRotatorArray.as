/**
 * @version v1
 * @summary An &out TArray<FRotator> is filled with Zero, yaw 90, and (10,20,30).
 * @topic Containers
 *
 * FillByFRotatorArray
 */
/**
 * @begin FillByFRotatorArray
 * @summary An &out TArray<FRotator> is filled with Zero, yaw 90, and (10,20,30).
 * @topic Containers
 */
void FillByFRotatorArray(TArray<FRotator>&out Result)
{
	Result.Add(FRotator::ZeroRotator);
	Result.Add(FRotator(0.0f, 90.0f, 0.0f));
	Result.Add(FRotator(10.0f, 20.0f, 30.0f));
}
/** @end */
