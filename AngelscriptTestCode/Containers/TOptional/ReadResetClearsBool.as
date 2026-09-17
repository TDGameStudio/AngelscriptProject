/**
 * @version v1
 * @summary A const&in TOptional<bool> still reports set before Reset.
 * @topic Containers
 *
 * ReadResetClearsBool
 */
/**
 * @begin ReadResetClearsBool
 * @summary A const&in TOptional<bool> still reports set before Reset.
 * @topic Containers
 */
bool ReadResetClearsBool(const TOptional<bool>&in Value)
{
	return Value.IsSet() && Value.GetValue() == true;
}
/** @end */
