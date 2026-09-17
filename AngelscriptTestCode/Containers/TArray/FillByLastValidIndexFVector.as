/**
 * @version v1
 * @summary An &out TArray<FVector> is filled so Last() is the tail element.
 * @topic Containers
 *
 * FillByLastValidIndexFVector
 */
/**
 * @begin FillByLastValidIndexFVector
 * @summary An &out TArray<FVector> is filled so Last() is the tail element.
 * @topic Containers
 */
void FillByLastValidIndexFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
