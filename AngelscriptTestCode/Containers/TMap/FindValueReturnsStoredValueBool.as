/**
 * @version v1
 * @summary Find copies the stored bool and returns true for a present int key.
 * @topic Containers
 *
 * FindValueReturnsStoredValueBool
 */
/**
 * @begin FindValueReturnsStoredValueBool
 * @summary Find copies the stored bool and returns true for a present int key.
 * @topic Containers
 */
bool FindValueReturnsStoredValueBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	bool Found = false;
	bool bFound = Map.Find(1, Found);
	return bFound && Found == true;
}
/** @end */
