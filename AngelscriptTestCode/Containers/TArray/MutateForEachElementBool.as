/**
 * @version v1
 * @summary An &inout TArray<bool> is inverted in place by range-for ref.
 * @topic Containers
 *
 * MutateForEachElementBool
 */
/**
 * @begin MutateForEachElementBool
 * @summary An &inout TArray<bool> is inverted in place by range-for ref.
 * @topic Containers
 */
void MutateForEachElementBool(TArray<bool>&inout Values)
{
	for (bool& Value : Values)
	{
		Value = !Value;
	}
}
/** @end */
