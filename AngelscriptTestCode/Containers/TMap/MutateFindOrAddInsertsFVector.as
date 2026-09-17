/**
 * @version v1
 * @summary An &inout TMap<int, FVector> inserts a missing key by FindOrAdd.
 * @topic Containers
 *
 * MutateFindOrAddInsertsFVector
 */
/**
 * @begin MutateFindOrAddInsertsFVector
 * @summary An &inout TMap<int, FVector> inserts a missing key by FindOrAdd.
 * @topic Containers
 */
void MutateFindOrAddInsertsFVector(TMap<int, FVector>&inout Values)
{
	Values.FindOrAdd(3) = FVector(0.0f, 0.0f, 1.0f);
}
/** @end */
