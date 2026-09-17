/**
 * @version v1
 * @summary Range-for visits each UObject member exactly once.
 * @topic Containers
 *
 * ForEachElementUObject
 */
/**
 * @begin ForEachElementUObject
 * @summary Range-for visits each UObject member exactly once.
 * @topic Containers
 */
UCLASS()
class UTSetForEachElementUObjectHost : UObject
{
}

bool ForEachElementUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetForEachElementUObjectHost::StaticClass(), n"ForEachElement_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetForEachElementUObjectHost::StaticClass(), n"ForEachElement_Second", true);
	Values.Add(First);
	Values.Add(Second);
	int32 VisitCount = 0;
	for (UObject Value : Values)
	{
		if (!Values.Contains(Value))
		{
			return false;
		}
		VisitCount += 1;
	}
	return VisitCount == 2;
}
/** @end */
