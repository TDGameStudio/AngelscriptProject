/**
 * @version v1
 * @summary GetKeys copies every key into the destination array.
 * @topic Containers
 *
 * GetKeysListsPresentKeys
 */
/**
 * @begin GetKeysListsPresentKeys
 * @summary GetKeys copies every key into the destination array.
 * @topic Containers
 */
bool GetKeysListsPresentKeys()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	TArray<FName> OutKeys;
	OutKeys.Add(NAME_None);
	int Before = OutKeys.Num();
	Map.GetKeys(OutKeys);
	int After = OutKeys.Num();
	return After == Before + 2
		&& OutKeys[After - 1] == NAME_None
		&& OutKeys.Contains(n"Alpha")
		&& OutKeys.Contains(n"Beta");
}
/** @end */
