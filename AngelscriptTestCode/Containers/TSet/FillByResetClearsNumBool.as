/**
 * @version v1
 * @summary An &out TSet<bool> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumBool
 */
/**
 * @begin FillByResetClearsNumBool
 * @summary An &out TSet<bool> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumBool(TSet<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Reset();
}
/** @end */
