/**
 * @version v1
 * @summary An &out TMap<int, int> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNum
 */
/**
 * @begin FillByEmptyClearsNum
 * @summary An &out TMap<int, int> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNum(TMap<int, int>&out Result)
{
	Result.Add(10, 100);
	Result.Add(20, 200);
	Result.Add(30, 300);
	Result.Empty();
}
/** @end */
