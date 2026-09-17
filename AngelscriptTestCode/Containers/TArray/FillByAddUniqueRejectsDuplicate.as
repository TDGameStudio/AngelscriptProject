/**
 * @version v1
 * @summary An &out TArray<int32> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddUniqueRejectsDuplicate
 */
/**
 * @begin FillByAddUniqueRejectsDuplicate
 * @summary An &out TArray<int32> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 */
void FillByAddUniqueRejectsDuplicate(TArray<int32>&out Result)
{
	Result.AddUnique(10);
	Result.AddUnique(20);
	Result.AddUnique(10);
	Result.AddUnique(30);
}
/** @end */
