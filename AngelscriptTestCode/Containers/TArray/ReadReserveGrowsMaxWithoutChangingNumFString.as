/**
 * @version v1
 * @summary A const&in TArray<FString> reports reserved Max and Slack without changing Num.
 * @topic Containers
 *
 * ReadReserveGrowsMaxWithoutChangingNumFString
 */
/**
 * @begin ReadReserveGrowsMaxWithoutChangingNumFString
 * @summary A const&in TArray<FString> reports reserved Max and Slack without changing Num.
 * @topic Containers
 */
bool ReadReserveGrowsMaxWithoutChangingNumFString(const TArray<FString>&in Values)
{
	return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
}
/** @end */
