/**
 * @version v1
 * @summary An &out TSet<int32> is filled by Add including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddDuplicateIgnored
 */
/**
 * @begin FillByAddDuplicateIgnored
 * @summary An &out TSet<int32> is filled by Add including a skipped duplicate.
 * @topic Containers
 */
void FillByAddDuplicateIgnored(TSet<int32>&out Result)
{
	Result.Add(10);
	Result.Add(10);
}
/** @end */
