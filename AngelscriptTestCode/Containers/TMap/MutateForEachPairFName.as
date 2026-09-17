/**
 * @version v1
 * @summary An &inout TMap<FName, int> doubles each value through range-for.
 * @topic Containers
 *
 * MutateForEachPairFName
 */
/**
 * @begin MutateForEachPairFName
 * @summary An &inout TMap<FName, int> doubles each value through range-for.
 * @topic Containers
 */
void MutateForEachPairFName(TMap<FName, int>&inout Values)
{
	for (FName Key, int Value : Values)
	{
		Values[Key] = Value * 2;
	}
}
/** @end */
