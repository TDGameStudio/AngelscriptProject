/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports Find of a present key without writing the map back.
 * @topic Containers
 *
 * ReadFindValueReturnsStoredValueFString
 */
/**
 * @begin ReadFindValueReturnsStoredValueFString
 * @summary A const&in TMap<FString, int> reports Find of a present key without writing the map back.
 * @topic Containers
 */
bool ReadFindValueReturnsStoredValueFString(const TMap<FString, int>&in Values)
{
	int Found = 0;
	return Values.Find("alpha", Found) && Found == 100 && !Values.Find("missing", Found);
}
/** @end */
