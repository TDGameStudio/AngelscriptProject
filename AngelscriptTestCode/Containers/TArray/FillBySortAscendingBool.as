/**
 * @version v1
 * @summary An &out TArray<bool> is filled then Sort orders it ascending.
 * @topic Containers
 *
 * FillBySortAscendingBool
 */
/**
 * @begin FillBySortAscendingBool
 * @summary An &out TArray<bool> is filled then Sort orders it ascending.
 * @topic Containers
 */
void FillBySortAscendingBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Sort();
}
/** @end */
