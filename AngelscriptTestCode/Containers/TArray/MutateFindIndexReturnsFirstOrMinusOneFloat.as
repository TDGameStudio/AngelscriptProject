/**
 * @version v1
 * @summary An &inout TArray<float> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 *
 * MutateFindIndexReturnsFirstOrMinusOneFloat
 */
/**
 * @begin MutateFindIndexReturnsFirstOrMinusOneFloat
 * @summary An &inout TArray<float> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 */
void MutateFindIndexReturnsFirstOrMinusOneFloat(TArray<float>&inout Values)
{
	Values.Add(10.0f);
}
/** @end */
