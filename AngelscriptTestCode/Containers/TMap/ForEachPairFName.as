/**
 * @version v1
 * @summary Value and key-value for-range visit every FName-key pair.
 * @topic Containers
 *
 * ForEachPairFName
 */
/**
 * @begin ForEachPairFName
 * @summary Value and key-value for-range visit every FName-key pair.
 * @topic Containers
 */
bool ForEachPairFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Add(n"Green", 2);
	int ValueSum = 0;
	for (int Value : Map)
	{
		ValueSum += Value;
	}
	int PairCount = 0;
	int PairSum = 0;
	for (FName Key, int Value : Map)
	{
		PairCount += 1;
		PairSum += Value;
		if (Key != n"Red" && Key != n"Green")
		{
			PairCount = -1;
		}
	}
	return ValueSum == 3 && PairCount == 2 && PairSum == 3;
}
/** @end */
