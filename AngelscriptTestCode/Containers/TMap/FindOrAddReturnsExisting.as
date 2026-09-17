/**
 * @version v1
 * @summary FindOrAdd returns the existing value and ignores a later default.
 * @topic Containers
 *
 * FindOrAddReturnsExisting
 */
/**
 * @begin FindOrAddReturnsExisting
 * @summary FindOrAdd returns the existing value and ignores a later default.
 * @topic Containers
 */
bool FindOrAddReturnsExisting()
{
	TMap<FName, int32> Map;
	int32& WithDefault = Map.FindOrAdd(n"Delta", 9);
	int32& Existing = Map.FindOrAdd(n"Delta", 3);
	return WithDefault == 9 && Map[n"Delta"] == 9 && Existing == 9;
}
/** @end */
