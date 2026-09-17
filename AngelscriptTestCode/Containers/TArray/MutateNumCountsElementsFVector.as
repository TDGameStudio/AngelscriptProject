/**
 * @version v1
 * @summary An &inout TArray<FVector> Adds one value so Num grows by one.
 * @topic Containers
 *
 * MutateNumCountsElementsFVector
 */
/**
 * @begin MutateNumCountsElementsFVector
 * @summary An &inout TArray<FVector> Adds one value so Num grows by one.
 * @topic Containers
 */
void MutateNumCountsElementsFVector(TArray<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
