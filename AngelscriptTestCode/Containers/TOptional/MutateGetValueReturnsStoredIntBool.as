/**
 * @version v1
 * @summary An &inout TOptional<bool> is rewritten through GetValue.
 * @topic Containers
 *
 * MutateGetValueReturnsStoredIntBool
 */
/**
 * @begin MutateGetValueReturnsStoredIntBool
 * @summary An &inout TOptional<bool> is rewritten through GetValue.
 * @topic Containers
 */
void MutateGetValueReturnsStoredIntBool(TOptional<bool>&inout Value)
{
	Value.GetValue() = false;
}
/** @end */
