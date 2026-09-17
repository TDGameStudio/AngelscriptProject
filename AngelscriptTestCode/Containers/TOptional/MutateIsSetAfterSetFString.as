/**
 * @version v1
 * @summary An &inout TOptional<FString> is unset by Reset.
 * @topic Containers
 *
 * MutateIsSetAfterSetFString
 */
/**
 * @begin MutateIsSetAfterSetFString
 * @summary An &inout TOptional<FString> is unset by Reset.
 * @topic Containers
 */
void MutateIsSetAfterSetFString(TOptional<FString>&inout Value)
{
	Value.Reset();
}
/** @end */
