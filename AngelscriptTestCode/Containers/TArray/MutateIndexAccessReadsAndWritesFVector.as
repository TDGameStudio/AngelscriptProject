/**
 * @version v1
 * @summary An &inout TArray<FVector> writes one [] slot in place.
 * @topic Containers
 *
 * MutateIndexAccessReadsAndWritesFVector
 */
/**
 * @begin MutateIndexAccessReadsAndWritesFVector
 * @summary An &inout TArray<FVector> writes one [] slot in place.
 * @topic Containers
 */
void MutateIndexAccessReadsAndWritesFVector(TArray<FVector>&inout Values)
{
	Values[1] = FVector(1.0f, 1.0f, 1.0f);
}
/** @end */
