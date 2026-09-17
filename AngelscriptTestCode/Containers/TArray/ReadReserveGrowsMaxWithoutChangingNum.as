/**
 * @version v1
 * @summary A const&in TArray<int32> reports reserved Max and Slack without changing Num.
 * @topic Containers
 *
 * ReadReserveGrowsMaxWithoutChangingNum
 */
/**
 * @begin ReadReserveGrowsMaxWithoutChangingNum
 * @summary A const&in TArray<int32> reports reserved Max and Slack without changing Num.
 * @topic Containers
 */
bool ReadReserveGrowsMaxWithoutChangingNum(const TArray<int32>&in Values)
{
	return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
}
/** @end */
