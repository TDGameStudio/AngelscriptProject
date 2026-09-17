/**
 * @version v1
 * @summary An &out TArray<FString> is filled then Swap exchanges ends.
 * @topic Containers
 *
 * FillBySwapElementsFString
 */
/**
 * @begin FillBySwapElementsFString
 * @summary An &out TArray<FString> is filled then Swap exchanges ends.
 * @topic Containers
 */
void FillBySwapElementsFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("gamma");
	Result.Swap(0, 2);
}
/** @end */
