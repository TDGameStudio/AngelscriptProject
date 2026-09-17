/**
 * @version v1
 * @summary An &inout TOptional<UObject> is unset by Reset.
 * @topic Containers
 *
 * MutateResetClearsUObject
 */
/**
 * @begin MutateResetClearsUObject
 * @summary An &inout TOptional<UObject> is unset by Reset.
 * @topic Containers
 */
void MutateResetClearsUObject(TOptional<UObject>&inout Value)
{
	Value.Reset();
}
/** @end */
