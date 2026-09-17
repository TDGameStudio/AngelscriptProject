/**
 * @version v1
 * @summary An &inout TArray<bool> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 *
 * MutateFindIndexReturnsFirstOrMinusOneBool
 */
/**
 * @begin MutateFindIndexReturnsFirstOrMinusOneBool
 * @summary An &inout TArray<bool> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 */
void MutateFindIndexReturnsFirstOrMinusOneBool(TArray<bool>&inout Values)
{
	Values.Add(false);
}
/** @end */
