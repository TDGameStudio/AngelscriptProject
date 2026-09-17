/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then Remove deletes every matching handle.
 * @topic Containers
 *
 * FillByRemoveAllMatchesUObject
 */
/**
 * @begin FillByRemoveAllMatchesUObject
 * @summary An &out TArray<UObject> is filled then Remove deletes every matching handle.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByRemoveAllMatchesUObjectHost : UObject
{
}

void FillByRemoveAllMatchesUObject(TArray<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTArrayFillByRemoveAllMatchesUObjectHost::StaticClass(), n"FillByRemoveAllMatches_A", true);
	UObject Match = NewObject(GetTransientPackage(), UTArrayFillByRemoveAllMatchesUObjectHost::StaticClass(), n"FillByRemoveAllMatches_B", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayFillByRemoveAllMatchesUObjectHost::StaticClass(), n"FillByRemoveAllMatches_C", true);
	UObject Fourth = NewObject(GetTransientPackage(), UTArrayFillByRemoveAllMatchesUObjectHost::StaticClass(), n"FillByRemoveAllMatches_D", true);
	UObject Fifth = NewObject(GetTransientPackage(), UTArrayFillByRemoveAllMatchesUObjectHost::StaticClass(), n"FillByRemoveAllMatches_E", true);
	Result.Add(First);
	Result.Add(Match);
	Result.Add(Third);
	Result.Add(Match);
	Result.Add(Fourth);
	Result.Add(Match);
	Result.Add(Fifth);
	Result.Remove(Match);
}
/** @end */
