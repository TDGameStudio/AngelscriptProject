/**
 * @version v1
 * @summary A const&in TOptional<int32> reports the value stored by Set.
 * @topic Containers
 *
 * ReadSetValue
 */
/**
 * @begin ReadSetValue
 * @summary A const&in TOptional<int32> reports the value stored by Set.
 * @topic Containers
 */
bool ReadSetValue(const TOptional<int32>&in Value)
{
	return Value.IsSet() && Value.GetValue() == 7;
}
/** @end */
