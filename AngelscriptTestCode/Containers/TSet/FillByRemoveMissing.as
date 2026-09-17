/**
 * @version v1
 * @summary An &out TSet<int32> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 *
 * FillByRemoveMissing
 */
/**
 * @begin FillByRemoveMissing
 * @summary An &out TSet<int32> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 */
void FillByRemoveMissing(TSet<int32>&out Result)
{
	Result.Add(10);
	Result.Remove(99);
}
/** @end */
