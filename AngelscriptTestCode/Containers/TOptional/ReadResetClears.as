/**
 * @version v1
 * @summary A const&in TOptional<int32> still reports set before Reset.
 * @topic Containers
 *
 * ReadResetClears
 */
/**
 * @begin ReadResetClears
 * @summary A const&in TOptional<int32> still reports set before Reset.
 * @topic Containers
 */
bool ReadResetClears(const TOptional<int32>&in Value)
{
	return Value.IsSet() && Value.GetValue() == 7;
}
/** @end */
