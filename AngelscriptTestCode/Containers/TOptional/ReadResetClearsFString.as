/**
 * @version v1
 * @summary A const&in TOptional<FString> still reports set before Reset.
 * @topic Containers
 *
 * ReadResetClearsFString
 */
/**
 * @begin ReadResetClearsFString
 * @summary A const&in TOptional<FString> still reports set before Reset.
 * @topic Containers
 */
bool ReadResetClearsFString(const TOptional<FString>&in Value)
{
	return Value.IsSet() && Value.GetValue() == "alpha";
}
/** @end */
