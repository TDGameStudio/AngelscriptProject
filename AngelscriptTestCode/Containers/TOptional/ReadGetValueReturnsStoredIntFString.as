/**
 * @version v1
 * @summary A const&in TOptional<FString> returns the stored value from GetValue.
 * @topic Containers
 *
 * ReadGetValueReturnsStoredIntFString
 */
/**
 * @begin ReadGetValueReturnsStoredIntFString
 * @summary A const&in TOptional<FString> returns the stored value from GetValue.
 * @topic Containers
 */
bool ReadGetValueReturnsStoredIntFString(const TOptional<FString>&in Value)
{
	return Value.GetValue() == "alpha";
}
/** @end */
