/**
 * @version v1
 * @summary A const&in TOptional<UObject> returns the stored handle from GetValue.
 * @topic Containers
 *
 * ReadGetValueReturnsStoredIntUObject
 */
/**
 * @begin ReadGetValueReturnsStoredIntUObject
 * @summary A const&in TOptional<UObject> returns the stored handle from GetValue.
 * @topic Containers
 */
bool ReadGetValueReturnsStoredIntUObject(const TOptional<UObject>&in Value)
{
	return Value.GetValue() != nullptr;
}
/** @end */
