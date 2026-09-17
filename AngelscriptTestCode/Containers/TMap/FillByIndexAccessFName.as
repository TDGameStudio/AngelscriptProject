/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled so bracket access can read stored values.
 * @topic Containers
 *
 * FillByIndexAccessFName
 */
/**
 * @begin FillByIndexAccessFName
 * @summary An &out TMap<FName, int> is filled so bracket access can read stored values.
 * @topic Containers
 */
void FillByIndexAccessFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Green", 2);
	Result.Add(n"Blue", 3);
}
/** @end */
