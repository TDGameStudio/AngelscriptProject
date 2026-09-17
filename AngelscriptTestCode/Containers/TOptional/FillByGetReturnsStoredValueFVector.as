/**
 * @version v1
 * @summary An &out TOptional<FVector> is filled so Get returns the stored value.
 * @topic Containers
 *
 * FillByGetReturnsStoredValueFVector
 */
/**
 * @begin FillByGetReturnsStoredValueFVector
 * @summary An &out TOptional<FVector> is filled so Get returns the stored value.
 * @topic Containers
 */
void FillByGetReturnsStoredValueFVector(TOptional<FVector>&out Result)
{
	Result.Set(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
