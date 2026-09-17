/**
 * @version v1
 * @summary A const&in TOptional<UObject> reports a non-null handle stored by Set.
 * @topic Containers
 *
 * ReadSetValueUObject
 */
/**
 * @begin ReadSetValueUObject
 * @summary A const&in TOptional<UObject> reports a non-null handle stored by Set.
 * @topic Containers
 */
bool ReadSetValueUObject(const TOptional<UObject>&in Value)
{
	return Value.IsSet() && Value.GetValue() != nullptr;
}
/** @end */
