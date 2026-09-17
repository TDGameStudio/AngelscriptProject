/**
 * @version v1
 * @summary A const&in TArray<FVector> reports reserved Max and Slack without changing Num.
 * @topic Containers
 *
 * ReadReserveGrowsMaxWithoutChangingNumFVector
 */
/**
 * @begin ReadReserveGrowsMaxWithoutChangingNumFVector
 * @summary A const&in TArray<FVector> reports reserved Max and Slack without changing Num.
 * @topic Containers
 */
bool ReadReserveGrowsMaxWithoutChangingNumFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
}
/** @end */
