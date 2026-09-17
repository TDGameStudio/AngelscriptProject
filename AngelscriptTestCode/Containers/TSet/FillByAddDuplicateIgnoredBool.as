/**
 * @version v1
 * @summary An &out TSet<bool> is filled by Add including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddDuplicateIgnoredBool
 */
/**
 * @begin FillByAddDuplicateIgnoredBool
 * @summary An &out TSet<bool> is filled by Add including a skipped duplicate.
 * @topic Containers
 */
void FillByAddDuplicateIgnoredBool(TSet<bool>&out Result)
{
	Result.Add(true);
	Result.Add(true);
}
/** @end */
