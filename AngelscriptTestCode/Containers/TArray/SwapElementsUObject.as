/**
 * @version v1
 * @summary Swap(0, 2) exchanges UObject ends while the middle handle stays.
 * @topic Containers
 *
 * SwapElementsUObject
 */
/**
 * @begin SwapElementsUObject
 * @summary Swap(0, 2) exchanges UObject ends while the middle handle stays.
 * @topic Containers
 */
UCLASS()
class UTArraySwapElementsUObjectHost : UObject
{
}

bool SwapElementsUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArraySwapElementsUObjectHost::StaticClass(), n"SwapElements_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArraySwapElementsUObjectHost::StaticClass(), n"SwapElements_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArraySwapElementsUObjectHost::StaticClass(), n"SwapElements_Third", true);
	Values.Add(First);
	Values.Add(Second);
	Values.Add(Third);
	Values.Swap(0, 2);
	Values.Swap(1, 1);
	return Values[0] == Third && Values[2] == First && Values[1] == Second && Values.Num() == 3;
}
/** @end */
