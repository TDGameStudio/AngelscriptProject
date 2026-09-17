/**
 * @version v1
 * @summary An &out TArray<FString> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtSwapFString
 */
/**
 * @begin FillByRemoveAtSwapFString
 * @summary An &out TArray<FString> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 */
void FillByRemoveAtSwapFString(TArray<FString>&out Result)
{
	Result.Add("a");
	Result.Add("b");
	Result.Add("c");
	Result.Add("d");
	Result.RemoveAtSwap(0);
}
/** @end */
