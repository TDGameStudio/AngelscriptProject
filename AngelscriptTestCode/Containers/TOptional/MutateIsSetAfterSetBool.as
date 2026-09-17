/**
 * @version v1
 * @summary An &inout TOptional<bool> is unset by Reset.
 * @topic Containers
 *
 * MutateIsSetAfterSetBool
 */
/**
 * @begin MutateIsSetAfterSetBool
 * @summary An &inout TOptional<bool> is unset by Reset.
 * @topic Containers
 */
void MutateIsSetAfterSetBool(TOptional<bool>&inout Value)
{
	Value.Reset();
}
/** @end */
