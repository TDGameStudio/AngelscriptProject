/**
 * @version v1
 * @summary A const&in TArray<FString> reports sorted ascending order.
 * @topic Containers
 *
 * ReadSortAscendingFString
 */
/**
 * @begin ReadSortAscendingFString
 * @summary A const&in TArray<FString> reports sorted ascending order.
 * @topic Containers
 */
bool ReadSortAscendingFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "a" && Values[1] == "b" && Values[2] == "c";
}
/** @end */
