/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumBool
 */
/**
 * @begin FillByEmptyClearsNumBool
 * @summary An &out TMap<int, bool> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(2, false);
	Result.Add(3, true);
	Result.Empty();
}
/** @end */
