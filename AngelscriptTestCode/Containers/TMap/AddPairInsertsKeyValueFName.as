/**
 * @version v1
 * @summary Add inserts distinct FName keys and stores each value.
 * @topic Containers
 *
 * AddPairInsertsKeyValueFName
 */
/**
 * @begin AddPairInsertsKeyValueFName
 * @summary Add inserts distinct FName keys and stores each value.
 * @topic Containers
 */
bool AddPairInsertsKeyValueFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Add(n"Green", 2);
	return Map.Num() == 2 && Map[n"Red"] == 1 && Map[n"Green"] == 2 && Map.Contains(n"Green");
}
/** @end */
