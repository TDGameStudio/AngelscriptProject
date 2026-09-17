/**
 * @version v1
 * @summary An &inout TOptional<FString> is unset by Reset.
 * @topic Containers
 *
 * MutateResetClearsFString
 */
/**
 * @begin MutateResetClearsFString
 * @summary An &inout TOptional<FString> is unset by Reset.
 * @topic Containers
 */
void MutateResetClearsFString(TOptional<FString>&inout Value)
{
	Value.Reset();
}
/** @end */
