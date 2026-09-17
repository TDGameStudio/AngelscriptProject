/**
 * @version v1
 * @summary GetKeys copies every FName key into the destination array.
 * @topic Containers
 *
 * GetKeysListsPresentKeysFName
 */
/**
 * @begin GetKeysListsPresentKeysFName
 * @summary GetKeys copies every FName key into the destination array.
 * @topic Containers
 */
bool GetKeysListsPresentKeysFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Add(n"Green", 2);
	TArray<FName> Keys;
	Map.GetKeys(Keys);
	return Keys.Num() == 2 && Keys.Contains(n"Red") && Keys.Contains(n"Green");
}
/** @end */
