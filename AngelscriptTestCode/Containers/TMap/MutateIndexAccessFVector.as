/**
 * @version v1
 * @summary An &inout TMap<int, FVector> writes an existing key through bracket access.
 * @topic Containers
 *
 * MutateIndexAccessFVector
 */
/**
 * @begin MutateIndexAccessFVector
 * @summary An &inout TMap<int, FVector> writes an existing key through bracket access.
 * @topic Containers
 */
void MutateIndexAccessFVector(TMap<int, FVector>&inout Values)
{
	Values[1] = FVector(9.0f, 9.0f, 9.0f);
}
/** @end */
