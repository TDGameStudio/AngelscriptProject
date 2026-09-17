/**
 * @version v1
 * @summary An &out TSet<int32> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNum
 */
/**
 * @begin FillByEmptyClearsNum
 * @summary An &out TSet<int32> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNum(TSet<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Empty();
}
/** @end */
