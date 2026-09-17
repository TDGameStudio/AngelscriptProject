/**
 * @version v1
 * @summary An &inout TOptional<FVector> is overwritten so Get returns the new stored value.
 * @topic Containers
 *
 * MutateGetReturnsStoredValueFVector
 */
/**
 * @begin MutateGetReturnsStoredValueFVector
 * @summary An &inout TOptional<FVector> is overwritten so Get returns the new stored value.
 * @topic Containers
 */
void MutateGetReturnsStoredValueFVector(TOptional<FVector>&inout Value)
{
	Value.Set(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
