/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then RemoveAt drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtIndexFVector
 */
/**
 * @begin FillByRemoveAtIndexFVector
 * @summary An &out TArray<FVector> is filled then RemoveAt drops the first index.
 * @topic Containers
 */
void FillByRemoveAtIndexFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Add(FVector(1.0f, 1.0f, 0.0f));
	Result.RemoveAt(0);
}
/** @end */
