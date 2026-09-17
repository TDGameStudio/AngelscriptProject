/**
 * @version v1
 * @summary An &out TOptional<FVector> is filled by Set.
 * @topic Containers
 *
 * FillBySetValueFVector
 */
/**
 * @begin FillBySetValueFVector
 * @summary An &out TOptional<FVector> is filled by Set.
 * @topic Containers
 */
void FillBySetValueFVector(TOptional<FVector>&out Result)
{
	Result.Set(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
