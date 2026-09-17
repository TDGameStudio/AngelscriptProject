/**
 * @version v1
 * @summary An &inout TMap<int, FVector> is replaced by assigning a new map.
 * @topic Containers
 *
 * MutateCopyAssignFVector
 */
/**
 * @begin MutateCopyAssignFVector
 * @summary An &inout TMap<int, FVector> is replaced by assigning a new map.
 * @topic Containers
 */
void MutateCopyAssignFVector(TMap<int, FVector>&inout Values)
{
	TMap<int, FVector> Source;
	Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Source.Add(3, FVector(0.0f, 0.0f, 1.0f));
	Values = Source;
}
/** @end */
