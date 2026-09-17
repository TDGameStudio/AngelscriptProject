/**
 * @version v1
 * @summary An &out TMap<int, int> is filled so Find can copy stored values.
 * @topic Containers
 *
 * FillByFindValueReturnsStoredValue
 */
/**
 * @begin FillByFindValueReturnsStoredValue
 * @summary An &out TMap<int, int> is filled so Find can copy stored values.
 * @topic Containers
 */
void FillByFindValueReturnsStoredValue(TMap<int, int>&out Result)
{
	Result.Add(10, 100);
	Result.Add(20, 200);
	Result.Add(30, 300);
}
/** @end */
