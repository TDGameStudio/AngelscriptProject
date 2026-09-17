/**
 * @version v1
 * @summary A const&in TMap<FString, int> is visited by range-for without writing the map back.
 * @topic Containers
 *
 * ReadForEachPairFString
 */
/**
 * @begin ReadForEachPairFString
 * @summary A const&in TMap<FString, int> is visited by range-for without writing the map back.
 * @topic Containers
 */
bool ReadForEachPairFString(const TMap<FString, int>&in Values)
{
	int Count = 0;
	int Sum = 0;
	for (FString Key, int Value : Values)
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
