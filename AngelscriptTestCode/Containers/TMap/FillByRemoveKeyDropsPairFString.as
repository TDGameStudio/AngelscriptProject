/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled then Remove drops the middle key.
 * @topic Containers
 *
 * FillByRemoveKeyDropsPairFString
 */
/**
 * @begin FillByRemoveKeyDropsPairFString
 * @summary An &out TMap<FString, int> is filled then Remove drops the middle key.
 * @topic Containers
 */
void FillByRemoveKeyDropsPairFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("beta", 200);
	Result.Add("gamma", 300);
	Result.Remove("beta");
}
/** @end */
