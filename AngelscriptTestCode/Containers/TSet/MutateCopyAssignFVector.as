/**
 * @version v1
 * @summary An &inout TSet<FVector> is replaced by assigning a new set.
 * @topic Containers
 *
 * MutateCopyAssignFVector
 */
/**
 * @begin MutateCopyAssignFVector
 * @summary An &inout TSet<FVector> is replaced by assigning a new set.
 * @topic Containers
 */
void MutateCopyAssignFVector(TSet<FVector>&inout Values)
{
	TSet<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Values = Source;
}
/** @end */
