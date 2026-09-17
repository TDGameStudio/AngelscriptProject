/**
 * @version v1
 * @summary FindOrAdd returns the existing FName-key value and ignores a later default.
 * @topic Containers
 *
 * FindOrAddReturnsExistingFName
 */
/**
 * @begin FindOrAddReturnsExistingFName
 * @summary FindOrAdd returns the existing FName-key value and ignores a later default.
 * @topic Containers
 */
bool FindOrAddReturnsExistingFName()
{
	TMap<FName, int> Map;
	int& WithDefault = Map.FindOrAdd(n"Delta", 9);
	int& Existing = Map.FindOrAdd(n"Delta", 3);
	return WithDefault == 9 && Map[n"Delta"] == 9 && Existing == 9;
}
/** @end */
