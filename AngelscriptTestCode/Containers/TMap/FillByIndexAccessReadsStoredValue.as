/**
 * @version v1
 * @summary An &out TMap<int, int> is filled so bracket access can read stored values.
 * @topic Containers
 *
 * FillByIndexAccessReadsStoredValue
 */
/**
 * @begin FillByIndexAccessReadsStoredValue
 * @summary An &out TMap<int, int> is filled so bracket access can read stored values.
 * @topic Containers
 */
void FillByIndexAccessReadsStoredValue(TMap<int, int>&out Result)
{
	Result.Add(10, 100);
	Result.Add(20, 200);
	Result.Add(30, 300);
}
/** @end */
