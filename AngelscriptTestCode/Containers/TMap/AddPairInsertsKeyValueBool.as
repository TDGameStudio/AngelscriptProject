/**
 * @version v1
 * @summary Add inserts distinct int keys and stores each bool value.
 * @topic Containers
 *
 * AddPairInsertsKeyValueBool
 */
/**
 * @begin AddPairInsertsKeyValueBool
 * @summary Add inserts distinct int keys and stores each bool value.
 * @topic Containers
 */
bool AddPairInsertsKeyValueBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Add(2, false);
	return Map.Num() == 2 && Map[1] == true && Map[2] == false && Map.Contains(2);
}
/** @end */
