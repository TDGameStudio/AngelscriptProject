/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFString
 */
/**
 * @begin FillByEmptyClearsNumFString
 * @summary An &out TMap<FString, int> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("beta", 200);
	Result.Add("gamma", 300);
	Result.Empty();
}
/** @end */
