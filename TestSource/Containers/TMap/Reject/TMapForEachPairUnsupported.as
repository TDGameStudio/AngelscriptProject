/**
 * for-each Pair.Key / Pair.Value on TMap is rejected. Use Element.GetKey()
 * / GetValue(), or for (Key, Value : Map).
 *
 * @Theme Containers.TMap
 * @Subject TMap.ForEachPairUnsupported
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapForEachPairUnsupported
 * @Kind CompileReject
 * @Covers TMap.foreach
 * @Inputs for (auto& Pair : Map) Pair.Key + Pair.Value
 * @Return does not compile; Key is not a member of TMapIterator
 * @Namespace TMapTest
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
