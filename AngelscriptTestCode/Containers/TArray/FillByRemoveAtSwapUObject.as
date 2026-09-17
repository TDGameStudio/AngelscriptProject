/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtSwapUObject
 */
/**
 * @begin FillByRemoveAtSwapUObject
 * @summary An &out TArray<UObject> is filled then RemoveAtSwap drops the first index.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByRemoveAtSwapUObjectHost : UObject
{
}

void FillByRemoveAtSwapUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtSwapUObjectHost::StaticClass(), n"FillByRemoveAtSwap_A", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtSwapUObjectHost::StaticClass(), n"FillByRemoveAtSwap_B", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtSwapUObjectHost::StaticClass(), n"FillByRemoveAtSwap_C", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtSwapUObjectHost::StaticClass(), n"FillByRemoveAtSwap_D", true));
	Result.RemoveAtSwap(0);
}
/** @end */
