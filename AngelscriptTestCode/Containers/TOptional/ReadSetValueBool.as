/**
 * @version v1
 * @summary A const&in TOptional<bool> reports the value stored by Set.
 * @topic Containers
 *
 * ReadSetValueBool
 */
/**
 * @begin ReadSetValueBool
 * @summary A const&in TOptional<bool> reports the value stored by Set.
 * @topic Containers
 */
bool ReadSetValueBool(const TOptional<bool>&in Value)
{
	return Value.IsSet() && Value.GetValue() == true;
}
/** @end */
