/**
 * @version v1
 * @summary An &inout TArray<int32> is reserved in place without changing Num.
 * @topic Containers
 *
 * MutateReserveGrowsMaxWithoutChangingNum
 */
/**
 * @begin MutateReserveGrowsMaxWithoutChangingNum
 * @summary An &inout TArray<int32> is reserved in place without changing Num.
 * @topic Containers
 */
void MutateReserveGrowsMaxWithoutChangingNum(TArray<int32>&inout Values)
{
	Values.Reserve(100);
}
/** @end */
