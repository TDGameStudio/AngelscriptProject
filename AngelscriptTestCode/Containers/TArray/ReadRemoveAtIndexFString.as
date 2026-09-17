/**
 * @version v1
 * @summary A const&in TArray<FString> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 *
 * ReadRemoveAtIndexFString
 */
/**
 * @begin ReadRemoveAtIndexFString
 * @summary A const&in TArray<FString> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 */
bool ReadRemoveAtIndexFString(const TArray<FString>&in Values)
{
	return Values.Num() == 2 && Values[0] == "beta" && Values[1] == "gamma";
}
/** @end */
