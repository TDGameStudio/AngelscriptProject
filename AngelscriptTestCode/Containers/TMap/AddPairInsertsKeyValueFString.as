/**
 * @version v1
 * @summary Add inserts distinct FString keys and stores each value.
 * @topic Containers
 *
 * AddPairInsertsKeyValueFString
 */
/**
 * @begin AddPairInsertsKeyValueFString
 * @summary Add inserts distinct FString keys and stores each value.
 * @topic Containers
 */
bool AddPairInsertsKeyValueFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Add("beta", 200);
	return Map.Num() == 2 && Map["alpha"] == 100 && Map["beta"] == 200 && Map.Contains("beta");
}
/** @end */
