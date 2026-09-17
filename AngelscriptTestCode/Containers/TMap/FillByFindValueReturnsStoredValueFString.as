/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled so Find can copy stored values.
 * @topic Containers
 *
 * FillByFindValueReturnsStoredValueFString
 */
/**
 * @begin FillByFindValueReturnsStoredValueFString
 * @summary An &out TMap<FString, int> is filled so Find can copy stored values.
 * @topic Containers
 */
void FillByFindValueReturnsStoredValueFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("beta", 200);
	Result.Add("gamma", 300);
}
/** @end */
