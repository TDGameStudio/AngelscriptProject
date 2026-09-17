/**
 * @version v1
 * @summary A const&in TOptional<FName> reports the value stored by Set.
 * @topic Containers
 *
 * ReadSetValueFName
 */
/**
 * @begin ReadSetValueFName
 * @summary A const&in TOptional<FName> reports the value stored by Set.
 * @topic Containers
 */
bool ReadSetValueFName(const TOptional<FName>&in Value)
{
	return Value.IsSet() && Value.GetValue() == n"Red";
}
/** @end */
