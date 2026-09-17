/**
 * @version v1
 * @summary A const&in TArray<FString> reports Add insertion order.
 * @topic Containers
 *
 * ReadAddOrderFString
 */
/**
 * @begin ReadAddOrderFString
 * @summary A const&in TArray<FString> reports Add insertion order.
 * @topic Containers
 */
bool ReadAddOrderFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma";
}
/** @end */
