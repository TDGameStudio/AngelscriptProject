/**
 * @version v1
 * @summary An &out TArray<FString> is filled then RemoveSwap deletes every match.
 * @topic Containers
 *
 * FillByRemoveSwapFString
 */
/**
 * @begin FillByRemoveSwapFString
 * @summary An &out TArray<FString> is filled then RemoveSwap deletes every match.
 * @topic Containers
 */
void FillByRemoveSwapFString(TArray<FString>&out Result)
{
	Result.Add("a");
	Result.Add("b");
	Result.Add("c");
	Result.Add("b");
	Result.RemoveSwap("b");
}
/** @end */
