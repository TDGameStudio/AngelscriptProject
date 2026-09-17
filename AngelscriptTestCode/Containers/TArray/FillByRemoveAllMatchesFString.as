/**
 * @version v1
 * @summary An &out TArray<FString> is filled then Remove deletes every match.
 * @topic Containers
 *
 * FillByRemoveAllMatchesFString
 */
/**
 * @begin FillByRemoveAllMatchesFString
 * @summary An &out TArray<FString> is filled then Remove deletes every match.
 * @topic Containers
 */
void FillByRemoveAllMatchesFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("gamma");
	Result.Add("beta");
	Result.Add("delta");
	Result.Add("beta");
	Result.Add("echo");
	Result.Remove("beta");
}
/** @end */
