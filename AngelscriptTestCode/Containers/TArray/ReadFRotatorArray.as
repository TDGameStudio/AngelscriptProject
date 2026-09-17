/**
 * @version v1
 * @summary A const&in TArray<FRotator> reports Zero, yaw 90, and (10,20,30).
 * @topic Containers
 *
 * ReadFRotatorArray
 */
/**
 * @begin ReadFRotatorArray
 * @summary A const&in TArray<FRotator> reports Zero, yaw 90, and (10,20,30).
 * @topic Containers
 */
bool ReadFRotatorArray(const TArray<FRotator>&in Values)
{
	return Values.Num() == 3
		&& Values[0].Equals(FRotator::ZeroRotator, 0.001f)
		&& Values[1].Equals(FRotator(0.0f, 90.0f, 0.0f), 0.001f)
		&& Values[2].Equals(FRotator(10.0f, 20.0f, 30.0f), 0.001f);
}
/** @end */
