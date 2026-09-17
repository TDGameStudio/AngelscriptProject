/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports pairs inserted by FindOrAdd.
 * @topic Containers
 *
 * ReadFindOrAddInsertsFString
 */
/**
 * @begin ReadFindOrAddInsertsFString
 * @summary A const&in TMap<FString, int> reports pairs inserted by FindOrAdd.
 * @topic Containers
 */
bool ReadFindOrAddInsertsFString(const TMap<FString, int>&in Values)
{
	return Values.Num() == 3 && Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma");
}
/** @end */
