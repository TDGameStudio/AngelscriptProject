/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled so bracket access can read stored values.
 * @topic Containers
 *
 * FillByIndexAccessFString
 */
/**
 * @begin FillByIndexAccessFString
 * @summary An &out TMap<FString, int> is filled so bracket access can read stored values.
 * @topic Containers
 */
void FillByIndexAccessFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("beta", 200);
	Result.Add("gamma", 300);
}
/** @end */
