/**
 * @version v1
 * @summary An &out TArray<FVector> is filled by Add in insertion order.
 * @topic Containers
 *
 * FillByAddFVector
 */
/**
 * @begin FillByAddFVector
 * @summary An &out TArray<FVector> is filled by Add in insertion order.
 * @topic Containers
 */
void FillByAddFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
