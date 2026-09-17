/**
 * @version v1
 * @summary A const&in TMap<FName, int> is visited by range-for without writing the map back.
 * @topic Containers
 *
 * ReadForEachPairFName
 */
/**
 * @begin ReadForEachPairFName
 * @summary A const&in TMap<FName, int> is visited by range-for without writing the map back.
 * @topic Containers
 */
bool ReadForEachPairFName(const TMap<FName, int>&in Values)
{
	int Count = 0;
	int Sum = 0;
	for (FName Key, int Value : Values)
	{
		if (!Values.Contains(Key) || Values[Key] != Value)
		{
			return false;
		}
		Count += 1;
		Sum += Value;
	}
	return Count == 3 && Sum == 6;
}
/** @end */
