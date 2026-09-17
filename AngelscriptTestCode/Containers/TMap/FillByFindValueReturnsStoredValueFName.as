/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled so Find can copy stored values.
 * @topic Containers
 *
 * FillByFindValueReturnsStoredValueFName
 */
/**
 * @begin FillByFindValueReturnsStoredValueFName
 * @summary An &out TMap<FName, int> is filled so Find can copy stored values.
 * @topic Containers
 */
void FillByFindValueReturnsStoredValueFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Green", 2);
	Result.Add(n"Blue", 3);
}
/** @end */
