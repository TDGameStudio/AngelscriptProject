/**
 * @version v1
 * @summary An &out TArray<bool> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 *
 * FillByRemoveSinglePreservesOrderBool
 */
/**
 * @begin FillByRemoveSinglePreservesOrderBool
 * @summary An &out TArray<bool> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 */
void FillByRemoveSinglePreservesOrderBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(false);
	Result.Add(true);
	Result.RemoveSingle(false);
}
/** @end */
