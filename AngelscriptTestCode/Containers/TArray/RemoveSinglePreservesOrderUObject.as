/**
 * @version v1
 * @summary RemoveSingle removes the first matching UObject handle and keeps later elements in order.
 * @topic Containers
 *
 * RemoveSinglePreservesOrderUObject
 */
/**
 * @begin RemoveSinglePreservesOrderUObject
 * @summary RemoveSingle removes the first matching UObject handle and keeps later elements in order.
 * @topic Containers
 */
UCLASS()
class UTArrayRemoveSinglePreservesOrderUObjectHost : UObject
{
}

bool RemoveSinglePreservesOrderUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayRemoveSinglePreservesOrderUObjectHost::StaticClass(), n"RemoveSingle_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayRemoveSinglePreservesOrderUObjectHost::StaticClass(), n"RemoveSingle_Second", true);
	UObject MissingHandle = NewObject(GetTransientPackage(), UTArrayRemoveSinglePreservesOrderUObjectHost::StaticClass(), n"RemoveSingle_Missing", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(First);
	int Removed = Values.RemoveSingle(First);
	int Missing = Values.RemoveSingle(MissingHandle);
	return Removed == 1 && Missing == 0 && Values.Num() == 2 && Values[0] == Second && Values[1] == First;
}
/** @end */
