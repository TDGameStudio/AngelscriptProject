/**
 * @version v1
 * @summary An &out TArray<int32> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNum
 */
/**
 * @begin FillByEmptyClearsNum
 * @summary An &out TArray<int32> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNum(TArray<int32>&out Result)
{
	Result.Add(10);
	Result.Add(20);
	Result.Add(30);
	Result.Empty();
}
/** @end */
