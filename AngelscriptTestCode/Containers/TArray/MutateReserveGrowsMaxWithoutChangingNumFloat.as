/**
 * @version v1
 * @summary An &inout TArray<float> is reserved in place without changing Num.
 * @topic Containers
 *
 * MutateReserveGrowsMaxWithoutChangingNumFloat
 */
/**
 * @begin MutateReserveGrowsMaxWithoutChangingNumFloat
 * @summary An &inout TArray<float> is reserved in place without changing Num.
 * @topic Containers
 */
void MutateReserveGrowsMaxWithoutChangingNumFloat(TArray<float>&inout Values)
{
	Values.Reserve(100);
}
/** @end */
