/**
 * @version v1
 * @summary An &inout TOptional<int32> is rewritten through GetValue.
 * @topic Containers
 *
 * MutateGetValueReturnsStoredInt
 */
/**
 * @begin MutateGetValueReturnsStoredInt
 * @summary An &inout TOptional<int32> is rewritten through GetValue.
 * @topic Containers
 */
void MutateGetValueReturnsStoredInt(TOptional<int32>&inout Value)
{
	Value.GetValue() = 11;
}
/** @end */
