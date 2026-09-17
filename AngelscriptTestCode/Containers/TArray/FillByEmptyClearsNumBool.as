/**
 * @version v1
 * @summary An &out TArray<bool> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumBool
 */
/**
 * @begin FillByEmptyClearsNumBool
 * @summary An &out TArray<bool> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
	Result.Empty();
}
/** @end */
