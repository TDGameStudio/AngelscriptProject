/**
 * @version v1
 * @summary GetKeys copies every FString key into the destination array.
 * @topic Containers
 *
 * GetKeysListsPresentKeysFString
 */
/**
 * @begin GetKeysListsPresentKeysFString
 * @summary GetKeys copies every FString key into the destination array.
 * @topic Containers
 */
bool GetKeysListsPresentKeysFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Add("beta", 200);
	TArray<FString> Keys;
	Map.GetKeys(Keys);
	return Keys.Num() == 2 && Keys.Contains("alpha") && Keys.Contains("beta");
}
/** @end */
