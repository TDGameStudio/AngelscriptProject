/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then RemoveSwap deletes every matching handle.
 * @topic Containers
 *
 * FillByRemoveSwapUObject
 */
/**
 * @begin FillByRemoveSwapUObject
 * @summary An &out TArray<UObject> is filled then RemoveSwap deletes every matching handle.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByRemoveSwapUObjectHost : UObject
{
}

void FillByRemoveSwapUObject(TArray<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTArrayFillByRemoveSwapUObjectHost::StaticClass(), n"FillByRemoveSwap_A", true);
	UObject Match = NewObject(GetTransientPackage(), UTArrayFillByRemoveSwapUObjectHost::StaticClass(), n"FillByRemoveSwap_B", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayFillByRemoveSwapUObjectHost::StaticClass(), n"FillByRemoveSwap_C", true);
	Result.Add(First);
	Result.Add(Match);
	Result.Add(Third);
	Result.Add(Match);
	Result.RemoveSwap(Match);
}
/** @end */
