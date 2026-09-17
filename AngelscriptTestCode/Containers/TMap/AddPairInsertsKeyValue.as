/**
 * @version v1
 * @summary Add inserts distinct keys and stores each value.
 * @topic Containers
 *
 * AddPairInsertsKeyValue
 */
/**
 * @begin AddPairInsertsKeyValue
 * @summary Add inserts distinct keys and stores each value.
 * @topic Containers
 */
bool AddPairInsertsKeyValue()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	return Map.Num() == 2 && Map[n"Alpha"] == 1 && Map[n"Beta"] == 2 && Map.Contains(n"Beta");
}
/** @end */
