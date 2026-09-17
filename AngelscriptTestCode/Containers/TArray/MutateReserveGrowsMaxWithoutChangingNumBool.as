/**
 * @version v1
 * @summary An &inout TArray<bool> is reserved in place without changing Num.
 * @topic Containers
 *
 * MutateReserveGrowsMaxWithoutChangingNumBool
 */
/**
 * @begin MutateReserveGrowsMaxWithoutChangingNumBool
 * @summary An &inout TArray<bool> is reserved in place without changing Num.
 * @topic Containers
 */
void MutateReserveGrowsMaxWithoutChangingNumBool(TArray<bool>&inout Values)
{
	Values.Reserve(100);
}
/** @end */
