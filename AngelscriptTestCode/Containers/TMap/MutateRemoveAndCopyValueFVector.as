/**
 * @version v1
 * @summary An &inout TMap<int, FVector> copies a value out and drops the pair.
 * @topic Containers
 *
 * MutateRemoveAndCopyValueFVector
 */
/**
 * @begin MutateRemoveAndCopyValueFVector
 * @summary An &inout TMap<int, FVector> copies a value out and drops the pair.
 * @topic Containers
 */
void MutateRemoveAndCopyValueFVector(TMap<int, FVector>&inout Values)
{
	FVector OutValue = FVector(0.0f, 0.0f, 0.0f);
	Values.RemoveAndCopyValue(1, OutValue);
}
/** @end */
