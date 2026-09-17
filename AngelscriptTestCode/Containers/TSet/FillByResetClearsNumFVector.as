/**
 * @version v1
 * @summary An &out TSet<FVector> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumFVector
 */
/**
 * @begin FillByResetClearsNumFVector
 * @summary An &out TSet<FVector> is filled then Reset clears Num.
 * @topic Containers
 */
void FillByResetClearsNumFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Reset();
}
/** @end */
