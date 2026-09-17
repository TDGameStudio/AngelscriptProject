/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 *
 * FillByRemoveSinglePreservesOrderFVector
 */
/**
 * @begin FillByRemoveSinglePreservesOrderFVector
 * @summary An &out TArray<FVector> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 */
void FillByRemoveSinglePreservesOrderFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.RemoveSingle(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
