/**
 * @version v1
 * @summary An &out TSet<FString> is filled by Add including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddDuplicateIgnoredFString
 */
/**
 * @begin FillByAddDuplicateIgnoredFString
 * @summary An &out TSet<FString> is filled by Add including a skipped duplicate.
 * @topic Containers
 */
void FillByAddDuplicateIgnoredFString(TSet<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("alpha");
}
/** @end */
