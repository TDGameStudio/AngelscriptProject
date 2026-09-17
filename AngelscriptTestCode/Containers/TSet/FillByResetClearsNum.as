/**
 * @version v1
 * @summary An &out TSet<int32> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNum
 */
/**
 * @begin FillByResetClearsNum
 * @summary An &out TSet<int32> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNum(TSet<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Reset();
}
/** @end */
