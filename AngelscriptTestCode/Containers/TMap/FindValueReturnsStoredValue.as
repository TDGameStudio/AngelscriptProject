/**
 * @version v1
 * @summary Find copies the stored value and returns true for a present key.
 * @topic Containers
 *
 * FindValueReturnsStoredValue
 */
/**
 * @begin FindValueReturnsStoredValue
 * @summary Find copies the stored value and returns true for a present key.
 * @topic Containers
 */
bool FindValueReturnsStoredValue()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	int32 Found = -1;
	bool bFound = Map.Find(n"Alpha", Found);
	return bFound && Found == 1;
}
/** @end */
