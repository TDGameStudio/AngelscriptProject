/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled then Remove drops the middle key.
 * @topic Containers
 *
 * FillByRemoveKeyDropsPairBool
 */
/**
 * @begin FillByRemoveKeyDropsPairBool
 * @summary An &out TMap<int, bool> is filled then Remove drops the middle key.
 * @topic Containers
 */
void FillByRemoveKeyDropsPairBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(2, false);
	Result.Add(3, true);
	Result.Remove(2);
}
/** @end */
