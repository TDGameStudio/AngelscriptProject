/**
 * @version v1
 * @summary An &out TSet<FVector> is filled by Add.
 * @topic Containers
 *
 * FillByAddElementIsContainedFVector
 */
/**
 * @begin FillByAddElementIsContainedFVector
 * @summary An &out TSet<FVector> is filled by Add.
 * @topic Containers
 */
void FillByAddElementIsContainedFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
