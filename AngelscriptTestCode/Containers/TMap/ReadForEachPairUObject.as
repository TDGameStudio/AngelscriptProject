/**
 * @version v1
 * @summary A const&in TMap<int, UObject> is visited by range-for without writing the map back.
 * @topic Containers
 *
 * ReadForEachPairUObject
 */
/**
 * @begin ReadForEachPairUObject
 * @summary A const&in TMap<int, UObject> is visited by range-for without writing the map back.
 * @topic Containers
 */
bool ReadForEachPairUObject(const TMap<int, UObject>&in Values)
{
	int Count = 0;
	for (int Key, UObject Value : Values)
	{
		if (!Values.Contains(Key) || Values[Key] != Value || Value == nullptr)
		{
			return false;
		}
		Count += 1;
	}
	return Count == 3;
}
/** @end */
