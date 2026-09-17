/**
 * @version v1
 * @summary An &out TArray<FVector> is filled by assigning a local source array.
 * @topic Containers
 *
 * FillByCopyAssignFVector
 */
/**
 * @begin FillByCopyAssignFVector
 * @summary An &out TArray<FVector> is filled by assigning a local source array.
 * @topic Containers
 */
void FillByCopyAssignFVector(TArray<FVector>&out Result)
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Result = Source;
}
/** @end */
