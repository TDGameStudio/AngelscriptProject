/**
 * @version v1
 * @summary A const&in TOptional<FVector> returns the stored value from Get.
 * @topic Containers
 *
 * ReadGetReturnsStoredValueFVector
 */
/**
 * @begin ReadGetReturnsStoredValueFVector
 * @summary A const&in TOptional<FVector> returns the stored value from Get.
 * @topic Containers
 */
bool ReadGetReturnsStoredValueFVector(const TOptional<FVector>&in Value)
{
	return Value.Get(FVector(0.0f, 1.0f, 0.0f)).Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
