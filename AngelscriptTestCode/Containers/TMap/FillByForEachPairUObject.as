/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachPairUObject
 */
/**
 * @begin FillByForEachPairUObject
 * @summary An &out TMap<int, UObject> is filled by range-for from a local source.
 * @topic Containers
 */
UCLASS()
class UTMapFillByForEachPairUObjectHost : UObject
{
}

void FillByForEachPairUObject(TMap<int, UObject>&out Result)
{
	TMap<int, UObject> Source;
	Source.Add(10, NewObject(GetTransientPackage(), UTMapFillByForEachPairUObjectHost::StaticClass(), n"ForEach_Fill_0", true));
	Source.Add(20, NewObject(GetTransientPackage(), UTMapFillByForEachPairUObjectHost::StaticClass(), n"ForEach_Fill_1", true));
	Source.Add(30, NewObject(GetTransientPackage(), UTMapFillByForEachPairUObjectHost::StaticClass(), n"ForEach_Fill_2", true));
	for (int Key, UObject Value : Source)
	{
		Result.Add(Key, Value);
	}
}
/** @end */
