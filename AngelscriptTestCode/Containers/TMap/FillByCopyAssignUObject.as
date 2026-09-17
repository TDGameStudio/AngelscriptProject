/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled by assigning a local source map.
 * @topic Containers
 *
 * FillByCopyAssignUObject
 */
/**
 * @begin FillByCopyAssignUObject
 * @summary An &out TMap<int, UObject> is filled by assigning a local source map.
 * @topic Containers
 */
UCLASS()
class UTMapFillByCopyAssignUObjectHost : UObject
{
}

void FillByCopyAssignUObject(TMap<int, UObject>&out Result)
{
	TMap<int, UObject> Source;
	Source.Add(10, NewObject(GetTransientPackage(), UTMapFillByCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Fill_0", true));
	Source.Add(20, NewObject(GetTransientPackage(), UTMapFillByCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Fill_1", true));
	Source.Add(30, NewObject(GetTransientPackage(), UTMapFillByCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Fill_2", true));
	Result = Source;
}
/** @end */
