/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 *
 * FillByFindOrAddReturnsExistingUObject
 */
/**
 * @begin FillByFindOrAddReturnsExistingUObject
 * @summary An &out TMap<int, UObject> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 */
UCLASS()
class UTMapFillByFindOrAddReturnsExistingUObjectHost : UObject
{
}

void FillByFindOrAddReturnsExistingUObject(TMap<int, UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTMapFillByFindOrAddReturnsExistingUObjectHost::StaticClass(), n"FindOrAddExisting_Fill_0", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapFillByFindOrAddReturnsExistingUObjectHost::StaticClass(), n"FindOrAddExisting_Fill_1", true);
	Result.FindOrAdd(10, First);
	Result.FindOrAdd(10, Second);
}
/** @end */
