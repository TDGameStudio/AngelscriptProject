/**
 * @version v1
 * @summary Value and key-value for-range visit every FVector pair.
 * @topic Containers
 *
 * ForEachPairFVector
 */
/**
 * @begin ForEachPairFVector
 * @summary Value and key-value for-range visit every FVector pair.
 * @topic Containers
 */
bool ForEachPairFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	int ValueCount = 0;
	for (FVector Value : Map)
	{
		if (Value.Equals(FVector(1.0f, 0.0f, 0.0f)) || Value.Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			ValueCount += 1;
		}
	}
	int PairCount = 0;
	for (int Key, FVector Value : Map)
	{
		PairCount += 1;
		if (Key != 1 && Key != 2)
		{
			PairCount = -1;
		}
	}
	return ValueCount == 2 && PairCount == 2;
}
/** @end */
