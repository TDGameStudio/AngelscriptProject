/**
 * @version v1
 * @summary A const&in TOptional<FString> returns the stored value from Get.
 * @topic Containers
 *
 * ReadGetReturnsStoredValueFString
 */
/**
 * @begin ReadGetReturnsStoredValueFString
 * @summary A const&in TOptional<FString> returns the stored value from Get.
 * @topic Containers
 */
bool ReadGetReturnsStoredValueFString(const TOptional<FString>&in Value)
{
	return Value.Get("fallback") == "alpha";
}
/** @end */
