/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled so bracket access can read stored handles.
 * @topic Containers
 *
 * FillByIndexAccessUObject
 */
/**
 * @begin FillByIndexAccessUObject
 * @summary An &out TMap<int, UObject> is filled so bracket access can read stored handles.
 * @topic Containers
 */
UCLASS()
class UTMapFillByIndexAccessUObjectHost : UObject
{
}

void FillByIndexAccessUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByIndexAccessUObjectHost::StaticClass(), n"Index_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByIndexAccessUObjectHost::StaticClass(), n"Index_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByIndexAccessUObjectHost::StaticClass(), n"Index_Fill_2", true));
}
/** @end */
