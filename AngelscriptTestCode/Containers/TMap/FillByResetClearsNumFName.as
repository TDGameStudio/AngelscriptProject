/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumFName
 */
/**
 * @begin FillByResetClearsNumFName
 * @summary An &out TMap<FName, int> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Green", 2);
	Result.Add(n"Blue", 3);
	Result.Reset();
}
/** @end */
