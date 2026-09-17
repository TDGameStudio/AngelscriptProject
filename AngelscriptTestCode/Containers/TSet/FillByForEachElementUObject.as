/**
 * @version v1
 * @summary An &out TSet<UObject> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementUObject
 */
/**
 * @begin FillByForEachElementUObject
 * @summary An &out TSet<UObject> is filled by range-for from a local source.
 * @topic Containers
 */
UCLASS()
class UTSetFillByForEachElementUObjectHost : UObject
{
}

void FillByForEachElementUObject(TSet<UObject>&out Result)
{
	TSet<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTSetFillByForEachElementUObjectHost::StaticClass(), n"FillByForEachElement_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTSetFillByForEachElementUObjectHost::StaticClass(), n"FillByForEachElement_1", true));
	for (UObject Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
