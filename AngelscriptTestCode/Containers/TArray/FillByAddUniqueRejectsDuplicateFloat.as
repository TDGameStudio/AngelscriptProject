/**
 * @version v1
 * @summary An &out TArray<float> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddUniqueRejectsDuplicateFloat
 */
/**
 * @begin FillByAddUniqueRejectsDuplicateFloat
 * @summary An &out TArray<float> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 */
void FillByAddUniqueRejectsDuplicateFloat(TArray<float>&out Result)
{
	Result.AddUnique(10.0f);
	Result.AddUnique(20.0f);
	Result.AddUnique(10.0f);
	Result.AddUnique(30.0f);
}
/** @end */
