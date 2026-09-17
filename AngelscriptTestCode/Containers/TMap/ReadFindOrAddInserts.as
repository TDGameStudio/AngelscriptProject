/**
 * @version v1
 * @summary A const&in TMap<int, int> reports pairs inserted by FindOrAdd.
 * @topic Containers
 *
 * ReadFindOrAddInserts
 */
/**
 * @begin ReadFindOrAddInserts
 * @summary A const&in TMap<int, int> reports pairs inserted by FindOrAdd.
 * @topic Containers
 */
bool ReadFindOrAddInserts(const TMap<int, int>&in Values)
{
	return Values.Num() == 3 && Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
}
/** @end */
