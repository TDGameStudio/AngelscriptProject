/**
 * @version v1
 * @summary Value and key-value for-range visit every FString-key pair.
 * @topic Containers
 *
 * ForEachPairFString
 */
/**
 * @begin ForEachPairFString
 * @summary Value and key-value for-range visit every FString-key pair.
 * @topic Containers
 */
bool ForEachPairFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Add("beta", 200);
	int ValueSum = 0;
	for (int Value : Map)
	{
		ValueSum += Value;
	}
	int PairCount = 0;
	int PairSum = 0;
	for (FString Key, int Value : Map)
	{
		PairCount += 1;
		PairSum += Value;
		if (Key != "alpha" && Key != "beta")
		{
			PairCount = -1;
		}
	}
	return ValueSum == 300 && PairCount == 2 && PairSum == 300;
}
/** @end */
