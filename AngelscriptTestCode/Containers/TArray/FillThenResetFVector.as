/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then emptied by Reset.
 * @topic Containers
 *
 * FillThenResetFVector
 */
/**
 * @begin FillThenResetFVector
 * @summary An &out TArray<FVector> is filled then emptied by Reset.
 * @topic Containers
 */
void FillThenResetFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Reset();
}
/** @end */
