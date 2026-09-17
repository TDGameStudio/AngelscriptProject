/**
 * @version v1
 * @summary A const&in TArray<float> reports reserved Max and Slack without changing Num.
 * @topic Containers
 *
 * ReadReserveGrowsMaxWithoutChangingNumFloat
 */
/**
 * @begin ReadReserveGrowsMaxWithoutChangingNumFloat
 * @summary A const&in TArray<float> reports reserved Max and Slack without changing Num.
 * @topic Containers
 */
bool ReadReserveGrowsMaxWithoutChangingNumFloat(const TArray<float>&in Values)
{
	return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
}
/** @end */
