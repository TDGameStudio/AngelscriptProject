/**
 * @version v1
 * @summary A const&in TOptional<UObject> returns the stored handle from Get.
 * @topic Containers
 *
 * ReadGetReturnsStoredValueUObject
 */
/**
 * @begin ReadGetReturnsStoredValueUObject
 * @summary A const&in TOptional<UObject> returns the stored handle from Get.
 * @topic Containers
 */
bool ReadGetReturnsStoredValueUObject(const TOptional<UObject>&in Value)
{
	return Value.Get(nullptr) != nullptr;
}
/** @end */
