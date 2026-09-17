/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled by FindOrAdd of three keys.
 * @topic Containers
 *
 * FillByFindOrAddInsertsUObject
 */
/**
 * @begin FillByFindOrAddInsertsUObject
 * @summary An &out TMap<int, UObject> is filled by FindOrAdd of three keys.
 * @topic Containers
 */
UCLASS()
class UTMapFillByFindOrAddInsertsUObjectHost : UObject
{
}

void FillByFindOrAddInsertsUObject(TMap<int, UObject>&out Result)
{
	Result.FindOrAdd(10) = NewObject(GetTransientPackage(), UTMapFillByFindOrAddInsertsUObjectHost::StaticClass(), n"FindOrAddInserts_Fill_0", true);
	Result.FindOrAdd(20) = NewObject(GetTransientPackage(), UTMapFillByFindOrAddInsertsUObjectHost::StaticClass(), n"FindOrAddInserts_Fill_1", true);
	Result.FindOrAdd(30) = NewObject(GetTransientPackage(), UTMapFillByFindOrAddInsertsUObjectHost::StaticClass(), n"FindOrAddInserts_Fill_2", true);
}
/** @end */
