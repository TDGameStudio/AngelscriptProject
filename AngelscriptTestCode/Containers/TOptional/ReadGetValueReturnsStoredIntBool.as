/**
 * @version v1
 * @summary A const&in TOptional<bool> returns the stored value from GetValue.
 * @topic Containers
 *
 * ReadGetValueReturnsStoredIntBool
 */
/**
 * @begin ReadGetValueReturnsStoredIntBool
 * @summary A const&in TOptional<bool> returns the stored value from GetValue.
 * @topic Containers
 */
bool ReadGetValueReturnsStoredIntBool(const TOptional<bool>&in Value)
{
	return Value.GetValue() == true;
}
/** @end */
