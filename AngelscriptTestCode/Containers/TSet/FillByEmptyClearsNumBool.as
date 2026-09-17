/**
 * @version v1
 * @summary An &out TSet<bool> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumBool
 */
/**
 * @begin FillByEmptyClearsNumBool
 * @summary An &out TSet<bool> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumBool(TSet<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Empty();
}
/** @end */
