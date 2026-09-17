/**
 * @version v1
 * @summary A const&in TSet<UObject> reports membership after a missing Remove.
 * @topic Containers
 *
 * ReadRemoveMissingUObject
 */
/**
 * @begin ReadRemoveMissingUObject
 * @summary A const&in TSet<UObject> reports membership after a missing Remove.
 * @topic Containers
 */
bool ReadRemoveMissingUObject(const TSet<UObject>&in Values)
{
	return Values.Num() == 1 && !Values.Contains(nullptr);
}
/** @end */
