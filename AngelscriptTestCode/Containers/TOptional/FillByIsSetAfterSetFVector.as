/**
 * @version v1
 * @summary An &out TOptional<FVector> is marked set by Set.
 * @topic Containers
 *
 * FillByIsSetAfterSetFVector
 */
/**
 * @begin FillByIsSetAfterSetFVector
 * @summary An &out TOptional<FVector> is marked set by Set.
 * @topic Containers
 */
void FillByIsSetAfterSetFVector(TOptional<FVector>&out Result)
{
	Result.Set(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
