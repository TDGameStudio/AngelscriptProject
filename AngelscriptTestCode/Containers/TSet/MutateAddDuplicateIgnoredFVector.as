/**
 * @version v1
 * @summary An &inout TSet<FVector> receives a duplicate Add.
 * @topic Containers
 *
 * MutateAddDuplicateIgnoredFVector
 */
/**
 * @begin MutateAddDuplicateIgnoredFVector
 * @summary An &inout TSet<FVector> receives a duplicate Add.
 * @topic Containers
 */
void MutateAddDuplicateIgnoredFVector(TSet<FVector>&inout Values)
{
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
