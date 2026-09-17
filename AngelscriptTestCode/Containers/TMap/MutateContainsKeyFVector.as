/**
 * @version v1
 * @summary An &inout TMap<int, FVector> Adds one pair so Contains can see a new key.
 * @topic Containers
 *
 * MutateContainsKeyFVector
 */
/**
 * @begin MutateContainsKeyFVector
 * @summary An &inout TMap<int, FVector> Adds one pair so Contains can see a new key.
 * @topic Containers
 */
void MutateContainsKeyFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
