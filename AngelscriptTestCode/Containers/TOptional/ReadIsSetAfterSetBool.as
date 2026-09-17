/**
 * @version v1
 * @summary A const&in TOptional<bool> reports IsSet after Set.
 * @topic Containers
 *
 * ReadIsSetAfterSetBool
 */
/**
 * @begin ReadIsSetAfterSetBool
 * @summary A const&in TOptional<bool> reports IsSet after Set.
 * @topic Containers
 */
bool ReadIsSetAfterSetBool(const TOptional<bool>&in Value)
{
	return Value.IsSet();
}
/** @end */
