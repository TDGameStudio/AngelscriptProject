/**
 * @version v1
 * @summary An &out TArray<FString> is filled then emptied by Reset.
 * @topic Containers
 *
 * FillThenResetFString
 */
/**
 * @begin FillThenResetFString
 * @summary An &out TArray<FString> is filled then emptied by Reset.
 * @topic Containers
 */
void FillThenResetFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("gamma");
	Result.Reset();
}
/** @end */
