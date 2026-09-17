/**
 * @version v1
 * @summary An &inout TArray<FVector> receives Insert at an index.
 * @topic Containers
 *
 * MutateInsertShiftsFollowingFVector
 */
/**
 * @begin MutateInsertShiftsFollowingFVector
 * @summary An &inout TArray<FVector> receives Insert at an index.
 * @topic Containers
 */
void MutateInsertShiftsFollowingFVector(TArray<FVector>&inout Values)
{
	Values.Insert(FVector(0.0f, 1.0f, 0.0f), 1);
}
/** @end */
