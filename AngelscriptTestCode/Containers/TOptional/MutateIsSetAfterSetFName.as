/**
 * @version v1
 * @summary An &inout TOptional<FName> is unset by Reset.
 * @topic Containers
 *
 * MutateIsSetAfterSetFName
 */
/**
 * @begin MutateIsSetAfterSetFName
 * @summary An &inout TOptional<FName> is unset by Reset.
 * @topic Containers
 */
void MutateIsSetAfterSetFName(TOptional<FName>&inout Value)
{
	Value.Reset();
}
/** @end */
