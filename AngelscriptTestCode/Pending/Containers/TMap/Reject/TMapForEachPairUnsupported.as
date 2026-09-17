/**
 * @version v1
 * @summary for-each Pair.Key / Pair.Value on TMap is rejected. Use Element.GetKey() / GetValue(), or for (Key, Value : Map).
 * @topic Containers
 */
/**
 * @version root
 * @summary for-each Pair.Key / Pair.Value on TMap is rejected. Use Element.GetKey() / GetValue(), or for (Key, Value : Map).
 * @topic Negative
 */
namespace TMapTest
{
	int UnsupportedMapPair()
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
}
/** @end */
