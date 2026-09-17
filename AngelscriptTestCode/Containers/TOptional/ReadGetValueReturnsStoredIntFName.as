/**
 * @version v1
 * @summary A const&in TOptional<FName> returns the stored value from GetValue.
 * @topic Containers
 *
 * ReadGetValueReturnsStoredIntFName
 */
/**
 * @begin ReadGetValueReturnsStoredIntFName
 * @summary A const&in TOptional<FName> returns the stored value from GetValue.
 * @topic Containers
 */
bool ReadGetValueReturnsStoredIntFName(const TOptional<FName>&in Value)
{
	return Value.GetValue() == n"Red";
}
/** @end */
