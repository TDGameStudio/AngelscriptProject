/**
 * @version v1
 * @summary A const&in TOptional<int32> returns the stored value from Get.
 * @topic Containers
 *
 * ReadGetReturnsStoredValue
 */
/**
 * @begin ReadGetReturnsStoredValue
 * @summary A const&in TOptional<int32> returns the stored value from Get.
 * @topic Containers
 */
bool ReadGetReturnsStoredValue(const TOptional<int32>&in Value)
{
	return Value.Get(9) == 7;
}
/** @end */
