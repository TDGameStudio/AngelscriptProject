/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports Find of a present key without writing the map back.
 * @topic Containers
 *
 * ReadFindValueReturnsStoredValueBool
 */
/**
 * @begin ReadFindValueReturnsStoredValueBool
 * @summary A const&in TMap<int, bool> reports Find of a present key without writing the map back.
 * @topic Containers
 */
bool ReadFindValueReturnsStoredValueBool(const TMap<int, bool>&in Values)
{
	bool Found = false;
	return Values.Find(1, Found) && Found == true && !Values.Find(99, Found);
}
/** @end */
