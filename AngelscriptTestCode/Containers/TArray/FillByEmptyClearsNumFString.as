/**
 * @version v1
 * @summary An &out TArray<FString> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFString
 */
/**
 * @begin FillByEmptyClearsNumFString
 * @summary An &out TArray<FString> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("gamma");
	Result.Empty();
}
/** @end */
