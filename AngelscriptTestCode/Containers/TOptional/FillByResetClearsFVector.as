/**
 * @version v1
 * @summary An &out TOptional<FVector> is set then Reset back to unset.
 * @topic Containers
 *
 * FillByResetClearsFVector
 */
/**
 * @begin FillByResetClearsFVector
 * @summary An &out TOptional<FVector> is set then Reset back to unset.
 * @topic Containers
 */
void FillByResetClearsFVector(TOptional<FVector>&out Result)
{
	Result.Set(FVector(1.0f, 0.0f, 0.0f));
	Result.Reset();
}
/** @end */
