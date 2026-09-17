/**
 * @version v1
 * @summary An &out TArray<bool> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddUniqueRejectsDuplicateBool
 */
/**
 * @begin FillByAddUniqueRejectsDuplicateBool
 * @summary An &out TArray<bool> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 */
void FillByAddUniqueRejectsDuplicateBool(TArray<bool>&out Result)
{
	Result.AddUnique(true);
	Result.AddUnique(false);
	Result.AddUnique(true);
}
/** @end */
