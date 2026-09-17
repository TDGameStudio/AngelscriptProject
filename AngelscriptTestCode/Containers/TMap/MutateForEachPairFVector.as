/**
 * @version v1
 * @summary An &inout TMap<int, FVector> scales each value through range-for.
 * @topic Containers
 *
 * MutateForEachPairFVector
 */
/**
 * @begin MutateForEachPairFVector
 * @summary An &inout TMap<int, FVector> scales each value through range-for.
 * @topic Containers
 */
void MutateForEachPairFVector(TMap<int, FVector>&inout Values)
{
	for (int Key, FVector Value : Values)
	{
		Values[Key] = Value * 2.0f;
	}
}
/** @end */
