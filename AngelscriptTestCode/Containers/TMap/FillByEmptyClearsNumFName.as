/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFName
 */
/**
 * @begin FillByEmptyClearsNumFName
 * @summary An &out TMap<FName, int> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Green", 2);
	Result.Add(n"Blue", 3);
	Result.Empty();
}
/** @end */
