/**
 * @version v1
 * @summary An &inout TMap<FString, int> doubles each value through range-for.
 * @topic Containers
 *
 * MutateForEachPairFString
 */
/**
 * @begin MutateForEachPairFString
 * @summary An &inout TMap<FString, int> doubles each value through range-for.
 * @topic Containers
 */
void MutateForEachPairFString(TMap<FString, int>&inout Values)
{
	for (FString Key, int Value : Values)
	{
		Values[Key] = Value * 2;
	}
}
/** @end */
