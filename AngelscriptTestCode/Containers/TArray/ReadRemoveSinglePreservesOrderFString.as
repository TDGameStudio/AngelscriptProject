/**
 * @version v1
 * @summary A const&in TArray<FString> reports the array after RemoveSingle kept later order.
 * @topic Containers
 *
 * ReadRemoveSinglePreservesOrderFString
 */
/**
 * @begin ReadRemoveSinglePreservesOrderFString
 * @summary A const&in TArray<FString> reports the array after RemoveSingle kept later order.
 * @topic Containers
 */
bool ReadRemoveSinglePreservesOrderFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "a" && Values[1] == "b" && Values[2] == "c";
}
/** @end */
