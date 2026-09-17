/**
 * @version v1
 * @summary An &inout TSet<FVector> Adds one value so Num grows by one.
 * @topic Containers
 *
 * MutateNumCountsElementsFVector
 */
/**
 * @begin MutateNumCountsElementsFVector
 * @summary An &inout TSet<FVector> Adds one value so Num grows by one.
 * @topic Containers
 */
void MutateNumCountsElementsFVector(TSet<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
