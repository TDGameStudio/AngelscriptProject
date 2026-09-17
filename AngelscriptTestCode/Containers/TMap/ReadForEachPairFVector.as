/**
 * @version v1
 * @summary A const&in TMap<int, FVector> is visited by range-for without writing the map back.
 * @topic Containers
 *
 * ReadForEachPairFVector
 */
/**
 * @begin ReadForEachPairFVector
 * @summary A const&in TMap<int, FVector> is visited by range-for without writing the map back.
 * @topic Containers
 */
bool ReadForEachPairFVector(const TMap<int, FVector>&in Values)
{
	int Count = 0;
	for (int Key, FVector Value : Values)
	{
		if (!Values.Contains(Key) || !Values[Key].Equals(Value))
		{
			return false;
		}
		Count += 1;
	}
	return Count == 3;
}
/** @end */
