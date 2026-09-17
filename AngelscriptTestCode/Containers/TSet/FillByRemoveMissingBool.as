/**
 * @version v1
 * @summary An &out TSet<bool> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 *
 * FillByRemoveMissingBool
 */
/**
 * @begin FillByRemoveMissingBool
 * @summary An &out TSet<bool> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 */
void FillByRemoveMissingBool(TSet<bool>&out Result)
{
	Result.Add(true);
	Result.Remove(false);
}
/** @end */
