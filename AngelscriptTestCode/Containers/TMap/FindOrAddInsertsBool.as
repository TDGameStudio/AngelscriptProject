/**
 * @version v1
 * @summary FindOrAdd of a missing int key inserts a default bool and does not throw.
 * @topic Containers
 *
 * FindOrAddInsertsBool
 */
/**
 * @begin FindOrAddInsertsBool
 * @summary FindOrAdd of a missing int key inserts a default bool and does not throw.
 * @topic Containers
 */
bool FindOrAddInsertsBool()
{
	TMap<int, bool> Map;
	bool Added = Map.FindOrAdd(2);
	return Added == false && Map.Num() == 1 && Map.Contains(2) && Map[2] == false;
}
/** @end */
