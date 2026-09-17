/**
 * @version v1
 * @summary A const&in TMap<int, bool> is visited by range-for without writing the map back.
 * @topic Containers
 *
 * ReadForEachPairBool
 */
/**
 * @begin ReadForEachPairBool
 * @summary A const&in TMap<int, bool> is visited by range-for without writing the map back.
 * @topic Containers
 */
bool ReadForEachPairBool(const TMap<int, bool>&in Values)
{
	int Count = 0;
	for (int Key, bool Value : Values)
	{
		if (!Values.Contains(Key) || Values[Key] != Value)
		{
			return false;
		}
		Count += 1;
	}
	return Count == 3;
}
/** @end */
