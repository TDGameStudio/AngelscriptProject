/**
 * @version v1
 * @summary A const&in TMap<int, int> reports GetKeys membership without writing the map back.
 * @topic Containers
 *
 * ReadGetKeysListsPresentKeys
 */
/**
 * @begin ReadGetKeysListsPresentKeys
 * @summary A const&in TMap<int, int> reports GetKeys membership without writing the map back.
 * @topic Containers
 */
bool ReadGetKeysListsPresentKeys(const TMap<int, int>&in Values)
{
	TArray<int> Keys;
	Values.GetKeys(Keys);
	return Keys.Num() == 3 && Keys.Contains(10) && Keys.Contains(20) && Keys.Contains(30);
}
/** @end */
