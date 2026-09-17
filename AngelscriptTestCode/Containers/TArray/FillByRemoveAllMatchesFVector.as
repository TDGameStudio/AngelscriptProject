/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then Remove deletes every match.
 * @topic Containers
 *
 * FillByRemoveAllMatchesFVector
 */
/**
 * @begin FillByRemoveAllMatchesFVector
 * @summary An &out TArray<FVector> is filled then Remove deletes every match.
 * @topic Containers
 */
void FillByRemoveAllMatchesFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(1.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 1.0f));
	Result.Remove(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
