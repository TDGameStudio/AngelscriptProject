/**
 * @version v1
 * @summary An &inout TOptional<FVector> is unset by Reset.
 * @topic Containers
 *
 * MutateResetClearsFVector
 */
/**
 * @begin MutateResetClearsFVector
 * @summary An &inout TOptional<FVector> is unset by Reset.
 * @topic Containers
 */
void MutateResetClearsFVector(TOptional<FVector>&inout Value)
{
	Value.Reset();
}
/** @end */
