/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then Swap exchanges ends.
 * @topic Containers
 *
 * FillBySwapElementsFVector
 */
/**
 * @begin FillBySwapElementsFVector
 * @summary An &out TArray<FVector> is filled then Swap exchanges ends.
 * @topic Containers
 */
void FillBySwapElementsFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Swap(0, 2);
}
/** @end */
