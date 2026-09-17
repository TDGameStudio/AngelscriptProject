/**
 * @version v1
 * @summary An &out TSet<FName> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFName
 */
/**
 * @begin FillByEmptyClearsNumFName
 * @summary An &out TSet<FName> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
	Result.Add(n"Green");
	Result.Empty();
}
/** @end */
