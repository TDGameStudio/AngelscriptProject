/**
 * @version v1
 * @summary An &out TSet<FString> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumFString
 */
/**
 * @begin FillByResetClearsNumFString
 * @summary An &out TSet<FString> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumFString(TSet<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Reset();
}
/** @end */
