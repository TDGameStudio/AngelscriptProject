/**
 * @version v1
 * @summary An &inout TOptional<bool> is overwritten so Get returns the new stored value.
 * @topic Containers
 *
 * MutateGetReturnsStoredValueBool
 */
/**
 * @begin MutateGetReturnsStoredValueBool
 * @summary An &inout TOptional<bool> is overwritten so Get returns the new stored value.
 * @topic Containers
 */
void MutateGetReturnsStoredValueBool(TOptional<bool>&inout Value)
{
	Value.Set(false);
}
/** @end */
