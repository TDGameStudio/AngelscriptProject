/**
 * @version v1
 * @summary Find copies the stored value and returns true for a present FName key.
 * @topic Containers
 *
 * FindValueReturnsStoredValueFName
 */
/**
 * @begin FindValueReturnsStoredValueFName
 * @summary Find copies the stored value and returns true for a present FName key.
 * @topic Containers
 */
bool FindValueReturnsStoredValueFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	int Found = -1;
	bool bFound = Map.Find(n"Red", Found);
	return bFound && Found == 1;
}
/** @end */
