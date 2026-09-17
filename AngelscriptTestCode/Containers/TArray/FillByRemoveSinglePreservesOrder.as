/**
 * @version v1
 * @summary An &out TArray<int32> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 *
 * FillByRemoveSinglePreservesOrder
 */
/**
 * @begin FillByRemoveSinglePreservesOrder
 * @summary An &out TArray<int32> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 */
void FillByRemoveSinglePreservesOrder(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(2);
	Result.Add(3);
	Result.RemoveSingle(2);
}
/** @end */
