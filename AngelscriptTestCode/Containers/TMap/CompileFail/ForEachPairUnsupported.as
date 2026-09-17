/**
 * @version v1
 * @summary for-each Pair.Key / Pair.Value on TMap is rejected.
 * @topic Containers
 *
 * ForEachPairUnsupported
 */
/**
 * @begin ForEachPairUnsupported
 * @summary for-each Pair.Key / Pair.Value on TMap is rejected.
 * @topic Containers
 */
int ForEachPairUnsupported()
{
	TMap<int, int> Map;
	Map.Add(1, 10);

	int Sum = 0;
	for (auto& Pair : Map)
	{
		Sum += Pair.Key + Pair.Value;
	}
	return Sum;
}
/** @end */
