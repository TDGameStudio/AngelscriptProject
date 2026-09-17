/**
 * @version v1
 * @summary An &out TArray<FString> is filled then overwritten by Copy.
 * @topic Containers
 *
 * FillByCopyRangeFString
 */
/**
 * @begin FillByCopyRangeFString
 * @summary An &out TArray<FString> is filled then overwritten by Copy.
 * @topic Containers
 */
void FillByCopyRangeFString(TArray<FString>&out Result)
{
	Result.Add("-");
	Result.Add("-");
	Result.Add("-");
	TArray<FString> Source;
	Source.Add("x");
	Source.Add("y");
	Result.Copy(Source, 0, 2, 1);
}
/** @end */
