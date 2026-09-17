/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then RemoveSwap deletes every match.
 * @topic Containers
 *
 * FillByRemoveSwapFVector
 */
/**
 * @begin FillByRemoveSwapFVector
 * @summary An &out TArray<FVector> is filled then RemoveSwap deletes every match.
 * @topic Containers
 */
void FillByRemoveSwapFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.RemoveSwap(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
