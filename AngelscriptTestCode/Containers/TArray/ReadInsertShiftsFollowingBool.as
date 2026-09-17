/**
 * @version v1
 * @summary A const&in TArray<bool> reports Insert order.
 * @topic Containers
 *
 * ReadInsertShiftsFollowingBool
 */
/**
 * @begin ReadInsertShiftsFollowingBool
 * @summary A const&in TArray<bool> reports Insert order.
 * @topic Containers
 */
bool ReadInsertShiftsFollowingBool(const TArray<bool>&in Values)
{
	return Values.Num() == 4 && Values[0] == false && Values[1] == true && Values[2] == true && Values[3] == false;
}
/** @end */
