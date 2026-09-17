/**
 * @version v1
 * @summary An &inout TOptional<bool> is unset by Reset.
 * @topic Containers
 *
 * MutateResetClearsBool
 */
/**
 * @begin MutateResetClearsBool
 * @summary An &inout TOptional<bool> is unset by Reset.
 * @topic Containers
 */
void MutateResetClearsBool(TOptional<bool>&inout Value)
{
	Value.Reset();
}
/** @end */
