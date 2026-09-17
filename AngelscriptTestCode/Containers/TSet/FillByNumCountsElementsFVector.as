/**
 * @version v1
 * @summary An &out TSet<FVector> is filled so Num becomes 2.
 * @topic Containers
 *
 * FillByNumCountsElementsFVector
 */
/**
 * @begin FillByNumCountsElementsFVector
 * @summary An &out TSet<FVector> is filled so Num becomes 2.
 * @topic Containers
 */
void FillByNumCountsElementsFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
