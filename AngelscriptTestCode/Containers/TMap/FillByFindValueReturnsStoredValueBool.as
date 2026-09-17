/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled so Find can copy stored values.
 * @topic Containers
 *
 * FillByFindValueReturnsStoredValueBool
 */
/**
 * @begin FillByFindValueReturnsStoredValueBool
 * @summary An &out TMap<int, bool> is filled so Find can copy stored values.
 * @topic Containers
 */
void FillByFindValueReturnsStoredValueBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(2, false);
	Result.Add(3, true);
}
/** @end */
