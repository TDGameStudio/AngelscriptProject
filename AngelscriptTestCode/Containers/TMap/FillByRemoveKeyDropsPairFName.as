/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled then Remove drops the middle key.
 * @topic Containers
 *
 * FillByRemoveKeyDropsPairFName
 */
/**
 * @begin FillByRemoveKeyDropsPairFName
 * @summary An &out TMap<FName, int> is filled then Remove drops the middle key.
 * @topic Containers
 */
void FillByRemoveKeyDropsPairFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Green", 2);
	Result.Add(n"Blue", 3);
	Result.Remove(n"Green");
}
/** @end */
