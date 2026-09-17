/**
 * @version v1
 * @summary FindOrAdd of a missing key inserts a default and does not throw.
 * @topic Containers
 *
 * FindOrAddInserts
 */
/**
 * @begin FindOrAddInserts
 * @summary FindOrAdd of a missing key inserts a default and does not throw.
 * @topic Containers
 */
bool FindOrAddInserts()
{
	TMap<int, int> Map;
	int Added = Map.FindOrAdd(20);
	return Added == 0 && Map.Num() == 1 && Map.Contains(20) && Map[20] == 0;
}
/** @end */
