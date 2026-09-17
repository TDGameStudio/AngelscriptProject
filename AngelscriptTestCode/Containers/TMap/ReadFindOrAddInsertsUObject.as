/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports pairs inserted by FindOrAdd.
 * @topic Containers
 *
 * ReadFindOrAddInsertsUObject
 */
/**
 * @begin ReadFindOrAddInsertsUObject
 * @summary A const&in TMap<int, UObject> reports pairs inserted by FindOrAdd.
 * @topic Containers
 */
bool ReadFindOrAddInsertsUObject(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 3 && Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
}
/** @end */
