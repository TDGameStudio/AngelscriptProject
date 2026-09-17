/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then RemoveSingle drops one matching handle.
 * @topic Containers
 *
 * FillByRemoveSinglePreservesOrderUObject
 */
/**
 * @begin FillByRemoveSinglePreservesOrderUObject
 * @summary An &out TArray<UObject> is filled then RemoveSingle drops one matching handle.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByRemoveSinglePreservesOrderUObjectHost : UObject
{
}

void FillByRemoveSinglePreservesOrderUObject(TArray<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTArrayFillByRemoveSinglePreservesOrderUObjectHost::StaticClass(), n"FillByRemoveSingle_A", true);
	UObject Match = NewObject(GetTransientPackage(), UTArrayFillByRemoveSinglePreservesOrderUObjectHost::StaticClass(), n"FillByRemoveSingle_B", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayFillByRemoveSinglePreservesOrderUObjectHost::StaticClass(), n"FillByRemoveSingle_C", true);
	Result.Add(First);
	Result.Add(Match);
	Result.Add(Match);
	Result.Add(Third);
	Result.RemoveSingle(Match);
}
/** @end */
