/**
 * @version v1
 * @summary An &out TMap<int, int> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNum
 */
/**
 * @begin FillByResetClearsNum
 * @summary An &out TMap<int, int> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNum(TMap<int, int>&out Result)
{
	Result.Add(10, 100);
	Result.Add(20, 200);
	Result.Add(30, 300);
	Result.Reset();
}
/** @end */
