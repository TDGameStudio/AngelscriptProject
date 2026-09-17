/**
 * @version v1
 * @summary A const&in TOptional<FName> still reports set before Reset.
 * @topic Containers
 *
 * ReadResetClearsFName
 */
/**
 * @begin ReadResetClearsFName
 * @summary A const&in TOptional<FName> still reports set before Reset.
 * @topic Containers
 */
bool ReadResetClearsFName(const TOptional<FName>&in Value)
{
	return Value.IsSet() && Value.GetValue() == n"Red";
}
/** @end */
