/**
 * @version v1
 * @summary An &out TArray<FString> is filled then RemoveAt drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtIndexFString
 */
/**
 * @begin FillByRemoveAtIndexFString
 * @summary An &out TArray<FString> is filled then RemoveAt drops the first index.
 * @topic Containers
 */
void FillByRemoveAtIndexFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("gamma");
	Result.Add("delta");
	Result.RemoveAt(0);
}
/** @end */
