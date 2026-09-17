/**
 * @version v1
 * @summary A const&in TOptional<FName> returns the stored value from Get.
 * @topic Containers
 *
 * ReadGetReturnsStoredValueFName
 */
/**
 * @begin ReadGetReturnsStoredValueFName
 * @summary A const&in TOptional<FName> returns the stored value from Get.
 * @topic Containers
 */
bool ReadGetReturnsStoredValueFName(const TOptional<FName>&in Value)
{
	return Value.Get(n"Fallback") == n"Red";
}
/** @end */
