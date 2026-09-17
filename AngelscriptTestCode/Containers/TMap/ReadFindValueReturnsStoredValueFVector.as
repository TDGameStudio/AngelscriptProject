/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports Find of a present key without writing the map back.
 * @topic Containers
 *
 * ReadFindValueReturnsStoredValueFVector
 */
/**
 * @begin ReadFindValueReturnsStoredValueFVector
 * @summary A const&in TMap<int, FVector> reports Find of a present key without writing the map back.
 * @topic Containers
 */
bool ReadFindValueReturnsStoredValueFVector(const TMap<int, FVector>&in Values)
{
	FVector Found = FVector(0.0f, 0.0f, 0.0f);
	return Values.Find(1, Found) && Found.Equals(FVector(1.0f, 0.0f, 0.0f)) && !Values.Find(99, Found);
}
/** @end */
