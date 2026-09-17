/**
 * @version v1
 * @summary An &inout TArray<float> is doubled in place by range-for ref.
 * @topic Containers
 *
 * MutateForEachElementFloat
 */
/**
 * @begin MutateForEachElementFloat
 * @summary An &inout TArray<float> is doubled in place by range-for ref.
 * @topic Containers
 */
void MutateForEachElementFloat(TArray<float>&inout Values)
{
	for (float& Value : Values)
	{
		Value *= 2.0f;
	}
}
/** @end */
