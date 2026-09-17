/**
 * @version v1
 * @summary A const&in TOptional<int32> returns the stored value from GetValue.
 * @topic Containers
 *
 * ReadGetValueReturnsStoredInt
 */
/**
 * @begin ReadGetValueReturnsStoredInt
 * @summary A const&in TOptional<int32> returns the stored value from GetValue.
 * @topic Containers
 */
bool ReadGetValueReturnsStoredInt(const TOptional<int32>&in Value)
{
	return Value.GetValue() == 7;
}
/** @end */
