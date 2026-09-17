/**
 * @version v1
 * @summary An &out TArray<FVector> is filled so Num becomes 3.
 * @topic Containers
 *
 * FillByNumCountsElementsFVector
 */
/**
 * @begin FillByNumCountsElementsFVector
 * @summary An &out TArray<FVector> is filled so Num becomes 3.
 * @topic Containers
 */
void FillByNumCountsElementsFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
