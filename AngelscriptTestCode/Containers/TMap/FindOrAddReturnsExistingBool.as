/**
 * @version v1
 * @summary FindOrAdd returns the existing bool value and ignores a later default.
 * @topic Containers
 *
 * FindOrAddReturnsExistingBool
 */
/**
 * @begin FindOrAddReturnsExistingBool
 * @summary FindOrAdd returns the existing bool value and ignores a later default.
 * @topic Containers
 */
bool FindOrAddReturnsExistingBool()
{
	TMap<int, bool> Map;
	bool& WithDefault = Map.FindOrAdd(1, true);
	bool& Existing = Map.FindOrAdd(1, false);
	return WithDefault == true && Map[1] == true && Existing == true;
}
/** @end */
