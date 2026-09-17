/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Add of a present member only.
 * @topic Containers
 *
 * MutateContainsMissingFVector
 */
/**
 * @begin MutateContainsMissingFVector
 * @summary An &inout TSet<FVector> receives Add of a present member only.
 * @topic Containers
 */
void MutateContainsMissingFVector(TSet<FVector>&inout Values)
{
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
