/**
 * @version v1
 * @summary An &out TSet<FName> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 *
 * FillByRemoveMissingFName
 */
/**
 * @begin FillByRemoveMissingFName
 * @summary An &out TSet<FName> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 */
void FillByRemoveMissingFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
	Result.Remove(n"Missing");
}
/** @end */
