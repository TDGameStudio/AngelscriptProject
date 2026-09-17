/**
 * @version v1
 * @summary An &inout TArray<float> overwrites Last() in place.
 * @topic Containers
 *
 * MutateLastValidIndexFloat
 */
/**
 * @begin MutateLastValidIndexFloat
 * @summary An &inout TArray<float> overwrites Last() in place.
 * @topic Containers
 */
void MutateLastValidIndexFloat(TArray<float>&inout Values)
{
	Values.Last() = 99.0f;
}
/** @end */
