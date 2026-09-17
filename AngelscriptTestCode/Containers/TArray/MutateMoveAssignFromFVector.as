/**
 * @version v1
 * @summary An &inout TArray<FVector> is replaced by MoveAssignFrom.
 * @topic Containers
 *
 * MutateMoveAssignFromFVector
 */
/**
 * @begin MutateMoveAssignFromFVector
 * @summary An &inout TArray<FVector> is replaced by MoveAssignFrom.
 * @topic Containers
 */
void MutateMoveAssignFromFVector(TArray<FVector>&inout Values)
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.MoveAssignFrom(Source);
}
/** @end */
