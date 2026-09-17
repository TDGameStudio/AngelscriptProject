/**
 * @version v1
 * @summary A const&in TOptional<UObject> still reports set before Reset.
 * @topic Containers
 *
 * ReadResetClearsUObject
 */
/**
 * @begin ReadResetClearsUObject
 * @summary A const&in TOptional<UObject> still reports set before Reset.
 * @topic Containers
 */
bool ReadResetClearsUObject(const TOptional<UObject>&in Value)
{
	return Value.IsSet() && Value.GetValue() != nullptr;
}
/** @end */
