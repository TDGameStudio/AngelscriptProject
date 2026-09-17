/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports Find of a present key without writing the map back.
 * @topic Containers
 *
 * ReadFindValueReturnsStoredValueUObject
 */
/**
 * @begin ReadFindValueReturnsStoredValueUObject
 * @summary A const&in TMap<int, UObject> reports Find of a present key without writing the map back.
 * @topic Containers
 */
bool ReadFindValueReturnsStoredValueUObject(const TMap<int, UObject>&in Values)
{
	UObject Found = nullptr;
	return Values.Find(10, Found) && Found != nullptr && !Values.Find(99, Found);
}
/** @end */
