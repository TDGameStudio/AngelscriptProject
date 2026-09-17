/**
 * @version v1
 * @summary An &out TMap<int, int> is filled then Remove drops the middle key.
 * @topic Containers
 *
 * FillByRemoveKeyDropsPair
 */
/**
 * @begin FillByRemoveKeyDropsPair
 * @summary An &out TMap<int, int> is filled then Remove drops the middle key.
 * @topic Containers
 */
void FillByRemoveKeyDropsPair(TMap<int, int>&out Result)
{
	Result.Add(10, 100);
	Result.Add(20, 200);
	Result.Add(30, 300);
	Result.Remove(20);
}
/** @end */
