/**
 * @version v1
 * @summary An &inout TMap<int, FVector> receives Add of a third pair.
 * @topic Containers
 *
 * MutateAddPairInsertsKeyValueFVector
 */
/**
 * @begin MutateAddPairInsertsKeyValueFVector
 * @summary An &inout TMap<int, FVector> receives Add of a third pair.
 * @topic Containers
 */
void MutateAddPairInsertsKeyValueFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
