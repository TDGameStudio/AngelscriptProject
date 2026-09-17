/**
 * @version v1
 * @summary A const&in TMap<int, int> reports Find of a present key without writing the map back.
 * @topic Containers
 *
 * ReadFindValueReturnsStoredValue
 */
/**
 * @begin ReadFindValueReturnsStoredValue
 * @summary A const&in TMap<int, int> reports Find of a present key without writing the map back.
 * @topic Containers
 */
bool ReadFindValueReturnsStoredValue(const TMap<int, int>&in Values)
{
	int Found = 0;
	return Values.Find(10, Found) && Found == 100 && !Values.Find(99, Found);
}
/** @end */
