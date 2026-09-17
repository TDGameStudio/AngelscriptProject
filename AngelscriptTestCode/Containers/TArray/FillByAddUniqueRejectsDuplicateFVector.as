/**
 * @version v1
 * @summary An &out TArray<FVector> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddUniqueRejectsDuplicateFVector
 */
/**
 * @begin FillByAddUniqueRejectsDuplicateFVector
 * @summary An &out TArray<FVector> is filled by AddUnique including a skipped duplicate.
 * @topic Containers
 */
void FillByAddUniqueRejectsDuplicateFVector(TArray<FVector>&out Result)
{
	Result.AddUnique(FVector(1.0f, 0.0f, 0.0f));
	Result.AddUnique(FVector(0.0f, 1.0f, 0.0f));
	Result.AddUnique(FVector(1.0f, 0.0f, 0.0f));
	Result.AddUnique(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
