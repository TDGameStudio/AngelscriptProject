/**
 * @version v1
 * @summary A const&in TArray<UObject> reports reserved Max and Slack without changing Num.
 * @topic Containers
 *
 * ReadReserveGrowsMaxWithoutChangingNumUObject
 */
/**
 * @begin ReadReserveGrowsMaxWithoutChangingNumUObject
 * @summary A const&in TArray<UObject> reports reserved Max and Slack without changing Num.
 * @topic Containers
 */
bool ReadReserveGrowsMaxWithoutChangingNumUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
}
/** @end */
