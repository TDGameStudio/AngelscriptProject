/**
 * @version v1
 * @summary A const&in TArray<FString> reports Swap order.
 * @topic Containers
 *
 * ReadSwapElementsFString
 */
/**
 * @begin ReadSwapElementsFString
 * @summary A const&in TArray<FString> reports Swap order.
 * @topic Containers
 */
bool ReadSwapElementsFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "gamma" && Values[1] == "beta" && Values[2] == "alpha";
}
/** @end */
