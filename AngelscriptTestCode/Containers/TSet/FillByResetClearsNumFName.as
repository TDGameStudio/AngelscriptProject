/**
 * @version v1
 * @summary An &out TSet<FName> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumFName
 */
/**
 * @begin FillByResetClearsNumFName
 * @summary An &out TSet<FName> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
	Result.Add(n"Green");
	Result.Reset();
}
/** @end */
