/**
 * @version v1
 * @summary Find copies the stored value and returns true for a present FString key.
 * @topic Containers
 *
 * FindValueReturnsStoredValueFString
 */
/**
 * @begin FindValueReturnsStoredValueFString
 * @summary Find copies the stored value and returns true for a present FString key.
 * @topic Containers
 */
bool FindValueReturnsStoredValueFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	int Found = -1;
	bool bFound = Map.Find("alpha", Found);
	return bFound && Found == 100;
}
/** @end */
