/**
 * @version v1
 * @summary A const&in TOptional<FString> reports the value stored by Set.
 * @topic Containers
 *
 * ReadSetValueFString
 */
/**
 * @begin ReadSetValueFString
 * @summary A const&in TOptional<FString> reports the value stored by Set.
 * @topic Containers
 */
bool ReadSetValueFString(const TOptional<FString>&in Value)
{
	return Value.IsSet() && Value.GetValue() == "alpha";
}
/** @end */
