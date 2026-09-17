/**
 * @version v1
 * @summary GetKeys copies every int key from a bool map into the destination array.
 * @topic Containers
 *
 * GetKeysListsPresentKeysBool
 */
/**
 * @begin GetKeysListsPresentKeysBool
 * @summary GetKeys copies every int key from a bool map into the destination array.
 * @topic Containers
 */
bool GetKeysListsPresentKeysBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Add(2, false);
	TArray<int> Keys;
	Map.GetKeys(Keys);
	return Keys.Num() == 2 && Keys.Contains(1) && Keys.Contains(2);
}
/** @end */
