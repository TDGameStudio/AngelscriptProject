/**
 * @version v1
 * @summary A const&in TSet<UObject> reports Contains false for nullptr.
 * @topic Containers
 *
 * ReadContainsMissingUObject
 */
/**
 * @begin ReadContainsMissingUObject
 * @summary A const&in TSet<UObject> reports Contains false for nullptr.
 * @topic Containers
 */
bool ReadContainsMissingUObject(const TSet<UObject>&in Values)
{
	return Values.Num() == 1 && !Values.Contains(nullptr);
}
/** @end */
