/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports GetKeys membership without writing the map back.
 * @topic Containers
 *
 * ReadGetKeysListsPresentKeysFString
 */
/**
 * @begin ReadGetKeysListsPresentKeysFString
 * @summary A const&in TMap<FString, int> reports GetKeys membership without writing the map back.
 * @topic Containers
 */
bool ReadGetKeysListsPresentKeysFString(const TMap<FString, int>&in Values)
{
	TArray<FString> Keys;
	Values.GetKeys(Keys);
	return Keys.Num() == 3 && Keys.Contains("alpha") && Keys.Contains("beta") && Keys.Contains("gamma");
}
/** @end */
