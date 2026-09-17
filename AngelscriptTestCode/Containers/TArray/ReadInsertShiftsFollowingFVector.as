/**
 * @version v1
 * @summary A const&in TArray<FVector> reports Insert order.
 * @topic Containers
 *
 * ReadInsertShiftsFollowingFVector
 */
/**
 * @begin ReadInsertShiftsFollowingFVector
 * @summary A const&in TArray<FVector> reports Insert order.
 * @topic Containers
 */
bool ReadInsertShiftsFollowingFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 4
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 0.0f, 1.0f))
		&& Values[3].Equals(FVector(1.0f, 1.0f, 0.0f));
}
/** @end */
