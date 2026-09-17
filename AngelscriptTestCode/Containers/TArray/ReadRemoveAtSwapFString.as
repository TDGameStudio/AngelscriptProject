/**
 * @version v1
 * @summary A const&in TArray<FString> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 *
 * ReadRemoveAtSwapFString
 */
/**
 * @begin ReadRemoveAtSwapFString
 * @summary A const&in TArray<FString> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 */
bool ReadRemoveAtSwapFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3
		&& !Values.Contains("a")
		&& Values.Contains("b")
		&& Values.Contains("c")
		&& Values.Contains("d");
}
/** @end */
