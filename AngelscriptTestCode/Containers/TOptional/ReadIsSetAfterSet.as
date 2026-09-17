/**
 * @version v1
 * @summary A const&in TOptional<int32> reports IsSet after Set.
 * @topic Containers
 *
 * ReadIsSetAfterSet
 */
/**
 * @begin ReadIsSetAfterSet
 * @summary A const&in TOptional<int32> reports IsSet after Set.
 * @topic Containers
 */
bool ReadIsSetAfterSet(const TOptional<int32>&in Value)
{
	return Value.IsSet();
}
/** @end */
