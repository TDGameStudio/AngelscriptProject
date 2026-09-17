/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports pairs inserted by FindOrAdd.
 * @topic Containers
 *
 * ReadFindOrAddInsertsFName
 */
/**
 * @begin ReadFindOrAddInsertsFName
 * @summary A const&in TMap<FName, int> reports pairs inserted by FindOrAdd.
 * @topic Containers
 */
bool ReadFindOrAddInsertsFName(const TMap<FName, int>&in Values)
{
	return Values.Num() == 3 && Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue");
}
/** @end */
