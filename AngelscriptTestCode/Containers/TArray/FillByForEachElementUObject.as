/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementUObject
 */
/**
 * @begin FillByForEachElementUObject
 * @summary An &out TArray<UObject> is filled by range-for from a local source.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByForEachElementUObjectHost : UObject
{
}

void FillByForEachElementUObject(TArray<UObject>&out Result)
{
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByForEachElementUObjectHost::StaticClass(), n"FillByForEachElement_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByForEachElementUObjectHost::StaticClass(), n"FillByForEachElement_1", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByForEachElementUObjectHost::StaticClass(), n"FillByForEachElement_2", true));
	for (UObject Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
