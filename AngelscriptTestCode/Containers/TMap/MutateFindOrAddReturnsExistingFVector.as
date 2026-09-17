/**
 * @version v1
 * @summary An &inout TMap<int, FVector> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 *
 * MutateFindOrAddReturnsExistingFVector
 */
/**
 * @begin MutateFindOrAddReturnsExistingFVector
 * @summary An &inout TMap<int, FVector> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 */
void MutateFindOrAddReturnsExistingFVector(TMap<int, FVector>&inout Values)
{
	Values.FindOrAdd(1, FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
