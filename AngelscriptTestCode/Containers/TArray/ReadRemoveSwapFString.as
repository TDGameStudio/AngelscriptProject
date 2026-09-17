/**
 * @version v1
 * @summary A const&in TArray<FString> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 *
 * ReadRemoveSwapFString
 */
/**
 * @begin ReadRemoveSwapFString
 * @summary A const&in TArray<FString> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 */
bool ReadRemoveSwapFString(const TArray<FString>&in Values)
{
	return Values.Num() == 2
		&& !Values.Contains("b")
		&& Values.Contains("a")
		&& Values.Contains("c");
}
/** @end */
