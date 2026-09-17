/**
 * @version v1
 * @summary An &out TOptional<FVector> is filled by copy assignment.
 * @topic Containers
 *
 * FillByCopyAssignFVector
 */
/**
 * @begin FillByCopyAssignFVector
 * @summary An &out TOptional<FVector> is filled by copy assignment.
 * @topic Containers
 */
void FillByCopyAssignFVector(TOptional<FVector>&out Result)
{
	TOptional<FVector> Source;
	Source.Set(FVector(1.0f, 0.0f, 0.0f));
	Result = Source;
}
/** @end */
