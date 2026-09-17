/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumBool
 */
/**
 * @begin FillByResetClearsNumBool
 * @summary An &out TMap<int, bool> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(2, false);
	Result.Add(3, true);
	Result.Reset();
}
/** @end */
