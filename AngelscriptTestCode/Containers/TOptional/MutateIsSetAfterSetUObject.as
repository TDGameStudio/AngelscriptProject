/**
 * @version v1
 * @summary An &inout TOptional<UObject> is unset by Reset.
 * @topic Containers
 *
 * MutateIsSetAfterSetUObject
 */
/**
 * @begin MutateIsSetAfterSetUObject
 * @summary An &inout TOptional<UObject> is unset by Reset.
 * @topic Containers
 */
void MutateIsSetAfterSetUObject(TOptional<UObject>&inout Value)
{
	Value.Reset();
}
/** @end */
