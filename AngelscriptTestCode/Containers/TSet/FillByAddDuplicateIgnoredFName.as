/**
 * @version v1
 * @summary An &out TSet<FName> is filled by Add including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddDuplicateIgnoredFName
 */
/**
 * @begin FillByAddDuplicateIgnoredFName
 * @summary An &out TSet<FName> is filled by Add including a skipped duplicate.
 * @topic Containers
 */
void FillByAddDuplicateIgnoredFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
	Result.Add(n"Red");
}
/** @end */
