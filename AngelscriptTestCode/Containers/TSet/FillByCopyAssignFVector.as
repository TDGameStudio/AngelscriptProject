/**
 * @version v1
 * @summary An &out TSet<FVector> is filled by assigning a local source set.
 * @topic Containers
 *
 * FillByCopyAssignFVector
 */
/**
 * @begin FillByCopyAssignFVector
 * @summary An &out TSet<FVector> is filled by assigning a local source set.
 * @topic Containers
 */
void FillByCopyAssignFVector(TSet<FVector>&out Result)
{
	TSet<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Result = Source;
}
/** @end */
