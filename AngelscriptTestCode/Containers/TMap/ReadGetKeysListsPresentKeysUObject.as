/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports GetKeys membership without writing the map back.
 * @topic Containers
 *
 * ReadGetKeysListsPresentKeysUObject
 */
/**
 * @begin ReadGetKeysListsPresentKeysUObject
 * @summary A const&in TMap<int, UObject> reports GetKeys membership without writing the map back.
 * @topic Containers
 */
bool ReadGetKeysListsPresentKeysUObject(const TMap<int, UObject>&in Values)
{
	TArray<int> Keys;
	Values.GetKeys(Keys);
	return Keys.Num() == 3 && Keys.Contains(10) && Keys.Contains(20) && Keys.Contains(30);
}
/** @end */
