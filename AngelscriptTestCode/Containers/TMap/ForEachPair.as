/**
 * @version v1
 * @summary Value and key-value for-range visit every pair.
 * @topic Containers
 *
 * ForEachPair
 */
/**
 * @begin ForEachPair
 * @summary Value and key-value for-range visit every pair.
 * @topic Containers
 */
bool ForEachPair()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	int32 ValueSum = 0;
	for (int32 Value : Map)
	{
		ValueSum += Value;
	}
	int32 PairCount = 0;
	int32 PairSum = 0;
	for (FName Key, int32 Value : Map)
	{
		PairCount += 1;
		PairSum += Value;
		if (Key != n"Alpha" && Key != n"Beta")
		{
			PairCount = -1;
		}
	}
	return ValueSum == 3 && PairCount == 2 && PairSum == 3;
}
/** @end */
