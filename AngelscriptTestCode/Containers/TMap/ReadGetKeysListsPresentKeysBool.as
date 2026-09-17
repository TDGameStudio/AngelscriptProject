/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports GetKeys membership without writing the map back.
 * @topic Containers
 *
 * ReadGetKeysListsPresentKeysBool
 */
/**
 * @begin ReadGetKeysListsPresentKeysBool
 * @summary A const&in TMap<int, bool> reports GetKeys membership without writing the map back.
 * @topic Containers
 */
bool ReadGetKeysListsPresentKeysBool(const TMap<int, bool>&in Values)
{
	TArray<int> Keys;
	Values.GetKeys(Keys);
	return Keys.Num() == 3 && Keys.Contains(1) && Keys.Contains(2) && Keys.Contains(3);
}
/** @end */
