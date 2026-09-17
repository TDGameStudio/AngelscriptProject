/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Insert order by identity.
 * @topic Containers
 *
 * ReadInsertShiftsFollowingUObject
 */
/**
 * @begin ReadInsertShiftsFollowingUObject
 * @summary A const&in TArray<UObject> reports Insert order by identity.
 * @topic Containers
 */
bool ReadInsertShiftsFollowingUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 4
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr && Values[3] != nullptr
		&& Values[0] != Values[1] && Values[1] != Values[2] && Values[2] != Values[3];
}
/** @end */
