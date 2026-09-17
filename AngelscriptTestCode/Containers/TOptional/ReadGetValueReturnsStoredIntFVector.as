/**
 * @version v1
 * @summary A const&in TOptional<FVector> returns the stored value from GetValue.
 * @topic Containers
 *
 * ReadGetValueReturnsStoredIntFVector
 */
/**
 * @begin ReadGetValueReturnsStoredIntFVector
 * @summary A const&in TOptional<FVector> returns the stored value from GetValue.
 * @topic Containers
 */
bool ReadGetValueReturnsStoredIntFVector(const TOptional<FVector>&in Value)
{
	return Value.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
