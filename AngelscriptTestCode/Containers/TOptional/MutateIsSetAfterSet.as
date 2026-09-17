/**
 * @version v1
 * @summary An &inout TOptional<int32> is unset by Reset.
 * @topic Containers
 *
 * MutateIsSetAfterSet
 */
/**
 * @begin MutateIsSetAfterSet
 * @summary An &inout TOptional<int32> is unset by Reset.
 * @topic Containers
 */
void MutateIsSetAfterSet(TOptional<int32>&inout Value)
{
	Value.Reset();
}
/** @end */
