/**
 * @version v1
 * @summary Range-for visits every UObject handle and indexed range-for counts the slots.
 * @topic Containers
 *
 * ForEachElementUObject
 */
/**
 * @begin ForEachElementUObject
 * @summary Range-for visits every UObject handle and indexed range-for counts the slots.
 * @topic Containers
 */
UCLASS()
class UTArrayForEachElementUObjectHost : UObject
{
}

bool ForEachElementUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayForEachElementUObjectHost::StaticClass(), n"ForEachElement_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayForEachElementUObjectHost::StaticClass(), n"ForEachElement_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayForEachElementUObjectHost::StaticClass(), n"ForEachElement_Third", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(Third);
	int32 MutableCount = 0;
	for (UObject& Value : Values)
	{
		if (Value == Values[MutableCount])
		{
			MutableCount += 1;
		}
	}
	int32 ConstCount = 0;
	const TArray<UObject> ConstValues = Values;
	for (const UObject& Value : ConstValues)
	{
		ConstCount += 1;
	}
	int32 IndexedCount = 0;
	for (int Index, UObject& Value : Values)
	{
		IndexedCount += Index + 1;
	}
	return MutableCount == 3 && ConstCount == 3 && IndexedCount == 6 && Values[0] == First;
}
/** @end */
