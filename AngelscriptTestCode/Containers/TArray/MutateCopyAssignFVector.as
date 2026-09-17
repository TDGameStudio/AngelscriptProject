/**
 * @version v1
 * @summary An &inout TArray<FVector> is replaced by assigning a new sequence.
 * @topic Containers
 *
 * MutateCopyAssignFVector
 */
/**
 * @begin MutateCopyAssignFVector
 * @summary An &inout TArray<FVector> is replaced by assigning a new sequence.
 * @topic Containers
 */
void MutateCopyAssignFVector(TArray<FVector>&inout Values)
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Values = Source;
}
/** @end */
