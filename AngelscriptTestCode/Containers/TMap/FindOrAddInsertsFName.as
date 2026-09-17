/**
 * @version v1
 * @summary FindOrAdd of a missing FName key inserts a default and does not throw.
 * @topic Containers
 *
 * FindOrAddInsertsFName
 */
/**
 * @begin FindOrAddInsertsFName
 * @summary FindOrAdd of a missing FName key inserts a default and does not throw.
 * @topic Containers
 */
bool FindOrAddInsertsFName()
{
	TMap<FName, int> Map;
	int Added = Map.FindOrAdd(n"Green");
	return Added == 0 && Map.Num() == 1 && Map.Contains(n"Green") && Map[n"Green"] == 0;
}
/** @end */
