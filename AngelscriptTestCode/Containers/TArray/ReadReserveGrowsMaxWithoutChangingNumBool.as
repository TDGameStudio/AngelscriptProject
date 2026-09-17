/**
 * @version v1
 * @summary A const&in TArray<bool> reports reserved Max and Slack without changing Num.
 * @topic Containers
 *
 * ReadReserveGrowsMaxWithoutChangingNumBool
 */
/**
 * @begin ReadReserveGrowsMaxWithoutChangingNumBool
 * @summary A const&in TArray<bool> reports reserved Max and Slack without changing Num.
 * @topic Containers
 */
bool ReadReserveGrowsMaxWithoutChangingNumBool(const TArray<bool>&in Values)
{
	return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
}
/** @end */
