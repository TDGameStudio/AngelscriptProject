/**
 * @version v1
 * @summary An &inout TOptional<FName> is unset by Reset.
 * @topic Containers
 *
 * MutateResetClearsFName
 */
/**
 * @begin MutateResetClearsFName
 * @summary An &inout TOptional<FName> is unset by Reset.
 * @topic Containers
 */
void MutateResetClearsFName(TOptional<FName>&inout Value)
{
	Value.Reset();
}
/** @end */
