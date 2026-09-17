/**
 * @version v1
 * @summary Value and key-value for-range visit every UObject pair.
 * @topic Containers
 *
 * ForEachPairUObject
 */
/**
 * @begin ForEachPairUObject
 * @summary Value and key-value for-range visit every UObject pair.
 * @topic Containers
 */
UCLASS()
class UTMapForEachPairUObjectHost : UObject
{
}

bool ForEachPairUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapForEachPairUObjectHost::StaticClass(), n"ForEach_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapForEachPairUObjectHost::StaticClass(), n"ForEach_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, Second);
	int ValueCount = 0;
	for (UObject Value : Map)
	{
		if (Value == First || Value == Second)
		{
			ValueCount += 1;
		}
	}
	int PairCount = 0;
	for (int Key, UObject Value : Map)
	{
		PairCount += 1;
		if (Key != 10 && Key != 20)
		{
			PairCount = -1;
		}
	}
	return ValueCount == 2 && PairCount == 2;
}
/** @end */
