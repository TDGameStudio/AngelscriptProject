/**
 * @version v1
 * @summary An &inout TMap<int, FVector> Adds one pair so Num becomes 3.
 * @topic Containers
 *
 * MutateNumCountsPairsFVector
 */
/**
 * @begin MutateNumCountsPairsFVector
 * @summary An &inout TMap<int, FVector> Adds one pair so Num becomes 3.
 * @topic Containers
 */
void MutateNumCountsPairsFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
