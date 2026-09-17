/**
 * @version v1
 * @summary RemoveSwap deletes every matching UObject handle and keeps a non-matching survivor.
 * @topic Containers
 *
 * RemoveSwapUObject
 */
/**
 * @begin RemoveSwapUObject
 * @summary RemoveSwap deletes every matching UObject handle and keeps a non-matching survivor.
 * @topic Containers
 */
UCLASS()
class UTArrayRemoveSwapUObjectHost : UObject
{
}

bool RemoveSwapUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayRemoveSwapUObjectHost::StaticClass(), n"RemoveSwap_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayRemoveSwapUObjectHost::StaticClass(), n"RemoveSwap_Second", true);
	UObject MissingHandle = NewObject(GetTransientPackage(), UTArrayRemoveSwapUObjectHost::StaticClass(), n"RemoveSwap_Missing", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(First);
	int Removed = Values.RemoveSwap(First);
	int Missing = Values.RemoveSwap(MissingHandle);
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values.Contains(Second);
}
/** @end */
