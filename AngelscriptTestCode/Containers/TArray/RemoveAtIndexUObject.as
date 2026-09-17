/**
 * @version v1
 * @summary RemoveAt drops the indexed UObject handle and shifts later elements down.
 * @topic Containers
 *
 * RemoveAtIndexUObject
 */
/**
 * @begin RemoveAtIndexUObject
 * @summary RemoveAt drops the indexed UObject handle and shifts later elements down.
 * @topic Containers
 */
UCLASS()
class UTArrayRemoveAtIndexUObjectHost : UObject
{
}

bool RemoveAtIndexUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayRemoveAtIndexUObjectHost::StaticClass(), n"RemoveAtIndex_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayRemoveAtIndexUObjectHost::StaticClass(), n"RemoveAtIndex_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayRemoveAtIndexUObjectHost::StaticClass(), n"RemoveAtIndex_Third", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(Third);
	Values.RemoveAt(1);
	return Values.Num() == 2 && Values[0] == First && Values[1] == Third;
}
/** @end */
