/**
 * @version v1
 * @summary A const&in TOptional<UObject> reports IsSet after Set.
 * @topic Containers
 *
 * ReadIsSetAfterSetUObject
 */
/**
 * @begin ReadIsSetAfterSetUObject
 * @summary A const&in TOptional<UObject> reports IsSet after Set.
 * @topic Containers
 */
bool ReadIsSetAfterSetUObject(const TOptional<UObject>&in Value)
{
	return Value.IsSet();
}
/** @end */
