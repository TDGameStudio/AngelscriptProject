/**
 * @version v1
 * @summary An &inout TArray<FVector> is scaled in place by range-for ref.
 * @topic Containers
 *
 * MutateForEachElementFVector
 */
/**
 * @begin MutateForEachElementFVector
 * @summary An &inout TArray<FVector> is scaled in place by range-for ref.
 * @topic Containers
 */
void MutateForEachElementFVector(TArray<FVector>&inout Values)
{
	for (FVector& Value : Values)
	{
		Value *= 2.0f;
	}
}
/** @end */
