/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumFString
 */
/**
 * @begin FillByResetClearsNumFString
 * @summary An &out TMap<FString, int> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("beta", 200);
	Result.Add("gamma", 300);
	Result.Reset();
}
/** @end */
