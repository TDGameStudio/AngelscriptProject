/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports Find of a present key without writing the map back.
 * @topic Containers
 *
 * ReadFindValueReturnsStoredValueFName
 */
/**
 * @begin ReadFindValueReturnsStoredValueFName
 * @summary A const&in TMap<FName, int> reports Find of a present key without writing the map back.
 * @topic Containers
 */
bool ReadFindValueReturnsStoredValueFName(const TMap<FName, int>&in Values)
{
	int Found = 0;
	return Values.Find(n"Red", Found) && Found == 1 && !Values.Find(n"Missing", Found);
}
/** @end */
