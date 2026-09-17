/**
 * @version v1
 * @summary An &inout TArray<int32> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 *
 * MutateFindIndexReturnsFirstOrMinusOne
 */
/**
 * @begin MutateFindIndexReturnsFirstOrMinusOne
 * @summary An &inout TArray<int32> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 */
void MutateFindIndexReturnsFirstOrMinusOne(TArray<int32>&inout Values)
{
	Values.Add(10);
}
/** @end */
