/**
 * @version v1
 * @summary FindOrAdd returns the existing FString-key value and ignores a later default.
 * @topic Containers
 *
 * FindOrAddReturnsExistingFString
 */
/**
 * @begin FindOrAddReturnsExistingFString
 * @summary FindOrAdd returns the existing FString-key value and ignores a later default.
 * @topic Containers
 */
bool FindOrAddReturnsExistingFString()
{
	TMap<FString, int> Map;
	int& WithDefault = Map.FindOrAdd("delta", 9);
	int& Existing = Map.FindOrAdd("delta", 3);
	return WithDefault == 9 && Map["delta"] == 9 && Existing == 9;
}
/** @end */
