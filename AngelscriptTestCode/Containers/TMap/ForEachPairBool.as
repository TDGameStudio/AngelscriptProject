/**
 * @version v1
 * @summary Value and key-value for-range visit every bool pair.
 * @topic Containers
 *
 * ForEachPairBool
 */
/**
 * @begin ForEachPairBool
 * @summary Value and key-value for-range visit every bool pair.
 * @topic Containers
 */
bool ForEachPairBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Add(2, false);
	int TrueCount = 0;
	for (bool Value : Map)
	{
		if (Value)
		{
			TrueCount += 1;
		}
	}
	int PairCount = 0;
	for (int Key, bool Value : Map)
	{
		PairCount += 1;
		if (Key != 1 && Key != 2)
		{
			PairCount = -1;
		}
	}
	return TrueCount == 1 && PairCount == 2;
}
/** @end */
