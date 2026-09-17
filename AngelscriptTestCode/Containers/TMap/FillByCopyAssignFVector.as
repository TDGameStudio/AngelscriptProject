/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled by assigning a local source map.
 * @topic Containers
 *
 * FillByCopyAssignFVector
 */
/**
 * @begin FillByCopyAssignFVector
 * @summary An &out TMap<int, FVector> is filled by assigning a local source map.
 * @topic Containers
 */
void FillByCopyAssignFVector(TMap<int, FVector>&out Result)
{
	TMap<int, FVector> Source;
	Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Source.Add(3, FVector(0.0f, 0.0f, 1.0f));
	Result = Source;
}
/** @end */
