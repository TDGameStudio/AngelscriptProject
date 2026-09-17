/**
 * @version v1
 * @summary An &inout TOptional<int32> is overwritten so Get returns the new stored value.
 * @topic Containers
 *
 * MutateGetReturnsStoredValue
 */
/**
 * @begin MutateGetReturnsStoredValue
 * @summary An &inout TOptional<int32> is overwritten so Get returns the new stored value.
 * @topic Containers
 */
void MutateGetReturnsStoredValue(TOptional<int32>&inout Value)
{
	Value.Set(11);
}
/** @end */
