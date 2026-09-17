/**
 * @version v1
 * @summary A const&in TOptional<FString> reports IsSet after Set.
 * @topic Containers
 *
 * ReadIsSetAfterSetFString
 */
/**
 * @begin ReadIsSetAfterSetFString
 * @summary A const&in TOptional<FString> reports IsSet after Set.
 * @topic Containers
 */
bool ReadIsSetAfterSetFString(const TOptional<FString>&in Value)
{
	return Value.IsSet();
}
/** @end */
