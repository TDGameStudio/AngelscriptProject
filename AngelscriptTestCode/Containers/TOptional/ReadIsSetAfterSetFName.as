/**
 * @version v1
 * @summary A const&in TOptional<FName> reports IsSet after Set.
 * @topic Containers
 *
 * ReadIsSetAfterSetFName
 */
/**
 * @begin ReadIsSetAfterSetFName
 * @summary A const&in TOptional<FName> reports IsSet after Set.
 * @topic Containers
 */
bool ReadIsSetAfterSetFName(const TOptional<FName>&in Value)
{
	return Value.IsSet();
}
/** @end */
