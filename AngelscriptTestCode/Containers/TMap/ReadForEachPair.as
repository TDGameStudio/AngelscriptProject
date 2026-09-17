/**
 * @version v1
 * @summary A const&in TMap<int, int> is visited by range-for without writing the map back.
 * @topic Containers
 *
 * ReadForEachPair
 */
/**
 * @begin ReadForEachPair
 * @summary A const&in TMap<int, int> is visited by range-for without writing the map back.
 * @topic Containers
 */
bool ReadForEachPair(const TMap<int, int>&in Values)
{
	int Count = 0;
	int Sum = 0;
	for (int Key, int Value : Values)
	{
		if (!Values.Contains(Key) || Values[Key] != Value)
		{
			return false;
		}
		Count += 1;
		Sum += Value;
	}
	return Count == 3 && Sum == 600;
}
/** @end */
