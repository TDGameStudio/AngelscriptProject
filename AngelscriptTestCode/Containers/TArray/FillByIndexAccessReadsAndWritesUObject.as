/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then [] writes one handle.
 * @topic Containers
 *
 * FillByIndexAccessReadsAndWritesUObject
 */
/**
 * @begin FillByIndexAccessReadsAndWritesUObject
 * @summary An &out TArray<UObject> is filled then [] writes one handle.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByIndexAccessReadsAndWritesUObjectHost : UObject
{
}

void FillByIndexAccessReadsAndWritesUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"FillByIndex_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"FillByIndex_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"FillByIndex_2", true));
	Result[1] = NewObject(GetTransientPackage(), UTArrayFillByIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"FillByIndex_W", true);
}
/** @end */
