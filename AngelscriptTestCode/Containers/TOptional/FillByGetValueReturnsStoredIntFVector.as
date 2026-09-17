/**
 * @version v1
 * @summary An &out TOptional<FVector> is filled so GetValue can read it.
 * @topic Containers
 *
 * FillByGetValueReturnsStoredIntFVector
 */
/**
 * @begin FillByGetValueReturnsStoredIntFVector
 * @summary An &out TOptional<FVector> is filled so GetValue can read it.
 * @topic Containers
 */
void FillByGetValueReturnsStoredIntFVector(TOptional<FVector>&out Result)
{
	Result.Set(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
