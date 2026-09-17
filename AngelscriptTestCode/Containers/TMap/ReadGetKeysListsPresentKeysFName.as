/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports GetKeys membership without writing the map back.
 * @topic Containers
 *
 * ReadGetKeysListsPresentKeysFName
 */
/**
 * @begin ReadGetKeysListsPresentKeysFName
 * @summary A const&in TMap<FName, int> reports GetKeys membership without writing the map back.
 * @topic Containers
 */
bool ReadGetKeysListsPresentKeysFName(const TMap<FName, int>&in Values)
{
	TArray<FName> Keys;
	Values.GetKeys(Keys);
	return Keys.Num() == 3 && Keys.Contains(n"Red") && Keys.Contains(n"Green") && Keys.Contains(n"Blue");
}
/** @end */
