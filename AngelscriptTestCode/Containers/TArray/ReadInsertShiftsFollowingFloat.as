/**
 * @version v1
 * @summary A const&in TArray<float> reports Insert order.
 * @topic Containers
 *
 * ReadInsertShiftsFollowingFloat
 */
/**
 * @begin ReadInsertShiftsFollowingFloat
 * @summary A const&in TArray<float> reports Insert order.
 * @topic Containers
 */
bool ReadInsertShiftsFollowingFloat(const TArray<float>&in Values)
{
	return Values.Num() == 4 && Values[0] == 10.0f && Values[1] == 15.0f && Values[2] == 20.0f && Values[3] == 30.0f;
}
/** @end */
