/**
 * @version v1
 * @summary An &inout TArray<FVector> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 *
 * MutateRemoveSinglePreservesOrderFVector
 */
/**
 * @begin MutateRemoveSinglePreservesOrderFVector
 * @summary An &inout TArray<FVector> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 */
void MutateRemoveSinglePreservesOrderFVector(TArray<FVector>&inout Values)
{
	Values.RemoveSingle(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
