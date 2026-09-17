/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumFVector
 */
/**
 * @begin FillByResetClearsNumFVector
 * @summary An &out TMap<int, FVector> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumFVector(TMap<int, FVector>&out Result)
{
	Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	Result.Reset();
}
/** @end */
