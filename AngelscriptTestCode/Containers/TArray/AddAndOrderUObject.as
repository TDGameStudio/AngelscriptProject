/**
 * @version v1
 * @summary Add appends UObject handles in insertion order.
 * @topic Containers
 *
 * AddAndOrderUObject
 */
/**
 * @begin AddAndOrderUObject
 * @summary Add appends UObject handles in insertion order.
 * @topic Containers
 */
UCLASS()
class UTArrayAddAndOrderUObjectHost : UObject
{
}

bool AddAndOrderUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayAddAndOrderUObjectHost::StaticClass(), n"AddAndOrder_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayAddAndOrderUObjectHost::StaticClass(), n"AddAndOrder_Second", true);
	Values.Add(First);
	Values.Add(Second);
	return Values.Num() == 2 && Values[0] == First && Values[1] == Second;
}
/** @end */
