/**
 * @version v1
 * @summary An &out TArray<FString> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddUniqueRejectsDuplicateFString
 */
/**
 * @begin FillByAddUniqueRejectsDuplicateFString
 * @summary An &out TArray<FString> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 */
void FillByAddUniqueRejectsDuplicateFString(TArray<FString>&out Result)
{
	Result.AddUnique("alpha");
	Result.AddUnique("beta");
	Result.AddUnique("alpha");
	Result.AddUnique("gamma");
}
/** @end */
