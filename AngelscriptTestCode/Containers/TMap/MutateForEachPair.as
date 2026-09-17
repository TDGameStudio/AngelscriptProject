/**
 * @version v1
 * @summary An &inout TMap<int, int> doubles each value through range-for.
 * @topic Containers
 *
 * MutateForEachPair
 */
/**
 * @begin MutateForEachPair
 * @summary An &inout TMap<int, int> doubles each value through range-for.
 * @topic Containers
 */
void MutateForEachPair(TMap<int, int>&inout Values)
{
	for (int Key, int Value : Values)
	{
		Values[Key] = Value * 2;
	}
}
/** @end */
