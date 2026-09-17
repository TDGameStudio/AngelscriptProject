/**
 * @version v1
 * @summary An &inout TMap<int, bool> flips each value through range-for.
 * @topic Containers
 *
 * MutateForEachPairBool
 */
/**
 * @begin MutateForEachPairBool
 * @summary An &inout TMap<int, bool> flips each value through range-for.
 * @topic Containers
 */
void MutateForEachPairBool(TMap<int, bool>&inout Values)
{
	for (int Key, bool Value : Values)
	{
		Values[Key] = !Value;
	}
}
/** @end */
