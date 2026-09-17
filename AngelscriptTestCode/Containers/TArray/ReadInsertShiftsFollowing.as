/**
 * @version v1
 * @summary A const&in TArray<int32> reports Insert order.
 * @topic Containers
 *
 * ReadInsertShiftsFollowing
 */
/**
 * @begin ReadInsertShiftsFollowing
 * @summary A const&in TArray<int32> reports Insert order.
 * @topic Containers
 */
bool ReadInsertShiftsFollowing(const TArray<int32>&in Values)
{
	return Values.Num() == 4 && Values[0] == 10 && Values[1] == 15 && Values[2] == 20 && Values[3] == 30;
}
/** @end */
