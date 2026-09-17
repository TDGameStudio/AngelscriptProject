/**
 * @version v1
 * @summary An &inout TOptional<int32> is unset by Reset.
 * @topic Containers
 *
 * MutateResetClears
 */
/**
 * @begin MutateResetClears
 * @summary An &inout TOptional<int32> is unset by Reset.
 * @topic Containers
 */
void MutateResetClears(TOptional<int32>&inout Value)
{
	Value.Reset();
}
/** @end */
