/**
 * @version v1
 * @summary An &inout TArray<UObject> is reserved in place without changing Num.
 * @topic Containers
 *
 * MutateReserveGrowsMaxWithoutChangingNumUObject
 */
/**
 * @begin MutateReserveGrowsMaxWithoutChangingNumUObject
 * @summary An &inout TArray<UObject> is reserved in place without changing Num.
 * @topic Containers
 */
void MutateReserveGrowsMaxWithoutChangingNumUObject(TArray<UObject>&inout Values)
{
	Values.Reserve(100);
}
/** @end */
