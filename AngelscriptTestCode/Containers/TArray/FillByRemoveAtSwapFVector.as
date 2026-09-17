/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtSwapFVector
 */
/**
 * @begin FillByRemoveAtSwapFVector
 * @summary An &out TArray<FVector> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 */
void FillByRemoveAtSwapFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Add(FVector(1.0f, 1.0f, 0.0f));
	Result.RemoveAtSwap(0);
}
/** @end */
