/**
 * @version v1
 * @summary An &inout TArray<int32> is doubled in place by range-for ref.
 * @topic Containers
 *
 * MutateForEachElement
 */
/**
 * @begin MutateForEachElement
 * @summary An &inout TArray<int32> is doubled in place by range-for ref.
 * @topic Containers
 */
void MutateForEachElement(TArray<int32>&inout Values)
{
	for (int32& Value : Values)
	{
		Value *= 2;
	}
}
/** @end */
