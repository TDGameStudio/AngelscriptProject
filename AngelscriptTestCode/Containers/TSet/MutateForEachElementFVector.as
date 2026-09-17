/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Add of one more member.
 * @topic Containers
 *
 * MutateForEachElementFVector
 */
/**
 * @begin MutateForEachElementFVector
 * @summary An &inout TSet<FVector> receives Add of one more member.
 * @topic Containers
 */
void MutateForEachElementFVector(TSet<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
