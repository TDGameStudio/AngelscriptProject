/**
 * @version v1
 * @summary A const&in TOptional<bool> returns the stored value from Get.
 * @topic Containers
 *
 * ReadGetReturnsStoredValueBool
 */
/**
 * @begin ReadGetReturnsStoredValueBool
 * @summary A const&in TOptional<bool> returns the stored value from Get.
 * @topic Containers
 */
bool ReadGetReturnsStoredValueBool(const TOptional<bool>&in Value)
{
	return Value.Get(false) == true;
}
/** @end */
