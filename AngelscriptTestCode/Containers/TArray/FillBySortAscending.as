/**
 * @version v1
 * @summary An &out TArray<int32> is filled then Sort orders it ascending.
 * @topic Containers
 *
 * FillBySortAscending
 */
/**
 * @begin FillBySortAscending
 * @summary An &out TArray<int32> is filled then Sort orders it ascending.
 * @topic Containers
 */
void FillBySortAscending(TArray<int32>&out Result)
{
	Result.Add(30);
	Result.Add(10);
	Result.Add(20);
	Result.Sort();
}
/** @end */
