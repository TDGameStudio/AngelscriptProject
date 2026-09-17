/**
 * @version v1
 * @summary RemoveAtSwap drops the indexed UObject handle and may reorder survivors.
 * @topic Containers
 *
 * RemoveAtSwapUObject
 */
/**
 * @begin RemoveAtSwapUObject
 * @summary RemoveAtSwap drops the indexed UObject handle and may reorder survivors.
 * @topic Containers
 */
UCLASS()
class UTArrayRemoveAtSwapUObjectHost : UObject
{
}

bool RemoveAtSwapUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayRemoveAtSwapUObjectHost::StaticClass(), n"RemoveAtSwap_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayRemoveAtSwapUObjectHost::StaticClass(), n"RemoveAtSwap_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayRemoveAtSwapUObjectHost::StaticClass(), n"RemoveAtSwap_Third", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(Third);
	Values.RemoveAtSwap(0);
	return Values.Num() == 2 && !Values.Contains(First);
}
/** @end */
