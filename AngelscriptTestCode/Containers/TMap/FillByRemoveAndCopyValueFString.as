/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 *
 * FillByRemoveAndCopyValueFString
 */
/**
 * @begin FillByRemoveAndCopyValueFString
 * @summary An &out TMap<FString, int> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 */
void FillByRemoveAndCopyValueFString(TMap<FString, int>&out Result)
{
	int OutValue = -1;
	Result.Add("alpha", 9);
	Result.RemoveAndCopyValue("alpha", OutValue);
}
/** @end */
