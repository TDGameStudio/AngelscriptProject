/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports pairs inserted by FindOrAdd.
 * @topic Containers
 *
 * ReadFindOrAddInsertsBool
 */
/**
 * @begin ReadFindOrAddInsertsBool
 * @summary A const&in TMap<int, bool> reports pairs inserted by FindOrAdd.
 * @topic Containers
 */
bool ReadFindOrAddInsertsBool(const TMap<int, bool>&in Values)
{
	return Values.Num() == 3 && Values.Contains(1) && Values.Contains(2) && Values.Contains(3);
}
/** @end */
