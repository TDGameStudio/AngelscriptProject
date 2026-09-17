/**
 * @version v1
 * @summary An &inout TOptional<FVector> is overwritten by Set.
 * @topic Containers
 *
 * MutateSetValueFVector
 */
/**
 * @begin MutateSetValueFVector
 * @summary An &inout TOptional<FVector> is overwritten by Set.
 * @topic Containers
 */
void MutateSetValueFVector(TOptional<FVector>&inout Value)
{
	Value.Set(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
