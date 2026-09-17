/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports the existing FindOrAdd handle.
 * @topic Containers
 *
 * ReadFindOrAddReturnsExistingUObject
 */
/**
 * @begin ReadFindOrAddReturnsExistingUObject
 * @summary A const&in TMap<int, UObject> reports the existing FindOrAdd handle.
 * @topic Containers
 */
bool ReadFindOrAddReturnsExistingUObject(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 1 && Values.Contains(10) && Values[10] != nullptr;
}
/** @end */
