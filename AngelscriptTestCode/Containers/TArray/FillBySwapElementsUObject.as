/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then Swap exchanges ends.
 * @topic Containers
 *
 * FillBySwapElementsUObject
 */
/**
 * @begin FillBySwapElementsUObject
 * @summary An &out TArray<UObject> is filled then Swap exchanges ends.
 * @topic Containers
 */
UCLASS()
class UTArrayFillBySwapElementsUObjectHost : UObject
{
}

void FillBySwapElementsUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillBySwapElementsUObjectHost::StaticClass(), n"FillBySwap_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillBySwapElementsUObjectHost::StaticClass(), n"FillBySwap_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillBySwapElementsUObjectHost::StaticClass(), n"FillBySwap_2", true));
	Result.Swap(0, 2);
}
/** @end */
