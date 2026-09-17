/**
 * @version v1
 * @summary An &inout TOptional<FVector> is rewritten through GetValue.
 * @topic Containers
 *
 * MutateGetValueReturnsStoredIntFVector
 */
/**
 * @begin MutateGetValueReturnsStoredIntFVector
 * @summary An &inout TOptional<FVector> is rewritten through GetValue.
 * @topic Containers
 */
void MutateGetValueReturnsStoredIntFVector(TOptional<FVector>&inout Value)
{
	Value.GetValue() = FVector(0.0f, 1.0f, 0.0f);
}
/** @end */
