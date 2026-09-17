/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 *
 * FillByRemoveAndCopyValueFName
 */
/**
 * @begin FillByRemoveAndCopyValueFName
 * @summary An &out TMap<FName, int> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 */
void FillByRemoveAndCopyValueFName(TMap<FName, int>&out Result)
{
	int OutValue = -1;
	Result.Add(n"Red", 9);
	Result.RemoveAndCopyValue(n"Red", OutValue);
}
/** @end */
