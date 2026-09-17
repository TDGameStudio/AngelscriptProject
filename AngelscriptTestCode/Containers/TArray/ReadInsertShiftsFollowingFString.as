/**
 * @version v1
 * @summary A const&in TArray<FString> reports Insert order.
 * @topic Containers
 *
 * ReadInsertShiftsFollowingFString
 */
/**
 * @begin ReadInsertShiftsFollowingFString
 * @summary A const&in TArray<FString> reports Insert order.
 * @topic Containers
 */
bool ReadInsertShiftsFollowingFString(const TArray<FString>&in Values)
{
	return Values.Num() == 4 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma" && Values[3] == "delta";
}
/** @end */
