/**
 * @version v1
 * @summary An &inout TArray<FVector> overwrites Last() in place.
 * @topic Containers
 *
 * MutateLastValidIndexFVector
 */
/**
 * @begin MutateLastValidIndexFVector
 * @summary An &inout TArray<FVector> overwrites Last() in place.
 * @topic Containers
 */
void MutateLastValidIndexFVector(TArray<FVector>&inout Values)
{
	Values.Last() = FVector(9.0f, 9.0f, 9.0f);
}
/** @end */
